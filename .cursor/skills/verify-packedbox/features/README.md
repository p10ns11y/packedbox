# packedbox verification map

Maintained source for verifying user-facing packedbox behavior. Read this index before driving; use the matching feature file as the recipe.

## Baseline preconditions

- Work from a packedbox git checkout (`core/path.contract` present).
- Run as **non-root**.
- Run `bash .cursor/skills/verify-packedbox/scripts/doctor.sh` and require exit 0 before the first drive.
- Prefer `/usr/bin/tmux` via `tn` / `pb_tmux` (avoid Cursor `/exec-daemon/tmux`).
- Never enable `av --launch-mutate` on a shared cloud agent unless the deny-list still passes and the user explicitly asked for a mutation proof.
- Never run deny-listed commands (sudo, recursive rm, disk wipe, pipe-to-shell, host teardown).

## Driving conventions

- Start recipes from repo root unless preconditions say otherwise.
- Treat every command as literal; keep quoted paths unchanged.
- Terminal actions run in a tmux session this run created (`verify-pb-$RUN_ID`) or via allowlisted `bash tests/*.test.sh`.
- Restore disposable `$HOME` fixtures after mutation proofs; keep proof artifacts.

## Proof and skip reporting

- Capture the user action and the resulting state (exit code + stdout and/or pane capture).
- CLI/test proof includes command, stdout, stderr, exit code.
- TUI proof includes pane titles and `tmux capture-pane` (and optional screenshot).
- Record the feature ID with every artifact under `/opt/cursor/artifacts/verify-packedbox/`.
- Report unreachable paths with the unmet precondition (e.g. no display for GTK).

## Feature entry contract

Each feature file: H1 + one paragraph, then exactly `Sub-features`, `How to get to it (user POV)`, `Driving it with bash+tmux`, `Gotchas`.

## Features

- [PATH contract and fix-path](./path-contract.md) — recovery and contract verify.
- [Terminal pack and verify cockpit](./terminal-verify-cockpit.md) — `tn` / `av` / nvim theme panes.
- [packedbox CLI status and audit](./cli-status-audit.md) — C CLI read-only status surface.

Sibling cockpits `at` / `ab` exist in `core/tmux-workflow.sh` but are not separate feature files yet (drive via terminal pack README if needed). `core/recover.sh` is covered indirectly by fix-path docs; add a dedicated feature if recovery-menu UX grows.
