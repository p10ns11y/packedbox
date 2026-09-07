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
    local tmux_dir="${HOME}/.config/tmux"
    local tmux_conf="$tmux_dir/tmux.conf"
    local marker='# Managed by packedbox packs/terminal'

    bash "$pack/tmux/bin/sync-tmux-verify.sh" || {
        echo "warn: sync-tmux-verify.sh did not install (existing unmanaged verify.conf?)" >&2
        return 0
    }

    mkdir -p "$tmux_dir"
    if [[ ! -f "$tmux_conf" ]]; then
        cat >"$tmux_conf" <<EOF
$marker
source-file ~/.config/tmux/verify.conf
EOF
        echo "tmux: wrote $tmux_conf"
        return 0
    fi

    if ! grep -qF 'source-file ~/.config/tmux/verify.conf' "$tmux_conf"; then
        printf '\n%s\nsource-file ~/.config/tmux/verify.conf\n' "$marker" >>"$tmux_conf"
        echo "tmux: ensured verify.conf include in $tmux_conf"
    else
        echo "tmux: verify.conf already sourced from $tmux_conf"
    fi
}

wire_nvim_init() {
    local init_lua="${HOME}/.config/nvim/init.lua"
    local begin_marker='-- BEGIN packedbox packs/terminal'
    local end_marker='-- END packedbox packs/terminal'
    local block_file out

    block_file="$(mktemp)"
    cat >"$block_file" <<EOF
$begin_marker
-- Eye-comfort theme without a plugin manager (lazy.nvim optional).
vim.opt.termguicolors = true
pcall(vim.cmd.colorscheme, "packedbox")
$end_marker
EOF

    mkdir -p "$(dirname "$init_lua")"
    if [[ ! -f "$init_lua" ]]; then
        cp "$block_file" "$init_lua"
        rm -f "$block_file"
        echo "nvim: wrote $init_lua"
        return 0
    fi

    if grep -qF -- "$begin_marker" "$init_lua" && grep -qF -- "$end_marker" "$init_lua"; then
        out="$(mktemp)"
        awk -v begin="$begin_marker" -v end="$end_marker" -v bf="$block_file" '
            $0 == begin {
                while ((getline line < bf) > 0) print line
                close(bf)
                skip = 1
                next
            }
            skip && $0 == end { skip = 0; next }
            !skip { print }
        ' "$init_lua" >"$out"
        mv "$out" "$init_lua"
        rm -f "$block_file"
        echo "nvim: refreshed managed block in $init_lua"
        return 0
    fi

    printf '\n' >>"$init_lua"
    cat "$block_file" >>"$init_lua"
    rm -f "$block_file"
    echo "nvim: appended managed block to $init_lua"
}

wire_nvim() {
    local pack="$1"
    local theme="$2"
    local theme_lua="$pack/nvim/themes/$theme/neovim.lua"
    local colors_lua="$pack/nvim/themes/$theme/colors.lua"
    local nvim_dir="${HOME}/.config/nvim"
    local plugins_dir="$nvim_dir/lua/plugins"
    local colors_dir="$nvim_dir/colors"
    local dest_plugin="$plugins_dir/packedbox-theme.lua"
    local dest_colors="$colors_dir/packedbox.lua"

    if [[ ! -f "$theme_lua" ]]; then
        echo "error: missing nvim theme: $theme_lua" >&2
        return 1
    fi
    if [[ ! -f "$colors_lua" ]]; then
        echo "error: missing nvim colorscheme: $colors_lua" >&2
        return 1
    fi

    mkdir -p "$plugins_dir" "$colors_dir"
    # Standalone colorscheme for stock Neovim (apt/pacman, no lazy.nvim).
    install -m 0644 "$colors_lua" "$dest_colors"
    # LazyVim / lazy.nvim plugin spec (no-op without a plugin manager).
    install -m 0644 "$theme_lua" "$dest_plugin"
    install -m 0644 "$pack/nvim/omarchy-theme-hotreload.lua" \
        "$nvim_dir/lua/packedbox-theme-hotreload.lua"
    wire_nvim_init
    echo "nvim: installed $dest_colors (+ lazy plugin spec)"
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
            echo "  nvim:    ~/.config/nvim/colors/packedbox.lua (+ init.lua)"
            ;;
        *)
            echo "error: unknown argument: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
}

main "$@"
