#!/usr/bin/env bash
# terminal-pack.test.sh — assert Phase 2 pack files and installer smoke.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAIL=0
TMPHOME="$(mktemp -d)"
trap 'rm -rf "$TMPHOME"' EXIT

fail() { printf 'FAIL %s\n' "$1" >&2; printf 'FAIL %s\n' "$1"; FAIL=$((FAIL + 1)); }
ok() { printf 'ok   %s\n' "$1"; }

require_file() {
    if [[ -f "$1" ]]; then
        ok "present $(basename "$1")"
    else
        fail "missing $1"
    fi
}

require_file "$ROOT/packs/terminal/ghostty/fragment.conf"
require_file "$ROOT/packs/terminal/ghostty/themes/eye-comfort-dark/ghostty.conf"
require_file "$ROOT/packs/terminal/nvim/themes/eye-comfort-dark/neovim.lua"
require_file "$ROOT/packs/terminal/nvim/themes/eye-comfort-dark/colors.lua"
require_file "$ROOT/packs/terminal/tmux/conf/tmux.verify.conf.ex"
require_file "$ROOT/packs/terminal/tmux/bin/sync-tmux-verify.sh"
require_file "$ROOT/packs/terminal/tmux/lib/project-tests.sh"
require_file "$ROOT/packs/terminal/install.sh"
require_file "$ROOT/adapters/arch/install.sh"

if grep -q 'Managed by packedbox packs/terminal' \
    "$ROOT/packs/terminal/tmux/conf/tmux.verify.conf.ex"; then
    ok 'tmux conf uses packedbox managed marker'
else
    fail 'tmux conf still references shellyxz migrate marker'
fi

HOME="$TMPHOME" bash "$ROOT/packs/terminal/install.sh" --pack-only >/dev/null
if [[ -f "$TMPHOME/.config/packedbox/packs/terminal/ghostty/fragment.conf" ]]; then
    ok 'install.sh --pack-only deploys pack tree'
else
    fail 'install.sh --pack-only did not deploy pack tree'
fi

HOME="$TMPHOME" bash "$ROOT/packs/terminal/install.sh" >/dev/null
if [[ -f "$TMPHOME/.config/ghostty/config" ]]; then
    ok 'install.sh wires ghostty config'
else
    fail 'install.sh did not wire ghostty config'
fi
if [[ -f "$TMPHOME/.config/tmux/verify.conf" ]]; then
    ok 'install.sh wires tmux verify.conf'
else
    fail 'install.sh did not wire tmux verify.conf'
fi
if [[ -f "$TMPHOME/.config/tmux/tmux.conf" ]] \
    && grep -qF 'source-file ~/.config/tmux/verify.conf' "$TMPHOME/.config/tmux/tmux.conf"; then
    ok 'install.sh wires tmux.conf to source verify.conf'
else
    fail 'install.sh did not wire tmux.conf source-file'
fi
if grep -qF '~/.config/shell/' "$TMPHOME/.config/tmux/verify.conf"; then
    fail 'verify.conf still references shellyxz ~/.config/shell paths'
else
    ok 'verify.conf uses packedbox pack bin paths'
fi
if grep -qF 'set -g prefix C-b' "$TMPHOME/.config/tmux/verify.conf" \
    && grep -qF 'set -g prefix2 C-Space' "$TMPHOME/.config/tmux/verify.conf"; then
    ok 'verify.conf sets Ctrl-b prefix and Ctrl-Space prefix2'
else
    fail 'verify.conf missing explicit prefix / prefix2'
fi
if grep -qF "C-b" "$ROOT/packs/terminal/tmux/lib/tmux-status-mode.sh" \
    && grep -qF '#{?client_prefix,PREFIX' "$ROOT/packs/terminal/tmux/lib/tmux-status-mode.sh"; then
    ok 'status-mode shows C-b hint and PREFIX latch'
else
    fail 'status-mode missing C-b / PREFIX segments'
fi
if grep -qE '^bind q source-file' "$TMPHOME/.config/tmux/verify.conf"; then
    ok 'verify.conf binds Prefix+q to reload tmux.conf'
else
    fail 'verify.conf missing Prefix+q reload bind'
fi
require_file "$ROOT/core/tmux-workflow.sh"
if grep -qF 'tmux-workflow.sh' "$ROOT/core/env.sh"; then
    ok 'env.sh sources tmux-workflow.sh'
else
    fail 'env.sh does not source tmux-workflow.sh'
fi
if grep -qF 'tmux-workflow.sh' "$ROOT/installers/lib/packedbox-install.sh"; then
    ok 'packedbox-install deploys tmux-workflow.sh'
else
    fail 'packedbox-install missing tmux-workflow.sh install'
fi

# Seed a HOME with core + stub layout bins for tmux-workflow checks.
seed_workflow_home() {
    local home="$1"
    local root="$home/.config/packedbox"
    mkdir -p "$root/core" "$root/packs/terminal/tmux/bin"
    cp -a "$ROOT/core/." "$root/core/"
    local s
    for s in agent-build-layout.sh agent-verify-layout.sh agent-test-layout.sh; do
        printf '#!/bin/sh\necho stub-%s "$@"\n' "$s" >"$root/packs/terminal/tmux/bin/$s"
        chmod +x "$root/packs/terminal/tmux/bin/$s"
    done
}

seed_workflow_home "$TMPHOME"
if HOME="$TMPHOME" bash -lc '
    PACKEDBOX_ROOT="$HOME/.config/packedbox"
    # shellcheck disable=SC1091
    . "$PACKEDBOX_ROOT/core/tmux-workflow.sh"
    type ab >/dev/null && type av >/dev/null && type at >/dev/null \
        && type agent_build >/dev/null && type agent_verify >/dev/null && type agent_test >/dev/null \
        && type pb_tmux >/dev/null && type t >/dev/null && type tn >/dev/null && type pb >/dev/null
'; then
    ok 'ab/av/at/t/tn/pb and pb_tmux helpers load from tmux-workflow.sh'
else
    fail 'ab/av/at/t/tn helpers did not load'
fi

# Outside-tmux guard: clear first-run one-liner (not opaque "must run inside tmux").
outside_msg="$(
    unset TMUX
    HOME="$TMPHOME" bash -c '
        PACKEDBOX_ROOT="$HOME/.config/packedbox"
        # shellcheck disable=SC1091
        . "$PACKEDBOX_ROOT/core/tmux-workflow.sh"
        av 2>&1 || true
    '
)"
if printf '%s' "$outside_msg" | grep -qF 'run: tn  (then av)'; then
    ok 'av outside tmux prints tn first-run one-liner'
else
    fail "av outside tmux missing first-run hint (got: $outside_msg)"
fi
layout_outside="$(
    unset TMUX
    "$ROOT/packs/terminal/tmux/bin/agent-verify-layout.sh" 2>&1 || true
)"
if printf '%s' "$layout_outside" | grep -qF 'run: tn'; then
    ok 'agent-verify-layout outside tmux prints tn one-liner'
else
    fail "layout outside tmux missing hint (got: $layout_outside)"
fi
if [[ -f "$TMPHOME/.config/nvim/lua/plugins/packedbox-theme.lua" ]]; then
    ok 'install.sh wires nvim lazy theme plugin'
else
    fail 'install.sh did not wire nvim lazy theme plugin'
fi
if [[ -f "$TMPHOME/.config/nvim/colors/packedbox.lua" ]] \
    && grep -qF 'colors_name = "packedbox"' "$TMPHOME/.config/nvim/colors/packedbox.lua"; then
    ok 'install.sh wires standalone nvim colorscheme'
else
    fail 'install.sh did not wire standalone nvim colorscheme'
fi
if [[ -f "$TMPHOME/.config/nvim/init.lua" ]] \
    && grep -qF -- 'BEGIN packedbox packs/terminal' "$TMPHOME/.config/nvim/init.lua" \
    && grep -qF 'colorscheme' "$TMPHOME/.config/nvim/init.lua" \
    && grep -qF 'packedbox' "$TMPHOME/.config/nvim/init.lua"; then
    ok 'install.sh wires managed nvim init.lua block'
else
    fail 'install.sh did not wire managed nvim init.lua'
fi

# Idempotent: re-install must not duplicate managed markers; preserve user config.
printf '\n-- user config kept\nvim.opt.number = true\n' >>"$TMPHOME/.config/nvim/init.lua"
HOME="$TMPHOME" bash "$ROOT/packs/terminal/install.sh" >/dev/null
begin_count="$(grep -cF -- 'BEGIN packedbox packs/terminal' "$TMPHOME/.config/nvim/init.lua" || true)"
if [[ "$begin_count" -eq 1 ]] \
    && grep -qF 'user config kept' "$TMPHOME/.config/nvim/init.lua"; then
    ok 'nvim init.lua re-install is idempotent (keeps user lines)'
else
    fail "nvim init.lua re-install duplicated or clobbered (begins=$begin_count)"
fi

# Append path when init.lua already exists without markers.
rm -f "$TMPHOME/.config/nvim/init.lua"
printf -- '-- preexisting lazy bootstrap\nprint("user-init")\n' >"$TMPHOME/.config/nvim/init.lua"
HOME="$TMPHOME" bash "$ROOT/packs/terminal/install.sh" >/dev/null
if grep -qF 'preexisting lazy bootstrap' "$TMPHOME/.config/nvim/init.lua" \
    && grep -qF -- 'BEGIN packedbox packs/terminal' "$TMPHOME/.config/nvim/init.lua"; then
    ok 'nvim init.lua appends managed block beside existing config'
else
    fail 'nvim init.lua append path lost user config or markers'
fi

# Headless: stock nvim (no plugins) loads packedbox, not default/empty scheme.
# Use a clean HOME install (prior cases left a print() in init.lua).
THEMEHOME="$(mktemp -d)"
HOME="$THEMEHOME" bash "$ROOT/packs/terminal/install.sh" >/dev/null
theme_probe="$(
    HOME="$THEMEHOME" nvim --headless \
        -c 'lua local c=vim.api.nvim_get_hl(0,{name="Normal"}); print(vim.g.colors_name, string.format("#%06x", c.bg or 0))' \
        -c qa 2>&1 | tr -d '\r'
)"
rm -rf "$THEMEHOME"
if printf '%s\n' "$theme_probe" | grep -qF 'packedbox' \
    && printf '%s\n' "$theme_probe" | grep -qiF '#181614'; then
    ok 'headless nvim loads packedbox eye-comfort-dark (not stock)'
else
    fail "headless nvim theme probe failed (got: $theme_probe)"
fi

assert_with_terminal() {
    local distro="$1" script="$ROOT/adapters/$1/install.sh"
    if grep -qF -- '--with-terminal' "$script" \
        && grep -qF 'packs/terminal/install.sh' "$script" \
        && grep -qF 'fix-path.sh' "$script"; then
        ok "$distro adapter advertises --with-terminal (+ pack + fix-path)"
    else
        fail "$distro adapter missing --with-terminal wiring"
    fi
}

assert_with_terminal ubuntu
assert_with_terminal debian
assert_with_terminal arch

if grep -q 'ensure_ghostty' "$ROOT/adapters/ubuntu/install.sh" \
    && grep -q 'snap install ghostty' "$ROOT/adapters/ubuntu/install.sh" \
    && grep -q 'mkasberg/ghostty-ubuntu' "$ROOT/adapters/ubuntu/install.sh"; then
    ok 'ubuntu adapter best-effort installs ghostty (apt/snap/deb)'
else
    fail 'ubuntu adapter missing ghostty install path'
fi

if grep -q 'ensure_ghostty' "$ROOT/adapters/debian/install.sh" \
    && grep -q 'snap install ghostty' "$ROOT/adapters/debian/install.sh" \
    && grep -q 'ghostty.org/docs/install/binary' "$ROOT/adapters/debian/install.sh"; then
    ok 'debian adapter best-effort installs ghostty (apt/snap + warn)'
else
    fail 'debian adapter missing ghostty install path'
fi

if grep -q 'ensure_ghostty' "$ROOT/adapters/arch/install.sh" \
    && grep -q 'pacman -Si ghostty' "$ROOT/adapters/arch/install.sh" \
    && grep -q 'paru -S' "$ROOT/adapters/arch/install.sh" \
    && grep -q 'omarchy-install-terminal' "$ROOT/adapters/arch/install.sh"; then
    ok 'arch adapter best-effort installs ghostty (pacman/paru/omarchy)'
else
    fail 'arch adapter missing ghostty install path'
fi

if grep -qE 'split-window .*-p ["$]' "$ROOT/packs/terminal/tmux/lib/verify-layout.sh" \
    "$ROOT/packs/terminal/tmux/bin/agent-test-layout.sh" 2>/dev/null; then
    fail 'tmux splits still use deprecated -p (breaks Ubuntu tmux 3.4)'
else
    ok 'tmux splits use -l N% (Ubuntu tmux 3.4 compatible)'
fi

# Distro-aware optional install hints (no Arch-only paru/pacman hardcoding).
if grep -qE 'paru -S|pacman -S' \
    "$ROOT/packs/terminal/tmux/bin/agent-verify-layout.sh" \
    "$ROOT/packs/terminal/tmux/bin/agent-test-layout.sh"; then
    fail 'layout scripts hardcode Arch package managers'
else
    ok 'layout scripts do not hardcode paru/pacman'
fi
if grep -q 'verify_missing_pkg_echo' \
    "$ROOT/packs/terminal/tmux/bin/agent-verify-layout.sh" \
    "$ROOT/packs/terminal/tmux/bin/agent-test-layout.sh" \
    && grep -q 'verify_optional_install_cmd' \
    "$ROOT/packs/terminal/tmux/lib/verify-launch.sh"; then
    ok 'layout scripts use verify_missing_pkg_echo helper'
else
    fail 'missing verify_missing_pkg_echo wiring'
fi

hint_lib="$ROOT/packs/terminal/tmux/lib/verify-launch.sh"
hint_tmp="$(mktemp -d)"
trap 'rm -rf "$TMPHOME" "$hint_tmp"' EXIT
printf 'ID=ubuntu\nID_LIKE=debian\n' >"$hint_tmp/os-ubuntu"
printf 'ID=arch\n' >"$hint_tmp/os-arch"
printf 'ID=fedora\n' >"$hint_tmp/os-other"

assert_hint() {
    local os_file="$1" pkg="$2" expect="$3" label="$4"
    local got
    got="$(
        VERIFY_OS_RELEASE="$os_file" bash -c '
            # shellcheck disable=SC1090
            . "$1"
            verify_optional_install_cmd "$2"
        ' bash "$hint_lib" "$pkg"
    )"
    if [ "$got" = "$expect" ]; then
        ok "$label"
    else
        fail "$label (got: $got)"
    fi
}

assert_hint "$hint_tmp/os-ubuntu" lazygit \
    'go install github.com/jesseduffield/lazygit@latest' \
    'ubuntu lazygit hint uses go install (not in 24.04 apt)'
assert_hint "$hint_tmp/os-ubuntu" btop \
    'sudo apt install htop' \
    'ubuntu btop/htop hint prefers htop (main)'
assert_hint "$hint_tmp/os-ubuntu" htop \
    'sudo apt install htop' \
    'ubuntu htop hint uses apt'
assert_hint "$hint_tmp/os-arch" lazygit \
    'sudo pacman -S lazygit' \
    'arch lazygit hint uses pacman (not paru)'
assert_hint "$hint_tmp/os-arch" btop \
    'sudo pacman -S btop' \
    'arch btop hint uses pacman'
assert_hint "$hint_tmp/os-other" lazygit \
    'install lazygit' \
    'generic lazygit hint has no package manager'

ubuntu_echo="$(
    VERIFY_OS_RELEASE="$hint_tmp/os-ubuntu" bash -c '
        . "$1"
        verify_missing_pkg_echo lazygit "install lazygit"
    ' bash "$hint_lib"
)"
if [ "$ubuntu_echo" = "echo 'install lazygit (optional: go install github.com/jesseduffield/lazygit@latest)'" ]; then
    ok 'ubuntu verify pane echo for missing lazygit'
else
    fail "ubuntu verify pane echo wrong (got: $ubuntu_echo)"
fi

require_file "$ROOT/packs/terminal/tmux/lib/verify-cmd-guard.sh"
if bash "$ROOT/packs/terminal/tmux/lib/verify-cmd-guard.sh" 'sudo rm -rf /' >/dev/null 2>&1; then
    fail 'verify-cmd-guard allowed sudo rm -rf /'
else
    ok 'verify-cmd-guard blocks sudo rm -rf /'
fi
if bash "$ROOT/packs/terminal/tmux/lib/verify-cmd-guard.sh" 'bash tests/path-contract.test.sh' >/dev/null 2>&1; then
    ok 'verify-cmd-guard allows allowlisted test command'
else
    fail 'verify-cmd-guard blocked allowlisted test command'
fi
if grep -qF "monitor 'NVIM'" "$ROOT/packs/terminal/tmux/bin/agent-verify-layout.sh"; then
    ok 'av generic layout launches NVIM pane'
else
    fail 'av generic layout missing NVIM pane'
fi
if [[ -x "$ROOT/.agents/verification/tmux-layout.sh" ]]; then
    ok 'project .agents/verification/tmux-layout.sh present'
else
    fail 'project verification tmux-layout.sh missing or not executable'
fi
if [[ -f "$ROOT/.cursor/skills/verify-packedbox/SKILL.md" ]]; then
    ok 'verify-packedbox skill present'
else
    fail 'verify-packedbox skill missing'
fi

echo "=== $FAIL failure(s) ==="
[[ "$FAIL" -eq 0 ]]
