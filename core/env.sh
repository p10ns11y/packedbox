#!/usr/bin/env sh
# packedbox core/env.sh — distro-agnostic PATH and environment presets.
# Provenance: shellyxz.sh core/env.sh (trimmed for Phase 1 PATH kernel).

PACKEDBOX_ROOT="${PACKEDBOX_ROOT:-$HOME/.config/packedbox}"

# shellcheck disable=SC1091
. "$PACKEDBOX_ROOT/core/lib.sh"
# shellcheck disable=SC1091
. "$PACKEDBOX_ROOT/core/path.sh"

shell_truth_seeker 2>/dev/null || true

# Guard against double-load in the same shell process.
if [ -n "${_PACKEDBOX_ENV_SH_LOADED:-}" ]; then
    if [ "${_PACKEDBOX_ENV_SH_LOADED_PID:-}" = "$$" ]; then
        resolve_packedbox_environment
        tool_contract_apply 2>/dev/null || true
        return 0 2>/dev/null || true
    fi
    unset _PACKEDBOX_ENV_SH_LOADED
fi
_PACKEDBOX_ENV_SH_LOADED=1
_PACKEDBOX_ENV_SH_LOADED_PID=$$

path_deny_sweep
source_environments
path_contract_apply

path_contract_apply --phase post_vite
path_deny_sweep
path_dedupe
tool_contract_apply

# t / tn / ab / av / at + agent_* → packs/terminal layout bins (when terminal pack is installed).
if [ -f "$PACKEDBOX_ROOT/core/tmux-workflow.sh" ]; then
    # shellcheck disable=SC1091
    . "$PACKEDBOX_ROOT/core/tmux-workflow.sh"
fi

if [ -f "$PACKEDBOX_ROOT/local/overwrite.sh" ]; then
    # shellcheck disable=SC1091
    . "$PACKEDBOX_ROOT/local/overwrite.sh"
fi

resolve_packedbox_environment
