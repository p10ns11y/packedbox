#!/usr/bin/env bash
# verify-cmd-guard.sh — deny illicit / machine-breaking commands before pane launch.
# Exit 0 = allowed; non-zero = blocked. Never set PACKEDBOX_ALLOW_ILLICIT to bypass.
set -euo pipefail

verify_cmd_is_denied() {
    local cmd="${1:-}"
    local line
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        if printf '%s' "$cmd" | grep -Eiq -- "$line"; then
            return 0
        fi
    done <<'EOF'
(^|[[:space:];|&])(sudo|su|doas)($|[[:space:]])
(^|[[:space:];|&])(rm[[:space:]]+(-[a-zA-Z]*[rR]|--recursive)|mkfs\.|wipefs|shred)($|[[:space:]])
(^|[[:space:];|&])dd[[:space:]]+
(^|[[:space:];|&])(reboot|shutdown|halt|poweroff)($|[[:space:]])
curl.*\|.*(ba)?sh
wget.*\|.*(ba)?sh
:\(\)\{:\|:&\};:
/dev/sd[a-z]
/dev/nvme
chmod[[:space:]]+(-R[[:space:]]+)?777[[:space:]]+/
>[[:space:]]*/etc/
tee[[:space:]]+/etc/
iptables[[:space:]]+-F
nft[[:space:]]+flush
docker[[:space:]]+system[[:space:]]+prune
kubectl[[:space:]]+delete[[:space:]]+ns
git[[:space:]]+push[[:space:]]+--force
EOF
    return 1
}

verify_cmd_guard() {
    local cmd="${1:?command}"
    if verify_cmd_is_denied "$cmd"; then
        echo "[BLOCKED] illicit or destructive command refused by packedbox verify guard:" >&2
        echo "  $cmd" >&2
        echo "Verification never runs sudo, recursive rm, disk wipe, pipe-to-shell, or host teardown." >&2
        return 1
    fi
    return 0
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    verify_cmd_guard "${1:?usage: verify-cmd-guard.sh 'command'}"
fi
