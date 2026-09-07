# ~/.config/tmux/verify.conf
# Verification workflow overlay — included from ~/.config/tmux/tmux.conf
# Managed by packedbox packs/terminal
#
# INSTALL / REFRESH (not sourced in zsh — tmux loads this file):
#   ~/.config/packedbox/packs/terminal/tmux/bin/sync-tmux-verify.sh
#   then inside tmux: Prefix+q  (Ctrl-b, then q — or Ctrl-Space, then q)
#
# PREFIX (Ubuntu / default packedbox):
#   prefix  = Ctrl-b     (always; usable on cloud desktops and plain terminals)
#   prefix2 = Ctrl-Space (Omarchy-friendly optional second prefix)
# Prefer: /usr/bin/tmux -f ~/.config/tmux/tmux.conf
#   (or: pb_tmux) so Cursor /exec-daemon/tmux is not used by mistake.
#
# WORKFLOW KEYS — SHIFTED letters (match shell aliases ab / av / at):
#   Prefix+B   agent build   — Shift+b  (lowercase b is NOT bound here)
#   Prefix+V   verify cockpit — Shift+v  (lowercase v = vertical split, unchanged)
#   Prefix+T   test cockpit   — Shift+t
#   Prefix+?   keymap menu (or click status-right)
#   Prefix+Z   zoom pane
#   Prefix+Space  cycle layout
#   Prefix+q   reload ~/.config/tmux/tmux.conf
#
# Shell helpers (sourced from core/env.sh → core/tmux-workflow.sh):
#   ab / agent_build    → agent-build-layout.sh
#   av / agent_verify   → agent-verify-layout.sh
#   at / agent_test     → agent-test-layout.sh
#
# SPLITS (stock tmux defaults unless your host tmux.conf overrides):
#   Prefix+%   split vertical (pane right)
#   Prefix+"   split horizontal (pane below)

# Workflow labels (set by agent-build / agent-verify layout scripts)
# @workflow_mode is build | verify | empty. @workflow_dir holds the project path.
# Mode bar (PREFIX/COPY/INSERT/NORMAL/ZOOM): tmux.status-mode.conf.ex + tmux-mode-sync.sh
set -g @workflow_status on
set -g @workflow_mode ''

# Explicit prefix story — Ctrl-b always; Ctrl-Space as optional second prefix.
set -g prefix C-b
set -g prefix2 C-Space
bind C-b send-prefix
bind C-Space send-prefix -2

source-file ~/.config/packedbox/packs/terminal/tmux/conf/tmux.status-mode.conf.ex

# Keymap helper — Prefix+? or click status-right
bind ? run-shell '~/.config/packedbox/packs/terminal/tmux/bin/tmux-keymap-menu.sh'
bind -n MouseDown1StatusRight run-shell '~/.config/packedbox/packs/terminal/tmux/bin/tmux-keymap-menu.sh'

# Reload config (Prefix+q) — matches keymap menu / shellyxz docs
bind q source-file ~/.config/tmux/tmux.conf \; display-message 'tmux.conf reloaded'

# Zoom active pane (Prefix+Z) — ad-hoc full width inside any window
bind Z resize-pane -Z

# Cycle layouts (Prefix+Space) — golden φ on verify window, tmux next-layout elsewhere
bind Space run-shell '~/.config/packedbox/packs/terminal/tmux/bin/tmux-cycle-layout.sh'

# Agent build (Prefix+B) — ab / agent_build
bind B run-shell '~/.config/packedbox/packs/terminal/tmux/bin/agent-build-layout.sh "#{pane_current_path}"'

# Verification cockpit (Prefix+V) — av / agent_verify
bind V run-shell '~/.config/packedbox/packs/terminal/tmux/bin/agent-verify-layout.sh "#{pane_current_path}"'

# Test cockpit (Prefix+T) — at / agent_test
bind T run-shell '~/.config/packedbox/packs/terminal/tmux/bin/agent-test-layout.sh "#{pane_current_path}"'
