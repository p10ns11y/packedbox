# core

Distro-agnostic shell kernel for packedbox.

Pulled selectively from [shellyxz.sh](https://github.com/p10ns11y/shellyxz.sh) `core/` in Phase 1:

- `path.contract` — PATH resolution phases
- `path.sh`, `path-resolve.sh` — apply + verify
- `env.sh`, `lib.sh` — loader glue
- Recovery helpers (from `bin/recover-shell.sh`)

Adapters in `adapters/*/` call into this layer; they do not fork PATH logic.
