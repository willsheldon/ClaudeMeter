---
id: S03
parent: M005
milestone: M005
provides:
  - Release-facing docs and workflow diagnostics that pin the official Autimo signing identity and define safe local verification versus explicit-confirmation publishing boundaries.
requires:
  - slice: S01
    provides: Accurate public docs context and current provider/project naming that release guidance builds on.
affects:
  - S04
key_files:
  - .github/workflows/release.yml
  - RELEASING.md
  - README.md
  - Pinemeter.xcodeproj/project.pbxproj
  - .gsd/milestones/M005/slices/S03/tasks/T01-SUMMARY.md
  - .gsd/milestones/M005/slices/S03/tasks/T02-SUMMARY.md
  - .gsd/milestones/M005/slices/S03/tasks/T03-SUMMARY.md
  - .gsd/milestones/M005/slices/S03/tasks/T04-SUMMARY.md
key_decisions:
  - Keep the official release signing identity pinned to `Developer ID Application: AUTIMO SYSTEMS INC (HMR9RDR6M2)` and `HMR9RDR6M2`.
  - Use `EXPECTED_TEAM_ID: HMR9RDR6M2` as a workflow constant and reject mutable `APPLE_TEAM_ID` secret dependencies.
  - Treat GitHub release creation, Homebrew tap pushes, Apple notarization submission, `git push`, tag changes, `gh release`, and history rewriting as remote mutation surfaces requiring explicit maintainer confirmation.
patterns_established:
  - Release documentation separates non-destructive local verification from publishing and remote mutation actions.
  - Workflow diagnostics should name pinned release identity and publishing boundaries without exposing secrets or accepting mutable team identifiers.
observability_surfaces:
  - Release workflow preflight diagnostics print expected signing identity/team and emit explicit errors for generic signing identity drift, missing pinned team, mutable team-secret dependency, and signed-artifact team mismatch.
drill_down_paths:
  - .gsd/milestones/M005/slices/S03/tasks/T01-SUMMARY.md
  - .gsd/milestones/M005/slices/S03/tasks/T02-SUMMARY.md
  - .gsd/milestones/M005/slices/S03/tasks/T03-SUMMARY.md
  - .gsd/milestones/M005/slices/S03/tasks/T04-SUMMARY.md
duration: ""
verification_result: passed
completed_at: 2026-07-01T22:12:33.584Z
blocker_discovered: false
---

# S03: Release and signing documentation

**Release guidance and workflow diagnostics now pin the Autimo Developer ID identity, reject mutable team-secret handling, and document explicit-confirmation boundaries for publishing actions.**

## What Happened

S03 audited the release workflow, Xcode signing settings, README, CHANGELOG, and release-facing documentation for signing identity drift and remote mutation risks. The slice established RELEASING.md as the canonical safe local release checklist, kept README as a concise public pointer, and aligned `.github/workflows/release.yml` with the official pinned signing identity `Developer ID Application: AUTIMO SYSTEMS INC (HMR9RDR6M2)` and team identifier `HMR9RDR6M2`. The workflow now treats `APPLE_TEAM_ID` as a forbidden mutable-secret pattern rather than a release dependency, verifies the signed app's team identifier against the pinned expected team, and prints explicit publishing-boundary diagnostics for GitHub release creation, Homebrew tap updates, notarization submission, pushes, tags, and history rewrites. No remote push, release creation, notarization submission, history rewrite, or other external state mutation was performed during the slice.

## Verification

Fresh slice-level verification was run through `gsd_exec` evidence `2d27afa8-e82d-4a7c-9b30-a2d5d41a93be`. The local-only Python check read `.github/workflows/release.yml`, `RELEASING.md`, `README.md`, and `Pinemeter.xcodeproj/project.pbxproj`; parsed the workflow YAML through Ruby Psych; confirmed the pinned Autimo Developer ID identity and `HMR9RDR6M2` development team; confirmed workflow artifact verification checks `TeamIdentifier=$EXPECTED_TEAM_ID` with `EXPECTED_TEAM_ID: HMR9RDR6M2`; confirmed the workflow does not depend on `secrets.APPLE_TEAM_ID` or an `APPLE_TEAM_ID` environment value; confirmed docs classify `git push` and `gh release` as explicit maintainer confirmation publishing actions; and confirmed the verification itself performed no external mutation commands.

## Requirements Advanced

- R013 — Advanced public open-source polish by adding release-facing documentation and workflow checks for signing identity safety and public release boundaries.

## Requirements Validated

None.

## New Requirements Surfaced

- None.

## Requirements Invalidated or Re-scoped

None.

## Operational Readiness

None.

## Deviations

T04 found `.gsd/milestones/M005/slices/S03/tasks/T04-PLAN.md` absent in this worktree, so execution used the inlined authoritative task contract and slice plan excerpt. A first closeout verification attempt used overly strict checks that treated defensive `APPLE_TEAM_ID` guard wording and variable-based `TeamIdentifier` verification as failures; the final verification refined those checks and passed. No source edits were made during closeout.

## Known Limitations

This slice does not prove live Apple notarization, GitHub release publication, or Homebrew tap updates. It intentionally documents and verifies local release-facing artifacts only, leaving live publishing to explicit maintainer-confirmed release operations.

## Follow-ups

S04 should fresh-reader test whether an outside contributor can understand that local verification is safe while workflow dispatch, `git push`, `gh release`, notarization submission, Homebrew tap updates, tags, and history rewrites are publishing actions that require explicit maintainer confirmation.

## Files Created/Modified

- `.github/workflows/release.yml` — Pinned release workflow identity/team handling, added mutable team-secret guardrails, and documented publishing-boundary diagnostics.
- `RELEASING.md` — Documented the official Autimo signing identity, local-only verification checks, and publishing actions requiring explicit maintainer confirmation.
- `README.md` — Added concise release safety guidance pointing readers to pinned signing identity and explicit publishing boundaries.
