# packedbox-ui

Thin **GTK4 + libadwaita** UI over the same packedbox shell backends as the CLI and adapters (Phase 4).

## Jobs

| Job | Backend | Navigation tag |
|-----|---------|----------------|
| Fix PATH | `installers/fix-path.sh` | `job-fix-path` |
| Check PATH | `core/check-path.sh` | `job-check-path` |
| Install core | `installers/fix-path.sh --install` | `job-install-core` |
| Install terminal pack | `packs/terminal/install.sh` | `job-install-terminal` |
| About | Built-in version text | `job-about` |

The UI uses **AdwNavigationView** (libadwaita ≥1.4): root page `home` lists jobs; each job is a static tagged page with `AdwToolbarView` + auto-back `AdwHeaderBar`, output pane, and Run control. Navigation uses `push_by_tag`; backends are invoked via `GSubprocess` only.

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
