#!/usr/bin/env bash
# doctor — read-only health check for verify-packedbox.
# Exit 0 = safe to drive; non-zero = refuse driving.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
if [[ ! -f "$ROOT/core/path.contract" ]]; then
    ROOT="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel 2>/dev/null || true)"
fi
FAIL=0

ok() { printf 'OK   %s\n' "$1"; }
bad() { printf 'FAIL %s\n' "$1" >&2; FAIL=$((FAIL + 1)); }

# Never drive as root on a shared cloud machine.
if [[ "$(id -u)" -eq 0 ]]; then
    bad 'running as root — refuse verification drive'
else
    ok "uid=$(id -u) (non-root)"
fi

if [[ ! -f "$ROOT/core/path.contract" ]]; then
    bad "missing $ROOT/core/path.contract"
else
    ok 'repo checkout looks like packedbox'
fi

if [[ ! -x "$HOME/.local/bin/packedbox-fix-path" ]] && [[ ! -f "$ROOT/installers/fix-path.sh" ]]; then
    bad 'fix-path not available'
else
    ok 'fix-path available'
fi

if [[ -f "$HOME/.config/packedbox/core/check-path.sh" ]]; then
    if bash "$HOME/.config/packedbox/core/check-path.sh" >/tmp/packedbox-doctor-path.txt 2>&1; then
        ok 'check-path passed'
    else
        # Cloud agent PATH pollution is common — warn but allow scripted tests.
        ok 'check-path reported issues (see /tmp/packedbox-doctor-path.txt) — use bash --norc + fix-path for PATH drives'
    fi
else
    ok 'core not installed in HOME (repo tests still OK)'
fi

GUARD="$HOME/.config/packedbox/packs/terminal/tmux/lib/verify-cmd-guard.sh"
[[ -f "$GUARD" ]] || GUARD="$ROOT/packs/terminal/tmux/lib/verify-cmd-guard.sh"
if [[ -f "$GUARD" ]]; then
    # shellcheck source=/dev/null
    source "$GUARD"
    if verify_cmd_guard 'sudo rm -rf /' 2>/dev/null; then
        bad 'deny guard failed to block sudo rm -rf /'
    else
        ok 'deny guard blocks illicit sample'
    fi
else
    bad 'verify-cmd-guard.sh missing'
fi

if command -v /usr/bin/tmux >/dev/null 2>&1 || command -v tmux >/dev/null 2>&1; then
    ok 'tmux present'
else
    bad 'tmux missing'
fi

if [[ -x "$ROOT/native/packedbox-cli/build/packedbox" ]] || command -v packedbox >/dev/null 2>&1; then
    ok 'packedbox CLI build or PATH entry present'
else
    ok 'CLI binary optional for PATH/terminal features'
fi

echo "=== doctor: $FAIL failure(s) ==="
[[ "$FAIL" -eq 0 ]]
