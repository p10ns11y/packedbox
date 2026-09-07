---
name: verify-packedbox
description: "Drive packedbox the way a user does — PATH recovery, terminal pack (tn/av/nvim), and CLI status/audit — with a hard deny-list so illicit or machine-breaking commands never run. Use when proving packedbox install/verify behavior on Ubuntu/Debian/Arch or cloud agents."
---

# verify-packedbox

Scripted verification for **packedbox** (PATH contract, adapters, terminal pack, C CLI). Agents read this cold mid-task.

## Security (non-negotiable)

Verification is **defensive by default**. It must never break a shared cloud machine.

**Never run** (blocked by `packs/terminal/tmux/lib/verify-cmd-guard.sh` before pane launch):

- `sudo` / `su` / `doas`
- Recursive `rm`, `mkfs`, `wipefs`, `shred`, raw `dd`
- `reboot` / `shutdown` / `halt` / `poweroff`
- `curl|sh` / `wget|sh` and fork bombs
- Writes into `/etc`, `chmod 777 /`, firewall flush, `docker system prune`, force-push to `main`/`master`

**Allowlisted drives only:**

- `bash tests/*.test.sh` from the repo root
- `bash ~/.config/packedbox/core/check-path.sh` (after `bash --norc` + `packedbox-fix-path` when needed)
- `./installers/fix-path.sh` / `packedbox-fix-path` (recovery apply — not `--install` unless in disposable `$HOME`)
- `packedbox status` / `packedbox audit` / `--help` / `--version`
- `tn` / `av` / `at` / `ab` layout helpers; `nvim` explore (read)
- `shellcheck` on repo paths listed in CI

**Mutate tier** (`av --launch-mutate`) stays off unless explicitly opted in — and still passes the deny-list.

Never drive as **root**. Never kill processes by name; only tear down tmux sessions **this run created**.

## Launch

No long-lived server. Short-lived CLI/TUI drives in isolated tmux sessions.

```bash
cd /workspace   # or packedbox checkout
source ~/.config/packedbox/core/env.sh   # if missing: ./adapters/ubuntu/install.sh --with-terminal
bash .cursor/skills/verify-packedbox/scripts/doctor.sh
```

Ready when doctor exits 0. Teardown: `tmux kill-session -t verify-pb-$RUN_ID` (only sessions you created).

For a fresh PATH/install proof, use a disposable home:

```bash
export HOME=/tmp/pb-verify-$RUN_ID
mkdir -p "$HOME"
# then adapter --with-terminal or fix-path --install under that HOME only
```

## Doctor

```bash
bash .cursor/skills/verify-packedbox/scripts/doctor.sh
```

Answers: non-root, checkout looks like packedbox, fix-path available, deny-guard blocks illicit sample, tmux present.

## Drive

Harness = **bash** + **tmux** (`/usr/bin/tmux` via `tn` / `pb_tmux`). Prefer `av`/`at`/`ab` over Prefix keys inside Cursor (IDE often eats Ctrl-b).

| Action | Command |
|--------|---------|
| Start session | `tn verify-pb-$RUN_ID` or `pb_tmux new -s verify-pb-$RUN_ID` |
| Verify cockpit | `cd <repo> && av` (opens GIT \| **NVIM** \| WATCH \| CMD; project layout under `.agents/verification/`) |
| PATH tests | `bash tests/path-contract.test.sh` |
| Terminal pack tests | `bash tests/terminal-pack.test.sh` |
| CLI | `./native/packedbox-cli/build/packedbox status` (build first if missing) |
| Guard check | `bash packs/terminal/tmux/lib/verify-cmd-guard.sh 'sudo rm -rf /'` → must fail |

Stable handles: session name `verify-pb-*`, pane titles `GIT` / `NVIM` / `WATCH` / `CMD`, test script paths under `tests/`.

## Evidence

Proof lives under `/opt/cursor/artifacts/verify-packedbox/` (or repo `artifacts/verify-packedbox/` if that dir is used). **Cleanup never deletes evidence.**

Capture:

- Command + stdout/stderr + exit code for CLI/tests
- `tmux capture-pane -p -t verify-pb-$RUN_ID:verify` after `av`
- Optional screenshot of Ghostty/nvim eye-comfort theme
- Side effects: files under disposable `$HOME/.config/packedbox` only

Proof standards: real user path (`tn` → `av`, or documented test scripts); action + resulting state; no internal test-only setters; mocks only at production boundaries (none required for PATH/tmux).

## Cleanup

```bash
# only sessions this run created
tmux has-session -t "verify-pb-$RUN_ID" 2>/dev/null && tmux kill-session -t "verify-pb-$RUN_ID"
# disposable HOME scratch (never /home/ubuntu production configs unless you created a temp HOME)
# rm -rf "/tmp/pb-verify-$RUN_ID"   # only if you created it for this run
```

Do **not** `killall tmux` / `pkill nvim`. Leave `/opt/cursor/artifacts/verify-packedbox/` intact.

## Helpers

| Script | Invocation |
|--------|------------|
| Doctor | `bash .cursor/skills/verify-packedbox/scripts/doctor.sh` |
| Deny guard | `bash packs/terminal/tmux/lib/verify-cmd-guard.sh '<cmd>'` |
| Project cockpit | `.agents/verification/tmux-layout.sh` (auto via `av` when executable) |

## Feature map

See [features/README.md](features/README.md).
