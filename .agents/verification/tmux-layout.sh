#!/usr/bin/env bash
# packedbox project verification cockpit — allowlisted panes only.
# Invoked by packs/terminal agent-verify-layout when present and executable.
set -euo pipefail

DIR="${1:-.}"
DIR="$(cd "$DIR" && pwd)"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PACK_TMUX="${HOME}/.config/packedbox/packs/terminal/tmux"
if [[ ! -d "$PACK_TMUX" ]]; then
    PACK_TMUX="$ROOT/packs/terminal/tmux"
fi

# shellcheck source=/dev/null
source "$PACK_TMUX/lib/verify-launch.sh"
# shellcheck source=/dev/null
source "$PACK_TMUX/lib/verify-layout.sh"
# shellcheck source=/dev/null
source "$PACK_TMUX/lib/verify-cmd-guard.sh"

SESSION="$(tmux display-message -p '#{session_name}')"
verify_set_workflow_dir "$SESSION" "$DIR" >/dev/null
tmux set-option -t "$SESSION" @workflow_mode verify

if ! verify_layout_ok "$SESSION"; then
    verify_layout_build_golden_grid "$SESSION" "$DIR" 1

    if command -v lazygit >/dev/null 2>&1; then
        verify_launch_pane 'verify.0' monitor 'GIT' "$DIR" lazygit
    else
        verify_launch_pane 'verify.0' monitor 'GIT' "$DIR" \
            "echo 'install lazygit (optional: go install github.com/jesseduffield/lazygit@latest)'"
    fi

    if command -v nvim >/dev/null 2>&1; then
        verify_launch_pane 'verify.1' monitor 'NVIM' "$DIR" "nvim $(printf '%q' "$DIR")"
    else
        verify_launch_pane 'verify.1' monitor 'NVIM' "$DIR" \
            "echo 'nvim not installed'"
    fi

    # Allowlisted test slice only — never arbitrary shell from the map.
    SAFE_TESTS='bash tests/path-contract.test.sh && bash tests/terminal-pack.test.sh'
    verify_cmd_guard "$SAFE_TESTS"
    verify_launch_pane 'verify.2' monitor 'WATCH' "$DIR" "$SAFE_TESTS"

    verify_launch_pane 'verify.3' monitor 'CMD' "$DIR" \
        "echo 'packedbox verify CMD — allowlisted: check-path | packedbox status | bash tests/*.test.sh'"
fi

tmux select-pane -t 'verify.3'
tmux display-message -d 3000 'packedbox verify: GIT|NVIM|tests|CMD (deny-listed illicit cmds)'
