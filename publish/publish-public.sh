#!/usr/bin/env bash
#
# publish-public.sh — mirror this internal repo to the public PineIT-ca/pinemeter
# repository with internal tooling stripped and identifying details anonymized,
# then publish a fresh notarized installer DMG as a GitHub Release asset.
#
# The public repo is published as a SINGLE squashed orphan commit authored by
# "Pineit <hello@pineit.ca>". Each run force-pushes a brand-new one-commit
# history, so old binaries never accumulate in the public git history.
#
# Usage:
#   publish/publish-public.sh                 # build, notarize, push, publish GitHub Release
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
PUBLIC_REPO="PineIT-ca/pinemeter"
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
  ".planning"
  "AGENTS.md"
  "CLAUDE.md"
  "RELEASING.md"
  "build"
  "work-to-date.md"
  "scripts/vm_validation"
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

  local ssm_hint=""
  command -v mysecrets >/dev/null && ssm_hint=" (if the key/issuer live in SSM, the AWS SSO session may have expired — run: aws sso login --profile sso-ws-claude)"
  [[ -f "$key_path" ]] || die "notary key not found at $key_path — set APP_STORE_CONNECT_KEY, store APP_STORE_CONNECT_API_KEY_BASE64 in SSM, or pass --no-notarize.${ssm_hint}"
  [[ -n "$issuer" ]] || die "notary issuer id missing — set APP_STORE_CONNECT_ISSUER_ID in SSM/env, or pass --no-notarize.${ssm_hint}"

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

# Next release version: patch-bump the latest published release, but honor a
# higher MAJOR.MINOR floor from the app's MARKETING_VERSION (a manual line bump).
# No prior release -> start MARKETING_VERSION's line at .0.
next_version() {
  local latest base bMaj bMin lMaj lMin lPat
  latest="$(gh api "repos/$PUBLIC_REPO/releases/latest" --jq '.tag_name' 2>/dev/null || true)"
  latest="${latest#v}"
  base="$(grep -m1 'MARKETING_VERSION' "$REPO_ROOT/Pinemeter.xcodeproj/project.pbxproj" 2>/dev/null | sed -E 's/.*= *([^;]+);.*/\1/' | tr -d ' ')"
  if [[ "$base" =~ ^([0-9]+)\.([0-9]+) ]]; then bMaj=${BASH_REMATCH[1]}; bMin=${BASH_REMATCH[2]}; else bMaj=1; bMin=0; fi
  if [[ "$latest" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
    lMaj=${BASH_REMATCH[1]}; lMin=${BASH_REMATCH[2]}; lPat=${BASH_REMATCH[3]}
  elif [[ "$latest" =~ ^([0-9]+)\.([0-9]+)$ ]]; then
    lMaj=${BASH_REMATCH[1]}; lMin=${BASH_REMATCH[2]}; lPat=0
  else
    printf '%s.%s.0' "$bMaj" "$bMin"; return
  fi
  if (( bMaj > lMaj )) || { (( bMaj == lMaj )) && (( bMin > lMin )); }; then
    printf '%s.%s.0' "$bMaj" "$bMin"
  else
    printf '%s.%s.%s' "$lMaj" "$lMin" "$((lPat + 1))"
  fi
}

# Monotonic integer build number encoded from the semantic version (1.2.3 -> 10203).
build_number() {
  local v="$1" M m p
  M="${v%%.*}"; v="${v#*.}"; m="${v%%.*}"; p="${v#*.}"
  printf '%d' "$(( 10#$M * 10000 + 10#$m * 100 + 10#$p ))"
}

# Body of the topmost CHANGELOG section (e.g. [Unreleased] or the newest version),
# leading/trailing blank lines trimmed. Empty if the changelog has no section.
release_notes() {
  awk '
    /^## \[/ { if (found) exit; found=1; next }
    found { lines[n++] = $0 }
    END {
      s = 0;   while (s < n   && lines[s] ~ /^[[:space:]]*$/) s++
      e = n-1; while (e >= s  && lines[e] ~ /^[[:space:]]*$/) e--
      for (i = s; i <= e; i++) print lines[i]
    }
  ' "$REPO_ROOT/CHANGELOG.md" 2>/dev/null
}

# Publish the notarized DMG as a GitHub Release asset (not committed to git).
# Each publish uses a fresh auto-incremented tag, so releases accumulate as history.
release_dmg() {
  local dmg="$1" tag="$2" notes_file="$STAGE/release-notes.md" body
  command -v gh >/dev/null || die "gh not found: cannot publish the GitHub Release"
  body="$(release_notes)"
  {
    [[ -n "$body" ]] && printf '### What'\''s changed\n\n%s\n\n---\n\n' "$body"
    printf 'Universal (Apple Silicon & Intel), Developer ID signed and notarized. Download **%s** below, open it, and drag **Pinemeter** into **Applications**.\n' "$DMG_NAME"
  } > "$notes_file"
  log "Publishing GitHub Release $tag to $PUBLIC_REPO"
  gh release create "$tag" "$dmg" \
    --repo "$PUBLIC_REPO" \
    --target "$PUBLIC_BRANCH" \
    --latest \
    --title "Pinemeter $tag" \
    --notes-file "$notes_file" \
    || die "gh release create failed for $tag"
  log "Release live: $PUBLIC_URL/releases/latest/download/$DMG_NAME"
}

# Generate the signed Sparkle feed before the public tree is committed. The
# enclosure points at the versioned release URL that release_dmg publishes
# immediately after the public source push.
create_appcast() {
  local dmg="$1" version="$2" private_key tool input_dir
  private_key="$(ssm_get SPARKLE_ED25519_PRIVATE_KEY)"
  [[ -n "$private_key" ]] \
    || die "SPARKLE_ED25519_PRIVATE_KEY missing from project SSM"

  tool="${DD:-}/SourcePackages/artifacts/sparkle/Sparkle/bin/generate_appcast"
  if [[ ! -x "$tool" ]]; then
    local tools_dd="$STAGE/sparkle-tools"
    log "Resolving Sparkle publishing tools"
    ( cd "$REPO_ROOT" && xcodebuild -resolvePackageDependencies \
        -project Pinemeter.xcodeproj \
        -scheme Pinemeter \
        -derivedDataPath "$tools_dd" \
        >"$STAGE/sparkle-tools.log" 2>&1 ) \
      || { tail -40 "$STAGE/sparkle-tools.log" >&2; die "Sparkle tool resolution failed"; }
    tool="$tools_dd/SourcePackages/artifacts/sparkle/Sparkle/bin/generate_appcast"
  fi
  [[ -x "$tool" ]] || die "Sparkle generate_appcast tool not found"

  input_dir="$STAGE/sparkle"
  mkdir -p "$input_dir"
  cp "$dmg" "$input_dir/$DMG_NAME"
  printf '%s' "$private_key" | "$tool" \
    --ed-key-file - \
    --download-url-prefix "$PUBLIC_URL/releases/download/v$version/" \
    --link "https://pineit-ca.github.io/pinemeter/" \
    "$input_dir"
  unset private_key

  [[ -f "$input_dir/appcast.xml" ]] || die "Sparkle appcast was not generated"
  cp "$input_dir/appcast.xml" "$STAGE/tree/site/appcast.xml"
  grep -q 'sparkle:edSignature=' "$STAGE/tree/site/appcast.xml" \
    || die "Sparkle appcast is missing its EdDSA signature"
  log "Signed Sparkle appcast generated for v$version"
}

# Ensure Pages exists, then deploy after the release is live so the workflow
# injects the new version rather than the previous release's version.
publish_pages() {
  command -v gh >/dev/null || die "gh not found: cannot deploy GitHub Pages"

  if ! gh api "repos/$PUBLIC_REPO/pages" >/dev/null 2>&1; then
    log "Enabling GitHub Pages with the Actions publishing source"
    gh api --method POST "repos/$PUBLIC_REPO/pages" \
      -f build_type=workflow >/dev/null \
      || die "failed to enable GitHub Pages for $PUBLIC_REPO"
  fi

  local previous_run run_id=""
  previous_run="$(gh run list \
    --repo "$PUBLIC_REPO" \
    --workflow deploy-pages.yml \
    --event workflow_dispatch \
    --limit 1 \
    --json databaseId \
    --jq '.[0].databaseId // empty')"

  log "Dispatching GitHub Pages from $PUBLIC_BRANCH"
  gh workflow run deploy-pages.yml \
    --repo "$PUBLIC_REPO" \
    --ref "$PUBLIC_BRANCH" \
    || die "failed to dispatch GitHub Pages"

  for _ in {1..15}; do
    run_id="$(gh run list \
      --repo "$PUBLIC_REPO" \
      --workflow deploy-pages.yml \
      --event workflow_dispatch \
      --limit 1 \
      --json databaseId \
      --jq '.[0].databaseId // empty')"
    [[ -n "$run_id" && "$run_id" != "$previous_run" ]] && break
    sleep 2
  done

  [[ -n "$run_id" && "$run_id" != "$previous_run" ]] \
    || die "could not find the dispatched GitHub Pages run"
  gh run watch "$run_id" --repo "$PUBLIC_REPO" --exit-status \
    || die "GitHub Pages deployment failed (run $run_id)"
  log "GitHub Pages deployed successfully (run $run_id)"
}

command -v git >/dev/null || die "git not found"
git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  || die "must run inside the internal git repo"

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
# 2b. Compute the auto-incremented release version (patch-bump off the latest
#     published release). Stamped into the app + published source below.
# ---------------------------------------------------------------------------
VERSION=""; BUILD_NUM=""
if [[ "$DO_DMG" -eq 1 ]]; then
  VERSION="$(next_version)"
  BUILD_NUM="$(build_number "$VERSION")"
  log "Auto-incremented release version: v$VERSION (build $BUILD_NUM)"
fi

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

# Stamp the auto-incremented version into the published source so it matches the release.
if [[ "$DO_DMG" -eq 1 && -n "$VERSION" ]]; then
  perl -pi -e "s/MARKETING_VERSION = [^;]+;/MARKETING_VERSION = $VERSION;/g; s/CURRENT_PROJECT_VERSION = [^;]+;/CURRENT_PROJECT_VERSION = $BUILD_NUM;/g" "$PBX"
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
    log "Archiving and exporting Pinemeter.app for Developer ID distribution"
    DD="$STAGE/dd"
    ARCHIVE_PATH="$STAGE/Pinemeter.xcarchive"
    EXPORT_PATH="$STAGE/export"
    EXPORT_OPTIONS="$STAGE/ExportOptions.plist"
    plutil -create xml1 "$EXPORT_OPTIONS"
    plutil -insert method -string developer-id "$EXPORT_OPTIONS"
    plutil -insert teamID -string "$REAL_TEAM_ID" "$EXPORT_OPTIONS"
    plutil -insert signingStyle -string manual "$EXPORT_OPTIONS"
    plutil -insert signingCertificate -string "$REAL_SIGN_IDENTITY" "$EXPORT_OPTIONS"

    # Archive + export makes Xcode re-sign Sparkle's nested helpers with the
    # distribution identity, hardened runtime, and secure timestamps.
    ( cd "$REPO_ROOT" && xcodebuild archive \
        -project Pinemeter.xcodeproj \
        -scheme Pinemeter \
        -configuration Release \
        -derivedDataPath "$DD" \
        -archivePath "$ARCHIVE_PATH" \
        -arch x86_64 -arch arm64 ONLY_ACTIVE_ARCH=NO \
        MARKETING_VERSION="$VERSION" CURRENT_PROJECT_VERSION="$BUILD_NUM" \
        CODE_SIGN_STYLE=Manual \
        CODE_SIGN_IDENTITY="$REAL_SIGN_IDENTITY" \
        DEVELOPMENT_TEAM="$REAL_TEAM_ID" \
        CODE_SIGN_INJECT_BASE_ENTITLEMENTS=NO \
        OTHER_CODE_SIGN_FLAGS="--timestamp --options runtime" \
        >"$STAGE/archive.log" 2>&1 ) \
      || { tail -40 "$STAGE/archive.log" >&2; die "Release archive failed"; }
    xcodebuild -exportArchive \
      -archivePath "$ARCHIVE_PATH" \
      -exportPath "$EXPORT_PATH" \
      -exportOptionsPlist "$EXPORT_OPTIONS" \
      >"$STAGE/export.log" 2>&1 \
      || { tail -40 "$STAGE/export.log" >&2; die "Developer ID export failed"; }
    APP_PATH="$EXPORT_PATH/Pinemeter.app"
  else
    warn "--app given: shipping $VERSION as the release tag, but the prebuilt app keeps its own embedded version"
  fi
  [[ -d "$APP_PATH" ]] || die "Pinemeter.app not found at: $APP_PATH"

  # Fail fast (before the slow notary round-trip) if the app is not distribution-signed.
  # Capture into vars and match in bash — a `... | grep -q` pipe would SIGPIPE codesign
  # and, under `set -o pipefail`, report a false failure.
  if [[ "$DO_NOTARIZE" -eq 1 ]]; then
    codesign --verify --deep --strict "$APP_PATH" \
      || die "app contains an invalid nested code signature"
    ent_info="$(codesign -d --entitlements - "$APP_PATH" 2>&1 || true)"
    [[ "$ent_info" == *get-task-allow* ]] \
      && die "app requests get-task-allow (not distribution-signed) — notarization would fail; rebuild without --app"

    sparkle_root="$APP_PATH/Contents/Frameworks/Sparkle.framework/Versions/Current"
    distribution_targets=(
      "$APP_PATH"
      "$sparkle_root/Autoupdate"
      "$sparkle_root/Updater.app"
      "$sparkle_root/XPCServices/Downloader.xpc"
      "$sparkle_root/XPCServices/Installer.xpc"
    )
    for distribution_target in "${distribution_targets[@]}"; do
      sig_info="$(codesign -dvv "$distribution_target" 2>&1 || true)"
      [[ "$sig_info" == *"Authority=$REAL_SIGN_IDENTITY"* ]] \
        || die "$(basename "$distribution_target") is not signed by $REAL_SIGN_IDENTITY"
      [[ "$sig_info" == *"Timestamp="* ]] \
        || die "$(basename "$distribution_target") has no secure timestamp"
    done
  fi

  log "Packaging $DMG_NAME from $(basename "$APP_PATH")"
  # Built outside the git tree — it ships as a GitHub Release asset, not a repo file.
  DMG_OUT="$STAGE/$DMG_NAME"
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

  if [[ "$DRY_RUN" -eq 0 ]]; then
    create_appcast "$DMG_OUT" "$VERSION"
  else
    warn "Sparkle appcast signing skipped during dry run"
  fi

  # Big, bold download button at the top of the README, linking to the latest
  # GitHub Release asset (idempotent).
  if [[ -f README.md ]] && ! grep -qF "releases/latest/download/$DMG_NAME" README.md; then
    DL_URL="$PUBLIC_URL/releases/latest/download/$DMG_NAME" \
    perl -0777 -pi -e '
      my $u = $ENV{DL_URL};
      my $btn = "\n<p align=\"center\">\n"
        . "  <a href=\"$u\">\n"
        . "    <img src=\"https://img.shields.io/badge/Download%20Pinemeter-for%20macOS-2D5A45?style=for-the-badge&logo=apple&logoColor=white\" alt=\"Download Pinemeter for macOS\" height=\"46\">\n"
        . "  </a>\n"
        . "</p>\n"
        . "<p align=\"center\"><sub>Universal &bull; Apple Silicon &amp; Intel &bull; Developer ID notarized &bull; macOS 14+</sub></p>\n";
      s/(\*\*All your AI usage\. One glance\.\*\*\n)/$1$btn/;
    ' README.md
  fi
else
  log "Skipping DMG (--no-dmg)"
fi

# ---------------------------------------------------------------------------
# 8. Guard: no internal identifiers survived into the staged tree.
# ---------------------------------------------------------------------------
log "Verifying no internal identifiers remain"
if grep -rIlE 'HMR9RDR6M2|AUTIMO SYSTEMS INC' . 2>/dev/null; then
  die "internal signing identifiers leaked into staged tree (see above)"
fi
for p in AGENTS.md CLAUDE.md RELEASING.md .gsd .planning .mcp.json; do
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
git add -A
git commit -q --author="$COMMIT_AUTHOR" -m "$COMMIT_MESSAGE"

if [[ "$DO_PUSH" -eq 1 ]]; then
  log "Force-pushing to $PUBLIC_REMOTE ($PUBLIC_BRANCH)"
  git remote add origin "$PUBLIC_REMOTE"
  git push --force origin "$PUBLIC_BRANCH"
  log "Done. Published $(git rev-parse --short HEAD) to $PUBLIC_REMOTE"
  if [[ "$DO_DMG" -eq 1 && -n "${DMG_OUT:-}" && -f "$DMG_OUT" ]]; then
    release_dmg "$DMG_OUT" "v$VERSION"
  fi
  publish_pages
else
  log "Committed locally (no push). Inspect: $STAGE/tree"
  trap - EXIT
  echo "(staging kept at $STAGE/tree)"
fi
