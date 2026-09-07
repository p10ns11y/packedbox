# packedbox phases

High-level delivery plan. Phase 0 is **scaffold + docs only** — no large upstream melt.

## Phase 0 — Scaffold (done)

| Deliverable | Status |
|-------------|--------|
| README, ADR-0001, PULL-INVENTORY, PHASES | Done |
| Directory scaffold (`core/`, `adapters/`, `packs/`, `installers/`, `native/`) | Done |
| Stub installers + native CMake placeholders | Done |
| `tools/harness/skills/packedbox` agent skill | Done |
| Source repos shellyxz.sh + arch-machine **not deleted** | Policy |

## Phase 1 — PATH + recover + fix-path (Ubuntu CI) **done**

**Goal:** Ship the shellyxz PATH contract and recovery story on Ubuntu with CI proof.

| Task | Source | Target | Status |
|------|--------|--------|--------|
| Pull PATH contract v2 | shellyxz `core/path.contract`, `core/path.sh`, `core/path-resolve.sh` | `core/` | Done |
| Pull recovery flow | shellyxz `bin/recover-shell.sh` | `core/recover.sh` | Done |
| Implement `fix-path.sh` | ADR-0001 requirement | `installers/fix-path.sh` | Done |
| Ubuntu adapter bootstrap | new | `adapters/ubuntu/install.sh` | Done |
| CI | new | `.github/workflows/ubuntu-path.yml` | Done |

**Exit criteria**

- `fix-path.sh` works from a clean `bash --norc` session on Ubuntu 24.04
- CI green on PRs touching `core/` or `installers/fix-path.sh`
- No Arch/Debian adapter work required yet

## Phase 1.5 — Native C legibility baseline **← current**

**Goal:** Make `native/packedbox-cli` and `native/packedbox-ui` write-legible-c conforming before elomaxz/GTK work.

| Task | Status |
|------|--------|
| Status enums, version/help dispatch, warning flags | Done |
| Repo `AGENTS.md` C law + build/test table | Done |
| `tests/cli-smoke.test.sh` + `.github/workflows/native-c.yml` | Done |
| FetchContent elomaxz | Deferred to Phase 3 |
| GTK4 shell | Deferred to Phase 4 |

## Phase 2 — Terminal pack

| Task | Source | Target |
|------|--------|--------|
| Ghostty config + theme tokens | arch-machine `modules/productivity/eye-comfort` | `packs/terminal/ghostty/` |
| tmux verify cockpit | shellyxz `plugins/verification/` | `packs/terminal/tmux/` |
| Neovim theme alignment | both | `packs/terminal/nvim/` |
| Arch adapter | arch-machine `install.sh` patterns | `adapters/arch/` |

## Phase 3 — packedbox-cli (elomaxz)

| Task | Notes |
|------|-------|
| FetchContent elomaxz in CMake | See arch-machine integration plans |
| Model install/maintenance/audit msgs | Replace ad-hoc bash state |
| `packedbox` CLI binary | `native/packedbox-cli/` |

## Phase 4 — packedbox-ui (GTK4)

| Task | Notes |
|------|-------|
| libadwaita application shell | `native/packedbox-ui/` |
| Wire to shared C core | Same elomaxz state as CLI |

## Phase 5 — Debian + full matrix

- `adapters/debian/`
- CI matrix: Arch, Debian, Ubuntu
- Optional Omarchy preset detection (shellyxz `environments/omarchy/`)
