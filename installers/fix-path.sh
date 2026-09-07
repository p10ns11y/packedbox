#!/usr/bin/env bash
# packedbox PATH recovery — required companion to install.sh (ADR-0001)
# Idempotent re-application of core/path.sh layers when interactive shell is broken.
set -euo pipefail

PACKEDBOX_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CORE_PATH="${PACKEDBOX_ROOT}/core/path.sh"

if [[ ! -f "${CORE_PATH}" ]]; then
  echo "packedbox fix-path: core/path.sh not yet installed (Phase 1)" >&2
  echo "  expected: ${CORE_PATH}" >&2
  exit 1
fi

# shellcheck source=/dev/null
source "${CORE_PATH}"
echo "packedbox: PATH layers applied from ${CORE_PATH}"
