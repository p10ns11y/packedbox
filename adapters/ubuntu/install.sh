#!/usr/bin/env bash
# Ubuntu adapter — PATH kernel bootstrap + optional terminal pack (Phase 2 parity with Arch).
# Installs apt prerequisites, deploys core/, and registers fix-path recovery.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
INSTALLERS_DIR="$ROOT_DIR/installers"

# shellcheck source=../../installers/lib/packedbox-install.sh
. "$INSTALLERS_DIR/lib/packedbox-install.sh"

usage() {
    cat <<'EOF'
packedbox Ubuntu adapter

Usage:
  adapters/ubuntu/install.sh                 Install core + fix-path recovery
  adapters/ubuntu/install.sh --deps-only     Install apt prerequisites only
  adapters/ubuntu/install.sh --with-terminal Install core + terminal pack deps + pack
  adapters/ubuntu/install.sh --help
EOF
}

ensure_apt_deps() {
    local with_terminal="${1:-0}"
    local packages=(bash curl git ca-certificates shellcheck)
    if [[ "$with_terminal" == 1 ]]; then
        packages+=(tmux neovim)
    fi
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

    if [[ "$with_terminal" == 1 ]] && ! command -v ghostty >/dev/null 2>&1; then
        echo "warn: ghostty not installed (not in Ubuntu apt; configs still deployed)" >&2
    fi
}

main() {
    case "${1:-}" in
        -h|--help|help)
            usage
            exit 0
            ;;
        --deps-only)
            ensure_apt_deps 0
            exit 0
            ;;
        --with-terminal)
            ensure_apt_deps 1
            bash "$INSTALLERS_DIR/fix-path.sh" --install
            bash "$ROOT_DIR/packs/terminal/install.sh"
            echo "packedbox Ubuntu bootstrap + terminal pack complete."
            echo "  core:      ~/.config/packedbox"
            echo "  recovery:  ~/.local/bin/packedbox-fix-path"
            echo "  terminal:  ~/.config/packedbox/packs/terminal"
            echo "  verify:    bash ~/.config/packedbox/core/check-path.sh"
            ;;
        "")
            ensure_apt_deps 0
            bash "$INSTALLERS_DIR/fix-path.sh" --install
            echo "packedbox Ubuntu bootstrap complete."
            echo "  core:      ~/.config/packedbox"
            echo "  recovery:  ~/.local/bin/packedbox-fix-path"
            echo "  verify:    bash ~/.config/packedbox/core/check-path.sh"
            ;;
        *)
            echo "error: unknown argument: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
}

main "$@"
