#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"
readonly spec_dir="${PWD}"

# metadata used by builder
readonly ARCHITECTURE="amd64"
readonly LICENSE='Apache License 2.0'
readonly CATEGORY='Tools/Pouch'
readonly MAINTAINER='Pouch pouch-dev@list.alibaba-inc.com'
readonly VENDOR='Pouch'
readonly DESCRIPTION=<<EOF
Pouch is an open-source project created by Alibaba Group to promote the container technology movement.
Pouch's vision is to advance container ecosystem and promote container standards OCI, so that container technologies become the foundation for application development in the Cloud era.
Pouch can pack, deliver and run any application. It provides applications with a lightweight runtime environment with strong isolation and minimal overhead. Pouch isolates applications from varying runtime environment, and minimizes operational workload. Pouch minimizes the effort for application developers to write Cloud-native applications, or to migrate legacy ones to a Cloud platform.
EOF

# install_pouch installs binary and bash completion into dist_dir.
install_pouch() {
  local commit_id dist_dir
  commit_id=${1}
  dist_dir=${2}

  local pkg_name gopath
  gopath="$(go env GOPATH)"
  pkg_name="github.com/alibaba/pouch"

  git clone "https://${pkg_name}" "${gopath}/src/${pkg_name}"

  pushd "${gopath}/src/${pkg_name}"

  # checkout to specific commit
  git checkout "${commit_id}"

  # build binary
  make

  # install binary into dist_dir
  PREFIX="${dist_dir}/usr/local/" make install

  # install bash completion
  cp contrib/completion/bash/pouch ${dist_dir}/usr/share/bash-completion/completions

  popd
}

# build rpm packge
build_rpm() {
  local dist_dir bundler_dir rpm_version rpm_release

  dist_dir=${1}
  bundler_dir=${2}
  rpm_version=${3}
  rpm_release=${4}


  fpm -f -s dir \
    -t rpm \
    -n pouch \
    \
    --url 'https://github.com/alibaba/pouch' \
    --description "${DESCRIPTION}" \
    -v "${rpm_version}" \
    -a "${ARCHITECTURE}" \
    -m "${MAINTAINER}" \
    --license "${LICENSE}" \
    --category "${CATEGORY}" \
    --iteration "${rpm_release}" \
    --vendor "$VENDOR" \
    -p "${bundler_dir}" \
    --verbose \
    \
    --before-install ${spec_dir}/rpm/before-install.sh \
    --after-install ${spec_dir}/rpm/after-install.sh \
    --before-remove ${spec_dir}/rpm/before-remove.sh \
    --after-remove ${spec_dir}/rpm/after-remove.sh \
    --rpm-posttrans ${spec_dir}/rpm/after-trans.sh \
    --rpm-sign \
    \
    -d pam-devel \
    -d fuse-devel \
    -d fuse-libs \
    -d fuse \
    "${dist_dir}/usr/local/bin/"=/usr/local/bin/ \
    "${dist_dir}/usr/lib64/"=/usr/lib64/ \
    "${spec_dir}/systemd/"=/usr/lib/systemd/system/
}

main() {
  local commit_id rpm_version rpm_release
  commit_id=$1
  rpm_version=$2
  rpm_release=$3

  local dist_dir bundler_dir

  # initialize dist dir
  dist_dir="${spec_dir}/rpm/pouch"
  rm -rf ${dist_dir} \
    && mkdir -p ${dist_dir} \
    && mkdir -p ${dist_dir}/usr/local/bin \
    && mkdir -p ${dist_dir}/usr/lib64 \
    && mkdir -p ${dist_dir}/usr/share/bash-completion/completions

  # initialize bundler dir
  bundler_dir="${spec_dir}/bundles/pouch-${rpm_version}${rpm_release}"
  mkdir -p $bundler_dir

  # install pouch
  install_pouch "${commit_id}" "${dist_dir}"

  # install lxcfs
  scripts/download_lxcfs.sh "${dist_dir}/usr/local/bin" "${dist_dir}/usr/lib64/"

  # install containerd
  scripts/download_containerd.sh "${dist_dir}/usr/local/bin"

  # install runc
  scripts/download_runc.sh "${dist_dir}/usr/local/bin"

  # install nvidia container runtime
  scripts/download_libnvidia-container.sh "${dist_dir}/usr/local/bin" "${dist_dir}/usr/lib64"

  # import gpg key
  gpg --import ${spec_dir}/keys/public
  gpg --import ${spec_dir}/keys/private
  rpm --import ${spec_dir}/keys/public
  echo "%_gpg_name Pouch Release" >> ${HOME}/.rpmmacros

  # build
  build_rpm "${dist_dir}" "${bundler_dir}" "${rpm_version}" "${rpm_release}"
}

main "$@"
