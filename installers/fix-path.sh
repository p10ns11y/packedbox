#!/usr/bin/env bash
# packedbox fix-path — required recovery helper (ADR-0001)
# Sets a minimal safe PATH without loading broken shell rc files.
# Adapted from shellyxz.sh bin/recover-shell.sh patterns.
#
# Usage:
#   bash installers/fix-path.sh
#   bash --norc installers/fix-path.sh
set -euo pipefail

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${HOME}/.local/bin:${HOME}/bin"

echo "packedbox fix-path: minimal PATH applied"
echo "PATH=$PATH"
echo ""
echo "Next steps if your shell config is broken:"
echo "  1. exec bash --norc   # or: exec zsh -f"
echo "  2. Edit ~/.config/packedbox/ after Phase 1 install"
echo "  3. Re-run packedbox installer when core/ is available"
