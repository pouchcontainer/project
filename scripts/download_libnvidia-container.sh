#!/usr/bin/env bash

set -euo pipefail

readonly LIBNVIDIA_CONTAINER_VERSION="1.0.0-rc.2"
readonly NVIDIA_RUNTIME_VERSION="1.4.0-1"

# download_libnvidia_container downloads binary and lib into dist.
download_libnvidia_container(){
  local tmpdir url target arch
  local dist_bin_dir dist_lib_dir

  dist_bin_dir=$1
  dist_lib_dir=$2

  tmpdir="$(mktemp -d /tmp/libnvidia-contianer-download-XXXXXX)"
  trap 'rm -rf /tmp/libnvidia-contianer-download-*' EXIT

  arch="x86_64"
  target="libnvidia-container_${LIBNVIDIA_CONTAINER_VERSION}"

  url="https://github.com/NVIDIA/libnvidia-container/releases/download"
  url="${url}/v${LIBNVIDIA_CONTAINER_VERSION}/${target}_${arch}.tar.xz"

  wget --quiet "${url}" -P "${tmpdir}"
  tar -xf "${tmpdir}/${target}_${arch}.tar.xz" -C "${tmpdir}"

  # copy binary
  cp ${tmpdir}/${target}/usr/local/bin/nvidia-container-cli "${dist_bin_dir}"

  # copy lib
  cp ${tmpdir}/${target}/usr/local/lib/libnvidia-container.so "${dist_lib_dir}"
  cp ${tmpdir}/${target}/usr/local/lib/libnvidia-container.so.1 "${dist_lib_dir}"
  cp ${tmpdir}/${target}/usr/local/lib/libnvidia-container.so.1.0.0 "${dist_lib_dir}"
}

# download_nvidia_container_runtime downloads and builds binary into dist.
download_nvidia_container_runtime() {
  local dist_bin_dir

  dist_bin_dir=$1

  local tmpdir url target gopath pkg

  gopath="$(go env GOPATH)"
  pkg="github.com/NVIDIA/nvidia-container-runtime"

  tmpdir="$(mktemp -d /tmp/nvida-container-download-XXXXX)"
  trap 'rm -rf /tmp/nvida-container-download-*' EXIT

  url="https://github.com/NVIDIA/nvidia-container-runtime/archive/"
  url="${url}/v${NVIDIA_RUNTIME_VERSION}.tar.gz"

  wget --quiet "${url}" -P "${tmpdir}"

  # unpack source code into gopath
  mkdir -p "${gopath}/src/${pkg}"
  tar -xzf "${tmpdir}/v${NVIDIA_RUNTIME_VERSION}.tar.gz" \
    -C "${gopath}/src/${pkg}" --strip-components=1 # skip level one

  go build -o "${dist_bin_dir}/nvidia-container-runtime-hook" \
    "${pkg}/hook/nvidia-container-runtime-hook"
}

main() {
  local dist_bin_dir dist_lib_dir

  dist_bin_dir=$1
  dist_lib_dir=$2

  download_libnvidia_container "${dist_bin_dir}" "${dist_lib_dir}"
  download_nvidia_container_runtime "${dist_bin_dir}"
}

main "$@"
