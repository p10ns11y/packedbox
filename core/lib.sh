#!/usr/bin/env sh
# packedbox core/lib.sh — shared safe-loading helpers (distro-agnostic).
# Provenance: shellyxz.sh core/lib.sh (trimmed for Phase 1 PATH kernel).

PACKEDBOX_ROOT="${PACKEDBOX_ROOT:-$HOME/.config/packedbox}"
OMARCHY_ROOT="${OMARCHY_ROOT:-$HOME/.local/share/omarchy}"

_is_interactive_session() {
    [ -t 0 ] && [ -t 1 ]
}

_file_is_safe_to_source() {
    source_candidate_path="$1"
    [ -n "$source_candidate_path" ] && [ -f "$source_candidate_path" ] || return 1
    [ -L "$source_candidate_path" ] && return 1
    file_owner_uid=$(stat -c '%u' "$source_candidate_path" 2>/dev/null) || return 1
    current_user_uid=$(id -u 2>/dev/null) || return 1
    [ "$file_owner_uid" = "$current_user_uid" ] || [ "$file_owner_uid" = 0 ] || return 1
    file_mode_octal=$(stat -c '%a' "$source_candidate_path" 2>/dev/null) || return 1
    case $((file_mode_octal % 10)) in
        2|3|6|7) return 1 ;;
    esac
    return 0
}

source_if_safe() {
    source_candidate_path="$1"
    if _file_is_safe_to_source "$source_candidate_path"; then
        # shellcheck disable=SC1090
        . "$source_candidate_path"
        return 0
    fi
    return 1
}

# Resolve PACKEDBOX_ENVIRONMENT: env var → environment file → auto-detect.
resolve_packedbox_environment() {
    if [ -n "${PACKEDBOX_ENVIRONMENT:-}" ]; then
        export PACKEDBOX_ENVIRONMENT
        return 0
    fi
    if [ -f "$PACKEDBOX_ROOT/environment" ]; then
        # shellcheck disable=SC1091
        . "$PACKEDBOX_ROOT/environment"
    fi
    if [ -z "${PACKEDBOX_ENVIRONMENT:-}" ]; then
        if [ -d "$HOME/.local/share/omarchy" ]; then
            PACKEDBOX_ENVIRONMENT=omarchy
        else
            PACKEDBOX_ENVIRONMENT=generic
        fi
    fi
    export PACKEDBOX_ENVIRONMENT
}

# Back-compat alias used by path-resolve.sh environment gates.
resolve_shell_environment() {
    resolve_packedbox_environment
    SHELL_ENVIRONMENT="${PACKEDBOX_ENVIRONMENT:-generic}"
    export SHELL_ENVIRONMENT
}

source_environments() {
    resolve_packedbox_environment
    for environment_preset_name in $PACKEDBOX_ENVIRONMENT; do
        environment_script_path="$PACKEDBOX_ROOT/environments/$environment_preset_name/env.sh"
        if [ -f "$environment_script_path" ]; then
            # shellcheck disable=SC1090
            . "$environment_script_path"
        elif [ "${PACKEDBOX_ENVIRONMENT_WARN:-0}" = 1 ]; then
            printf 'lib.sh: missing environment: %s\n' "$environment_script_path" >&2
        fi
    done
    unset environment_preset_name environment_script_path
}

shell_truth_seeker() {
    [ "${PACKEDBOX_TRUTH_SEEKER:-1}" = 1 ] || return 0
    if [ -n "${ZSH_VERSION+set}" ]; then
        resolved_shell_binary=$(command -v zsh 2>/dev/null || echo /usr/bin/zsh)
        [ -x "$resolved_shell_binary" ] && export SHELL="$resolved_shell_binary"
    elif [ -n "${BASH_VERSION+set}" ]; then
        resolved_shell_binary=$(command -v bash 2>/dev/null || echo /usr/bin/bash)
        [ -x "$resolved_shell_binary" ] && export SHELL="$resolved_shell_binary"
    fi
    unset resolved_shell_binary
}

unset source_candidate_path file_owner_uid current_user_uid file_mode_octal environment_preset_name environment_script_path 2>/dev/null || true
