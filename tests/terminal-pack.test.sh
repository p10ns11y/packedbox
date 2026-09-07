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
if [[ -f "$TMPHOME/.config/nvim/lua/plugins/packedbox-theme.lua" ]]; then
    ok 'install.sh wires nvim theme plugin'
else
    fail 'install.sh did not wire nvim theme plugin'
fi

echo "=== $FAIL failure(s) ==="
[[ "$FAIL" -eq 0 ]]
