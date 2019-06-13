#!/usr/bin/env bash

set -euo pipefail

readonly CONTAINERD_VERSION="v1.2.5"

# main downloads containerd binary into specific dir.
main() {
  local dist gopath

  dist="${1}"
  gopath="$(go env GOPATH)/src/github.com/containerd/containerd"

  git clone --branch "$CONTAINERD_VERSION" --depth 1 \
    https://github.com/containerd/containerd.git "${gopath}"

  cd "$gopath"
  make BUILDTAGS='no_cri no_btrfs'
  cp -f bin/* "${dist}/"
}

main "$@"
