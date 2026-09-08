# adapters/arch

Arch Linux (+ Omarchy) adapter — PATH kernel bootstrap + optional terminal pack.

**Upstream:** [arch-machine](https://github.com/p10ns11y/arch-machine) `sentinel` — package patterns only (no full module melt).

## Contents

- `install.sh` — pacman prerequisites + deploy `core/` to `~/.config/packedbox`
- Registers `fix-path.sh` as `~/.local/bin/packedbox-fix-path`
- Writes idempotent bashrc managed block for `core/env.sh`
- `--with-terminal` — also installs `tmux` + `neovim` + nerd font, best-effort **Ghostty**, and runs `packs/terminal/install.sh`

### Ghostty (best-effort)

1. `pacman -S ghostty` when the package exists in sync DBs
2. `paru -S ghostty` when `paru` is present
3. `omarchy-install-terminal ghostty` when the Omarchy helper is present

Configs under `~/.config/ghostty` are always deployed by the terminal pack even if the binary install fails.

## Usage

```bash
./adapters/arch/install.sh                 # PATH + recovery
./adapters/arch/install.sh --deps-only
./adapters/arch/install.sh --with-terminal # + tmux/neovim/ghostty + terminal pack
```

### tmux on cloud desktops

Not `tmux -s`. First attach:

```bash
source ~/.config/packedbox/core/env.sh
tn
cd /path/to/project && av
```

Prefer `t` / `tn` so Cursor’s `/exec-daemon/tmux` is not nested. Full keys, helpers, and distro install hints: [packs/terminal/README.md](../../packs/terminal/README.md).

### Cloud / new machines

Pacman packages and `~/.config` installs are per-machine — re-run `./adapters/arch/install.sh --with-terminal` on new machines (or bake into an image).

See [docs/PHASES.md](../../docs/PHASES.md).
