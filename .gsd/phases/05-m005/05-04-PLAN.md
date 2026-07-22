# S04: Fresh-reader public UAT

**Goal:** Close public polish with an evidence-backed external-reader pass.
**Demo:** A fresh-reader checklist proves an outside contributor can understand, build, test, and safely report issues.

## Must-Haves

- UAT verifies discoverability of purpose, install/build/test commands, provider setup, privacy/security posture, and support path.
- Link/path checks pass or documented gaps are fixed.
- Milestone validation records Contract, Integration, Operational, and UAT evidence.

## Proof Level

- This slice proves: final-assembly

## Integration Closure

Docs, site, workflows, templates, and project commands are checked together from a clean reader perspective.

## Verification

- Records public-readiness gaps and final evidence for future release work.

<tasks>
- [x] **T01**: Added a fresh-reader public-readiness UAT checklist for Pinemeter’s public docs, setup, privacy, issue reporting, release safety, and support boundaries. _(small)_
  Create a public-readiness UAT checklist that a fresh contributor can follow from the repository root: purpose, build/test, provider setup, privacy/security, issue reporting, release safety, and support boundaries. Include checks for contribution and release docs if they exist after prior slices.
  - Files: `.gsd/milestones/M005/slices/S04/S04-UAT.md`
  - Verify: Checklist separates automated artifact checks from human fresh-reader checks and references public files only.
- [x] **T02**: Ran non-destructive public artifact checks across README, site, GitHub templates/workflows, CONTRIBUTING.md, and RELEASING.md and documented the review findings. _(medium)_
  Run non-destructive checks over README, site, GitHub configuration, and any contribution or release docs created by prior slices for stale names, missing paths, unsafe secret prompts, and command drift.
  - Files: `README.md`, `site/index.html`, `.github`
  - Verify: `rg -n "ClaudeMeter|Pinemeter|secret|token|cookie|xcodebuild|HMR9RDR6M2|Developer ID Application" README.md site/index.html .github` plus the same check over CONTRIBUTING.md and RELEASING.md if present; review and document findings.
- [x] **T03**: Recorded public-readiness verification evidence, clarified two public-doc reporting/release boundaries, and marked human fresh-reader checks as human-only. _(medium)_
  Run the build/test command if public docs require it, execute automated UAT checks, mark human-only checks clearly, and prepare milestone validation evidence.
  - Files: `README.md`, `.gsd/milestones/M005/slices/S04/S04-UAT.md`
  - Verify: `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` plus GSD UAT evidence for automated public-readiness checks.
</tasks>

## Files Likely Touched

- .gsd/milestones/M005/slices/S04/S04-UAT.md
- README.md
- site/index.html
- .github
