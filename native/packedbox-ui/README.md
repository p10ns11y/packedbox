# packedbox-ui

Thin **GTK4 + libadwaita** UI over the same packedbox shell backends as the CLI and adapters (Phase 4).

## Jobs

| Job | Backend |
|-----|---------|
| Fix PATH | `installers/fix-path.sh` |
| Check PATH | `core/check-path.sh` |
| Install core | `installers/fix-path.sh --install` |
| Install terminal pack | `packs/terminal/install.sh` |
| About | Built-in version text |

The UI shells out to these scripts — it does not reimplement PATH logic in GTK.

## Dependencies

**Full UI (GTK4 + libadwaita):**

- Debian/Ubuntu: `libgtk-4-dev`, `libadwaita-1-dev`
- Arch: `gtk4`, `libadwaita`

**Headless stub:** builds without GTK for CI and smoke tests (`--version`, `--help`, stub banner).

Set `PACKEDBOX_ROOT` to override repository discovery when the binary is not run from a checkout.

## Build

```bash
cmake -B build -S .
cmake --build build
ctest --test-dir build --output-on-failure
./build/packedbox-ui            # GTK app when deps present
./build/packedbox-ui --version  # always works headless
```

To skip GTK detection (stub only):

```bash
cmake -B build -S . -DPACKEDBOX_UI_BUILD_GTK=OFF
```

## CI

GitHub `ubuntu-path` and CLI smoke workflows do **not** require GTK. The optional `.github/workflows/packedbox-ui.yml` workflow installs GTK dev packages and builds the full UI on `ubuntu-24.04`.

Warning flags: `-Wall -Wextra -Werror -Wconversion -Wshadow`. See repo-root [AGENTS.md](../../AGENTS.md).
