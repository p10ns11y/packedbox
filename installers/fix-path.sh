#!/usr/bin/env bash
# packedbox fix-path — required recovery helper (ADR-0001)
# Sets a safe PATH and applies the packedbox path.contract without loading broken rc files.
# Provenance: shellyxz.sh bin/recover-shell.sh + core/path-resolve.sh
#
# Usage:
#   bash installers/fix-path.sh              # apply PATH contract in current shell
#   bash --norc installers/fix-path.sh       # recovery from broken ~/.bashrc
#   bash installers/fix-path.sh --install    # install core + rc hook + symlink
set -euo pipefail

# Resolve through ~/.local/bin/packedbox-fix-path symlink so lib/ is found.
_script_source="${BASH_SOURCE[0]}"
while [ -L "$_script_source" ]; do
    _link_dir="$(cd "$(dirname "$_script_source")" && pwd)"
    _script_source="$(readlink "$_script_source")"
    case "$_script_source" in
        /*) ;;
        *) _script_source="$_link_dir/$_script_source" ;;
    esac
done
SCRIPT_DIR="$(cd "$(dirname "$_script_source")" && pwd)"
unset _script_source _link_dir
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=installers/lib/packedbox-install.sh
. "$SCRIPT_DIR/lib/packedbox-install.sh"

INSTALL=false
QUIET=false

usage() {
    cat <<'EOF'
packedbox fix-path — PATH recovery and contract apply

Usage:
  fix-path.sh              Apply packedbox PATH contract (minimal bootstrap PATH first)
  fix-path.sh --install    Install core to ~/.config/packedbox, rc hook, and symlink
  fix-path.sh --quiet      Suppress informational output (still exports PATH)
  fix-path.sh --help

Works from bash --norc when rc files are broken.
EOF
}

log() {
    [[ "$QUIET" == true ]] && return 0
    printf '%s\n' "$*"
}

main() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --install) INSTALL=true; shift ;;
            --quiet|-q) QUIET=true; shift ;;
            -h|--help|help)
                usage
                exit 0
                ;;
            *)
                echo "error: unknown argument: $1" >&2
                usage >&2
                exit 2
                ;;
        esac
    done

    packedbox_minimal_path

    local pb_root=""
    if [[ "$INSTALL" == true ]]; then
        packedbox_install_core "$ROOT_DIR" >/dev/null
        packedbox_install_rc_hook
        packedbox_install_fix_path_symlink "$SCRIPT_DIR/fix-path.sh"
        log "packedbox fix-path: installed core to ~/.config/packedbox"
        pb_root="${HOME}/.config/packedbox"
    elif ! pb_root="$(packedbox_find_root "$ROOT_DIR")"; then
        log "packedbox fix-path: minimal PATH applied (core not found — run with --install)"
        log "PATH=$PATH"
        exit 0
    fi

    packedbox_apply_path_contract "$pb_root"
    log "packedbox fix-path: PATH contract applied from $pb_root"
    log "PATH=$PATH"
}

main "$@"
