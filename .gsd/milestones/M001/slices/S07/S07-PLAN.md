# S07: Verification and open source history plan

**Goal:** Close M001 with fresh final Pinemeter verification, classified remaining open-source readiness exceptions, and a non-destructive git history squash and public hygiene plan that future maintainers can execute only after explicit human confirmation.
**Demo:** After this: renamed test and clean build commands pass, final review artifacts are linked, and a non-destructive git history squash and open-source hygiene plan exists.

## Must-Haves

- Fresh final verification evidence exists for `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` and `xcodebuild clean build -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` after S06 cleanup.
- Remaining old ClaudeMeter or claudemeter references are scanned and classified as compatibility, history, operational secret-path, pending public URL, or actionable active-identity defects; no unclassified active UI/project identity references remain.
- Final review artifacts from S01 through S06 are linked from S07 closure artifacts with their downstream relevance summarized.
- A cold-reader-safe non-destructive git history and open-source hygiene plan exists, including branch/remotes/commit-count status, missing public hygiene files, license attribution caveat, site URL caveat, hard-stop destructive commands, and human confirmation gates.
- No history rewrite, reset, filter-repo operation, remote push, repo creation, release publication, or secret storage mutation is performed in S07.
- Requirements R002, R008, and R009 have explicit evidence or plan coverage; R001, R004, R005, R006, and R007 are linked as supporting prior-slice evidence.

## Proof Level

- This slice proves: Full local verification plus artifact review. Required executable proof is the renamed Xcode test command and clean build command run from the worktree after S06. Supporting proof is concise gsd_exec evidence for remaining identity/public-hygiene/secret-shaped scans and non-destructive git state inspection. Artifact proof is S07-FINAL-AUDIT.md, S07-OPEN-SOURCE-HISTORY-PLAN.md, and S07-ASSESSMENT.md.

## Integration Closure

Consumes completed S01, S03, S04, and S06 outputs without modifying completed slice artifacts or compatibility-sensitive runtime identifiers. Integrates final verification with prior review baselines by linking S01 identity migration, S02 inventory, S03 security baseline, S04 architecture baseline, S05 provider/error audit, and S06 cleanup validation. Does not change source behavior unless final audit reveals an obvious safe documentation-only correction, in which case full verification still remains required.

## Verification

- Adds no runtime telemetry. Improves release observability through final gsd_exec evidence IDs, executable Xcode build/test logs, classified exception tables, and a public-readiness checklist that exposes hard-stop gates before any future history rewrite or publication.

## Tasks

- [x] **T01: Captured fresh passing renamed Pinemeter Xcode test and clean build evidence for final milestone verification.** `est:30-60 minutes`
  ---
  skills_used:
    - verify-before-complete
  ---
  Why: R002 and R008 require fresh proof that behavior remains stable and the renamed Pinemeter project and scheme pass after all prior cleanup.
  - Files: `Pinemeter.xcodeproj/project.pbxproj`, `Pinemeter.xcodeproj/xcshareddata/xcschemes/Pinemeter.xcscheme`, `Pinemeter`, `PinemeterTests`
  - Verify: xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug && xcodebuild clean build -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug

- [ ] **T02: Classify final identity and hygiene scan findings** `est:45-75 minutes`
  ---
  skills_used:
    - verify-before-complete
  ---
  Why: S07 must prove remaining old names and public-readiness gaps are understood rather than accidentally shipping active ClaudeMeter identity or secret-shaped content.
  - Files: `.gsd/milestones/M001/slices/S07/S07-FINAL-AUDIT.md`, `README.md`, `LICENSE`, `CHANGELOG.md`, `site/index.html`, `.github/workflows/test.yml`, `.github/workflows/release.yml`, `.github/workflows/deploy-pages.yml`, `scripts/provider_workflow_copy_audit.py`, `Pinemeter`, `PinemeterTests`, `work-to-date.md`
  - Verify: test -f .gsd/milestones/M001/slices/S07/S07-FINAL-AUDIT.md

- [ ] **T03: Write non destructive history and public hygiene plan** `est:60-90 minutes`
  ---
  skills_used:
    - write-docs
  ---
  Why: R009 is plan-only: future maintainers need a safe, cold-reader-ready path for squashing history and preparing an open-source repo without S07 performing destructive or outward-facing operations.
  - Files: `.gsd/milestones/M001/slices/S07/S07-OPEN-SOURCE-HISTORY-PLAN.md`, `.gsd/milestones/M001/slices/S07/S07-FINAL-AUDIT.md`, `README.md`, `LICENSE`, `CHANGELOG.md`, `site/index.html`, `.github/workflows/test.yml`, `.github/workflows/release.yml`, `.github/workflows/deploy-pages.yml`
  - Verify: test -f .gsd/milestones/M001/slices/S07/S07-OPEN-SOURCE-HISTORY-PLAN.md

- [ ] **T04: Assemble final S07 assessment and closure evidence** `est:45-60 minutes`
  ---
  skills_used:
    - write-docs
    - verify-before-complete
  ---
  Why: The slice needs one closure artifact that ties final verification, prior review outputs, final audit classifications, and the history plan to M001 success criteria and requirements.
  - Files: `.gsd/milestones/M001/slices/S07/S07-ASSESSMENT.md`, `.gsd/milestones/M001/slices/S07/S07-FINAL-AUDIT.md`, `.gsd/milestones/M001/slices/S07/S07-OPEN-SOURCE-HISTORY-PLAN.md`
  - Verify: test -f .gsd/milestones/M001/slices/S07/S07-ASSESSMENT.md

## Files Likely Touched

- Pinemeter.xcodeproj/project.pbxproj
- Pinemeter.xcodeproj/xcshareddata/xcschemes/Pinemeter.xcscheme
- Pinemeter
- PinemeterTests
- .gsd/milestones/M001/slices/S07/S07-FINAL-AUDIT.md
- README.md
- LICENSE
- CHANGELOG.md
- site/index.html
- .github/workflows/test.yml
- .github/workflows/release.yml
- .github/workflows/deploy-pages.yml
- scripts/provider_workflow_copy_audit.py
- work-to-date.md
- .gsd/milestones/M001/slices/S07/S07-OPEN-SOURCE-HISTORY-PLAN.md
- .gsd/milestones/M001/slices/S07/S07-ASSESSMENT.md
