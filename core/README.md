# core

Distro-agnostic shell kernel for packedbox.

Pulled from [shellyxz.sh](https://github.com/p10ns11y/shellyxz.sh) `core/` in Phase 1:

| File | Role |
|------|------|
| `path.contract` | PATH resolution phases (v2) |
| `path.sh`, `path-resolve.sh` | Apply, verify, dedupe |
| `env.sh`, `lib.sh` | Loader glue |
| `tmux-workflow.sh` | Thin `ab` / `av` / `at` + `pb_tmux` (sourced from `env.sh`) |
| `tool.contract` | Command pins + shadow warnings |
| `recover.sh` | Recovery when rc files break |
| `check-path.sh` | PATH contract verification |

Installed to `~/.config/packedbox/` by `installers/fix-path.sh --install` or `adapters/ubuntu/install.sh`.

Adapters in `adapters/*/` call into this layer; they do not fork PATH logic.
