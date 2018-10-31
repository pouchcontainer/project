#!/usr/bin/env bash

set -euo pipefail

# main pulls and build lxcfs.
main() {
  local dist_bin_dir dist_lib_dir
  dist_bin_dir=$1
  dist_lib_dir=$2

  local tmpdir branch

  tmpdir="$(mktemp -d /tmp/lxcfs-build-XXXXXX)"
  branch="stable-2.0"
  trap 'rm -rf /tmp/lxcfs-build-*' EXIT

  # pull code
  git clone -b "${branch}" https://github.com/lxc/lxcfs.git "${tmpdir}/lxcfs"

  # cd and build
  pushd "${tmpdir}/lxcfs"

  # NOTE: avoid to impact user's lxcfs
  grep -l -r "liblxcfs" . | xargs sed -i 's/liblxcfs/libpouchlxcfs/g'
  ./bootstrap.sh
  ./configure
  make install

  cp /usr/local/bin/lxcfs "${dist_bin_dir}/pouch-lxcfs"
  cp /usr/local/lib/lxcfs/libpouchlxcfs.so "${dist_lib_dir}/"
  popd
}

main "$@"
