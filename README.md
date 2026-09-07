# packedbox

Portable Linux bootstrap for **Arch** (± Omarchy), **Debian**, and **Ubuntu**: a shared PATH contract, terminal pack (Ghostty + tmux + Neovim), and a thin native control plane (C CLI + GTK UI).

> **Rename note:** This product was previously called *boxy*. Upstream repos and historical docs may still use the old name; packedbox is the canonical name going forward.

## What packedbox is

| Layer | Role |
|-------|------|
| `core/` | Distro-agnostic shell kernel — PATH contract, env, recovery hooks |
| `adapters/{arch,debian,ubuntu}/` | Package managers, presets, and install glue per distro |
| `packs/terminal/` | Ghostty + tmux + Neovim bundle (themes, keymaps, verify layout) |
| `installers/` | `install.sh` entrypoint + required `fix-path.sh` for broken sessions |
| `native/packedbox-cli` | C CLI on [elomaxz](https://github.com/p10ns11y/elomaxz) + CMake |
| `native/packedbox-ui` | Thin GTK4 / libadwaita UI over the same core |

Design decisions: [docs/ADR-0001-tech-stack.md](docs/ADR-0001-tech-stack.md). Roadmap: [docs/PHASES.md](docs/PHASES.md). Upstream inventory: [docs/PULL-INVENTORY.md](docs/PULL-INVENTORY.md).

## Source repos

packedbox **melts ideas and modules** from two upstream projects. Neither repo is deleted or deprecated by this work — they stay the source of truth for their domains until content is explicitly pulled and adapted.

| Repo | Branch | Keeps |
|------|--------|-------|
| [p10ns11y/shellyxz.sh](https://github.com/p10ns11y/shellyxz.sh) | `master` | Portable shell kernel, PATH contract v2, recovery, tmux verification cockpit |
| [p10ns11y/arch-machine](https://github.com/p10ns11y/arch-machine) | `sentinel` | Arch/Omarchy profiles, Ghostty eye-comfort themes, maintenance tooling |

## Terminal pack (Ghostty + tmux + nvim)

The first user-visible pack wires a consistent terminal workflow:

- **Ghostty** — terminal emulator config and eye-comfort themes (from arch-machine productivity modules)
- **tmux** — session layout, verify/build/test cockpit keymaps (from shellyxz verification plugin)
- **Neovim** — shared theme tokens and minimal starter config aligned with Ghostty colors

Pack layout lives under `packs/terminal/`. Adapters decide how configs are installed on each distro.

## Agent / C notes

Root [AGENTS.md](AGENTS.md) lists build/test commands and the **write-legible-c** law for everything under `native/`. Phase 1.5 landed a conforming CLI/UI baseline (`0.1.0`) before elomaxz (Phase 3) and GTK4 (Phase 4).

## Quick start (Phase 1 — PATH kernel)

```bash
git clone https://github.com/p10ns11y/packedbox.git
cd packedbox

# Ubuntu bootstrap: install core + recovery helper
./adapters/ubuntu/install.sh

# Or PATH recovery only (works from bash --norc when rc files break)
./installers/fix-path.sh --install
~/.local/bin/packedbox-fix-path

# Verify
bash ~/.config/packedbox/core/check-path.sh
```

Full installer orchestration (`installers/install.sh --distro`) lands in a later phase.

## OUT list (not in this repo yet)

Explicit **out-of-scope** items. These stay upstream or land in later phases:

| Item | Stays / lands |
|------|----------------|
| shellyxz verification plugin (`plugins/verification/`) | shellyxz.sh → `packs/terminal/` Phase 2 |
| shellyxz full `bin/` task runner & migrate flow | shellyxz.sh — later phases |
| arch-machine YAML profiles & `modules/*` installers | arch-machine → `adapters/arch/` Phase 2+ |
| arch-machine `tools/archy`, `tools/groxy`, `tools/keeper` (Rust) | arch-machine — not ported; packedbox uses C/GTK instead |
| arch-machine `.agents/`, `.grok/`, eye-comfort image assets (184+ theme files) | arch-machine — reference only until pack needs them |
| elomaxz state machine implementation | elomaxz repo + `native/packedbox-cli` Phase 3 |
| GTK4 UI | `native/packedbox-ui` Phase 4 |
| Multi-distro CI matrix (Arch, Debian) | Phase 5 |

## Quality law

- **No large code melt** — selective pull with inventory and ADR traceability.
- **Source repos live** — shellyxz.sh and arch-machine are not deleted.
- **PATH safety** — every install path must ship `fix-path.sh`; recovery before features.
- **Test the contract** — Phase 1 adds Ubuntu CI for PATH + recover + fix-path.

## License

TBD — inherit from upstream modules as they are pulled.
