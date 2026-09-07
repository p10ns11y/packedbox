# packedbox

**Portable Linux bootstrap** — melts the portable cores of [p10ns11y/shellyxz.sh](https://github.com/p10ns11y/shellyxz.sh) and [p10ns11y/arch-machine](https://github.com/p10ns11y/arch-machine) into one multi-distro installer and shell kernel.

| Distro | Adapter | Notes |
|--------|---------|-------|
| Arch Linux | `adapters/arch/` | Primary dev target; optional Omarchy overlay |
| Debian | `adapters/debian/` | Triexe-oriented package mapping (Phase 2+) |
| Ubuntu | `adapters/ubuntu/` | CI-first validation target (Phase 1) |

This is **not** an Arch-only rename of arch-machine. packedbox is distro-agnostic at the core; Arch/Omarchy is the richest adapter, not the only one.

## What packedbox is

- A **portable shell kernel** (`core/`) with a strict PATH contract, recovery tooling, and environment presets (`generic`, `omarchy`).
- **Shell-first installers** (`installers/`) that bootstrap dotfiles, fix broken PATH sessions, and delegate package work to per-distro adapters.
- A **terminal pack** (`packs/terminal/`) for Ghostty + tmux + Neovim — the v1 “daily driver” surface.
- A thin **C CLI** (`native/packedbox-cli/`) built on [elomaxz](https://github.com/p10ns11y/elomaxz) via CMake FetchContent — status, doctor, pack toggles.
- An optional **GTK4/libadwaita UI** (`native/packedbox-ui/`) for settings and pack management (v1 scope; see [ADR-0001](docs/ADR-0001-tech-stack.md)).

## What packedbox is not

- A wholesale import of arch-machine profiles (ML/AI, security-dev), keeper, groxy, or the full `.agents` ontology.
- A replacement for **archy** (Ratatui control plane) — that stays in arch-machine unless a future ADR says otherwise.
- An archive or delete of the source repos — **shellyxz.sh and arch-machine remain active**; packedbox pulls selected portable pieces over time.

## v1 repository tree

```
packedbox/
├── README.md
├── core/                    # Portable shell kernel (from shellyxz)
│   ├── path.contract
│   ├── path.sh
│   ├── path-resolve.sh
│   ├── env.sh
│   └── tool.contract
├── adapters/
│   ├── arch/                # pacman/paru, Omarchy hooks
│   ├── debian/              # apt, Triexe mapping (stub → real)
│   └── ubuntu/              # apt/snap, CI target (stub → real)
├── packs/
│   └── terminal/            # Ghostty + tmux + nvim pack
├── installers/
│   ├── install.sh           # Primary entry (shell)
│   └── fix-path.sh          # Required PATH recovery helper
├── native/
│   ├── packedbox-cli/       # C CLI (elomaxz + CMake)
│   └── packedbox-ui/        # GTK4/libadwaita (v1 desktop)
└── docs/
    ├── ADR-0001-tech-stack.md
    ├── PULL-INVENTORY.md
    └── PHASES.md
```

## v1 terminal pack

The first shipped **pack** is the terminal stack:

| Tool | Role |
|------|------|
| **Ghostty** | GPU terminal; eye-comfort theme fragments from arch-machine |
| **tmux** | Verification cockpit layouts; agent/human split panes |
| **Neovim** | Editor; hot-reload theme hooks from eye-comfort |

Pack install is adapter-aware (package names differ per distro) but config is shared under `packs/terminal/`.

## Explicit OUT list (v1)

These stay in source repos or are reimplemented minimally — **not** copied wholesale into packedbox:

| Item | Source | Reason |
|------|--------|--------|
| keeper | arch-machine | Secrets vault; separate product surface |
| groxy | arch-machine | XChat/ACP remote control; not portable bootstrap |
| Full `.agents/` ontology | both | Agent harness; optional future `tools/` slice only |
| ML-dev / security-dev profiles | arch-machine | Heavy workstation profiles; out of v1 scope |
| gum / tinfoil install face | arch-machine | Replaced by packedbox shell installers + optional GTK UI |
| archy (Ratatui) | arch-machine | Arch-specific control plane; not multi-distro |
| Omarchy waybar/yazi/systemd theming | arch-machine eye-comfort | v1 pack is terminal-only; desktop theming later |
| shellyxz verification plugin wholesale | shellyxz | Optional tmux templates only; not full plugin tree in Phase 0 |

## Architecture decisions

| ADR | Topic |
|-----|-------|
| [ADR-0001](docs/ADR-0001-tech-stack.md) | C CLI (elomaxz), GTK4 UI, shell installers |

More ADRs will land as phases progress (PATH contract versioning, adapter interface, pack manifest format).

## Source repos (not deleted)

| Repo | Default branch | packedbox relationship |
|------|----------------|------------------------|
| [shellyxz.sh](https://github.com/p10ns11y/shellyxz.sh) | `master` | PATH kernel, migrate/recover, environments |
| [arch-machine](https://github.com/p10ns11y/arch-machine) | `sentinel` | Thin-install pattern, eye-comfort terminal themes, verification cockpit |

See [docs/PULL-INVENTORY.md](docs/PULL-INVENTORY.md) for file-level KEEP / COPY / REWRITE decisions.

## Roadmap

Phases 0–6 are documented in [docs/PHASES.md](docs/PHASES.md).

**Phase 0** (this PR): docs, ADRs, directory scaffold — no large code melt.

**Phase 1** (next): PATH contract + `recover-shell` + `fix-path.sh` on Ubuntu CI.

## Status

Phase 0 — scaffold and inventory only. Installers and adapters are stubs until Phase 1+.
