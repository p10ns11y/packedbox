#!/usr/bin/env bash
# ui-smoke.test.sh — build packedbox-ui headless and verify job catalog paths.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UI_SRC="$ROOT/native/packedbox-ui"
BUILD="$UI_SRC/build-smoke"
FAIL=0

fail() { printf 'FAIL %s\n' "$1" >&2; FAIL=$((FAIL + 1)); }
ok() { printf 'ok   %s\n' "$1"; }

rm -rf "$BUILD"
cmake -B "$BUILD" -S "$UI_SRC" -DPACKEDBOX_UI_BUILD_GTK=OFF >/dev/null
cmake --build "$BUILD" >/dev/null

BIN="$BUILD/packedbox-ui"
if [[ ! -x "$BIN" ]]; then
    fail 'packedbox-ui binary missing'
    echo "=== $FAIL failure(s) ==="
    exit 1
fi

ver_out=$("$BIN" --version 2>&1) || fail 'packedbox-ui --version exit'
if [[ "$ver_out" == *"packedbox-ui 0.2.0"* ]]; then
    ok 'packedbox-ui --version'
else
    fail "packedbox-ui --version output: $ver_out"
fi

help_out=$("$BIN" --help 2>&1) || fail 'packedbox-ui --help exit'
if [[ "$help_out" == *"Usage: packedbox-ui"* ]]; then
    ok 'packedbox-ui --help'
else
    fail "packedbox-ui --help output: $help_out"
fi

stub_out=$("$BIN" 2>&1) || fail 'packedbox-ui stub banner exit'
if [[ "$stub_out" == *"packedbox-ui 0.2.0"* ]]; then
    ok 'packedbox-ui stub banner'
else
    fail "packedbox-ui stub output: $stub_out"
fi

for script in installers/fix-path.sh core/check-path.sh packs/terminal/install.sh; do
    if [[ -f "$ROOT/$script" ]]; then
        ok "backend present: $script"
    else
        fail "backend missing: $script"
    fi
done

if pkg-config --exists gtk4 libadwaita-1 2>/dev/null; then
    GTK_BUILD="$UI_SRC/build-smoke-gtk"
    rm -rf "$GTK_BUILD"
    cmake -B "$GTK_BUILD" -S "$UI_SRC" >/dev/null
    cmake --build "$GTK_BUILD" >/dev/null
    if [[ -x "$GTK_BUILD/packedbox-ui" ]]; then
        ok 'packedbox-ui GTK build'
    else
        fail 'packedbox-ui GTK binary missing'
    fi
else
    ok 'GTK dev packages not installed — skipped full UI build'
fi

echo "=== $FAIL failure(s) ==="
[[ "$FAIL" -eq 0 ]]
