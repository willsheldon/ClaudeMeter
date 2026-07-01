---
id: T01
parent: S03
milestone: M005
key_files:
  - .github/workflows/release.yml
  - Pinemeter.xcodeproj/project.pbxproj
  - README.md
  - CHANGELOG.md
key_decisions:
  - Confirmed the official release signing identity remains pinned to Developer ID Application: AUTIMO SYSTEMS INC (HMR9RDR6M2) and TeamIdentifier HMR9RDR6M2 rather than a generic Developer ID identity or mutable APPLE_TEAM_ID secret.
duration: 
verification_result: passed
completed_at: 2026-07-01T22:02:07.147Z
blocker_discovered: false
---

# T01: Audited release and signing surfaces for pinned Autimo Developer ID identity, safe local verification guidance, and remote-publishing mutation points.

**Audited release and signing surfaces for pinned Autimo Developer ID identity, safe local verification guidance, and remote-publishing mutation points.**

## What Happened

Inspected `.github/workflows/release.yml`, `Pinemeter.xcodeproj/project.pbxproj`, `README.md`, and `CHANGELOG.md` against the slice goal of documenting release practices safely without publishing or mutating remote state.

Findings:
- The release workflow pins `EXPECTED_SIGNING_IDENTITY` to `Developer ID Application: AUTIMO SYSTEMS INC (HMR9RDR6M2)` and `EXPECTED_TEAM_ID` to `HMR9RDR6M2`.
- The Xcode project pins `CODE_SIGN_IDENTITY = "Developer ID Application: AUTIMO SYSTEMS INC (HMR9RDR6M2)";` and `DEVELOPMENT_TEAM = HMR9RDR6M2;` for app and test target build configurations.
- The workflow rejects generic `Developer ID Application` project/workflow assumptions and rejects mutable `APPLE_TEAM_ID`-style workflow secrets.
- The workflow verifies installed certificate presence before build and verifies the built app signature contains `Authority=$EXPECTED_SIGNING_IDENTITY` and `TeamIdentifier=$EXPECTED_TEAM_ID` after signing.
- README documents safe local release-surface checks and warns that the manual release workflow publishes artifacts.
- CHANGELOG records the release signing safety documentation and preflight audit change.
- Remote mutation surfaces are explicitly identified: GitHub Release creation through `contents: write` and Homebrew tap clone/commit/push via `HOMEBREW_TAP_TOKEN`.

## Failure Modes

External dependencies and failure paths audited:
- GitHub Actions filesystem/project files: missing or malformed `.github/workflows/release.yml`, `Pinemeter.xcodeproj/project.pbxproj`, `README.md`, or `CHANGELOG.md` causes the verification script to fail before reporting success.
- Apple signing certificate/keychain: the workflow checks `security find-certificate -c "$EXPECTED_SIGNING_IDENTITY"`; missing or wrong certificate emits a GitHub Actions error, lists available identities for diagnosis, removes the temporary `.p12`, and exits.
- Xcode/codesign subprocesses: release build and signature verification bubble nonzero subprocess exits through `set -e` or explicit `exit 1`; post-build signature details are printed for diagnosis.
- Apple notarization service/network/API credentials: `xcrun notarytool submit --wait` output is captured; non-accepted notarization fetches the detailed notarization log, removes temporary AuthKey/zip artifacts, and exits.
- GitHub release and Homebrew publishing network/token surfaces: these are still mutating release steps by design, but README and workflow diagnostics identify them so local signing checks are not performed by running the publishing workflow.

## Load Profile

This task has no runtime load dimension. The audited surfaces are manual release workflow files, static project signing settings, and documentation. At 10x expected release frequency, the first likely operational saturation point would be external Apple/GitHub/Homebrew network/API reliability rather than in-app resource usage; this task does not add runtime pooling, rate limiting, pagination, or caching.

## Negative Tests

Negative surfaces covered by the read-only verification script:
- Generic project signing identity (`CODE_SIGN_IDENTITY = Developer ID Application`) is rejected.
- Generic workflow signing identity is rejected.
- Mutable `APPLE_TEAM_ID` secret/env usage in the workflow is rejected.
- Missing pinned project identity/team settings are rejected.
- Missing expected workflow identity/team env values are rejected.
- Missing workflow certificate preflight, authority verification, team verification, remote mutation diagnostics, README release warning, or CHANGELOG entry are rejected.

These checks are encoded as inline shell assertions in GSD evidence `855d2097-8f02-4955-93ad-fdba171a1b72`; no separate source test file was added because the task is a documentation/release-surface audit and the plan’s verification contract is summary evidence rather than a product test suite.

## Verification

Ran a read-only `gsd_exec` verification script over the release workflow, Xcode project, README, and CHANGELOG. The final run passed, confirming pinned signing identity/team, no generic Developer ID identity, no mutable `APPLE_TEAM_ID` workflow secret dependency, documented release safety guidance, and documented remote mutation surfaces. An earlier verification attempt (`7ba9a6f0-ed96-41d0-9c4f-90b0c4b764f8`) had passing audit assertions but a non-portable timing expression caused a shell arithmetic failure; the final evidence fixed timing and exited 0.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `gsd_exec purpose='release signing audit verification final' bash read-only audit of .github/workflows/release.yml Pinemeter.xcodeproj/project.pbxproj README.md CHANGELOG.md` | 0 | ✅ pass | 54ms |

## Deviations

No source edits were required during this execution turn; the expected release workflow, project signing, README, and CHANGELOG audit surfaces were already present in the active worktree and were verified read-only.

## Known Issues

None. The release workflow intentionally retains remote-publishing steps; README and workflow diagnostics warn not to use workflow dispatch as a local signing-only check.

## Files Created/Modified

- `.github/workflows/release.yml`
- `Pinemeter.xcodeproj/project.pbxproj`
- `README.md`
- `CHANGELOG.md`
