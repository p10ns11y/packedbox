#!/usr/bin/env bash
# Arch (± Omarchy) adapter — PATH core, optional terminal pack deps.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
INSTALLERS_DIR="$ROOT_DIR/installers"

# shellcheck source=../../installers/lib/packedbox-install.sh
. "$INSTALLERS_DIR/lib/packedbox-install.sh"

usage() {
    cat <<'EOF'
packedbox Arch adapter (Phase 2)

Usage:
  adapters/arch/install.sh                 Install core + fix-path recovery
  adapters/arch/install.sh --deps-only     Install pacman prerequisites only
  adapters/arch/install.sh --with-terminal Install core + terminal pack
  adapters/arch/install.sh --help
EOF
}

have_pkg_mgr() {
    command -v pacman >/dev/null 2>&1
}

run_pacman_install() {
    local packages=("$@")
    if [[ "$(id -u)" -eq 0 ]]; then
        pacman -Sy --needed --noconfirm "${packages[@]}"
    elif command -v sudo >/dev/null 2>&1; then
        sudo pacman -Sy --needed --noconfirm "${packages[@]}"
    else
        echo "warn: cannot install pacman packages (not root, no sudo)" >&2
        return 0
    fi
}

ensure_pacman_deps() {
    local packages=(bash curl git tmux neovim ttf-jetbrains-mono-nerd)
    if ! have_pkg_mgr; then
        echo "warn: pacman not found; skipping package install" >&2
        return 0
    fi
    run_pacman_install "${packages[@]}"

    # Ghostty: prefer pacman, else paru, else Omarchy helper when present.
    if pacman -Si ghostty >/dev/null 2>&1; then
        run_pacman_install ghostty
    elif command -v paru >/dev/null 2>&1; then
        paru -S --needed --noconfirm ghostty || echo "warn: paru ghostty failed" >&2
    elif command -v omarchy-install-terminal >/dev/null 2>&1; then
        omarchy-install-terminal ghostty || echo "warn: omarchy-install-terminal ghostty failed" >&2
    else
        echo "warn: ghostty not installed (no pacman package / paru / omarchy helper)" >&2
    fi
}

main() {
    case "${1:-}" in
        -h|--help|help)
            usage
            exit 0
            ;;
        --deps-only)
            ensure_pacman_deps
            exit 0
            ;;
        --with-terminal)
            ensure_pacman_deps
            bash "$INSTALLERS_DIR/fix-path.sh" --install
            bash "$ROOT_DIR/packs/terminal/install.sh"
            echo "packedbox Arch bootstrap + terminal pack complete."
            ;;
        "")
            ensure_pacman_deps
            bash "$INSTALLERS_DIR/fix-path.sh" --install
            echo "packedbox Arch bootstrap complete."
            echo "  core:      ~/.config/packedbox"
            echo "  recovery:  ~/.local/bin/packedbox-fix-path"
            echo "  terminal:  adapters/arch/install.sh --with-terminal"
            ;;
        *)
            echo "error: unknown argument: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
}

main "$@"
