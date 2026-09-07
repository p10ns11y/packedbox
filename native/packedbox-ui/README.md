# packedbox-ui

Optional desktop UI for packedbox v1 — **GTK4 + libadwaita** (ADR-0001).

## Scope

- Pack enable/disable toggles
- PATH contract status (read-only mirror of `packedbox doctor`)
- Environment preset selector (`generic` / `omarchy`)

## Blast radius

See [docs/ADR-0001-tech-stack.md](../../docs/ADR-0001-tech-stack.md) — requires GTK dev packages; separate CI job from headless PATH tests.

## Phase

Scaffold only in Phase 0. Implementation in **Phase 5**.

Headless and server installs skip this component entirely.
