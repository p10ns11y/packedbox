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
3. Community `.deb` from [mkasberg/ghostty-ubuntu](https://github.com/mkasberg/ghostty-ubuntu) (linked from Ghostty’s install page) for 24.04 / 26.04

Configs under `~/.config/ghostty` are always deployed by the terminal pack even if the binary install fails.

## Usage

```bash
./adapters/ubuntu/install.sh                 # PATH + recovery
./adapters/ubuntu/install.sh --deps-only
./adapters/ubuntu/install.sh --with-terminal # + tmux/neovim/ghostty + terminal pack
```

See [docs/PHASES.md](../../docs/PHASES.md).
