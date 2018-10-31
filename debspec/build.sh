#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"
readonly specdir="${PWD}"

# add_changelog adds the changelog into the debian.
add_changelog() {
  local build_dir deb_version deb_date

  build_dir=$1
  deb_version=$2
  deb_date="$(date --rfc-2822)"
  cat > ${1}/debian/changelog <<EOF
pouch (${deb_version}+ubuntu) grape; urgency=low

  * Version: ${deb_version}

 -- PouchContainer <pouch-dev@list.alibaba-inc.com>  ${deb_date}
EOF
}

# generate_release uses gpg key to release deb package.
generate_release() {
  local key_dir default_key pkg_dir

  key_dir=${1}
  pkg_dir=${2}

  # read the default key from file
  default_key="$(cat ${key_dir}/default_key)"
  gpg --import "${key_dir}/public"
  gpg --import "${key_dir}/private"

  # into the deb package and archive
  cd ${pkg_dir}
  dpkg-scanpackages . /dev/null | gzip -9c > Packages.gz
  apt-ftparchive release ./ > Release

  # add default key to release
  gpg -abs --default-key "${default_key}" -o Release.gpg Release
  gpg --clearsign --default-key "${default_key}" -o InRelease Release
}

# main builds the deb package.
main() {
  local deb_version pouch_commit pkg_name bundle_dir

  pouch_commit=$1
  deb_version=$2
  pkg_name="pouch_${2}+ubuntu_amd64.deb"

  # add changelog
  add_changelog "${specdir}" "${deb_version}"

  # get into the build_dir and build
  POUCH_COMMIT=${pouch_commit} dpkg-buildpackage -uc -us

  # copy files into bundle
  bundle_dir="${specdir}/bundles/${2}+ubuntu_amd64/"
  rm -rf ${bundle_dir} && mkdir -p ${bundle_dir}
  cp ${specdir}/../pouch_* ${bundle_dir}
  generate_release "${specdir}/keys" "${bundle_dir}/"
}

main "$@"
