#!/usr/bin/env bash
# Debian adapter — PATH kernel bootstrap + optional terminal pack (parity with Ubuntu).
# Installs apt prerequisites, deploys core/, and registers fix-path recovery.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
INSTALLERS_DIR="$ROOT_DIR/installers"

# shellcheck source=../../installers/lib/packedbox-install.sh
. "$INSTALLERS_DIR/lib/packedbox-install.sh"

usage() {
    cat <<'EOF'
packedbox Debian adapter

Usage:
  adapters/debian/install.sh                 Install core + fix-path recovery
  adapters/debian/install.sh --deps-only     Install apt prerequisites only
  adapters/debian/install.sh --with-terminal Install core + terminal pack deps + pack
  adapters/debian/install.sh --help
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

run_apt_update() {
    run_as_root apt-get update -qq
}

run_apt_install() {
    if ! can_run_as_root; then
        echo "warn: cannot install apt packages (not root, no sudo)" >&2
        return 1
    fi
    DEBIAN_FRONTEND=noninteractive run_as_root apt-get install -y -qq "$@"
}

ghostty_on_path() {
    command -v ghostty >/dev/null 2>&1
}

# Snap may land in /snap/bin before login PATH picks it up.
ghostty_path_nudge() {
    if [[ -x /snap/bin/ghostty ]] && ! ghostty_on_path; then
        export PATH="/snap/bin:${PATH}"
    fi
}

# Ghostty is rarely in default Debian apt; try apt → snap → clear warn.
ensure_ghostty() {
    if ghostty_on_path; then
        echo "ghostty: already installed ($(command -v ghostty))"
        return 0
    fi

    if command -v apt-cache >/dev/null 2>&1 && apt-cache show ghostty >/dev/null 2>&1; then
        echo "ghostty: installing from apt"
        run_apt_install ghostty || echo "warn: apt install ghostty failed" >&2
        ghostty_on_path && return 0
    fi

    if command -v snap >/dev/null 2>&1; then
        echo "ghostty: installing via snap (classic)"
        if ! can_run_as_root; then
            echo "warn: cannot snap install ghostty (not root, no sudo)" >&2
        elif ! run_as_root snap install ghostty --classic; then
            echo "warn: snap install ghostty failed" >&2
        fi
        ghostty_path_nudge
        ghostty_on_path && return 0
    fi

    echo "warn: ghostty not installed (no apt package / snap); see https://ghostty.org/docs/install/binary — configs still deployed" >&2
    return 0
}

ensure_apt_deps() {
    local with_terminal="${1:-0}"
    local packages=(bash curl git ca-certificates shellcheck)
    if [[ "$with_terminal" == 1 ]]; then
        packages+=(tmux neovim)
    fi
    if command -v apt-get >/dev/null 2>&1; then
        if ! run_apt_update; then
            echo "warn: cannot update apt (not root, no sudo)" >&2
            return 0
        fi
        if ! run_apt_install "${packages[@]}"; then
            return 0
        fi
    else
        echo "warn: apt-get not found; skipping package install" >&2
    fi

    if [[ "$with_terminal" == 1 ]]; then
        ensure_ghostty
    fi
}

print_done() {
    local kind="$1"
    echo "packedbox Debian bootstrap${kind} complete."
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
            ensure_apt_deps 0
            exit 0
            ;;
        --with-terminal)
            ensure_apt_deps 1
            bash "$INSTALLERS_DIR/fix-path.sh" --install
            bash "$ROOT_DIR/packs/terminal/install.sh"
            print_done " + terminal pack"
            ;;
        "")
            ensure_apt_deps 0
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
