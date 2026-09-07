#!/usr/bin/env bash
# Verify packedbox PATH contract installation and runtime behavior.
# Usage: check-path.sh [--json]
set -euo pipefail

PACKEDBOX_ROOT="${PACKEDBOX_ROOT:-$HOME/.config/packedbox}"
JSON=false

for arg in "$@"; do
    case "$arg" in
        --json) JSON=true ;;
        -h|--help)
            echo "Usage: check-path.sh [--json]"
            exit 0
            ;;
    esac
done

errors=0
warnings=0

fail() { echo "ERROR: $1"; errors=$((errors + 1)); }
warn() { echo "WARN:  $1"; warnings=$((warnings + 1)); }
ok()   { echo "OK:   $1"; }

echo "=== packedbox PATH checks ==="

for required in core/path.contract core/path.sh core/path-resolve.sh core/env.sh core/lib.sh core/tool.contract; do
    if [[ -f "$PACKEDBOX_ROOT/$required" ]]; then
        ok "$required present"
    else
        fail "$required missing under $PACKEDBOX_ROOT"
    fi
done

if [[ -f "$PACKEDBOX_ROOT/core/path.contract" ]]; then
    grep -q '^phase:core' "$PACKEDBOX_ROOT/core/path.contract" \
        && ok 'path.contract v2 format (phase:core)' \
        || warn 'path.contract missing phase:core'
    grep -q '^deny:' "$PACKEDBOX_ROOT/core/path.contract" \
        && ok 'path.contract has deny list' \
        || warn 'path.contract missing deny entries'
fi

if [[ -f "$PACKEDBOX_ROOT/core/env.sh" ]]; then
    grep -q 'path_contract_apply' "$PACKEDBOX_ROOT/core/env.sh" \
        && ok 'env.sh uses path_contract_apply' \
        || warn 'env.sh missing path_contract_apply'
    grep -q 'path_deny_sweep' "$PACKEDBOX_ROOT/core/env.sh" \
        && ok 'env.sh uses path_deny_sweep' \
        || warn 'env.sh missing path_deny_sweep'
fi

if [[ -x "$HOME/.local/bin/packedbox-fix-path" ]]; then
    ok 'packedbox-fix-path installed in ~/.local/bin'
else
    warn 'packedbox-fix-path not in ~/.local/bin (run fix-path.sh --install)'
fi

bashrc_marker='# packedbox managed block begin'
if grep -qF "$bashrc_marker" "$HOME/.bashrc" 2>/dev/null; then
    ok 'bashrc has packedbox managed block'
else
    warn 'bashrc missing packedbox managed block (run fix-path.sh --install)'
fi

if [[ -f "$PACKEDBOX_ROOT/core/path-resolve.sh" ]]; then
    # shellcheck disable=SC1091
    . "$PACKEDBOX_ROOT/core/lib.sh"
    # shellcheck disable=SC1091
    . "$PACKEDBOX_ROOT/core/path.sh"
    if path_contract_verify --json 2>/dev/null | grep -q '"ok":true'; then
        ok 'PATH runtime contract verify'
    else
        fail 'PATH runtime contract verify failed'
        path_contract_verify 2>&1 || true
    fi
fi

echo ""
echo "=== summary: $errors error(s), $warnings warning(s) ==="

if [[ "$JSON" == true ]]; then
    if [[ "$errors" -eq 0 ]]; then
        printf '{"ok":true,"errors":%s,"warnings":%s}\n' "$errors" "$warnings"
    else
        printf '{"ok":false,"errors":%s,"warnings":%s}\n' "$errors" "$warnings"
    fi
fi

[[ "$errors" -eq 0 ]]
