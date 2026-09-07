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
