#!/usr/bin/env bash
# packedbox primary installer (Phase 0 stub)
# See docs/ADR-0001-tech-stack.md — shell installers are the required bootstrap path.
set -euo pipefail

PACKEDBOX_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

die() { echo "packedbox: $*" >&2; exit 1; }

detect_distro() {
  if [[ -f /etc/os-release ]]; then
    # shellcheck source=/dev/null
    . /etc/os-release
    echo "${ID:-unknown}"
    return
  fi
  echo unknown
}

main() {
  local distro
  distro="$(detect_distro)"
  local adapter="${PACKEDBOX_ROOT}/adapters/${distro}"

  echo "packedbox install (Phase 0 stub)"
  echo "  root:    ${PACKEDBOX_ROOT}"
  echo "  distro:  ${distro}"
  echo "  adapter: ${adapter}"

  if [[ ! -d "${adapter}" ]]; then
    die "no adapter for distro '${distro}' — see adapters/ (Phase 1+)"
  fi

  echo "Phase 0: scaffold only. Implement in Phase 1 (Ubuntu) and Phase 2+ (Debian/Arch)."
  echo "Recovery: ${PACKEDBOX_ROOT}/installers/fix-path.sh"
  exit 0
}

main "$@"
