# adapters/arch

Arch Linux (+ Omarchy) adapter.

**Upstream:** [arch-machine](https://github.com/p10ns11y/arch-machine) `sentinel` — package patterns only (no full module melt).

## Usage

```bash
./adapters/arch/install.sh                 # core + fix-path
./adapters/arch/install.sh --deps-only     # pacman prerequisites
./adapters/arch/install.sh --with-terminal # core + packs/terminal
```

Packages: `bash` `curl` `git` `tmux` `neovim` `ttf-jetbrains-mono-nerd`, plus `ghostty` via pacman/paru/omarchy helper when available.
