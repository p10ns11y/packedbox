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

echo "=== $FAIL failure(s) ==="
[[ "$FAIL" -eq 0 ]]
