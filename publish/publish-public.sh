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
#   publish/publish-public.sh                 # build Release, package DMG, push
#   publish/publish-public.sh --app PATH.app  # reuse an already-built .app
#   publish/publish-public.sh --no-dmg        # skip the installer DMG
#   publish/publish-public.sh --no-push       # stage + commit locally, do not push
#   publish/publish-public.sh --dry-run       # build staging tree only, show tree, stop
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

# ---------------------------------------------------------------------------
# Args
# ---------------------------------------------------------------------------
APP_PATH=""
DO_DMG=1
DO_PUSH=1
DRY_RUN=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --app) APP_PATH="${2:?--app needs a path}"; shift 2 ;;
    --no-dmg) DO_DMG=0; shift ;;
    --no-push) DO_PUSH=0; shift ;;
    --dry-run) DRY_RUN=1; DO_PUSH=0; shift ;;
    -h|--help) sed -n '2,20p' "$0"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

log() { printf '\033[1;32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarn:\033[0m %s\n' "$*" >&2; }
die() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

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
    log "Building Release Pinemeter.app"
    DD="$STAGE/dd"
    ( cd "$REPO_ROOT" && xcodebuild build \
        -project Pinemeter.xcodeproj \
        -scheme Pinemeter \
        -configuration Release \
        -derivedDataPath "$DD" \
        -destination 'generic/platform=macOS' \
        >"$STAGE/build.log" 2>&1 ) || { tail -40 "$STAGE/build.log" >&2; die "Release build failed"; }
    APP_PATH="$DD/Build/Products/Release/Pinemeter.app"
  fi
  [[ -d "$APP_PATH" ]] || die "Pinemeter.app not found at: $APP_PATH"

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
