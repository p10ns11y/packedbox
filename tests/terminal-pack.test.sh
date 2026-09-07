#!/usr/bin/env bash
# terminal-pack.test.sh — assert Phase 2 pack files and installer smoke.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAIL=0
TMPHOME="$(mktemp -d)"
trap 'rm -rf "$TMPHOME"' EXIT

fail() { printf 'FAIL %s\n' "$1" >&2; FAIL=$((FAIL + 1)); }
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
if HOME="$TMPHOME" bash -lc '
    PACKEDBOX_ROOT="$HOME/.config/packedbox"
    mkdir -p "$PACKEDBOX_ROOT/core" "$PACKEDBOX_ROOT/packs/terminal/tmux/bin"
    cp -a "'"$ROOT"'/core/." "$PACKEDBOX_ROOT/core/"
    # stub layout bins so _packedbox_layout_script succeeds on --help-style checks
    for s in agent-build-layout.sh agent-verify-layout.sh agent-test-layout.sh; do
        printf "#!/bin/sh\necho stub-%s \"\$@\"\n" "$s" >"$PACKEDBOX_ROOT/packs/terminal/tmux/bin/$s"
        chmod +x "$PACKEDBOX_ROOT/packs/terminal/tmux/bin/$s"
    done
    # shellcheck disable=SC1091
    . "$PACKEDBOX_ROOT/core/tmux-workflow.sh"
    type ab >/dev/null && type av >/dev/null && type at >/dev/null \
        && type agent_build >/dev/null && type agent_verify >/dev/null && type agent_test >/dev/null \
        && type pb_tmux >/dev/null
'; then
    ok 'ab/av/at and pb_tmux helpers load from tmux-workflow.sh'
else
    fail 'ab/av/at helpers did not load'
fi
if [[ -f "$TMPHOME/.config/nvim/lua/plugins/packedbox-theme.lua" ]]; then
    ok 'install.sh wires nvim theme plugin'
else
    fail 'install.sh did not wire nvim theme plugin'
fi

if grep -qF 'adapters/ubuntu/install.sh --with-terminal' "$ROOT/adapters/ubuntu/install.sh" \
    || grep -qF '--with-terminal' "$ROOT/adapters/ubuntu/install.sh"; then
    ok 'ubuntu adapter documents --with-terminal'
else
    fail 'ubuntu adapter missing --with-terminal'
fi

if grep -q 'ensure_ghostty' "$ROOT/adapters/ubuntu/install.sh" \
    && grep -q 'snap install ghostty' "$ROOT/adapters/ubuntu/install.sh" \
    && grep -q 'mkasberg/ghostty-ubuntu' "$ROOT/adapters/ubuntu/install.sh"; then
    ok 'ubuntu adapter best-effort installs ghostty (apt/snap/deb)'
else
    fail 'ubuntu adapter missing ghostty install path'
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
    'sudo apt install btop' \
    'ubuntu btop hint uses apt'
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

echo "=== $FAIL failure(s) ==="
[[ "$FAIL" -eq 0 ]]
