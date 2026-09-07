#!/usr/bin/env bash
# recover.test.sh — smoke test for packedbox recovery helper.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAIL=0

fail() { printf 'FAIL %s\n' "$1" >&2; FAIL=$((FAIL + 1)); }
ok() { printf 'ok   %s\n' "$1"; }

output=$(bash --norc "$ROOT/core/recover.sh" 2>&1) || {
    fail 'recover.sh failed under bash --norc'
}

if [[ "$output" != *"packedbox recovery"* ]]; then
    fail 'recover.sh missing expected banner'
else
    ok 'recover.sh prints recovery banner'
fi

if [[ "$output" != *"packedbox-fix-path"* ]]; then
    fail 'recover.sh missing fix-path guidance'
else
    ok 'recover.sh references packedbox-fix-path'
fi

echo "=== $FAIL failure(s) ==="
[[ "$FAIL" -eq 0 ]]
