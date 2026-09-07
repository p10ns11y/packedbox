# packedbox-ui

Thin **GTK4 + libadwaita** UI over the packedbox elomaxz core (Phase 4).

## Current

Version `0.1.0` stub under **write-legible-c**: status enum and banner only. Prefer GTK4/libadwaita per [ADR-0001](../../docs/ADR-0001-tech-stack.md).

## Dependencies (Phase 4)

- gtk4
- libadwaita-1

## Build

```bash
cmake -B build -S .
cmake --build build
ctest --test-dir build --output-on-failure
./build/packedbox-ui
```

Warning flags: `-Wall -Wextra -Werror -Wconversion -Wshadow`. See repo-root [AGENTS.md](../../AGENTS.md).
