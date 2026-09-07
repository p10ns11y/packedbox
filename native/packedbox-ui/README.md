# packedbox-ui

Thin **GTK4 + libadwaita** UI over packedbox shell backends (Phase 4).

## Navigation pages (CoS)

| Tag | Backend |
|-----|---------|
| `home` | Entry list |
| `install-fix-path` | `installers/fix-path.sh` (apply / `--install`) |
| `adapters` | `adapters/{arch,debian,ubuntu}/install.sh` |
| `terminal-pack` | `packs/terminal/install.sh` |
| `status` | `core/check-path.sh`, `packedbox status|audit` |

`AdwNavigationView` (libadwaita ≥1.4): home lists entries; each page is `AdwToolbarView` + auto-back `AdwHeaderBar` + output pane. Navigation uses `push_by_tag`. No PATH logic in GTK — `GSubprocess` only.

## Dependencies

**Full UI:** `libgtk-4-dev`, `libadwaita-1-dev` (or Arch `gtk4`, `libadwaita`)

**Headless stub:** builds without GTK for CI (`--version`, `--help`).

Set `PACKEDBOX_ROOT` to override repository discovery.

## Build

```bash
cmake -B build -S .
cmake --build build
ctest --test-dir build --output-on-failure
./build/packedbox-ui --version   # headless
./build/packedbox-ui             # GTK when deps present
```

Stub only: `cmake -B build -S . -DPACKEDBOX_UI_BUILD_GTK=OFF`

## CI

`ubuntu-path` / CLI smoke do not require GTK. Optional `.github/workflows/packedbox-ui.yml` builds the full UI when dev packages are installed.
