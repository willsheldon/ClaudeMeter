---
id: T04
parent: S03
milestone: M005
key_files:
  - .github/workflows/release.yml
  - RELEASING.md
  - README.md
key_decisions:
  - Keep `EXPECTED_TEAM_ID: HMR9RDR6M2` as a pinned workflow constant rather than accepting a mutable `APPLE_TEAM_ID` secret for release signing.
  - Treat GitHub release creation, Homebrew tap pushes, and Apple notarization submission as remote mutation surfaces that require explicit maintainer confirmation.
duration: 
verification_result: passed
completed_at: 2026-07-01T22:10:19.005Z
blocker_discovered: false
---

# T04: Pinned release workflow team handling away from mutable APPLE_TEAM_ID secrets and made publishing boundaries explicit in workflow diagnostics.

**Pinned release workflow team handling away from mutable APPLE_TEAM_ID secrets and made publishing boundaries explicit in workflow diagnostics.**

## What Happened

Updated `.github/workflows/release.yml` to document that the manual release workflow publishes artifacts only after explicit maintainer confirmation and to keep release signing pinned to `Developer ID Application: AUTIMO SYSTEMS INC (HMR9RDR6M2)` with `EXPECTED_TEAM_ID: HMR9RDR6M2`. The workflow audit step now explicitly states that GitHub release creation, Homebrew tap pushes, and Apple notarization submission are remote mutation surfaces requiring explicit maintainer confirmation. Existing `RELEASING.md` and `README.md` already contained the required pinned identity, `TeamIdentifier=HMR9RDR6M2`, `APPLE_TEAM_ID` warning, and `git push` / `gh release` explicit-confirmation language, so no doc edits were needed.

## Verification

Ran local-only `gsd_exec` verification that read repository files, parsed `.github/workflows/release.yml`, confirmed the pinned Autimo signing identity and `TeamIdentifier=HMR9RDR6M2`, confirmed no workflow dependency on `APPLE_TEAM_ID`, confirmed docs classify `git push` and `gh release` as explicit-confirmation publishing actions, confirmed workflow publishing-boundary wording, and confirmed no push, release, notarization, rewrite, or other external mutation command was executed.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `gsd_exec bash: python local release checks plus ruby YAML.load_file(".github/workflows/release.yml")` | 0 | ✅ pass | 131ms |

## Deviations

The task plan file `.gsd/milestones/M005/slices/S03/tasks/T04-PLAN.md` was absent in this worktree, so execution used the inlined authoritative task contract and slice excerpt. `RELEASING.md` and `README.md` required no edits because they already contained the required explicit-confirmation wording and pinned identity guidance.

## Known Issues

None.

## Files Created/Modified

- `.github/workflows/release.yml`
- `RELEASING.md`
- `README.md`
