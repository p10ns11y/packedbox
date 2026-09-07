#!/usr/bin/env bash
# fix-path.test.sh — prove fix-path.sh repairs PATH from bash --norc on Ubuntu.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAIL=0

fail() {
    printf 'FAIL %s\n' "$1" >&2
    FAIL=$((FAIL + 1))
}

ok() {
    printf 'ok   %s\n' "$1"
}

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

export HOME="$TEST_HOME"
unset PACKEDBOX_ROOT
mkdir -p "$TEST_HOME/.local/bin"

# Simulate broken PATH (only /usr/bin) like a corrupted session.
export PATH="/usr/bin"

# Run fix-path from bash --norc (no rc files).
output=$(bash --norc "$ROOT/installers/fix-path.sh" --install 2>&1) || {
    fail 'fix-path.sh --install failed under bash --norc'
    printf '%s\n' "$output" >&2
}

if [[ "$output" != *"PATH contract applied"* ]]; then
    fail 'fix-path did not report PATH contract applied'
else
    ok 'fix-path applies contract from bash --norc'
fi

if [[ ! -f "$TEST_HOME/.config/packedbox/core/path.contract" ]]; then
    fail 'core not installed to ~/.config/packedbox'
else
    ok 'fix-path --install deploys core'
fi

if [[ ! -f "$TEST_HOME/.config/packedbox/core/tmux-workflow.sh" ]]; then
    fail 'tmux-workflow.sh not installed to ~/.config/packedbox/core'
else
    ok 'fix-path --install deploys tmux-workflow.sh'
fi

if grep -qF 'tmux-workflow.sh' "$TEST_HOME/.config/packedbox/core/env.sh" \
    && grep -qE '^ab\(\)|^av\(\)|^at\(\)' "$TEST_HOME/.config/packedbox/core/tmux-workflow.sh"; then
    ok 'installed env.sh sources tmux-workflow with ab/av/at'
else
    fail 'installed env/tmux-workflow missing ab/av/at wiring'
fi

# Fresh shell with bashrc managed block must define ab / av / at (functions).
# Ubuntu login shells source ~/.bashrc via ~/.profile — seed a minimal profile.
printf '%s\n' \
    'if [ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ]; then . "$HOME/.bashrc"; fi' \
    >"$TEST_HOME/.profile"
if HOME="$TEST_HOME" bash -lc '
    type ab >/dev/null && type av >/dev/null && type at >/dev/null
'; then
    ok 'bashrc-managed shell defines ab/av/at'
else
    fail 'bashrc-managed shell missing ab/av/at'
fi

if [[ ! -x "$TEST_HOME/.local/bin/packedbox-fix-path" ]]; then
    fail 'packedbox-fix-path symlink missing'
else
    ok 'fix-path --install registers packedbox-fix-path symlink'
fi

# Symlink must resolve SCRIPT_DIR through the link (recovery entrypoint).
symlink_out=$(bash --norc "$TEST_HOME/.local/bin/packedbox-fix-path" 2>&1) || {
    fail 'packedbox-fix-path symlink invocation failed'
    printf '%s\n' "$symlink_out" >&2
}
if [[ "$symlink_out" == *"PATH contract applied"* ]]; then
    ok 'packedbox-fix-path symlink applies PATH contract'
else
    fail "packedbox-fix-path symlink did not apply contract: $symlink_out"
fi

if ! grep -qF '# packedbox managed block begin' "$TEST_HOME/.bashrc" 2>/dev/null; then
    fail 'bashrc managed block not written'
else
    ok 'fix-path --install writes bashrc managed block'
fi

# Second run must be idempotent.
if ! bash --norc "$ROOT/installers/fix-path.sh" --install >/dev/null 2>&1; then
    fail 'fix-path --install not idempotent on second run'
else
    ok 'fix-path --install is idempotent'
fi

# Verify PATH contract in subshell after fix-path apply.
verify_out=$(bash --norc -c "
    export HOME='$TEST_HOME'
    export PACKEDBOX_ROOT='$TEST_HOME/.config/packedbox'
    . \"\$PACKEDBOX_ROOT/core/lib.sh\"
    . \"\$PACKEDBOX_ROOT/core/path.sh\"
    path_deny_sweep
    path_contract_apply
    path_contract_apply --phase post_vite
    path_deny_sweep
    path_contract_verify --json
" 2>/dev/null || true)

if [[ "$verify_out" != *'"ok":true'* ]]; then
    fail "PATH contract verify failed after fix-path: $verify_out"
else
    ok 'PATH contract verify passes after fix-path install'
fi

echo "=== $FAIL failure(s) ==="
[[ "$FAIL" -eq 0 ]]
