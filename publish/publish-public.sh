#!/usr/bin/env bash
#
# publish-public.sh — mirror this internal repo to the public PineIT-ca/pinemeter
# repository with internal tooling stripped and identifying details anonymized,
# then attach a fresh installer DMG under releases/.
#
# The public repo is published as a SINGLE squashed orphan commit authored by
# "Pineit <hello@pineit.ca>". Each run force-pushes a brand-new one-commit
# history, so old binaries never accumulate in the public git history.
#
# Usage:
#   publish/publish-public.sh                 # build Release, package DMG, notarize, push
#   publish/publish-public.sh --app PATH.app  # reuse an already-built .app
#   publish/publish-public.sh --no-dmg        # skip the installer DMG
#   publish/publish-public.sh --no-notarize   # build+staple skipped; ship unnotarized DMG
#   publish/publish-public.sh --no-push       # stage + commit locally, do not push
#   publish/publish-public.sh --dry-run       # build staging tree only, show tree, stop
#
# Notarization uses an App Store Connect API key. Resolution order for each of
# APP_STORE_CONNECT_ISSUER_ID / _KEY_ID / the .p8 key: process env, then project
# SSM (via `mysecrets run`), then the notarytool default key location
# ~/.private_keys/AuthKey_<KEY_ID>.p8. Store the issuer once with:
#   mysecrets set APP_STORE_CONNECT_ISSUER_ID <uuid>
#
set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
PUBLIC_REMOTE="git@github.com:PineIT-ca/pinemeter.git"
PUBLIC_BRANCH="main"
COMMIT_AUTHOR="Pineit <hello@pineit.ca>"
COMMIT_MESSAGE="Pinemeter: AI usage meters for the macOS menu bar"
DMG_NAME="Pinemeter.dmg"
VOLUME_NAME="Pinemeter"

# Internal-only paths removed before publishing (relative to repo root).
STRIP_PATHS=(
  ".bg-shell"
  ".claude"
  ".gsd"
  ".gsd-backups"
  ".gsd-id"
  ".gsd-worktrees"
  ".mcp.json"
  "AGENTS.md"
  "CLAUDE.md"
  "RELEASING.md"
  "build"
  "work-to-date.md"
  "scripts/vm_validation"
  ".github/workflows/release.yml"
  "publish"
)

# Real signing identity pinned for local/CI release builds. Scrubbed to the
# generic Developer ID so public forkers do not inherit the pinned team.
REAL_SIGN_IDENTITY='Developer ID Application: AUTIMO SYSTEMS INC (HMR9RDR6M2)'
REAL_TEAM_ID='HMR9RDR6M2'

# Upstream repo links that must point at the published fork on live surfaces
# (issue templates, marketing site). Attribution links in README/CHANGELOG are
# left pointing at the upstream author on purpose.
UPSTREAM_URL='https://github.com/eddmann/Pinemeter'
PUBLIC_URL='https://github.com/PineIT-ca/pinemeter'
RELOCATE_URL_FILES=(
  ".github/ISSUE_TEMPLATE/config.yml"
  "site/index.html"
)

# Apple notarization (App Store Connect API key). The Autimo key lives at the
# notarytool default location; the issuer resolves from env/SSM at run time.
NOTARY_KEY_ID="${APP_STORE_CONNECT_KEY_ID:-NR4JSA5M6L}"
NOTARY_KEY_PATH="${APP_STORE_CONNECT_KEY:-$HOME/.private_keys/AuthKey_${NOTARY_KEY_ID}.p8}"
NOTARY_ISSUER="${APP_STORE_CONNECT_ISSUER_ID:-}"

# ---------------------------------------------------------------------------
# Args
# ---------------------------------------------------------------------------
APP_PATH=""
DO_DMG=1
DO_PUSH=1
DO_NOTARIZE=1
DRY_RUN=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --app) APP_PATH="${2:?--app needs a path}"; shift 2 ;;
    --no-dmg) DO_DMG=0; shift ;;
    --no-notarize) DO_NOTARIZE=0; shift ;;
    --no-push) DO_PUSH=0; shift ;;
    --dry-run) DRY_RUN=1; DO_PUSH=0; shift ;;
    -h|--help) sed -n '2,26p' "$0"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

log() { printf '\033[1;32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarn:\033[0m %s\n' "$*" >&2; }
die() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

# Read a single APP_STORE_CONNECT_* value from project SSM without echoing it.
# Must run from REPO_ROOT: mysecrets resolves the project (and its ssm_path) from
# CWD, and by call time CWD is the staging tree with the project markers stripped.
ssm_get() { ( cd "$REPO_ROOT" && mysecrets run -- bash -c 'printf "%s" "${'"$1"':-}"' ) 2>/dev/null || true; }

# Notarize a DMG with Apple and staple the ticket in place.
notarize_dmg() {
  local dmg="$1" app="${2:-}"
  local issuer="$NOTARY_ISSUER" key_id="$NOTARY_KEY_ID" key_path="$NOTARY_KEY_PATH"

  if command -v mysecrets >/dev/null; then
    [[ -z "$issuer" ]] && issuer="$(ssm_get APP_STORE_CONNECT_ISSUER_ID)"
    local ssm_keyid; ssm_keyid="$(ssm_get APP_STORE_CONNECT_KEY_ID)"
    if [[ -n "$ssm_keyid" && -z "${APP_STORE_CONNECT_KEY_ID:-}" ]]; then
      key_id="$ssm_keyid"; key_path="${APP_STORE_CONNECT_KEY:-$HOME/.private_keys/AuthKey_${key_id}.p8}"
    fi
    if [[ ! -f "$key_path" ]]; then
      local ssm_b64; ssm_b64="$(ssm_get APP_STORE_CONNECT_API_KEY_BASE64)"
      if [[ -n "$ssm_b64" ]]; then
        key_path="$STAGE/AuthKey_${key_id}.p8"
        printf '%s' "$ssm_b64" | base64 --decode > "$key_path"
      fi
    fi
  fi

  [[ -f "$key_path" ]] || die "notary key not found at $key_path — set APP_STORE_CONNECT_KEY, store APP_STORE_CONNECT_API_KEY_BASE64 in SSM, or pass --no-notarize"
  [[ -n "$issuer" ]] || die "notary issuer id missing — run 'mysecrets set APP_STORE_CONNECT_ISSUER_ID <uuid>' (or export APP_STORE_CONNECT_ISSUER_ID), or pass --no-notarize"

  log "Notarizing $(basename "$dmg") with Apple (key $key_id; may take a few minutes)"
  xcrun notarytool submit "$dmg" \
    --key "$key_path" --key-id "$key_id" --issuer "$issuer" \
    --wait --timeout 30m
  log "Stapling and validating the notarization ticket"
  xcrun stapler staple "$dmg"
  xcrun stapler validate "$dmg" || die "stapler validate failed for $dmg"
  # Assess the app itself; the unsigned DMG container is not a valid spctl target.
  if [[ -n "$app" ]]; then
    local gk; gk="$(spctl -a -t exec -vv "$app" 2>&1 || true)"
    [[ "$gk" == *"source=Notarized Developer ID"* ]] \
      && log "Gatekeeper: app accepted as Notarized Developer ID" \
      || warn "Gatekeeper did not confirm the app as Notarized Developer ID"
  fi
}

command -v git >/dev/null || die "git not found"
[[ -d "$REPO_ROOT/.git" ]] || die "must run inside the internal git repo"

STAGE="$(mktemp -d "${TMPDIR:-/tmp}/pinemeter-publish.XXXXXX")"
cleanup() { rm -rf "$STAGE"; }
trap cleanup EXIT

# ---------------------------------------------------------------------------
# 1. Export tracked files at HEAD (clean, no untracked cruft) into staging.
# ---------------------------------------------------------------------------
log "Exporting HEAD ($(git rev-parse --short HEAD)) into staging tree"
mkdir -p "$STAGE/tree"
git archive --format=tar HEAD | tar -x -C "$STAGE/tree"

cd "$STAGE/tree"

# ---------------------------------------------------------------------------
# 2. Strip internal-only paths.
# ---------------------------------------------------------------------------
log "Stripping internal tooling and planning artifacts"
for p in "${STRIP_PATHS[@]}"; do
  rm -rf "./$p"
done
# Belt-and-suspenders: no stray planning/agent files survive.
find . -name ".DS_Store" -delete 2>/dev/null || true

# ---------------------------------------------------------------------------
# 3. Anonymize: scrub the pinned signing identity from the Xcode project.
# ---------------------------------------------------------------------------
log "Scrubbing pinned signing identity from project.pbxproj"
PBX="Pinemeter.xcodeproj/project.pbxproj"
[[ -f "$PBX" ]] || die "missing $PBX in export"
# Literal replacements; perl \Q..\E quotes any regex metacharacters in the value.
REAL_SIGN_IDENTITY="$REAL_SIGN_IDENTITY" \
  perl -pi -e 's/\Q$ENV{REAL_SIGN_IDENTITY}\E/Developer ID Application/g' "$PBX"
REAL_TEAM_ID="$REAL_TEAM_ID" \
  perl -pi -e 's/\QDEVELOPMENT_TEAM = $ENV{REAL_TEAM_ID};\E/DEVELOPMENT_TEAM = "";/g' "$PBX"

if grep -qF "$REAL_TEAM_ID" "$PBX"; then
  die "team id $REAL_TEAM_ID still present in $PBX after scrub"
fi

# ---------------------------------------------------------------------------
# 4. Anonymize: point live repo links at the published fork.
# ---------------------------------------------------------------------------
log "Relocating live repo links to the published fork"
for f in "${RELOCATE_URL_FILES[@]}"; do
  [[ -f "$f" ]] || { warn "relocate target missing: $f"; continue; }
  UPSTREAM_URL="$UPSTREAM_URL" PUBLIC_URL="$PUBLIC_URL" \
    perl -pi -e 's/\Q$ENV{UPSTREAM_URL}\E/$ENV{PUBLIC_URL}/g' "$f"
done

# ---------------------------------------------------------------------------
# 5. Anonymize: ensure the Pineit modifications copyright line in LICENSE.
# ---------------------------------------------------------------------------
if [[ -f LICENSE ]] && ! grep -qF "Pineit (pineit.ca) for modifications" LICENSE; then
  log "Adding Pineit modifications copyright to LICENSE"
  perl -0777 -pi -e 's/(MIT License\n\n)/${1}Copyright (c) 2026 Pineit (pineit.ca) for modifications\n/' LICENSE
fi

# ---------------------------------------------------------------------------
# 6. Anonymize: collapse the GSD ignore rules in .gitignore.
# ---------------------------------------------------------------------------
if [[ -f .gitignore ]]; then
  log "Rewriting private-tooling rules in .gitignore"
  grep -viE 'gsd|\.claude/|\.bg-shell/|\.mcp\.json' .gitignore > .gitignore.tmp || true
  cat >> .gitignore.tmp <<'EOF'

# Private planning/tooling artifacts (never published)
.gsd/
.gsd-id
.gsd-backups/
.gsd-worktrees/
.claude/
.bg-shell/
.mcp.json
EOF
  mv .gitignore.tmp .gitignore
fi

# ---------------------------------------------------------------------------
# 7. Build + package the installer DMG (unless skipped) and link it in README.
# ---------------------------------------------------------------------------
if [[ "$DO_DMG" -eq 1 ]]; then
  if [[ -z "$APP_PATH" ]]; then
    log "Building Release Pinemeter.app (universal, Developer ID, hardened runtime + secure timestamp)"
    DD="$STAGE/dd"
    # Distribution signing, mirroring the release workflow: strip the base
    # (get-task-allow) entitlements and add a secure timestamp + hardened runtime,
    # all of which Apple's notary service requires.
    ( cd "$REPO_ROOT" && xcodebuild clean build \
        -project Pinemeter.xcodeproj \
        -scheme Pinemeter \
        -configuration Release \
        -derivedDataPath "$DD" \
        -arch x86_64 -arch arm64 \
        CODE_SIGN_STYLE=Manual \
        CODE_SIGN_IDENTITY="$REAL_SIGN_IDENTITY" \
        DEVELOPMENT_TEAM="$REAL_TEAM_ID" \
        CODE_SIGN_INJECT_BASE_ENTITLEMENTS=NO \
        OTHER_CODE_SIGN_FLAGS="--timestamp --options runtime" \
        >"$STAGE/build.log" 2>&1 ) || { tail -40 "$STAGE/build.log" >&2; die "Release build failed"; }
    APP_PATH="$DD/Build/Products/Release/Pinemeter.app"
  fi
  [[ -d "$APP_PATH" ]] || die "Pinemeter.app not found at: $APP_PATH"

  # Fail fast (before the slow notary round-trip) if the app is not distribution-signed.
  # Capture into vars and match in bash — a `... | grep -q` pipe would SIGPIPE codesign
  # and, under `set -o pipefail`, report a false failure.
  if [[ "$DO_NOTARIZE" -eq 1 && "$DRY_RUN" -eq 0 ]]; then
    sig_info="$(codesign -dvv "$APP_PATH" 2>&1 || true)"
    ent_info="$(codesign -d --entitlements - "$APP_PATH" 2>&1 || true)"
    [[ "$ent_info" == *get-task-allow* ]] \
      && die "app requests get-task-allow (not distribution-signed) — notarization would fail; rebuild without --app"
    [[ "$sig_info" == *"Timestamp="* ]] \
      || die "app signature has no secure timestamp — notarization would fail; rebuild without --app"
  fi

  log "Packaging $DMG_NAME from $(basename "$APP_PATH")"
  mkdir -p releases
  DMG_OUT="$STAGE/tree/releases/$DMG_NAME"
  if command -v create-dmg >/dev/null; then
    STAGE_APP="$STAGE/dmgsrc"
    rm -rf "$STAGE_APP"; mkdir -p "$STAGE_APP"
    cp -R "$APP_PATH" "$STAGE_APP/"
    create-dmg \
      --volname "$VOLUME_NAME" \
      --app-drop-link 480 170 \
      --icon "Pinemeter.app" 160 170 \
      --window-size 640 360 \
      --no-internet-enable \
      "$DMG_OUT" "$STAGE_APP" >/dev/null 2>&1 \
      || hdiutil create -volname "$VOLUME_NAME" -srcfolder "$APP_PATH" -ov -format UDZO "$DMG_OUT" >/dev/null
  else
    hdiutil create -volname "$VOLUME_NAME" -srcfolder "$APP_PATH" -ov -format UDZO "$DMG_OUT" >/dev/null
  fi
  [[ -f "$DMG_OUT" ]] || die "DMG was not produced"
  log "DMG size: $(du -h "$DMG_OUT" | cut -f1)"

  if [[ "$DO_NOTARIZE" -eq 1 && "$DRY_RUN" -eq 0 ]]; then
    notarize_dmg "$DMG_OUT" "$APP_PATH"
  else
    warn "Notarization skipped — the DMG is signed but not notarized (Gatekeeper will warn on first open)"
  fi

  # Insert a Download section pointing at the in-repo DMG (idempotent).
  if [[ -f README.md ]] && ! grep -qF "releases/$DMG_NAME" README.md; then
    DMG_NAME="$DMG_NAME" perl -0777 -pi -e '
      my $block = "### Download\n\nGrab the latest signed build: **[$ENV{DMG_NAME}](releases/$ENV{DMG_NAME})**. "
        . "Open the disk image and drag **Pinemeter** into **Applications**. "
        . "On first launch, right-click the app and choose **Open** if macOS asks to verify it.\n\n";
      s/(## Installation\n\n)(### Build from source)/${1}${block}${2}/;
    ' README.md
  fi
else
  log "Skipping DMG (--no-dmg)"
fi

# ---------------------------------------------------------------------------
# 8. Guard: no internal identifiers survived into the staged tree.
# ---------------------------------------------------------------------------
log "Verifying no internal identifiers remain"
if grep -rIlE 'HMR9RDR6M2|AUTIMO SYSTEMS INC' . 2>/dev/null | grep -v '/releases/'; then
  die "internal signing identifiers leaked into staged tree (see above)"
fi
for p in AGENTS.md CLAUDE.md RELEASING.md .gsd .mcp.json .github/workflows/release.yml; do
  [[ -e "$p" ]] && die "strip failed: $p still present"
done

if [[ "$DRY_RUN" -eq 1 ]]; then
  log "Dry run — staged tree at: $STAGE/tree"
  find . -type f -not -path './.git/*' | sort
  trap - EXIT   # keep staging for inspection
  echo "(staging kept at $STAGE/tree — remove manually when done)"
  exit 0
fi

# ---------------------------------------------------------------------------
# 9. Commit as a single anonymized orphan and force-push.
# ---------------------------------------------------------------------------
log "Creating single squashed commit"
git init -q -b "$PUBLIC_BRANCH"
git config user.name "Pineit"
git config user.email "hello@pineit.ca"
# DMGs are binary; make sure nothing tries to normalize them.
printf '*.dmg binary\n' > .gitattributes
git add -A
git commit -q --author="$COMMIT_AUTHOR" -m "$COMMIT_MESSAGE"

if [[ "$DO_PUSH" -eq 1 ]]; then
  log "Force-pushing to $PUBLIC_REMOTE ($PUBLIC_BRANCH)"
  git remote add origin "$PUBLIC_REMOTE"
  git push --force origin "$PUBLIC_BRANCH"
  log "Done. Published $(git rev-parse --short HEAD) to $PUBLIC_REMOTE"
else
  log "Committed locally (no push). Inspect: $STAGE/tree"
  trap - EXIT
  echo "(staging kept at $STAGE/tree)"
fi
