#!/usr/bin/env bash

set -euo pipefail

readonly RUNC_VERSION="52288e785fdf58c85a7a194c4061848d0fff3f78"

# main downloads runc binary into specific dir.
main() {
  local gopath dist

  dist="${1}"
  gopath="$(go env GOPATH)/src/github.com/opencontainers/runc"

  git clone https://github.com/alibaba/runc.git "${gopath}"
  cd "${gopath}"
  git checkout "${RUNC_VERSION}"
  make
  cp -f runc "${dist}/runc"
}

main "$@"
