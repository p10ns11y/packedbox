# packs/terminal

Ghostty + tmux + Neovim terminal pack (Phase 2).

| Component | Upstream | Pulled |
|-----------|----------|--------|
| Ghostty | arch-machine `modules/productivity/eye-comfort` | `fragment.conf`, `roles.json`, four theme `ghostty.conf` |
| tmux | shellyxz `plugins/verification/` | conf examples, keymaps, layout bins/libs (paths adapted) |
| Neovim | eye-comfort themes | four `neovim.lua` + hotreload helper |

**OUT:** wallpaper JPGs, waybar/yazi units, full eye-comfort Python stack, verification docs images, cockpit-mcp.

## Layout

```
ghostty/          # fragment + themes + roles.json
tmux/             # conf/, bin/, lib/, data/
nvim/             # themes/ + omarchy-theme-hotreload.lua
install.sh        # deploy pack + wire ~/.config/{ghostty,tmux,nvim}
```

## Install

```bash
# from repo root
./packs/terminal/install.sh
PACKEDBOX_THEME=eye-comfort-light ./packs/terminal/install.sh
```

Arch one-shot: `./adapters/arch/install.sh --with-terminal`  
Ubuntu one-shot: `./adapters/ubuntu/install.sh --with-terminal`

## Usage

Prefer **Ghostty** when available (`ghostty`). First attach (not `tmux -s`):

```bash
source ~/.config/packedbox/core/env.sh   # or a new bash login shell
tn                                      # ≡ pb_tmux new -s packedbox (attach if exists)
cd /path/to/project && av               # verify; or at / ab
```

Re-attach: `tn` (or `pb attach -t packedbox`).

Prefix = **Ctrl-b** (also **Ctrl-Space** / `prefix2`). Layouts require that session:

| Key / command | Layout |
|---------------|--------|
| `Prefix+V` or `av` | verify cockpit |
| `Prefix+B` or `ab` | agent build |
| `Prefix+T` or `at` | test cockpit |

Helpers (`tn` / `av` / `ab` / `at` / `pb_tmux` / `pb`) come from `core/tmux-workflow.sh`, sourced by `core/env.sh`. Outside tmux, `av` prints: `run: tn  (then av)`.

Optional pane tools use os-release install hints (Ubuntu `apt` / Arch `pacman`; lazygit on Debian/Ubuntu prefers `go install`).

Script fallbacks (same layouts): `~/.config/packedbox/packs/terminal/tmux/bin/agent-*-layout.sh`.
