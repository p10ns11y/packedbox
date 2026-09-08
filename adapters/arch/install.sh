#!/usr/bin/env bash
# Arch (± Omarchy) adapter — PATH kernel bootstrap + optional terminal pack.
# Installs pacman prerequisites, deploys core/, and registers fix-path recovery.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
INSTALLERS_DIR="$ROOT_DIR/installers"

# shellcheck source=../../installers/lib/packedbox-install.sh
. "$INSTALLERS_DIR/lib/packedbox-install.sh"

usage() {
    cat <<'EOF'
packedbox Arch adapter

Usage:
  adapters/arch/install.sh                 Install core + fix-path recovery
  adapters/arch/install.sh --deps-only     Install pacman prerequisites only
  adapters/arch/install.sh --with-terminal Install core + terminal pack deps + pack
  adapters/arch/install.sh --help
EOF
}

can_run_as_root() {
    [[ "$(id -u)" -eq 0 ]] || command -v sudo >/dev/null 2>&1
}

# Run a command as root when needed. Returns 1 when neither root nor sudo is available.
run_as_root() {
    if [[ "$(id -u)" -eq 0 ]]; then
        "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        return 1
    fi
}

have_pkg_mgr() {
    command -v pacman >/dev/null 2>&1
}

run_pacman_install() {
    if ! can_run_as_root; then
        echo "warn: cannot install pacman packages (not root, no sudo)" >&2
        return 1
    fi
    run_as_root pacman -Sy --needed --noconfirm "$@"
}

ghostty_on_path() {
    command -v ghostty >/dev/null 2>&1
}

# Ghostty: prefer pacman, else paru, else Omarchy helper when present.
ensure_ghostty() {
    if ghostty_on_path; then
        echo "ghostty: already installed ($(command -v ghostty))"
        return 0
    fi

    if ! have_pkg_mgr; then
        echo "warn: ghostty not installed (no pacman)" >&2
        return 0
    fi

    if pacman -Si ghostty >/dev/null 2>&1; then
        echo "ghostty: installing from pacman"
        run_pacman_install ghostty || echo "warn: pacman install ghostty failed" >&2
        ghostty_on_path && return 0
    fi

    if command -v paru >/dev/null 2>&1; then
        echo "ghostty: installing via paru"
        paru -S --needed --noconfirm ghostty || echo "warn: paru ghostty failed" >&2
        ghostty_on_path && return 0
    fi

    if command -v omarchy-install-terminal >/dev/null 2>&1; then
        echo "ghostty: installing via omarchy-install-terminal"
        omarchy-install-terminal ghostty || echo "warn: omarchy-install-terminal ghostty failed" >&2
        ghostty_on_path && return 0
    fi

    echo "warn: ghostty not installed (no pacman package / paru / omarchy helper); configs still deployed" >&2
    return 0
}

ensure_pacman_deps() {
    local with_terminal="${1:-0}"
    local packages=(bash curl git)
    if [[ "$with_terminal" == 1 ]]; then
        packages+=(tmux neovim ttf-jetbrains-mono-nerd)
    fi

    if ! have_pkg_mgr; then
        echo "warn: pacman not found; skipping package install" >&2
    else
        run_pacman_install "${packages[@]}" || true
    fi

    if [[ "$with_terminal" == 1 ]]; then
        ensure_ghostty
    fi
}

print_done() {
    local kind="$1"
    echo "packedbox Arch bootstrap${kind} complete."
    echo "  core:      ~/.config/packedbox"
    echo "  recovery:  ~/.local/bin/packedbox-fix-path"
    if [[ "$kind" == *"terminal"* ]]; then
        echo "  terminal:  ~/.config/packedbox/packs/terminal"
    fi
    echo "  verify:    bash ~/.config/packedbox/core/check-path.sh"
}

main() {
    case "${1:-}" in
        -h|--help|help)
            usage
            exit 0
            ;;
        --deps-only)
            ensure_pacman_deps 0
            exit 0
            ;;
        --with-terminal)
            ensure_pacman_deps 1
            bash "$INSTALLERS_DIR/fix-path.sh" --install
            bash "$ROOT_DIR/packs/terminal/install.sh"
            print_done " + terminal pack"
            ;;
        "")
            ensure_pacman_deps 0
            bash "$INSTALLERS_DIR/fix-path.sh" --install
            print_done ""
            ;;
        *)
            echo "error: unknown argument: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
}

main "$@"
