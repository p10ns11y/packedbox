#!/usr/bin/env bash
# packedbox installer — Phase 0 stub
# See docs/ADR-0001-tech-stack.md and docs/PHASES.md
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

usage() {
    cat <<'EOF'
packedbox installer (Phase 0 scaffold)

Usage:
  install.sh [--help]
  install.sh --distro <arch|debian|ubuntu>   (Phase 1+)

Phase 0: validates layout only. Use fix-path.sh for PATH recovery.
EOF
}

main() {
    case "${1:-}" in
        -h|--help|help|"")
            usage
            exit 0
            ;;
        --distro)
            echo "error: --distro not implemented until Phase 1 (ubuntu first)" >&2
            echo "see docs/PHASES.md" >&2
            exit 2
            ;;
        *)
            echo "error: unknown argument: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
}

# Verify required companion script exists (ADR-0001)
if [[ ! -x "$SCRIPT_DIR/fix-path.sh" ]]; then
    echo "error: installers/fix-path.sh is required but missing or not executable" >&2
    exit 1
fi

main "$@"
