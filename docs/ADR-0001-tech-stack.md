# ADR-0001: packedbox technology stack

| Status | Accepted (Phase 0) |
|--------|-------------------|
| Date | 2026-09-07 |
| Context | Merge portable shell kernel (shellyxz.sh) with Arch workstation tooling (arch-machine) into one multi-distro product |

## Decision

packedbox uses a **hybrid architecture**:

1. **Shell functional core** — distro-agnostic `core/` (PATH contract, env, recovery) with thin `adapters/{arch,debian,ubuntu}/` imperative shells.
2. **C CLI** — `native/packedbox-cli` built with **CMake**, state machine on **[elomaxz](https://github.com/p10ns11y/elomaxz)** (MVU-style `Model` / `Msg` / `Cmd`).
3. **Native UI** — `native/packedbox-ui` prefers **GTK4 + libadwaita** (Adwaita styling, GNOME-friendly) over Rust TUI alternatives carried from arch-machine (`archy`).
4. **Installers** — `installers/install.sh` orchestrates adapters and packs; **`installers/fix-path.sh` is required** and must be installed alongside every bootstrap path.

## Rationale

### elomaxz + CMake for CLI

arch-machine already documents elomaxz integration ([`.grok/ideas/elomaxz-integration/`](https://github.com/p10ns11y/arch-machine/tree/sentinel/.grok/ideas/elomaxz-integration)). elomaxz gives:

- Predictable **functional core** for install/maintenance/audit flows
- First-class **Cmd** effects for shell execution (pacman, apt, cp, systemctl)
- **Testable** state transitions without reimplementing logic in bash

CMake is the build system for both native targets and for vendoring elomaxz via `FetchContent` (see arch-machine `INTEGRATION_PLAN_arch-machine_cmake.md`).

### GTK4 / libadwaita for UI

| Option | Verdict |
|--------|---------|
| Rust `archy` TUI | Proven in arch-machine but duplicates control-plane language; not multi-distro UI story |
| Web/Electron | Heavy; poor fit for PATH/bootstrap tool |
| **GTK4 + libadwaita** | Native on Arch/Omarchy/GNOME Ubuntu; thin wrapper over same elomaxz core as CLI |

The UI stays **thin**: menus and status that call into `packedbox-cli` or shared C library — no pacman logic in GTK callbacks.

### Installers + fix-path.sh

shellyxz.sh demonstrates that PATH misconfiguration can brick interactive shells. packedbox treats recovery as a **first-class deliverable**:

- `installers/fix-path.sh` — minimal safe `PATH` without loading broken rc files (adapted from shellyxz `bin/recover-shell.sh` patterns)
- `installers/install.sh` — dispatches to adapter + pack hooks; always registers `fix-path.sh` in a known location (`~/.local/bin/packedbox-fix-path` or equivalent)

**Rule:** No install path ships without `fix-path.sh`.

## Consequences

### Positive

- Single language for control plane (C + elomaxz) across CLI and UI
- Clear separation: bash adapters execute, C core decides, GTK displays
- Aligns with shellyxz "functional core, imperative shell" and arch-machine evidence loops

### Negative / deferred

- Rust tools (`archy`, `groxy`, `keeper`) remain in arch-machine; not ported in Phase 0
- GTK4 dependency excludes minimal headless-only targets (CLI still works)
- elomaxz integration is scaffold-only until Phase 3

## Directory mapping

```
packedbox/
├── core/                 # shellyxz-derived kernel (PATH, env, recover)
├── adapters/
│   ├── arch/             # pacman/paru, Omarchy detection
│   ├── debian/           # apt
│   └── ubuntu/           # apt + snap nuances
├── packs/terminal/       # Ghostty + tmux + nvim
├── installers/
│   ├── install.sh        # entrypoint
│   └── fix-path.sh       # required recovery
└── native/
    ├── packedbox-cli/    # elomaxz + CMake
    └── packedbox-ui/     # GTK4 + libadwaita
```

## References

- [p10ns11y/elomaxz](https://github.com/p10ns11y/elomaxz)
- [arch-machine elomaxz integration plans](https://github.com/p10ns11y/arch-machine/tree/sentinel/.grok/ideas/elomaxz-integration)
- [shellyxz.sh PATH contract](https://github.com/p10ns11y/shellyxz.sh/blob/master/core/path.contract)
- [docs/PULL-INVENTORY.md](PULL-INVENTORY.md)
- [docs/PHASES.md](PHASES.md)
