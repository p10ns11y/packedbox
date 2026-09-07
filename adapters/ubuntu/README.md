# adapters/ubuntu

Ubuntu adapter — **Phase 1** PATH kernel bootstrap.

## Contents

- `install.sh` — apt prerequisites (bash, curl, git, shellcheck) + deploy `core/` to `~/.config/packedbox`
- Registers `fix-path.sh` as `~/.local/bin/packedbox-fix-path`
- Writes idempotent bashrc managed block for `core/env.sh`

## Usage

```bash
./adapters/ubuntu/install.sh           # full bootstrap
./adapters/ubuntu/install.sh --deps-only
```

See [docs/PHASES.md](../../docs/PHASES.md).
