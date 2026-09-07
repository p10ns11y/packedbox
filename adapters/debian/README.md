# adapters/debian

Debian adapter (Phase 5 slice).

Mirrors the Ubuntu PATH bootstrap with a smaller apt set (`bash` `curl` `git` `ca-certificates`). Terminal pack wiring stays shared via `packs/terminal/install.sh`.

```bash
./adapters/debian/install.sh
./adapters/debian/install.sh --deps-only
```
