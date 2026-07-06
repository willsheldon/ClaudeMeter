#!/usr/bin/env bash
set -euo pipefail

HOST="${PINEMETER_VM_HOST:-macvm2.local}"
USER_NAME="${PINEMETER_VM_USER:-will}"
APP_PATH="${PINEMETER_APP_PATH:-}"
INSTALL_PATH="${PINEMETER_VM_INSTALL_PATH:-/Applications/Pinemeter.app}"
LAUNCH_ARGS="${PINEMETER_VM_LAUNCH_ARGS:-}"
EVIDENCE_DIR="${PINEMETER_VM_EVIDENCE_DIR:-.gsd/milestones/M006-fd23vy/evidence/S02}"
MODE="all"

SSH_OPTS=(
  -o BatchMode=yes
  -o ConnectTimeout=10
  -o ConnectionAttempts=1
  -o StrictHostKeyChecking=accept-new
)

usage() {
  cat <<'USAGE'
Usage: scripts/vm_validation/pinemeter_vm_validate.sh [--dry-run|--install|--reset|--launch|--all]

Environment:
  PINEMETER_VM_HOST          VM host, default macvm2.local
  PINEMETER_VM_USER          VM SSH user, default will
  PINEMETER_APP_PATH         Local Pinemeter.app bundle to install. If omitted, auto-detects Debug build output.
  PINEMETER_VM_INSTALL_PATH  Remote install path, default /Applications/Pinemeter.app
  PINEMETER_VM_LAUNCH_ARGS   Optional launch arguments, for example --open-popover-after-launch in DEBUG builds
  PINEMETER_VM_EVIDENCE_DIR  Local evidence output directory

Safety:
  Never prints cookie values, Keychain values, tokens, auth headers, or browser storage contents.
  Reset deletes only:
    - UserDefaults domain ca.pineit.Pinemeter
    - Keychain service ca.pineit.pinemeter.sessionkey account default
    - Keychain service com.pinemeter.chatgpt.session account chatgpt.com
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) MODE="dry-run" ;;
    --install) MODE="install" ;;
    --reset) MODE="reset" ;;
    --launch) MODE="launch" ;;
    --all) MODE="all" ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage >&2; exit 64 ;;
  esac
  shift
done

mkdir -p "$EVIDENCE_DIR"
EVIDENCE_FILE="$EVIDENCE_DIR/vm-validate-$(date -u +%Y%m%dT%H%M%SZ).txt"
REMOTE="${USER_NAME}@${HOST}"

log() { printf '%s\n' "$*" | tee -a "$EVIDENCE_FILE"; }

find_app_path() {
  if [[ -n "$APP_PATH" ]]; then
    printf '%s\n' "$APP_PATH"
    return
  fi

  local settings built_products_dir candidate
  settings=$(xcodebuild -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -showBuildSettings 2>/dev/null)
  built_products_dir=$(printf '%s\n' "$settings" | awk -F ' = ' '/^[[:space:]]*BUILT_PRODUCTS_DIR = / {print $2; exit}')
  candidate="$built_products_dir/Pinemeter.app"
  if [[ -d "$candidate" ]]; then
    printf '%s\n' "$candidate"
    return
  fi

  find "$HOME/Library/Developer/Xcode/DerivedData" -path '*/Build/Products/Debug/Pinemeter.app' -type d -print 2>/dev/null | sort | tail -1
}

remote_reset_script() {
  cat <<'REMOTE_RESET'
set -euo pipefail
APP_DOMAIN="ca.pineit.Pinemeter"
CLAUDE_SERVICE="ca.pineit.pinemeter.sessionkey"
CLAUDE_ACCOUNT="default"
CHATGPT_SERVICE="com.pinemeter.chatgpt.session"
CHATGPT_ACCOUNT="chatgpt.com"

echo "reset.preferences.domain=${APP_DOMAIN}"
defaults delete "${APP_DOMAIN}" >/dev/null 2>&1 || true

echo "reset.keychain.claude=${CLAUDE_SERVICE}/${CLAUDE_ACCOUNT}"
security delete-generic-password -s "${CLAUDE_SERVICE}" -a "${CLAUDE_ACCOUNT}" >/dev/null 2>&1 || true

echo "reset.keychain.chatgpt=${CHATGPT_SERVICE}/${CHATGPT_ACCOUNT}"
security delete-generic-password -s "${CHATGPT_SERVICE}" -a "${CHATGPT_ACCOUNT}" >/dev/null 2>&1 || true

echo "reset.complete=true"
REMOTE_RESET
}

remote_launch_script() {
  cat <<REMOTE_LAUNCH
set -euo pipefail
INSTALL_PATH="$INSTALL_PATH"
LAUNCH_ARGS="$LAUNCH_ARGS"
killall Pinemeter >/dev/null 2>&1 || true
if [ -n "\$LAUNCH_ARGS" ]; then
  open -na "\$INSTALL_PATH" --args \$LAUNCH_ARGS
else
  open -a "\$INSTALL_PATH"
fi
sleep 3
if pgrep -x Pinemeter >/dev/null 2>&1; then
  echo "launch.process=Pinemeter"
  echo "launch.running=true"
else
  echo "launch.running=false"
  exit 3
fi
PREF_FILE="\$HOME/Library/Preferences/ca.pineit.Pinemeter.plist"
if [ -e "\$PREF_FILE" ]; then
  echo "preferences.file=present"
else
  echo "preferences.file=missing"
fi
REMOTE_LAUNCH
}

run_remote() {
  ssh "${SSH_OPTS[@]}" "$REMOTE" "$@" | tee -a "$EVIDENCE_FILE"
}

write_header() {
  {
    echo "# Pinemeter VM validate"
    date -u '+timestamp_utc=%Y-%m-%dT%H:%M:%SZ'
    echo "target=${REMOTE}"
    echo "install_path=${INSTALL_PATH}"
    echo "mode=${MODE}"
    echo "launch_args=${LAUNCH_ARGS:-none}"
    echo "secret_policy=no cookie dbs, keychain values, tokens, auth headers, or browser storage contents are read or printed"
    echo
  } > "$EVIDENCE_FILE"
}

do_dry_run() {
  local app_candidate
  app_candidate=$(find_app_path || true)
  log "dry_run=true"
  log "app_path=${app_candidate:-not-found}"
  log "would_install_to=${INSTALL_PATH}"
  log "would_reset_preferences=ca.pineit.Pinemeter"
  log "would_delete_keychain=ca.pineit.pinemeter.sessionkey/default"
  log "would_delete_keychain=com.pinemeter.chatgpt.session/chatgpt.com"
  log "would_launch=${INSTALL_PATH}"
}

do_install() {
  local app_candidate
  app_candidate=$(find_app_path)
  if [[ -z "$app_candidate" || ! -d "$app_candidate" ]]; then
    log "result=missing_app_bundle"
    log "category=local_build_output_missing"
    exit 2
  fi
  log "app_path=${app_candidate}"
  log "app_bundle_exists=true"
  log "install.start=true"
  tar -C "$(dirname "$app_candidate")" -czf - "$(basename "$app_candidate")" \
    | ssh "${SSH_OPTS[@]}" "$REMOTE" "set -euo pipefail; killall Pinemeter >/dev/null 2>&1 || true; rm -rf /tmp/pinemeter-install; mkdir -p /tmp/pinemeter-install; tar -xzf - -C /tmp/pinemeter-install; sudo rm -rf '$INSTALL_PATH'; sudo ditto /tmp/pinemeter-install/Pinemeter.app '$INSTALL_PATH'; sudo xattr -dr com.apple.quarantine '$INSTALL_PATH' >/dev/null 2>&1 || true; test -d '$INSTALL_PATH'; echo install.complete=true" \
    | tee -a "$EVIDENCE_FILE"
}

do_reset() {
  log "reset.start=true"
  remote_reset_script | ssh "${SSH_OPTS[@]}" "$REMOTE" 'bash -s' | tee -a "$EVIDENCE_FILE"
}

do_launch() {
  log "launch.start=true"
  remote_launch_script | ssh "${SSH_OPTS[@]}" "$REMOTE" 'bash -s' | tee -a "$EVIDENCE_FILE"
}

write_header

case "$MODE" in
  dry-run) do_dry_run ;;
  install) do_install ;;
  reset) do_reset ;;
  launch) do_launch ;;
  all) do_install; do_reset; do_launch ;;
  *) echo "Unhandled mode: $MODE" >&2; exit 64 ;;
esac

log "evidence_file=${EVIDENCE_FILE}"
