# packedbox-cli

C command-line interface for packedbox, built with **CMake** and **[elomaxz](https://github.com/p10ns11y/elomaxz)**.

## Current (`0.2.0`)

- write-legible-c modules (`cli.c`, `app.c`, `main.c`)
- Commands: `--version`, `--help`, `status`, `audit`
- elomaxz via FetchContent (`v0.1`) or `PACKEDBOX_ELOMAXZ_SOURCE_DIR`

## Build

```bash
# optional local elomaxz checkout
export PACKEDBOX_ELOMAXZ_SOURCE_DIR=/path/to/elomaxz
cmake -B build -S .
cmake --build build
ctest --test-dir build --output-on-failure
./build/packedbox status
```

Warning flags apply to packedbox sources only (`-Wall -Wextra -Werror -Wconversion -Wshadow`).

## Architecture

See [docs/ADR-0001-tech-stack.md](../../docs/ADR-0001-tech-stack.md) and [AGENTS.md](../../AGENTS.md).
