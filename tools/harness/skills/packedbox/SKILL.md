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
3. **Phase discipline** — check `docs/PHASES.md` before implementing; Phase 1 PATH is done; Phase 1.5 is native C baseline; Phase 2 = terminal pack; Phase 3 = elomaxz CLI.
4. **Tech stack** — C CLI + CMake + elomaxz; UI prefers GTK4/libadwaita (not Rust archy).
5. **C under `native/`** — write-legible-c; see root `AGENTS.md`.

## Layout

```
core/                     # distro-agnostic kernel
adapters/{arch,debian,ubuntu}/
packs/terminal/           # Ghostty + tmux + nvim
installers/{install.sh,fix-path.sh}
native/{packedbox-cli,packedbox-ui}/
docs/{ADR-0001,PULL-INVENTORY,PHASES}.md
AGENTS.md                 # build/test + C law
```

## Phase checklist

### Phase 1 (done)

- [x] Pull shellyxz PATH contract into `core/`
- [x] Adapt recovery → `core/recover.sh`
- [x] Production `installers/fix-path.sh`
- [x] `adapters/ubuntu/install.sh`
- [x] `.github/workflows/ubuntu-path.yml`

### Phase 1.5 (native C baseline)

- [x] write-legible-c CLI/UI stubs + `AGENTS.md`
- [x] `tests/cli-smoke.test.sh`
- [ ] Publish `.github/workflows/native-c.yml` (needs `workflow` token scope)
- [ ] Phase 3 elomaxz FetchContent (not started)

## References

- [AGENTS.md](../../../AGENTS.md)
- [README.md](../../../README.md)
- [docs/ADR-0001-tech-stack.md](../../../docs/ADR-0001-tech-stack.md)
- [docs/PULL-INVENTORY.md](../../../docs/PULL-INVENTORY.md)
- [docs/PHASES.md](../../../docs/PHASES.md)
