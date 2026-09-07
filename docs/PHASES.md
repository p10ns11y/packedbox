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

## Phase 1.5 — Native C legibility baseline **done**

| Task | Status |
|------|--------|
| Status enums, version/help dispatch, warning flags | Done |
| Repo `AGENTS.md` C law + build/test table | Done |
| `tests/cli-smoke.test.sh` | Done |
| `.github/workflows/native-c.yml` | Local file ready; needs `workflow` OAuth scope to publish |

## Phase 2 — Terminal pack **done**

| Task | Source | Target | Status |
|------|--------|--------|--------|
| Ghostty config + theme tokens | arch-machine eye-comfort | `packs/terminal/ghostty/` | Done |
| tmux verify cockpit (selective) | shellyxz `plugins/verification/` | `packs/terminal/tmux/` | Done |
| Neovim theme alignment | eye-comfort `neovim.lua` | `packs/terminal/nvim/` | Done |
| Pack installer | new | `packs/terminal/install.sh` | Done |
| Arch adapter | pacman patterns | `adapters/arch/install.sh` | Done |
| Pack tests | new | `tests/terminal-pack.test.sh` | Done |

**OUT of Phase 2:** wallpaper assets, waybar/yazi, eye-comfort Python timers, cockpit-mcp, full test-discovery stack.

## Phase 3 — packedbox-cli (elomaxz) **done (MVP)**

| Task | Status |
|------|--------|
| FetchContent / local `PACKEDBOX_ELOMAXZ_SOURCE_DIR` | Done |
| `status` / `audit` msgs via `elomaxz_run_batch` | Done |
| write-legible-c adapters around foreign void* ABI | Done |
| Install/maintenance Cmd shell effects | Deferred (Phase 3.1) |

## Phase 4 — packedbox-ui (GTK4) **← next**

| Task | Notes |
|------|-------|
| libadwaita application shell | `native/packedbox-ui/` |
| Wire to shared C core | Same elomaxz state as CLI |

## Phase 5 — Debian + full matrix

- `adapters/debian/`
- CI matrix: Arch, Debian, Ubuntu
- Optional Omarchy preset detection (shellyxz `environments/omarchy/`)
