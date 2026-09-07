---
name: packedbox
description: Work on packedbox — portable Linux bootstrap (Arch/Debian/Ubuntu), PATH contract, Ghostty+tmux+nvim pack, C CLI (elomaxz) + GTK4 UI. Use when editing packedbox repo or planning pulls from shellyxz.sh / arch-machine.
---

# packedbox agent skill

## Product

**packedbox** (formerly *boxy*) — multi-distro bootstrap melting:

- [shellyxz.sh](https://github.com/p10ns11y/shellyxz.sh) `master` — shell kernel, PATH, recovery, tmux verify
- [arch-machine](https://github.com/p10ns11y/arch-machine) `sentinel` — Arch profiles, Ghostty themes, maintenance

**Neither upstream repo is deleted.** Pull selectively; document in `docs/PULL-INVENTORY.md`.

## Quality law

1. **No large code melt** — one concern per PR; update PULL-INVENTORY when pulling files.
2. **`fix-path.sh` is required** — every install path must ship `installers/fix-path.sh`.
3. **Phase discipline** — `docs/PHASES.md`: Phases 0–3 MVP done; next Phase 4 GTK or Phase 3.1 Cmd effects.
4. **Tech stack** — C CLI + CMake + elomaxz; UI prefers GTK4/libadwaita (not Rust archy).
5. **C under `native/`** — write-legible-c; see root `AGENTS.md`.

## Layout

```
core/                     # distro-agnostic kernel
adapters/{arch,debian,ubuntu}/
packs/terminal/           # Ghostty + tmux + nvim (+ install.sh)
installers/{install.sh,fix-path.sh}
native/{packedbox-cli,packedbox-ui}/
docs/{ADR-0001,PULL-INVENTORY,PHASES}.md
AGENTS.md
```

## Phase checklist

- [x] Phase 1 PATH + recover + Ubuntu CI
- [x] Phase 1.5 write-legible-c CLI/UI baseline
- [x] Phase 2 terminal pack + Arch adapter
- [x] Phase 3 MVP: elomaxz `status` / `audit`
- [ ] Phase 3.1: Cmd/effect shell for install/maintenance
- [ ] Phase 4: GTK4/libadwaita UI
- [x] Phase 5: Debian adapter (CI matrix blocked on workflow scope)

## References

- [AGENTS.md](../../../AGENTS.md)
- [README.md](../../../README.md)
- [docs/PHASES.md](../../../docs/PHASES.md)
- [docs/PULL-INVENTORY.md](../../../docs/PULL-INVENTORY.md)
