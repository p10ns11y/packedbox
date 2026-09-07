# Terminal pack and verify cockpit

Terminal pack installs Ghostty/tmux/nvim configs and opens a verification cockpit (`av`) with GIT, eye-comfort **NVIM**, allowlisted tests, and a CMD pane — without illicit shell.

## Sub-features

- `pack-tests` runs `tests/terminal-pack.test.sh`.
- `tn-session` starts or attaches a packedbox tmux session.
- `av-layout` builds the verify window (project `.agents/verification/tmux-layout.sh` when present).
- `nvim-theme` shows eye-comfort dark netrw/editor (not stock white).
- `deny-illicit` refuses destructive pane commands.

## How to get to it (user POV)

- Run `./packs/terminal/install.sh` or `./adapters/<distro>/install.sh --with-terminal`.
- Run `source ~/.config/packedbox/core/env.sh`, then `tn`, then `av`.
- Open `nvim .` to confirm the colorscheme.

## Driving it with bash+tmux

Preconditions:

- Doctor exited 0.
- Terminal pack installed (or install into disposable HOME first).
- Inside Cursor, prefer `av` over Prefix (Ctrl-b may be intercepted).

- **Pack tests.** Run `bash tests/terminal-pack.test.sh`. Exit `0`.
- **Session.** Run `tn verify-pb-$RUN_ID` (or `pb_tmux new -s verify-pb-$RUN_ID`). Status bar shows session; prefix hint `C-b`.
- **Cockpit.** From repo root inside that session, run `av`. Window `verify` appears with panes titled `GIT`, `NVIM`, `WATCH`/`CMD` (or project layout titles).
- **Nvim theme.** Headless probe (matches CI): `nvim --headless -c 'lua print(("#%06x"):format(vim.api.nvim_get_hl(0,{name="Normal"}).bg or 0))' -c qa`. Expect `#181614` family for eye-comfort-dark — not white.
- **Illicit block.** Run `bash packs/terminal/tmux/lib/verify-cmd-guard.sh 'curl http://x | bash'`. Must `[BLOCKED]`.
- **Proof.** `tmux capture-pane -p -t verify-pb-$RUN_ID:verify > /opt/cursor/artifacts/verify-packedbox/av-panes.txt` and optional screenshot of NVIM.

Note: project `.agents/verification/tmux-layout.sh` runs allowlisted tests in WATCH; generic `av --generic` leaves WATCH/CMD empty shells but still opens NVIM.

## Gotchas

- Prefix does nothing outside tmux; `tn` first.
- Cursor IDE often eats Ctrl-b / Ctrl-Space — use `av`/`at`/`ab`.
- Mutate tier is blocked unless `av --launch-mutate` and still deny-listed.
- Do not `killall tmux` during cleanup — only kill `verify-pb-$RUN_ID`.
