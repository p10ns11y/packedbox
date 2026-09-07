#!/usr/bin/env bash
# cli-smoke.test.sh — build packedbox-cli / packedbox-ui and check banners.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAIL=0

fail() { printf 'FAIL %s\n' "$1" >&2; FAIL=$((FAIL + 1)); }
ok() { printf 'ok   %s\n' "$1"; }

build_one() {
    local name="$1"
    local src="$ROOT/native/$name"
    local build="$src/build-smoke"

    rm -rf "$build"
    cmake -B "$build" -S "$src" >/dev/null
    cmake --build "$build" >/dev/null
}

build_one packedbox-cli || fail 'packedbox-cli cmake build'
build_one packedbox-ui || fail 'packedbox-ui cmake build'

CLI_BIN="$ROOT/native/packedbox-cli/build-smoke/packedbox"
UI_BIN="$ROOT/native/packedbox-ui/build-smoke/packedbox-ui"

if [[ -x "$CLI_BIN" ]]; then
    out=$("$CLI_BIN" --version 2>&1) || fail 'packedbox --version exit'
    if [[ "$out" == *"packedbox 0.1.0"* ]]; then
        ok 'packedbox --version'
    else
        fail "packedbox --version output: $out"
    fi

    help_out=$("$CLI_BIN" --help 2>&1) || fail 'packedbox --help exit'
    if [[ "$help_out" == *"Usage: packedbox"* ]]; then
        ok 'packedbox --help'
    else
        fail "packedbox --help output: $help_out"
    fi

    if "$CLI_BIN" --nope >/dev/null 2>&1; then
        fail 'packedbox unknown flag should fail'
    else
        ok 'packedbox rejects unknown flag'
    fi
else
    fail 'packedbox binary missing'
fi

if [[ -x "$UI_BIN" ]]; then
    ui_out=$("$UI_BIN" 2>&1) || fail 'packedbox-ui exit'
    if [[ "$ui_out" == *"packedbox-ui 0.1.0"* ]]; then
        ok 'packedbox-ui banner'
    else
        fail "packedbox-ui output: $ui_out"
    fi
else
    fail 'packedbox-ui binary missing'
fi

echo "=== $FAIL failure(s) ==="
[[ "$FAIL" -eq 0 ]]
