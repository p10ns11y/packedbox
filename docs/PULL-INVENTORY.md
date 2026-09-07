# Pull Inventory — shellyxz.sh + arch-machine → packedbox

File-level decisions for melting portable cores into packedbox. Generated during Phase 0 from live repo trees via `gh api` (2026-09-07).

| Repo | Default branch | Tree size |
|------|----------------|-----------|
| [p10ns11y/shellyxz.sh](https://github.com/p10ns11y/shellyxz.sh) | `master` | ~221 paths |
| [p10ns11y/arch-machine](https://github.com/p10ns11y/arch-machine) | `sentinel` | ~578 paths |

**Legend:** **KEEP** = copy/adapt with minimal changes · **COPY** = duplicate subset or pattern · **REWRITE** = reimplement idea, new code · **OUT** = do not import · **OPTIONAL** = may land in later phase

---

## shellyxz.sh (`master`)

### KEEP — core kernel

| Path | packedbox target | Notes |
|------|------------------|-------|
| `core/path.contract` | `core/path.contract` | Authoritative PATH layer spec |
| `core/path-resolve.sh` | `core/path-resolve.sh` | Resolver implementation |
| `core/path.sh` | `core/path.sh` | Layer application |
| `core/env.sh` | `core/env.sh` | Environment bootstrap |
| `core/tool.contract` | `core/tool.contract` | Tool init manifest contract |
| `core/lib.sh` | `core/lib.sh` | Shared shell helpers |
| `core/aliases.sh` | `core/aliases.sh` | Portable aliases (review trim) |
| `core/functions.sh` | `core/functions.sh` | Portable functions (review trim) |

### KEEP — migrate / recover

| Path | packedbox target | Notes |
|------|------------------|-------|
| `bin/migrate.sh` | `installers/` (integrate) | Primary bootstrap; merge into `install.sh` flow Phase 1 |
| `bin/lib/migrate-common.sh` | `installers/lib/migrate-common.sh` | Shared migrate helpers |
| `bin/recover-shell.sh` | `installers/recover-shell.sh` | Recovery entry |
| `bin/check-shell.sh` | `installers/check-shell.sh` | Post-install validation |

### KEEP — environments

| Path | packedbox target | Notes |
|------|------------------|-------|
| `environments/generic/*` | `core/environments/generic/` | Container/VPS/CI preset |
| `environments/omarchy/*` | `core/environments/omarchy/` | Omarchy overlay |
| `environments/README.md` | `core/environments/README.md` | Preset docs |

### KEEP — tests

| Path | packedbox target | Notes |
|------|------------------|-------|
| `bin/test/path-contract.test.sh` | `tests/path-contract.test.sh` | Phase 1 CI |
| `bin/test/strict-path.test.sh` | `tests/strict-path.test.sh` | Phase 1 CI |

### OPTIONAL — verification tmux templates

| Path | packedbox target | Notes |
|------|------------------|-------|
| `.agents/skills/verification-cockpit/templates/tmux-layout.sh` | `packs/terminal/tmux/` | Cockpit layout seed |
| `.agents/skills/verification-cockpit/templates/tmux-theme.conf` | `packs/terminal/tmux/` | Theme seed |
| `plugins/verification/**` | — | Full plugin OUT for v1; templates only |

### REWRITE — top-level shims

| Path | Decision | Notes |
|------|----------|-------|
| `env.sh`, `lib.sh`, `aliases.sh`, `functions.sh` (root) | REWRITE | Thin re-exports → `core/` in packedbox |
| `bin/migrate.sh` one-liner curl UX | REWRITE | `installers/install.sh` owns UX |

### OUT — shellyxz

| Path | Reason |
|------|--------|
| `.agents/ontology/**` | Agent harness; not bootstrap |
| `.agents/skills/stellar-roadmap/**` | Roadmap skill; optional `tools/` later |
| `arch-design/plans/shell-kernel-ontology.md` | Ontology plan; not v1 |
| `bin/check-ontology.sh`, `bin/extract-ontology-facts.sh` | Ontology tooling |
| `bin/cockpit-mcp.sh`, `bin/agent-*` | Agent verification; optional later |
| `plugins/verification/**` (wholesale) | See OPTIONAL templates only |
| `planned-features/**` | Historical sprint notes |
| `templates/**` | Regenerate from packedbox `core/` + installers |
| `.cursor/**` | Editor config; not product |

---

## arch-machine (`sentinel`)

### KEEP (selective) — patterns & terminal

| Path | packedbox target | Notes |
|------|------------------|-------|
| `install.sh --thin` pattern | `installers/install.sh` | **REWRITE** thin-install orchestration |
| `lib/installer.sh`, `lib/logger.sh` | `installers/lib/` | **COPY** selectively; trim tinfoil refs |
| `modules/productivity/eye-comfort/snippets/ghostty.fragment.conf` | `packs/terminal/ghostty/` | Ghostty theme fragment |
| `modules/productivity/eye-comfort/themes/*/ghostty.conf` | `packs/terminal/ghostty/themes/` | Per-theme snippets |
| `modules/productivity/eye-comfort/nvim/omarchy-theme-hotreload.lua` | `packs/terminal/nvim/` | Nvim hot-reload |
| `modules/productivity/eye-comfort/hooks/theme-set.d/90-reload-nvim-tmux.sh` | `packs/terminal/hooks/` | tmux/nvim reload hook |
| `.agents/verification/tmux-layout.sh` | `packs/terminal/tmux/` | Verification cockpit |
| `.agents/verification/tmux-theme.conf` | `packs/terminal/tmux/` | Cockpit theme |
| `.agents/skills/verification-cockpit/templates/*` | `packs/terminal/tmux/` | Merge with shellyxz templates |

### REWRITE — adapters (stubs → real)

| Path | packedbox target | Notes |
|------|------------------|-------|
| (none — greenfield) | `adapters/arch/` | pacman/paru/Omarchy from arch-machine module maps |
| (none — greenfield) | `adapters/debian/` | apt + Triexe mapping |
| (none — greenfield) | `adapters/ubuntu/` | apt; Phase 1 CI target |

arch-machine is Arch-only today; Debian/Ubuntu adapters are new work informed by `config/tools.yaml` and module install scripts.

### COPY — reference only (implement fresh)

| Path | Notes |
|------|-------|
| `config/tools.yaml` | Tool manifest reference for adapters |
| `config/baselines/omarchy.yaml` | Omarchy baseline reference |
| `docs/eye-comfort.md` | Terminal theming docs → `packs/terminal/README.md` |
| `.grok/ideas/elomaxz-integration/**` | CMake FetchContent patterns → `native/packedbox-cli/` |

### OUT — arch-machine

| Path | Reason |
|------|--------|
| `tools/archy/**` | Ratatui control plane; Arch-specific; wholesale OUT |
| `bin/groxy`, `tools/groxy/**` | Remote XChat/ACP; not portable bootstrap |
| `modules/security/keeper/**` | Secrets vault product |
| `config/profiles/ml-dev.yaml`, `security-dev.yaml` | Heavy profiles |
| `modules/ml_ai/**`, `modules/security/**` (except keeper path above) | Profile modules |
| `.agents/**` (except verification tmux templates) | Full ontology OUT |
| `lib/tui/**`, `lib/tui.sh` | gum/tinfoil face OUT |
| `bin/tinfoil.go` | Go shim OUT |
| `maintenance/**` (most) | Arch maintenance scripts; selective inventory later |
| `modules/productivity/eye-comfort/waybar/**` | Desktop bar; terminal pack only in v1 |
| `modules/productivity/eye-comfort/yazi/**` | File manager theming; later pack |
| `modules/productivity/personal-tweaks/**` | Personal Omarchy tweaks |
| `policies/**`, `VAULT-GUIDE.md` | Keeper/vault domain |
| `devplays/**` | Dev experiments |

---

## packedbox native (new code)

| Component | Source inspiration | Decision |
|-----------|-------------------|----------|
| `native/packedbox-cli/` | elomaxz + arch-machine integration plans | **REWRITE** new C CLI |
| `native/packedbox-ui/` | No direct copy | **REWRITE** GTK4/libadwaita per ADR-0001 |

---

## Phase mapping

| Phase | Inventory action |
|-------|------------------|
| 0 | This document + empty scaffold dirs |
| 1 | KEEP shellyxz core PATH + recover + fix-path; Ubuntu adapter stub → real |
| 2 | Debian/Triexe adapter; arch adapter package maps |
| 3 | Terminal pack KEEP paths (ghostty/nvim/tmux) |
| 4 | packedbox-cli FetchContent integrate |
| 5 | packedbox-ui GTK scaffold |
| 6 | OPTIONAL verification templates; hardening |

---

## Verification commands

```bash
# Refresh tree counts
gh api repos/p10ns11y/shellyxz.sh/git/trees/master?recursive=1 --jq '.tree | length'
gh api repos/p10ns11y/arch-machine/git/trees/sentinel?recursive=1 --jq '.tree | length'

# Diff a shellyxz core file before copy
gh api repos/p10ns11y/shellyxz.sh/contents/core/path.contract?ref=master --jq '.sha'
```

**Policy:** Source repos are **not** archived or deleted. packedbox pulls; it does not replace their GitHub presence.
