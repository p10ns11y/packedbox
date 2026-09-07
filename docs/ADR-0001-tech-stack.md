# ADR-0001: Technology Stack for packedbox v1

| Field | Value |
|-------|-------|
| Status | Accepted |
| Date | 2026-09-07 |
| Deciders | packedbox maintainers |
| Supersedes | — |

## Context

packedbox merges portable cores from shellyxz.sh (shell kernel, PATH contract) and arch-machine (thin install, terminal theming, verification cockpit). We need stable choices for:

1. A native CLI for `doctor`, status, and pack operations.
2. An optional desktop UI for non-terminal users.
3. Primary installation and recovery — must work when GUI and fancy TUI are unavailable.

Prior art in arch-machine includes archy (Rust/Ratatui), tinfoil/gum shell TUI, and `.grok/ideas/elomaxz-integration/` CMake FetchContent notes.

## Decision

### 1. C CLI via elomaxz + CMake FetchContent

**Choice:** `native/packedbox-cli/` — C11 CLI using [elomaxz](https://github.com/p10ns11y/elomaxz) as a library, fetched at configure time with CMake `FetchContent`.

**Rationale:**

- elomaxz already targets portable C with minimal deps — fits multi-distro bootstrap.
- FetchContent pins versions without vendoring large trees in git.
- C aligns with “runs everywhere” recovery tooling; no Rust toolchain required on end-user machines for the CLI alone.
- arch-machine’s eagle-satellite-elomaxz skill and CMake guides inform integration patterns.

**Non-goals for v1 CLI:**

- Reimplement pacman/apt logic in C — adapters stay shell.
- Replace tmux verification workflows — CLI complements them.

**Sketch:**

```cmake
include(FetchContent)
FetchContent_Declare(
  elomaxz
  GIT_REPOSITORY https://github.com/p10ns11y/elomaxz.git
  GIT_TAG        v0.3  # pin at integrate time
)
FetchContent_MakeAvailable(elomaxz)
target_link_libraries(packedbox-cli PRIVATE elomaxz)
```

### 2. Desktop UI — GTK4 + libadwaita (v1 preference)

**Choice:** `native/packedbox-ui/` — GTK4 with libadwaita for v1 desktop settings UI.

**Rationale:**

- Consistent with Linux desktop targets (GNOME/Omarchy-adjacent workflows).
- libadwaita gives accessible, maintained widgets without a custom toolkit.
- Terminal pack (Ghostty/tmux/nvim) remains the primary v1 surface; UI is optional adjunct.

**Blast radius (document explicitly):**

| Area | Impact |
|------|--------|
| Build deps | `gtk4`, `libadwaita-1`, `pkg-config`, meson/cmake glue |
| CI | Needs GTK dev packages on Ubuntu runner; may split UI job from headless PATH CI |
| Omarchy/GNOME | Native look; Wayland/X11 both supported by GTK4 |
| Non-GNOME DEs | UI still runs; may not match host chrome — acceptable for v1 settings app |
| Headless servers | UI not installed; shell installers + CLI only |
| Future Qt/alternative | Would require ADR-0002; not planned in v1 |

**Non-goals for v1 UI:**

- Full archy menu replacement.
- Profile editor for ML/security-dev YAML — out of scope.

### 3. Shell installers as primary path

**Choice:** `installers/install.sh` and `installers/fix-path.sh` are the **required** install and recovery entry points.

**Rationale:**

- shellyxz’s proven model: migrate/recover when PATH is broken and `git`/`nvim` may be missing.
- Shell works over SSH, rescue TTY, and CI without compiled artifacts.
- `fix-path.sh` is mandatory companion — sourced or executed when interactive shell loads a broken contract.

**Contract:**

- `install.sh` detects distro → delegates to `adapters/<distro>/`.
- `fix-path.sh` re-applies `core/path.sh` layers idempotently; safe to run from `recover-shell.sh` flow.
- Native CLI/UI are **optional** layers installed by adapters when dev packages exist.

## Consequences

### Positive

- Clear separation: shell = bootstrap/recover, C = fast status, GTK = optional GUI.
- Ubuntu CI can validate shell path without building GTK in Phase 1.
- elomaxz reuse avoids a second CLI framework.

### Negative

- Two native build graphs (CLI + UI) increase CI matrix cost — mitigate with staged jobs.
- GTK ties UI to glib ecosystem — acceptable for v1 Linux desktop focus.

### Neutral

- archy, groxy, keeper remain in arch-machine; no migration implied.

## Alternatives considered

| Alternative | Rejected because |
|-------------|------------------|
| Rust CLI (archy-style) | Toolchain burden on bootstrap path; archy stays Arch-specific |
| Ratatui TUI as primary | Poor SSH/recovery story vs shell; gum/tinfoil face explicitly OUT |
| Qt6 UI | Heavier deps; no strong v1 requirement vs GTK on target distros |
| Go CLI (tinfoil) | arch-machine moving away from Go shim as primary face |
| Electron/Tauri UI | Contradicts portable/bootstrap goals |

## References

- arch-machine: `.grok/ideas/elomaxz-integration/CMake_FetchContent_Guide.md`
- shellyxz: `bin/recover-shell.sh`, `core/path.contract`
- packedbox: [PULL-INVENTORY.md](PULL-INVENTORY.md), [PHASES.md](PHASES.md)
