#!/usr/bin/env bash

set -euo pipefail

readonly CONTAINERD_VERSION="1.0.3"

# main downloads containerd binary into specific dir.
main() {
  local url target tmpdir dist

  dist="${1}"

  target="containerd-${CONTAINERD_VERSION}.linux-amd64.tar.gz"
  url="https://github.com/containerd/containerd/releases/download"
  url="${url}/v${CONTAINERD_VERSION}/${target}"

  tmpdir="$(mktemp -d /tmp/containerd-download-XXXXXX)"
  trap 'rm -rf /tmp/containerd-download-*' EXIT

  wget --quiet "${url}" -P "${tmpdir}"
  tar xf "${tmpdir}/${target}" -C "${tmpdir}"
  cp -f "${tmpdir}"/bin/* "${dist}/"
}

main "$@"
