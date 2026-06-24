# S05: Gemini workflow UAT

**Goal:** Close Gemini with end-to-end workflow evidence and regression protection.
**Demo:** A repeatable UAT proves Gemini setup, refresh, recovery, and coexistence with Claude and ChatGPT.

## Must-Haves

- UAT covers clean state, Gemini-only, all-provider, invalid credential, and clear/reconnect flows.
- Full xcodebuild test passes.
- Milestone validation documents Contract, Integration, Operational, and UAT evidence.

## Proof Level

- This slice proves: final-assembly

## Integration Closure

All Gemini provider slices are exercised together with existing providers.

## Verification

- Records Gemini diagnostic and UAT evidence for future provider work.

## Tasks

- [ ] **T01: Write Gemini UAT checklist** `est:small`
  Create a UAT checklist for Gemini setup, refresh, invalid credential, clear/reconnect, Gemini-only, and all-provider states. Use synthetic or mock credentials unless the user explicitly supplies real credentials through approved secret handling.
  - Files: `.gsd/milestones/M004/slices/S05/S05-UAT.md`
  - Verify: Checklist distinguishes automated, runtime, and human-follow-up checks and contains no real secret values.

- [ ] **T02: Run Gemini final verification** `est:medium`
  Run full tests and provider redaction/copy audits after Gemini integration, fixing only M004-scope issues.
  - Files: `Pinemeter`, `PinemeterTests`, `scripts/provider_workflow_copy_audit.py`
  - Verify: `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` plus provider copy/redaction audit where applicable.

- [ ] **T03: Record Gemini UAT evidence** `est:small`
  Execute non-destructive automated UAT checks, record GSD UAT results with evidence references, and prepare validation notes for Contract, Integration, Operational, and UAT classes.
  - Files: `.gsd/milestones/M004/slices/S05/S05-UAT.md`, `.gsd/milestones/M004/M004-VALIDATION.md`
  - Verify: GSD UAT result records objective evidence for each automated PASS or FAIL and marks real-credential-only checks as NEEDS-HUMAN where appropriate.

## Files Likely Touched

- .gsd/milestones/M004/slices/S05/S05-UAT.md
- Pinemeter
- PinemeterTests
- scripts/provider_workflow_copy_audit.py
- .gsd/milestones/M004/M004-VALIDATION.md
