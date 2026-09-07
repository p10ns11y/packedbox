# packedbox-cli

C CLI for packedbox — built on **elomaxz** via CMake FetchContent (see [docs/ADR-0001-tech-stack.md](../../docs/ADR-0001-tech-stack.md)).

## Planned commands (Phase 4)

| Command | Purpose |
|---------|---------|
| `packedbox doctor` | PATH contract + adapter health |
| `packedbox status` | Installed packs and environment preset |
| `packedbox pack list` | List available packs |
| `packedbox pack enable\|disable <name>` | Toggle packs |

## Build (Phase 4)

```bash
cmake -B build -S .
cmake --build build
```

**Not required** for Phase 1 shell bootstrap — adapters and `installers/fix-path.sh` work without this binary.

## References

- arch-machine: `.grok/ideas/elomaxz-integration/`
- elomaxz: https://github.com/p10ns11y/elomaxz
