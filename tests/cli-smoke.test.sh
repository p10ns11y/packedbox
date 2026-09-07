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
    local extra_env=()

    rm -rf "$build"
    if [[ "$name" == "packedbox-cli" && -f "${PACKEDBOX_ELOMAXZ_SOURCE_DIR:-}/src/elomaxz.c" ]]; then
        extra_env=(env "PACKEDBOX_ELOMAXZ_SOURCE_DIR=$PACKEDBOX_ELOMAXZ_SOURCE_DIR")
    elif [[ "$name" == "packedbox-cli" && -f "$HOME/Work/personal/elomaxz/src/elomaxz.c" ]]; then
        extra_env=(env "PACKEDBOX_ELOMAXZ_SOURCE_DIR=$HOME/Work/personal/elomaxz")
    fi
    "${extra_env[@]}" cmake -B "$build" -S "$src" >/dev/null
    cmake --build "$build" >/dev/null
}

build_one packedbox-cli || fail 'packedbox-cli cmake build'
build_one packedbox-ui || fail 'packedbox-ui cmake build'

CLI_BIN="$ROOT/native/packedbox-cli/build-smoke/packedbox"
UI_BIN="$ROOT/native/packedbox-ui/build-smoke/packedbox-ui"

if [[ -x "$CLI_BIN" ]]; then
    out=$("$CLI_BIN" --version 2>&1) || fail 'packedbox --version exit'
    if [[ "$out" == *"packedbox 0.2.0"* ]]; then
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

    status_out=$("$CLI_BIN" status 2>&1) || fail 'packedbox status exit'
    if [[ "$status_out" == *"packedbox status:"* ]]; then
        ok 'packedbox status'
    else
        fail "packedbox status output: $status_out"
    fi

    audit_out=$("$CLI_BIN" audit 2>&1) || fail 'packedbox audit exit'
    if [[ "$audit_out" == *"packedbox audit:"* ]]; then
        ok 'packedbox audit'
    else
        fail "packedbox audit output: $audit_out"
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
    ui_ver=$("$UI_BIN" --version 2>&1) || fail 'packedbox-ui --version exit'
    if [[ "$ui_ver" == *"packedbox-ui 0.2.0"* ]]; then
        ok 'packedbox-ui --version'
    else
        fail "packedbox-ui --version output: $ui_ver"
    fi

    ui_help=$("$UI_BIN" --help 2>&1) || fail 'packedbox-ui --help exit'
    if [[ "$ui_help" == *"Usage: packedbox-ui"* ]]; then
        ok 'packedbox-ui --help'
    else
        fail "packedbox-ui --help output: $ui_help"
    fi
else
    fail 'packedbox-ui binary missing'
fi

echo "=== $FAIL failure(s) ==="
[[ "$FAIL" -eq 0 ]]
