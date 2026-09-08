#!/usr/bin/env bash
# Minimal project test command resolver for packedbox (Phase 2).
# Full shellyxz parse-project-tests / allowlist stack stays OUT — see PULL-INVENTORY.
set -euo pipefail

# Print a shell command string for one-shot or watch test runs.
# Usage: project_test_cmd ROOT [once|watch]
project_test_cmd() {
    local root="${1:?root}"
    local mode="${2:-once}"
    local runner="${root}/bin/run-project-tests.sh"
    local cmd=""

    if [ -x "$runner" ]; then
        if [ "$mode" = watch ]; then
            printf 'TEST_WATCH_INTERVAL=${TEST_WATCH_INTERVAL:-60} %q --watch' "$runner"
        else
            printf '%q' "$runner"
        fi
        return 0
    fi

    if [ -f "${root}/package.json" ]; then
        cmd='npm test'
    elif [ -f "${root}/Cargo.toml" ]; then
        cmd='cargo test'
    elif [ -f "${root}/pyproject.toml" ] || [ -f "${root}/pytest.ini" ]; then
        cmd='pytest'
    elif [ -d "${root}/tests" ] && compgen -G "${root}/tests/*.test.sh" >/dev/null; then
        cmd='bash tests/path-contract.test.sh && bash tests/terminal-pack.test.sh'
    else
        cmd="echo 'at: no project test runner found (add bin/run-project-tests.sh)'"
    fi

    if [ "$mode" = watch ]; then
        printf 'while true; do %s; sleep "${TEST_WATCH_INTERVAL:-60}"; done' "$cmd"
    else
        printf '%s' "$cmd"
    fi
}
