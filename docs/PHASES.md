# packedbox Phases 0–6

Delivery roadmap for melting shellyxz + arch-machine portable cores into a multi-distro bootstrap.

| Phase | Focus | Exit criteria |
|-------|-------|---------------|
| **0** | Docs, ADRs, scaffold | This PR merged; no large code melt |
| **1** | PATH + recover + fix-path | Ubuntu CI green on PATH contract tests |
| **2** | Debian adapter (Triexe) | `install.sh` works on Debian with generic env |
| **3** | Terminal pack | Ghostty + tmux + nvim configs install on Arch |
| **4** | packedbox-cli | C CLI builds; `packedbox doctor` runs |
| **5** | packedbox-ui | GTK4 settings app builds (optional install) |
| **6** | Hardening + optional verification | Cross-distro matrix; tmux cockpit templates |

---

## Phase 0 — Scaffold (current)

**Goal:** Align naming (`packedbox`, not boxy), document decisions, stub directory layout.

**Deliverables:**

- [README.md](../README.md) — product scope, v1 tree, OUT list
- [ADR-0001-tech-stack.md](ADR-0001-tech-stack.md) — elomaxz CLI, GTK4 UI, shell installers
- [PULL-INVENTORY.md](PULL-INVENTORY.md) — KEEP/COPY/REWRITE/OUT per file
- Empty scaffold: `core/`, `adapters/`, `packs/terminal/`, `installers/`, `native/`

**Non-goals:** Copying shellyxz or arch-machine code; CI beyond markdown lint.

---

## Phase 1 — PATH + recover + fix-path (next)

**Goal:** Portable shell kernel works on **Ubuntu** with automated CI — the first non-Arch proof point.

**Scope:**

1. **KEEP** from shellyxz: `core/path.contract`, `path.sh`, `path-resolve.sh`, `env.sh`, `tool.contract`
2. **KEEP** tooling: `recover-shell.sh`, `check-shell.sh`, migrate-common patterns
3. **`installers/fix-path.sh`** — required idempotent PATH repair (ADR-0001)
4. **`adapters/ubuntu/`** — real apt hooks for core deps (not just stub)
5. **CI:** GitHub Actions on `ubuntu-latest`:
   - Run `path-contract.test.sh`, `strict-path.test.sh`
   - Simulate broken PATH → `fix-path.sh` → `check-shell.sh` passes

**Exit criteria:**

- Ubuntu CI badge green on main
- Documented recovery path in README matches tested scripts

---

## Phase 2 — Debian (Triexe)

**Goal:** Second adapter validates apt-based mapping independent of Ubuntu CI shortcuts.

**Scope:**

- `adapters/debian/` — Triexe-oriented package names where they diverge
- `core/environments/generic` default on Debian CI
- Shared adapter interface documented (shell functions: `adapter_install`, `adapter_packages`)

**Exit criteria:**

- Debian container/job passes PATH tests + minimal install dry-run

---

## Phase 3 — Terminal pack

**Goal:** Ship Ghostty + tmux + Neovim as `packs/terminal/` with Arch-first install.

**Scope:**

- COPY KEEP paths from arch-machine eye-comfort (ghostty fragments, nvim hot-reload, tmux cockpit)
- `adapters/arch/` — paru/pacman package list for terminal tools
- Optional Omarchy theme hooks

**Exit criteria:**

- `./installers/install.sh --pack terminal` on Arch installs configs
- tmux verification layout launches (manual or scripted smoke)

---

## Phase 4 — packedbox-cli

**Goal:** Native C CLI via elomaxz + CMake FetchContent.

**Scope:**

- `native/packedbox-cli/` — CMake project, pinned elomaxz tag
- Commands: `doctor`, `status`, `pack list|enable|disable` (read-only first)
- CI: compile on Ubuntu + Arch containers

**Exit criteria:**

- `packedbox doctor` reports PATH contract health
- No regression on shell-only install path

---

## Phase 5 — packedbox-ui

**Goal:** Optional GTK4/libadwaita settings UI (ADR-0001 blast radius accepted).

**Scope:**

- `native/packedbox-ui/` — pack toggles, PATH status display
- Separate CI job with `libgtk-4-dev`, `libadwaita-1-dev`

**Exit criteria:**

- UI builds and launches on Ubuntu + Omarchy/GNOME
- Headless install path unchanged

---

## Phase 6 — Hardening

**Goal:** Production-quality multi-distro matrix and optional agent verification templates.

**Scope:**

- Cross-distro CI matrix (Arch, Debian, Ubuntu)
- OPTIONAL: shellyxz/arch-machine verification tmux templates under `packs/terminal/tmux/`
- Performance and idempotency audits on `install.sh` / `fix-path.sh`

**Exit criteria:**

- Documented support matrix matches CI
- No open P0 PATH/recovery bugs

---

## Naming note

The working title **boxy** is retired. All user-facing names, binaries, and paths use **packedbox** (`packedbox-cli`, `packedbox-ui`).
