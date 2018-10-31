#!/usr/bin/env bash

set -euo pipefail

readonly RUNC_VERSION="v1.0.0-rc4-2"

# main downloads runc binary into specific dir.
main() {
  local url target tmpdir dist

  dist="${1}"

  target="runc.amd64"
  url="https://github.com/alibaba/runc/releases/download/"
  url="${url}/${RUNC_VERSION}/${target}"

  tmpdir="$(mktemp -d /tmp/runc-download-XXXXXX)"
  trap 'rm -rf /tmp/runc-download-*' EXIT

  wget --quiet "${url}" -P "${tmpdir}"
  chmod +x "${tmpdir}/${target}"
  cp -f "${tmpdir}/${target}" "${dist}/"
}

main "$@"
