---
id: T03
parent: S03
milestone: M005
key_files:
  - RELEASING.md
  - README.md
  - .github/workflows/release.yml
key_decisions:
  - No edits were required because existing release guidance already pins the Autimo Developer ID identity and separates local verification from publishing or remote mutation.
duration: 
verification_result: passed
completed_at: 2026-07-01T22:07:08.770Z
blocker_discovered: false
---

# T03: Verified the release workflow and release-facing documentation locally for pinned Autimo signing identity, safe verification guidance, and explicit remote mutation boundaries.

**Verified the release workflow and release-facing documentation locally for pinned Autimo signing identity, safe verification guidance, and explicit remote mutation boundaries.**

## What Happened

Validated `.github/workflows/release.yml` syntax using a local YAML parse and checked release-safety invariants in `.github/workflows/release.yml`, `README.md`, and `RELEASING.md`. The workflow pins `EXPECTED_SIGNING_IDENTITY` to `Developer ID Application: AUTIMO SYSTEMS INC (HMR9RDR6M2)` and `EXPECTED_TEAM_ID` to `HMR9RDR6M2`, rejects mutable `APPLE_TEAM_ID`-style signing reliance, and verifies both `Authority=` and `TeamIdentifier=` in `codesign -dvv` output. README and RELEASING.md consistently distinguish local read-only verification from publishing or remote mutation surfaces including workflow dispatch, notarization submission, GitHub release creation, Homebrew tap edits, `git push`, `gh release`, tag changes, and history rewriting. No stale or unsafe instructions were found, so no source edits were made.

## Failure Modes

External dependencies for this verification were the local filesystem (`RELEASING.md`, `README.md`, `.github/workflows/release.yml`) and local subprocesses (`ruby`, `python3`, `rg`). Missing files, malformed YAML, missing pinned strings, unsafe mutable `APPLE_TEAM_ID` usage, or failed subprocess execution all bubble as non-zero `gsd_exec` results; both verification commands exited 0, so those failure paths were not observed.

## Load Profile



## Negative Tests

The local invariant inspection explicitly checked negative safety conditions: generic or mutable `APPLE_TEAM_ID` release-signing reliance must not appear in the workflow, README must warn that generic `Developer ID Application` and mutable team secrets are unsafe, and RELEASING.md must name remote mutation operations (`git push`, `gh release`, history rewriting) as requiring explicit maintainer confirmation. The required `rg` audit also surfaced all relevant release/signing terms for manual review.

## Verification

Ran local-only verification through `gsd_exec`: Ruby parsed `.github/workflows/release.yml`, Python asserted workflow/doc safety invariants, and `rg -n "Developer ID Application|HMR9RDR6M2|APPLE_TEAM_ID|git push|gh release|rewrite" RELEASING.md README.md .github/workflows/release.yml` confirmed the release-facing docs and workflow contain the expected pinned identity and publishing-boundary guidance. No pushing, publishing, notarization submission, release creation, history rewriting, or other external state change was performed.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `ruby -e 'require "yaml"; YAML.load_file(".github/workflows/release.yml"); puts "release.yml YAML parse: ok"' && python3 inline safety invariant inspection` | 0 | ✅ pass | 133ms |
| 2 | `rg -n "Developer ID Application|HMR9RDR6M2|APPLE_TEAM_ID|git push|gh release|rewrite" RELEASING.md README.md .github/workflows/release.yml` | 0 | ✅ pass | 16ms |

## Deviations

None.

## Known Issues

None.

## Files Created/Modified

- `RELEASING.md`
- `README.md`
- `.github/workflows/release.yml`
