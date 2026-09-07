# adapters/ubuntu

Ubuntu adapter — PATH kernel bootstrap + optional terminal pack.

## Contents

- `install.sh` — apt prerequisites + deploy `core/` to `~/.config/packedbox`
- Registers `fix-path.sh` as `~/.local/bin/packedbox-fix-path`
- Writes idempotent bashrc managed block for `core/env.sh`
- `--with-terminal` — also installs `tmux` + `neovim`, best-effort **Ghostty**, and runs `packs/terminal/install.sh`

### Ghostty (best-effort)

Ubuntu apt ships Ghostty starting with **26.04**. On older releases the adapter tries, in order:

1. `apt install ghostty` when the package is available
2. `snap install ghostty --classic` when `snap` is present ([Ghostty docs](https://ghostty.org/docs/install/binary))
3. Community `.deb` from [mkasberg/ghostty-ubuntu](https://github.com/mkasberg/ghostty-ubuntu) for 24.04 / 26.04

Configs under `~/.config/ghostty` are always deployed by the terminal pack even if the binary install fails.

## Usage

```bash
./adapters/ubuntu/install.sh                 # PATH + recovery
./adapters/ubuntu/install.sh --deps-only
./adapters/ubuntu/install.sh --with-terminal # + tmux/neovim/ghostty + terminal pack
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

Apt packages and `~/.config` installs are per-machine — re-run `./adapters/ubuntu/install.sh --with-terminal` on new cloud agents (or bake into an environment snapshot).

See [docs/PHASES.md](../../docs/PHASES.md).
