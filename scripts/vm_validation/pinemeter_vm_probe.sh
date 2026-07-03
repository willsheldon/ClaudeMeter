#!/usr/bin/env bash
set -euo pipefail

HOST="${PINEMETER_VM_HOST:-macvm2.local}"
USER_NAME="${PINEMETER_VM_USER:-will}"
OUT_DIR="${PINEMETER_VM_EVIDENCE_DIR:-.gsd/milestones/M006-fd23vy/evidence/S01}"
SSH_OPTS=(
  -o BatchMode=yes
  -o ConnectTimeout=10
  -o ConnectionAttempts=1
  -o StrictHostKeyChecking=accept-new
)

mkdir -p "$OUT_DIR"
OUT_FILE="$OUT_DIR/vm-probe-$(date -u +%Y%m%dT%H%M%SZ).txt"

{
  echo "# Pinemeter VM probe"
  date -u '+timestamp_utc=%Y-%m-%dT%H:%M:%SZ'
  echo "target=${USER_NAME}@${HOST}"
  echo "secret_policy=no cookie dbs, keychain values, tokens, auth headers, or browser storage contents are read"
  echo
} > "$OUT_FILE"

if ! ssh "${SSH_OPTS[@]}" "${USER_NAME}@${HOST}" 'printf reachable' >/dev/null 2>>"$OUT_FILE"; then
  {
    echo "result=unreachable"
    echo "category=ssh_or_dns_unavailable"
    echo "next_action=verify VM is booted, on the same network, and reachable by PINEMETER_VM_HOST"
  } >> "$OUT_FILE"
  echo "$OUT_FILE"
  exit 2
fi

ssh "${SSH_OPTS[@]}" "${USER_NAME}@${HOST}" 'set -euo pipefail
printf "result=reachable\n"
printf "hostname="; hostname
printf "macos_version="; sw_vers -productVersion
printf "macos_build="; sw_vers -buildVersion
printf "user_id="; id -un
printf "sudo_user="; sudo -n whoami
printf "chrome_profiles=\n"
chrome_dir="$HOME/Library/Application Support/Google/Chrome"
if [ -d "$chrome_dir" ]; then
  find "$chrome_dir" -maxdepth 1 -type d \( -name "Default" -o -name "Profile*" \) -print | sed "s|$HOME|~|" | sort
else
  echo "chrome-dir-missing"
fi
printf "tools=\n"
for tool in screencapture osascript pgrep open defaults security sqlite3 python3; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf "%s: present\n" "$tool"
  else
    printf "%s: missing\n" "$tool"
  fi
done
printf "apps=\n"
for app in "/Applications/Google Chrome.app" "/Applications/PineShot.app"; do
  if [ -e "$app" ]; then
    printf "%s: present\n" "$app"
  else
    printf "%s: missing\n" "$app"
  fi
done
' >> "$OUT_FILE"

echo "$OUT_FILE"
