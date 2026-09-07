# packedbox — agent notes

Portable Linux bootstrap (Arch ± Omarchy, Debian, Ubuntu): PATH contract, terminal pack, C CLI + thin GTK UI. Melts ideas from `shellyxz.sh` and `arch-machine`; those repos stay alive.

## Build / test / lint

| Area | Command |
|------|---------|
| PATH contract | `bash tests/path-contract.test.sh` |
| fix-path / recover | `bash tests/fix-path.test.sh` · `bash tests/recover.test.sh` |
| Terminal pack | `bash tests/terminal-pack.test.sh` |
| CLI smoke | `bash tests/cli-smoke.test.sh` |
| CLI cmake | `PACKEDBOX_ELOMAXZ_SOURCE_DIR=/path/to/elomaxz cmake -B native/packedbox-cli/build -S native/packedbox-cli && cmake --build native/packedbox-cli/build && ctest --test-dir native/packedbox-cli/build --output-on-failure` |
| UI cmake | `cmake -B native/packedbox-ui/build -S native/packedbox-ui && cmake --build native/packedbox-ui/build && ctest --test-dir native/packedbox-ui/build --output-on-failure` |
| Shell lint (CI) | `shellcheck` on `core/`, `installers/`, `adapters/ubuntu/` |

Do not claim done without running the tests that cover the files you touched.

## Boundaries

| Do | Do not |
|----|--------|
| One concern per PR; update `docs/PULL-INVENTORY.md` when pulling upstream files | Large code melt from shellyxz / arch-machine |
| Ship `installers/fix-path.sh` on every install path | Install flows without recovery |
| Follow `docs/PHASES.md` — Phases 0–3 MVP done; next is Phase 4 GTK or 3.1 Cmd effects | Skip phases or invent parallel stacks |
| C CLI on elomaxz + CMake; UI GTK4/libadwaita (Phase 4) | Port Rust `archy` / Electron control planes |

## C law (`native/`)

All C under `native/` follows **write-legible-c** (C11). Hard gates agents must not skip:

- File order: comment → includes → constants → types → static prototypes → public defs → static defs
- No naked literals except obvious 0/1; module status enum (`*_OK` = 0); check every fallible call
- Functions: one job, ≤40 lines, nesting ≤2, ≤4 params (context → outputs → inputs), orchestrator / leaf / adapter only
- No `goto` (unless one justified multi-resource cleanup), no recursion, every loop bounded
- Public entry validates → `*_ERR_ARG`; static helpers `assert` invariants
- Compile with `-Wall -Wextra -Werror -Wconversion -Wshadow` on packedbox targets (not upstream elomaxz)

Foreign elomaxz `Model`/`Msg` void* ABI: document deviations at the call site in `src/app.c`.

## Intentional architecture (looks odd, keep it)

1. **Bash adapters execute; C decides** — installers stay shell; `packedbox status|audit` is the elomaxz MVP.
2. **`fix-path.sh` is a product surface** — PATH bricks are expected; recovery is not optional tooling.
3. **Upstream repos are not deleted** — selective pull with inventory rows, never a wholesale copy.

## Docs map

Capability docs: `README.md`, `docs/ADR-0001-tech-stack.md`, `docs/PHASES.md`, `docs/PULL-INVENTORY.md`. Per-tree purpose: directory `README.md` files. Harness skill: `tools/harness/skills/packedbox/SKILL.md`.
