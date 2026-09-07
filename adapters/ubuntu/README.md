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

Prefer **Ghostty** when the binary is installed (`ghostty`).

### tmux on cloud desktops

Prefer the distro binary so Cursor’s `/exec-daemon/tmux` is not nested by mistake:

```bash
/usr/bin/tmux -f ~/.config/tmux/tmux.conf
# or after env loads (helpers from core/tmux-workflow.sh):
pb_tmux new -s packedbox
```

Prefix is **Ctrl-b** (also **Ctrl-Space** as `prefix2`). Layouts must run **inside** tmux — Prefix binds or shellyxz-style helpers after `source ~/.config/packedbox/core/env.sh` (or a new shell):

| Key / command | Layout |
|---------------|--------|
| `Prefix+V` or `av` | verify cockpit |
| `Prefix+B` or `ab` | agent build |
| `Prefix+T` or `at` | test cockpit |

Script fallbacks: `~/.config/packedbox/packs/terminal/tmux/bin/agent-*-layout.sh`.

### Cloud / new machines

Repo and installer changes persist via git. Apt packages and `~/.config` installs are per-machine — re-run `./adapters/ubuntu/install.sh --with-terminal` on new cloud agents (or bake into an environment snapshot).

See [docs/PHASES.md](../../docs/PHASES.md).
