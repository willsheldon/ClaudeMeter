---
id: T02
parent: S03
milestone: M005
key_files:
  - RELEASING.md
  - README.md
key_decisions:
  - Use RELEASING.md as the canonical safe release checklist and keep README as a concise pointer to pinned identity and publishing boundaries.
duration: 
verification_result: passed
completed_at: 2026-07-01T22:04:57.860Z
blocker_discovered: false
---

# T02: Added safe release documentation that pins the Autimo Developer ID identity and separates local verification from publishing or remote mutation.

**Added safe release documentation that pins the Autimo Developer ID identity and separates local verification from publishing or remote mutation.**

## What Happened

Created `RELEASING.md` as the canonical safe release checklist and updated the README release safety section to point to it.

The release guide now documents the official signing identity `Developer ID Application: AUTIMO SYSTEMS INC (HMR9RDR6M2)`, the expected `TeamIdentifier=HMR9RDR6M2`, and the fixed development team value `HMR9RDR6M2`. It explicitly warns against generic `Developer ID Application` matching and mutable `APPLE_TEAM_ID`-style secrets.

The guide names non-destructive checks that only read local files or local build artifacts: grepping the project/workflow for pinned signing configuration and using `codesign` to inspect a locally built app. It also names publishing and remote mutation boundaries that require explicit maintainer confirmation, including workflow dispatch, notarization submission, GitHub release creation, Homebrew tap updates, `git push`, `gh release`, tag changes, and history rewriting.

## Failure Modes

External dependencies for this documentation task are local filesystem reads/writes and local command availability for verification. The implementation uses static Markdown guidance only; failed local checks bubble as command failures and do not trigger any network, publishing, or secret access path. The documented release failure path tells maintainers to inspect the project signing settings, workflow expected identity variables, imported certificate identity, and `codesign -dvv` output before retrying a release.

## Load Profile

No runtime load dimension applies. This task added documentation only and does not introduce services, queues, API calls, background jobs, or runtime resource saturation points.

## Negative Tests

No automated negative test surface applies beyond textual verification for unsafe release guidance. The verification grep reviewed generic `Developer ID Application`, `APPLE_TEAM_ID`, `push`, and release references to confirm unsafe cases are documented as warnings or explicit-confirmation publishing boundaries, not recommended release behavior.

## Verification

Ran the required release-documentation grep through `gsd_exec` and reviewed the output. Matches showed the new `RELEASING.md` and README section pin `Developer ID Application: AUTIMO SYSTEMS INC (HMR9RDR6M2)`, include `TeamIdentifier=HMR9RDR6M2`, warn against generic `Developer ID Application` and mutable `APPLE_TEAM_ID`, and classify `git push`, GitHub release creation, Homebrew tap updates, and other remote mutations as explicit-confirmation publishing actions. No external state changes, pushes, releases, notarization submissions, or remote mutations were performed.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `rg -n "Developer ID Application: AUTIMO SYSTEMS INC \\(HMR9RDR6M2\\)|TeamIdentifier=HMR9RDR6M2|Developer ID Application|APPLE_TEAM_ID|push|release" RELEASING.md README.md .github/workflows/release.yml` | 0 | ✅ pass | 14ms |

## Deviations

None.

## Known Issues

None.

## Files Created/Modified

- `RELEASING.md`
- `README.md`
