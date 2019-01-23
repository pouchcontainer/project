#!/usr/bin/env bash

set -euo pipefail

readonly RUNC_VERSION="6a93df143f66a1c8bc967200473a568a8487d287"

# main downloads runc binary into specific dir.
main() {
  local gopath dist

  dist="${1}"
  gopath="${GOPATH}/src/github.com/opencontainers/runc"

  git clone https://github.com/alibaba/runc.git "${gopath}"
  cd "${gopath}"
  git checkout "${RUNC_VERSION}"
  make
  cp -f runc "${dist}/runc"
}

main "$@"
