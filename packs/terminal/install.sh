#!/usr/bin/env bash
# Install packs/terminal into ~/.config/packedbox and wire Ghostty/tmux/nvim.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
INSTALLERS_DIR="$ROOT_DIR/installers"
DEFAULT_THEME="${PACKEDBOX_THEME:-eye-comfort-dark}"

# shellcheck source=../../installers/lib/packedbox-install.sh
. "$INSTALLERS_DIR/lib/packedbox-install.sh"

usage() {
    cat <<'EOF'
packedbox terminal pack installer (Phase 2)

Usage:
  packs/terminal/install.sh                 Install pack + wire configs
  packs/terminal/install.sh --pack-only     Copy pack files only
  packs/terminal/install.sh --help

Env:
  PACKEDBOX_THEME   Theme id (default: eye-comfort-dark)
EOF
}

install_pack_tree() {
    local dest="${HOME}/.config/packedbox/packs/terminal"
    mkdir -p "$dest"
    rm -rf "$dest/ghostty" "$dest/tmux" "$dest/nvim"
    cp -a "$SCRIPT_DIR/ghostty" "$dest/ghostty"
    cp -a "$SCRIPT_DIR/tmux" "$dest/tmux"
    cp -a "$SCRIPT_DIR/nvim" "$dest/nvim"
    printf '%s\n' "$dest"
}

wire_ghostty() {
    local pack="$1"
    local theme="$2"
    local theme_conf="$pack/ghostty/themes/$theme/ghostty.conf"
    local ghostty_dir="${HOME}/.config/ghostty"
    local main_conf="$ghostty_dir/config"

    if [[ ! -f "$theme_conf" ]]; then
        echo "error: missing theme conf: $theme_conf" >&2
        return 1
    fi

    mkdir -p "$ghostty_dir/themes"
    install -m 0644 "$theme_conf" "$ghostty_dir/themes/packedbox-$theme.conf"
    install -m 0644 "$pack/ghostty/fragment.conf" "$ghostty_dir/packedbox-fragment.conf"

    if [[ ! -f "$main_conf" ]]; then
        cat >"$main_conf" <<EOF
# Managed by packedbox packs/terminal
config-file = $ghostty_dir/themes/packedbox-$theme.conf
config-file = $ghostty_dir/packedbox-fragment.conf
EOF
        echo "ghostty: wrote $main_conf"
        return 0
    fi

    if ! grep -qF "packedbox-$theme.conf" "$main_conf"; then
        printf '\n# Managed by packedbox packs/terminal\nconfig-file = %s\n' \
            "$ghostty_dir/themes/packedbox-$theme.conf" >>"$main_conf"
    fi
    if ! grep -qF 'packedbox-fragment.conf' "$main_conf"; then
        printf 'config-file = %s\n' "$ghostty_dir/packedbox-fragment.conf" >>"$main_conf"
    fi
    echo "ghostty: ensured includes in $main_conf"
}

wire_tmux() {
    local pack="$1"
    bash "$pack/tmux/bin/sync-tmux-verify.sh" || {
        echo "warn: sync-tmux-verify.sh did not install (existing unmanaged verify.conf?)" >&2
        return 0
    }
}

wire_nvim() {
    local pack="$1"
    local theme="$2"
    local theme_lua="$pack/nvim/themes/$theme/neovim.lua"
    local nvim_dir="${HOME}/.config/nvim/lua/plugins"
    local dest="$nvim_dir/packedbox-theme.lua"

    if [[ ! -f "$theme_lua" ]]; then
        echo "error: missing nvim theme: $theme_lua" >&2
        return 1
    fi

    mkdir -p "$nvim_dir"
    install -m 0644 "$theme_lua" "$dest"
    install -m 0644 "$pack/nvim/omarchy-theme-hotreload.lua" \
        "${HOME}/.config/nvim/lua/packedbox-theme-hotreload.lua"
    echo "nvim: installed $dest"
}

main() {
    case "${1:-}" in
        -h|--help|help)
            usage
            exit 0
            ;;
        --pack-only)
            install_pack_tree
            echo "packedbox terminal pack copied."
            ;;
        "")
            local pack
            pack="$(install_pack_tree)"
            wire_ghostty "$pack" "$DEFAULT_THEME"
            wire_tmux "$pack"
            wire_nvim "$pack" "$DEFAULT_THEME"
            echo "packedbox terminal pack install complete (theme=$DEFAULT_THEME)."
            echo "  pack:    $pack"
            echo "  ghostty: ~/.config/ghostty"
            echo "  tmux:    ~/.config/tmux/verify.conf"
            echo "  nvim:    ~/.config/nvim/lua/plugins/packedbox-theme.lua"
            ;;
        *)
            echo "error: unknown argument: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
}

main "$@"
