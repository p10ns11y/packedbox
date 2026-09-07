# packedbox-cli

C command-line interface for packedbox, built with **CMake** and **[elomaxz](https://github.com/p10ns11y/elomaxz)** (Phase 3).

## Current

Version `0.1.0` baseline under **write-legible-c**: status enum, `--version` / `--help`, unknown-flag exit. No elomaxz dependency yet (Phase 3).

## Build

```bash
cmake -B build -S .
cmake --build build
ctest --test-dir build --output-on-failure
./build/packedbox --version
```

Warning flags: `-Wall -Wextra -Werror -Wconversion -Wshadow`.

## Architecture

See [docs/ADR-0001-tech-stack.md](../../docs/ADR-0001-tech-stack.md) and repo-root [AGENTS.md](../../AGENTS.md).
