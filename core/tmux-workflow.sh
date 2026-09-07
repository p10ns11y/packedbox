#!/usr/bin/env sh
# packedbox core/tmux-workflow.sh — thin shellyxz-style ab / av / at helpers.
# Provenance: shellyxz.sh core/aliases.sh + agent_* slice of core/functions.sh (trimmed).
# Calls packs/terminal/tmux/bin layout scripts; does not pull the full functions.sh melt.

_packedbox_tmux_guard() {
    if [ -z "${TMUX:-}" ]; then
        echo "Start tmux first: /usr/bin/tmux -f ~/.config/tmux/tmux.conf" >&2
        echo "  (or: pb_tmux new -s packedbox)" >&2
        return 1
    fi
}

_packedbox_layout_script() {
    _pb_layout_name="$1"
    _pb_layout_script="${PACKEDBOX_ROOT:-$HOME/.config/packedbox}/packs/terminal/tmux/bin/${_pb_layout_name}"
    if [ ! -x "$_pb_layout_script" ]; then
        echo "packedbox: missing $_pb_layout_script (run packs/terminal/install.sh)" >&2
        return 1
    fi
    printf '%s\n' "$_pb_layout_script"
}

# Prefer distro tmux over Cursor /exec-daemon/tmux when both exist.
packedbox_tmux() {
    if [ -x /usr/bin/tmux ]; then
        /usr/bin/tmux "$@"
    else
        command tmux "$@"
    fi
}

# Attach-or-create with packedbox verify.conf (cloud-desktop safe launch path).
pb_tmux() {
    _pb_tmux_conf="${HOME}/.config/tmux/tmux.conf"
    if [ -f "$_pb_tmux_conf" ]; then
        packedbox_tmux -f "$_pb_tmux_conf" "$@"
    else
        packedbox_tmux "$@"
    fi
}

agent_build() {
    _packedbox_tmux_guard || return 1
    _pb_script="$(_packedbox_layout_script agent-build-layout.sh)" || return 1
    # Default cwd to $PWD (shellyxz UX); callers may pass an explicit directory.
    _pb_dir="${PWD:-.}"
    _pb_dir_set=0
    while [ $# -gt 0 ]; do
        case "$1" in
            -c | --continue | --strict)
                break
                ;;
            *)
                if [ "$_pb_dir_set" = 0 ] && { [ "$1" = . ] || [ -d "$1" ]; }; then
                    _pb_dir="$1"
                    _pb_dir_set=1
                    shift
                else
                    break
                fi
                ;;
        esac
    done
    "$_pb_script" "$_pb_dir" "$@"
}

agent_verify() {
    _packedbox_tmux_guard || return 1
    _pb_script="$(_packedbox_layout_script agent-verify-layout.sh)" || return 1
    _pb_dir="${PWD:-.}"
    _pb_dir_set=0
    _pb_scan=0
    _pb_mutate=0
    _pb_generic=0
    while [ $# -gt 0 ]; do
        case "$1" in
            --scan)
                _pb_scan=1
                shift
                ;;
            --generic)
                _pb_generic=1
                shift
                ;;
            --launch-mutate)
                _pb_mutate=1
                shift
                ;;
            *)
                if [ "$_pb_dir_set" = 0 ] && { [ "$1" = . ] || [ -d "$1" ]; }; then
                    _pb_dir="$1"
                    _pb_dir_set=1
                    shift
                else
                    echo "agent_verify: unknown argument: $1" >&2
                    return 1
                fi
                ;;
        esac
    done
    set -- "$_pb_dir"
    if [ "$_pb_generic" = 1 ]; then
        set -- "$@" --generic
    fi
    if [ "$_pb_scan" = 1 ] && [ "$_pb_mutate" = 1 ]; then
        AGENT_VERIFY_RESCAN=1 AGENT_VERIFY_LAUNCH_MUTATE=1 "$_pb_script" "$@"
    elif [ "$_pb_scan" = 1 ]; then
        AGENT_VERIFY_RESCAN=1 "$_pb_script" "$@"
    elif [ "$_pb_mutate" = 1 ]; then
        AGENT_VERIFY_LAUNCH_MUTATE=1 "$_pb_script" "$@"
    else
        "$_pb_script" "$@"
    fi
}

agent_test() {
    _packedbox_tmux_guard || return 1
    _pb_script="$(_packedbox_layout_script agent-test-layout.sh)" || return 1
    _pb_dir="${PWD:-.}"
    _pb_dir_set=0
    while [ $# -gt 0 ]; do
        case "$1" in
            --watch | --run)
                break
                ;;
            *)
                if [ "$_pb_dir_set" = 0 ] && { [ "$1" = . ] || [ -d "$1" ]; }; then
                    _pb_dir="$1"
                    _pb_dir_set=1
                    shift
                else
                    break
                fi
                ;;
        esac
    done
    "$_pb_script" "$_pb_dir" "$@"
}

agent_back() {
    agent_build -c
}

# Shellyxz UX names (ab / av / at). `at` shadows batch at(1) intentionally.
# Functions (not aliases) so they work in non-interactive bash and `type` finds them.
ab() { agent_build "$@"; }
av() { agent_verify "$@"; }
at() { agent_test "$@"; }
