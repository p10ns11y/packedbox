#!/usr/bin/env bash
# Debian adapter — PATH core bootstrap (Phase 5 slice).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
INSTALLERS_DIR="$ROOT_DIR/installers"

# shellcheck source=../../installers/lib/packedbox-install.sh
. "$INSTALLERS_DIR/lib/packedbox-install.sh"

usage() {
    cat <<'EOF'
packedbox Debian adapter (Phase 5)

Usage:
  adapters/debian/install.sh              Install core + fix-path recovery
  adapters/debian/install.sh --deps-only  Install apt prerequisites only
  adapters/debian/install.sh --help
EOF
}

ensure_apt_deps() {
    local packages=(bash curl git ca-certificates)
    if command -v apt-get >/dev/null 2>&1; then
        if [[ "$(id -u)" -eq 0 ]]; then
            apt-get update -qq
            DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "${packages[@]}"
        elif command -v sudo >/dev/null 2>&1; then
            sudo apt-get update -qq
            DEBIAN_FRONTEND=noninteractive sudo apt-get install -y -qq "${packages[@]}"
        else
            echo "warn: cannot install apt packages (not root, no sudo)" >&2
            return 0
        fi
    else
        echo "warn: apt-get not found; skipping package install" >&2
    fi
}

main() {
    case "${1:-}" in
        -h|--help|help)
            usage
            exit 0
            ;;
        --deps-only)
            ensure_apt_deps
            exit 0
            ;;
        "")
            ensure_apt_deps
            bash "$INSTALLERS_DIR/fix-path.sh" --install
            echo "packedbox Debian bootstrap complete."
            echo "  core:      ~/.config/packedbox"
            echo "  recovery:  ~/.local/bin/packedbox-fix-path"
            ;;
        *)
            echo "error: unknown argument: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
}

main "$@"
