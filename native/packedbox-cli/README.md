# packedbox-cli

C command-line interface for packedbox, built with **CMake** and **[elomaxz](https://github.com/p10ns11y/elomaxz)** (Phase 3).

## Phase 0

Stub binary prints version string. No elomaxz dependency yet.

## Build

```bash
cmake -B build -S .
cmake --build build
./build/packedbox
```

## Architecture

See [docs/ADR-0001-tech-stack.md](../../docs/ADR-0001-tech-stack.md).
