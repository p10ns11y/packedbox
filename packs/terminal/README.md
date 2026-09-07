# packs/terminal

Ghostty + tmux + Neovim terminal pack (Phase 2).

| Component | Upstream | Pulled |
|-----------|----------|--------|
| Ghostty | arch-machine `modules/productivity/eye-comfort` | `fragment.conf`, `roles.json`, four theme `ghostty.conf` |
| tmux | shellyxz `plugins/verification/` | conf examples, keymaps, layout bins/libs (paths adapted) |
| Neovim | eye-comfort themes | standalone `colors.lua` + lazy `neovim.lua` + hotreload |

**OUT:** wallpaper JPGs, waybar/yazi units, full eye-comfort Python stack, verification docs images, cockpit-mcp.

## Layout

```
ghostty/          # fragment + themes + roles.json
tmux/             # conf/, bin/, lib/, data/
nvim/             # themes/<id>/{colors.lua,neovim.lua} + hotreload
install.sh        # deploy pack + wire ~/.config/{ghostty,tmux,nvim}
```

## Install

```bash
# from repo root
./packs/terminal/install.sh
PACKEDBOX_THEME=eye-comfort-light ./packs/terminal/install.sh
```

One-shot per distro:

```bash
./adapters/ubuntu/install.sh --with-terminal
./adapters/debian/install.sh --with-terminal
./adapters/arch/install.sh --with-terminal
```

Neovim gets a **standalone** `~/.config/nvim/colors/packedbox.lua` plus a managed block in `init.lua` (`colorscheme packedbox`). No lazy.nvim required — stock apt/pacman nvim is themed. The `lua/plugins/packedbox-theme.lua` lazy spec is still installed for LazyVim users and is a no-op without a plugin manager.

See the theme: `nvim .` (or `nvim -c Explore`) after install — dark eye-comfort by default (`PACKEDBOX_THEME=eye-comfort-dark`).

## Usage

Prefer **Ghostty** when available (`ghostty`). First attach (not `tmux -s`):

```bash
source ~/.config/packedbox/core/env.sh   # or a new bash login shell
tn                                      # new -s packedbox (attach if exists)
cd /path/to/project && av               # verify; or at / ab
t ls                                    # packedbox tmux wrapper (≡ pb_tmux)
```

Cheat sheet: `t` · `tn` · `av`. Re-attach: `tn` (or `t attach -t packedbox`).

You must be **inside** the `packedbox` tmux session (status bar shows `[packedbox]` and a dim `C-b`). A bare Ghostty/xfce shell has no Prefix.

Prefix = **Ctrl-b** (status shows `C-b`; `PREFIX` lights when the key arrives). **Ctrl-Space** is optional `prefix2` (often swallowed by browser/IME on cloud desktops).

| Key / command | Layout |
|---------------|--------|
| `av` or `Prefix+V` (Shift+v) | verify cockpit |
| `ab` or `Prefix+B` (Shift+b) | agent build |
| `at` or `Prefix+T` (Shift+t) | test cockpit |

On Cursor cloud desktops: if Ctrl-b never lights `PREFIX`, type **`av` / `ab` / `at`** — that is the supported path when the remote viewer eats chords.

Helpers (`t` / `tn` / `av` / `ab` / `at` / `pb_tmux` / `pb`) come from `core/tmux-workflow.sh`, sourced by `core/env.sh`. Outside tmux, helpers print `run: tn  (then <helper>)`.

Optional pane tools use os-release install hints (Ubuntu `apt` / Arch `pacman`; lazygit on Debian/Ubuntu prefers `go install`).

Script fallbacks (same layouts): `~/.config/packedbox/packs/terminal/tmux/bin/agent-*-layout.sh`.
