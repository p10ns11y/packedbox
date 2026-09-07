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

run_apt_install() {
    local packages=("$@")
    if [[ "$(id -u)" -eq 0 ]]; then
        DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "${packages[@]}"
    elif command -v sudo >/dev/null 2>&1; then
        DEBIAN_FRONTEND=noninteractive sudo apt-get install -y -qq "${packages[@]}"
    else
        echo "warn: cannot install apt packages (not root, no sudo)" >&2
        return 1
    fi
}

run_apt_update() {
    if [[ "$(id -u)" -eq 0 ]]; then
        apt-get update -qq
    elif command -v sudo >/dev/null 2>&1; then
        sudo apt-get update -qq
    else
        return 1
    fi
}

# Ghostty: apt (Ubuntu 26.04+), else snap, else community .deb (ghostty.org docs).
ensure_ghostty() {
    if command -v ghostty >/dev/null 2>&1; then
        echo "ghostty: already installed ($(command -v ghostty))"
        return 0
    fi

    if command -v apt-cache >/dev/null 2>&1 && apt-cache show ghostty >/dev/null 2>&1; then
        echo "ghostty: installing from apt"
        run_apt_install ghostty || echo "warn: apt install ghostty failed" >&2
        if command -v ghostty >/dev/null 2>&1; then
            return 0
        fi
    fi

    if command -v snap >/dev/null 2>&1; then
        echo "ghostty: installing via snap (classic)"
        if [[ "$(id -u)" -eq 0 ]]; then
            snap install ghostty --classic || echo "warn: snap install ghostty failed" >&2
        elif command -v sudo >/dev/null 2>&1; then
            sudo snap install ghostty --classic || echo "warn: snap install ghostty failed" >&2
        else
            echo "warn: cannot snap install ghostty (not root, no sudo)" >&2
        fi
        # Snap may land in /snap/bin; ensure login shells find it.
        if [[ -x /snap/bin/ghostty ]] && ! command -v ghostty >/dev/null 2>&1; then
            export PATH="/snap/bin:${PATH}"
        fi
        if command -v ghostty >/dev/null 2>&1; then
            return 0
        fi
    fi

    if install_ghostty_community_deb; then
        return 0
    fi

    echo "warn: ghostty not installed (no apt package / snap / community .deb); configs still deployed" >&2
    return 0
}

install_ghostty_community_deb() {
    local arch version_id suffix api_json deb_url deb_file tmpdir
    if ! command -v curl >/dev/null 2>&1 || ! command -v apt-get >/dev/null 2>&1; then
        return 1
    fi
    if [[ ! -r /etc/os-release ]]; then
        return 1
    fi
    # shellcheck source=/dev/null
    . /etc/os-release
    arch="$(dpkg --print-architecture 2>/dev/null || true)"
    version_id="${VERSION_ID:-}"
    if [[ -z "$arch" || -z "$version_id" ]]; then
        return 1
    fi
    # Community packages (mkasberg/ghostty-ubuntu) cover 24.04 and 26.04.
    case "$version_id" in
        24.04|26.04) suffix="${arch}_${version_id}" ;;
        *)
            echo "warn: no community ghostty .deb for Ubuntu ${version_id}" >&2
            return 1
            ;;
    esac

    echo "ghostty: downloading community .deb for Ubuntu ${version_id} (${arch})"
    tmpdir="$(mktemp -d)"
    api_json="${tmpdir}/releases.json"
    if ! curl -fsSL "https://api.github.com/repos/mkasberg/ghostty-ubuntu/releases/latest" \
        -o "$api_json"; then
        echo "warn: failed to query ghostty-ubuntu releases" >&2
        rm -rf "$tmpdir"
        return 1
    fi
    deb_url="$(
        # Prefer exact arch_VERSION.deb asset from latest release.
        grep -oE "https://github.com/mkasberg/ghostty-ubuntu/releases/download/[^\"]+/ghostty_[^\"]+_${suffix}\\.deb" \
            "$api_json" | head -n1 || true
    )"
    if [[ -z "$deb_url" ]]; then
        echo "warn: no ghostty .deb asset matching ${suffix}" >&2
        rm -rf "$tmpdir"
        return 1
    fi
    deb_file="${tmpdir}/$(basename "$deb_url")"
    if ! curl -fsSL "$deb_url" -o "$deb_file"; then
        echo "warn: failed to download $deb_url" >&2
        rm -rf "$tmpdir"
        return 1
    fi
    if ! run_apt_install "$deb_file"; then
        echo "warn: apt install of community ghostty .deb failed" >&2
        rm -rf "$tmpdir"
        return 1
    fi
    rm -rf "$tmpdir"
    if command -v ghostty >/dev/null 2>&1; then
        echo "ghostty: installed from community .deb"
        return 0
    fi
    return 1
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
