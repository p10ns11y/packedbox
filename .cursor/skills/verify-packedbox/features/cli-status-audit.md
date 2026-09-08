# packedbox CLI status and audit

The C CLI reports install/status and audit information read-only via elomaxz `status` / `audit`.

## Sub-features

- `cli-help` shows usage without side effects.
- `cli-version` prints version.
- `cli-status` runs `status`.
- `cli-audit` runs `audit`.
- `cli-reject` rejects unknown flags.

## How to get to it (user POV)

- Build with CMake, then run `./native/packedbox-cli/build/packedbox <cmd>`.
- Or run `bash tests/cli-smoke.test.sh`.

## Driving it with bash+tmux

Preconditions:

- Doctor exited 0.
- Binary present, or build once: `cmake -B native/packedbox-cli/build -S native/packedbox-cli && cmake --build native/packedbox-cli/build` (no sudo). Smoke tests may use `build-smoke/` instead.

- **Smoke suite.** Run `bash tests/cli-smoke.test.sh`. Exit `0` covers help/version/status/audit/reject (also builds UI stub — ignore GTK display).
- **Manual status.** Run `./native/packedbox-cli/build/packedbox status` (or `build-smoke/packedbox` after smoke). Exit `0`; stdout is non-empty status text.
- **Manual audit.** Run `./native/packedbox-cli/build/packedbox audit`. Exit `0`.
- **Proof.** Save combined stdout to `/opt/cursor/artifacts/verify-packedbox/cli-smoke.txt`.

## Gotchas

- Building needs network only if FetchContent pulls elomaxz — prefer cached build on cloud images.
- CLI must not be used to invoke install shells that require sudo during verification.
- GTK UI (`packedbox-ui`) may be `verified-unreachable` without a display; do not fail the CLI feature for that.
