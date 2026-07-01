# Releasing Pinemeter

This document describes the safe local checks to run before triggering the manual release workflow. It intentionally separates non-destructive verification from steps that publish artifacts or mutate remote repositories.

## Official signing identity

Release artifacts must be signed with the pinned Autimo Developer ID identity:

- Signing identity: `Developer ID Application: AUTIMO SYSTEMS INC (HMR9RDR6M2)`
- Expected Team Identifier: `TeamIdentifier=HMR9RDR6M2`
- Expected development team value: `HMR9RDR6M2`

Do not replace this with the generic `Developer ID Application` identity. Do not introduce a mutable `APPLE_TEAM_ID` or similar secret for release signing; the release path must continue to pin and verify the Autimo team identifier explicitly.

## Non-destructive local verification

These checks read local files or local build artifacts only. They do not push commits, create GitHub releases, update the Homebrew tap, notarize, or publish anything.

### Check pinned release configuration

```bash
EXPECTED_SIGNING_IDENTITY="Developer ID Application: AUTIMO SYSTEMS INC (HMR9RDR6M2)"
EXPECTED_TEAM_ID="HMR9RDR6M2"

grep -F "CODE_SIGN_IDENTITY = \"$EXPECTED_SIGNING_IDENTITY\";" Pinemeter.xcodeproj/project.pbxproj
grep -F "DEVELOPMENT_TEAM = $EXPECTED_TEAM_ID;" Pinemeter.xcodeproj/project.pbxproj
grep -F "EXPECTED_SIGNING_IDENTITY: \"$EXPECTED_SIGNING_IDENTITY\"" .github/workflows/release.yml
grep -F "EXPECTED_TEAM_ID: $EXPECTED_TEAM_ID" .github/workflows/release.yml
```

### Check a built release artifact locally

After a local release build exists at `build/Build/Products/Release/Pinemeter.app`, verify the signature details before considering any publishing step:

```bash
APP_PATH="build/Build/Products/Release/Pinemeter.app"
EXPECTED_SIGNING_IDENTITY="Developer ID Application: AUTIMO SYSTEMS INC (HMR9RDR6M2)"
EXPECTED_TEAM_ID="HMR9RDR6M2"

codesign -vvv --deep --strict "$APP_PATH"
SIGNATURE_DETAILS=$(codesign -dvv "$APP_PATH" 2>&1)
echo "$SIGNATURE_DETAILS"
echo "$SIGNATURE_DETAILS" | grep -F "Authority=$EXPECTED_SIGNING_IDENTITY"
echo "$SIGNATURE_DETAILS" | grep -F "TeamIdentifier=$EXPECTED_TEAM_ID"
codesign -d --entitlements - "$APP_PATH"
```

For an installed or downloaded app, the same signature checks can be run against that `.app` path. The important release invariant is that `Authority=Developer ID Application: AUTIMO SYSTEMS INC (HMR9RDR6M2)` and `TeamIdentifier=HMR9RDR6M2` both appear in the `codesign -dvv` output.

## Publishing and remote mutation boundaries

The GitHub Actions release workflow is manual, but it is not just a local verification job. Once triggered with valid secrets, it can mutate remote state:

- Creates a GitHub release using `contents: write` and uploads the ZIP artifact.
- Clones, commits to, and runs `git push` against the Homebrew tap using `HOMEBREW_TAP_TOKEN`.
- Submits the app to Apple notarization with App Store Connect credentials.

Do not trigger, re-run, or modify these publishing steps as a signing check. Workflow dispatch, publishing, `git push`, `gh release`, Homebrew tap updates, notarization submissions, tag changes, or history rewriting require explicit maintainer confirmation for the intended version and target repository.

## Failure diagnostics

If signing verification fails, inspect the failing surface before retrying any release:

1. Confirm `Pinemeter.xcodeproj/project.pbxproj` still contains `CODE_SIGN_IDENTITY = "Developer ID Application: AUTIMO SYSTEMS INC (HMR9RDR6M2)";` and `DEVELOPMENT_TEAM = HMR9RDR6M2;`.
2. Confirm `.github/workflows/release.yml` still exports `EXPECTED_SIGNING_IDENTITY` and `EXPECTED_TEAM_ID` with the official values.
3. Confirm the imported Apple certificate contains `Developer ID Application: AUTIMO SYSTEMS INC (HMR9RDR6M2)` before building.
4. Inspect `codesign -dvv` output for the produced app and verify `TeamIdentifier=HMR9RDR6M2`.
5. Treat any generic `Developer ID Application` match without `AUTIMO SYSTEMS INC (HMR9RDR6M2)` as unsafe for release artifacts.

Keep secrets out of logs and documentation. The release documentation should name required secret keys only when needed for diagnosis, never their values.
