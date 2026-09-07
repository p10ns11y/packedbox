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
3. **Phase discipline** — check `docs/PHASES.md` before implementing; Phase 1 = PATH + recover + fix-path on Ubuntu CI only.
4. **Tech stack** — C CLI + CMake + elomaxz; UI prefers GTK4/libadwaita (not Rust archy).

## Layout

```
core/                     # distro-agnostic kernel
adapters/{arch,debian,ubuntu}/
packs/terminal/           # Ghostty + tmux + nvim
installers/{install.sh,fix-path.sh}
native/{packedbox-cli,packedbox-ui}/
docs/{ADR-0001,PULL-INVENTORY,PHASES}.md
```

## Phase 1 checklist (next)

- [ ] Pull shellyxz `core/path.contract`, `path.sh`, `path-resolve.sh` into `core/`
- [ ] Adapt `bin/recover-shell.sh` → `core/recover.sh`
- [ ] Make `installers/fix-path.sh` production-ready
- [ ] `adapters/ubuntu/install.sh`
- [ ] `.github/workflows/ubuntu-path.yml`

## References

- [README.md](../../../README.md)
- [docs/ADR-0001-tech-stack.md](../../../docs/ADR-0001-tech-stack.md)
- [docs/PULL-INVENTORY.md](../../../docs/PULL-INVENTORY.md)
- [docs/PHASES.md](../../../docs/PHASES.md)
