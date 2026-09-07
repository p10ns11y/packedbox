# installers/

Primary bootstrap entry points (ADR-0001).

| Script | Required | Phase |
|--------|----------|-------|
| [install.sh](install.sh) | yes | 1+ |
| [fix-path.sh](fix-path.sh) | yes | 1 |
| `recover-shell.sh` | yes | 1 (from shellyxz) |
| `check-shell.sh` | yes | 1 (from shellyxz) |

When PATH is broken, run `fix-path.sh` or `recover-shell.sh` from a rescue TTY or `bash --norc`.
