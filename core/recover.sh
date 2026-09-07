#!/usr/bin/env bash
# packedbox recovery when rc files are broken or source loops fail.
# Works from a graphical terminal, SSH, or TTY without loading ~/.bashrc.
# Provenance: shellyxz.sh bin/recover-shell.sh (adapted for packedbox)
#
# Usage:
#   bash ~/.config/packedbox/core/recover.sh
#   bash --norc ~/.config/packedbox/core/recover.sh
set -euo pipefail

CONFIG_DIR="${PACKEDBOX_ROOT:-$HOME/.config/packedbox}"
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${HOME}/.local/bin:${HOME}/bin"

echo "=== packedbox recovery ==="
echo ""
echo "Minimal PATH is set. You are NOT in your normal shell config."
echo ""

latest_backup=""
if [ -d "$CONFIG_DIR/backups" ]; then
    latest_backup=$(find "$CONFIG_DIR/backups" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort | tail -1)
fi

echo "Options:"
echo "  1. Apply packedbox PATH contract (safe, no rc files)"
echo "       packedbox-fix-path"
echo "       bash $CONFIG_DIR/../installers/fix-path.sh  # from repo checkout"
echo ""
echo "  2. Restore dotfiles from latest backup"
if [ -n "$latest_backup" ] && [ -x "$latest_backup/revert.sh" ]; then
    echo "       $latest_backup/revert.sh"
else
    echo "       (no backups found under $CONFIG_DIR/backups/)"
fi
echo ""
echo "  3. Start a clean shell (no rc files)"
echo "       exec bash --norc"
echo "       exec zsh -f"
echo ""
echo "  4. Edit packedbox modules directly (no rc required)"
echo "       \$EDITOR $CONFIG_DIR/core/env.sh"
echo "       \$EDITOR $CONFIG_DIR/local/path.contract"
echo ""
echo "  5. Verify when stable"
echo "       bash $CONFIG_DIR/core/check-path.sh"
echo ""
echo "Tip: if even bash is broken, run:  /usr/bin/bash --norc"
echo "     then point it at this script with the full path above."
