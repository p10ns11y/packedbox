#!/usr/bin/env bash
# packedbox installer helpers — shared by fix-path.sh and adapters.
set -euo pipefail

packedbox_find_root() {
    local repo_hint="${1:-}"
    local candidate
    for candidate in \
        "${HOME}/.config/packedbox" \
        "${repo_hint}" \
        "${PACKEDBOX_ROOT:-}"; do
        [[ -n "$candidate" ]] || continue
        if [[ -f "$candidate/core/path.contract" ]]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done
    return 1
}

packedbox_minimal_path() {
    export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${HOME}/.local/bin:${HOME}/bin"
}

packedbox_apply_path_contract() {
    local root="$1"
    export PACKEDBOX_ROOT="$root"
    # shellcheck disable=SC1091
    . "$root/core/lib.sh"
    # shellcheck disable=SC1091
    . "$root/core/path.sh"
    path_contract_apply_core_only
}

packedbox_managed_block() {
    cat <<'EOF'
# packedbox managed block begin
if [ -f "$HOME/.config/packedbox/core/env.sh" ]; then
    # shellcheck disable=SC1091
    . "$HOME/.config/packedbox/core/env.sh"
fi
# packedbox managed block end
EOF
}

packedbox_install_rc_hook() {
    local bashrc="$HOME/.bashrc"
    local marker_begin='# packedbox managed block begin'
    local marker_end='# packedbox managed block end'
    local block
    block="$(packedbox_managed_block)"

    if [[ ! -f "$bashrc" ]]; then
        printf '%s\n' "$block" >"$bashrc"
        return 0
    fi

    if grep -qF "$marker_begin" "$bashrc"; then
        # Replace existing managed block idempotently.
        local tmp
        tmp="$(mktemp)"
        awk -v begin="$marker_begin" -v end="$marker_end" '
            $0 == begin { skip=1; next }
            $0 == end { skip=0; next }
            skip { next }
            { print }
        ' "$bashrc" >"$tmp"
        printf '\n%s\n' "$block" >>"$tmp"
        mv "$tmp" "$bashrc"
    else
        printf '\n%s\n' "$block" >>"$bashrc"
    fi
}

packedbox_install_core() {
    local src_root="$1"
    local dest="${HOME}/.config/packedbox"
    mkdir -p "$dest/core" "$dest/environments/generic" "$dest/local"
    install -m 0644 "$src_root/core/path.contract" "$dest/core/"
    install -m 0644 "$src_root/core/path.sh" "$dest/core/"
    install -m 0644 "$src_root/core/path-resolve.sh" "$dest/core/"
    install -m 0644 "$src_root/core/env.sh" "$dest/core/"
    install -m 0644 "$src_root/core/lib.sh" "$dest/core/"
    install -m 0644 "$src_root/core/tool.contract" "$dest/core/"
    install -m 0755 "$src_root/core/recover.sh" "$dest/core/"
    install -m 0755 "$src_root/core/check-path.sh" "$dest/core/"
    if [[ -f "$src_root/environments/generic/env.sh" ]]; then
        install -m 0644 "$src_root/environments/generic/env.sh" "$dest/environments/generic/"
    fi
    if [[ -f "$src_root/local/path.contract.example" ]]; then
        install -m 0644 "$src_root/local/path.contract.example" "$dest/local/"
    fi
    printf '%s\n' "$dest"
}

packedbox_install_fix_path_symlink() {
    local src_script="$1"
    mkdir -p "${HOME}/.local/bin"
    ln -sf "$src_script" "${HOME}/.local/bin/packedbox-fix-path"
}
