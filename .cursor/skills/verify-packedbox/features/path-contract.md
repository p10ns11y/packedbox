# PATH contract and fix-path

PATH contract lets a user recover a broken shell PATH and verify the managed order without loading broken rc files.

## Sub-features

- `path-tests` runs the repo PATH contract unit tests.
- `fix-path-apply` applies the contract from `bash --norc`.
- `fix-path-symlink` runs recovery via `~/.local/bin/packedbox-fix-path`.
- `check-path` prints OK/ERROR for the installed core.

## How to get to it (user POV)

- Run `bash tests/path-contract.test.sh` from the repo.
- Run `bash --norc ./installers/fix-path.sh` or `~/.local/bin/packedbox-fix-path`.
- Run `bash ~/.config/packedbox/core/check-path.sh` after install.

## Driving it with bash+tmux

Preconditions:

- Doctor exited 0.
- Non-root shell.
- For install proofs, prefer disposable `HOME=/tmp/pb-verify-$RUN_ID`.

- **Unit tests.** Run `bash tests/path-contract.test.sh && bash tests/fix-path.test.sh`. Exit code `0` and stdout contain `0 failure(s)`.
- **Apply from norc.** Run `bash --norc ./installers/fix-path.sh`. Stdout contains `PATH contract applied` (full line: `packedbox fix-path: PATH contract applied from …`).
- **Symlink recovery.** Covered by `tests/fix-path.test.sh`; after `--install` into disposable HOME, `bash --norc "$HOME/.local/bin/packedbox-fix-path"` must apply without missing `lib/`.
- **Guard still on.** Run `bash packs/terminal/tmux/lib/verify-cmd-guard.sh 'sudo rm -rf /'`. Exit non-zero with `[BLOCKED]`.
- **Proof.** Save stdout to `/opt/cursor/artifacts/verify-packedbox/path-contract.txt`.

## Gotchas

- Cloud agent shells have polluted PATH (`/exec-daemon`, cargo); `check-path` may fail until `bash --norc` + fix-path.
- Never prove fix-path by rewriting the real cloud user's `/etc` or system PATH files.
- `fix-path --install` against the live `$HOME` is allowed only when the user asked to bootstrap this machine.
