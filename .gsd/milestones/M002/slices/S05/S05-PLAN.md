# S05: Credential lifecycle verification

**Goal:** Close M002 with end to end lifecycle tests, diagnostic checks, and requirement validation for durable credential acquisition.
**Demo:** A fresh verification report proves credential acquisition, reuse, repair, clearing, and redaction work across Claude and ChatGPT paths.

## Must-Haves

- Automated tests cover first use, reuse after relaunch boundary, repair, clear, invalid credential, and redaction cases.
- Build and tests pass with official Autimo signing settings preserved.
- R010 moves from deferred to validated with evidence.
- Follow up work for M003 provider workflow polish is explicitly documented.

## Proof Level

- This slice proves: Full xcodebuild test suite plus targeted credential lifecycle evidence and UAT notes.

## Integration Closure

Verifies all M002 slices work together and hands provider copy or workflow gaps to M003.

## Verification

- Confirms durable diagnostic surfaces exist for credential state without leaking credential material.

## Tasks

- [x] **T01: Added credential lifecycle regression tests across Claude and ChatGPT paths.** `est:medium`
  Add lifecycle tests covering first setup, valid reuse, invalid credential recovery, repair after signing identity change, clear, and re acquisition across Claude and ChatGPT credential paths using synthetic credential material.
  - Files: `PinemeterTests/SecurityInvariantTests.swift`, `PinemeterTests/ProviderErrorWorkflowTests.swift`, `PinemeterTests/AppModelTests.swift`, `PinemeterTests/ChatGPTUsageServiceTests.swift`
  - Verify: xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests -only-testing:PinemeterTests/ProviderErrorWorkflowTests -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/ChatGPTUsageServiceTests

- [x] **T02: Ran the full Debug credential verification suite and confirmed official Autimo signing settings remain intact.** `est:small`
  Run the full Debug test suite and inspect signing settings so M002 closes only if credential behavior and official Autimo signing remain intact. Capture any failures as remediation instead of suppressing them.
  - Files: `.gsd/milestones/M002/slices/S05/S05-ASSESSMENT.md`
  - Verify: xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug && xcodebuild -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -showBuildSettings | egrep 'CODE_SIGN_IDENTITY|DEVELOPMENT_TEAM'

- [x] **T03: Validated R010 with M002/S05 lifecycle evidence and recorded M003 handoff scope for provider workflow polish.** `est:small`
  Update R010 validation evidence after lifecycle verification passes, document any remaining provider workflow polish for M003, and ensure R011 through R014 remain correctly scoped for later milestones.
  - Files: `.gsd/REQUIREMENTS.md`, `.gsd/QUEUE.md`, `.gsd/milestones/M002/slices/S05/S05-SUMMARY.md`
  - Verify: grep -n 'R010' .gsd/REQUIREMENTS.md && grep -n 'M003' .gsd/QUEUE.md

## Files Likely Touched

- PinemeterTests/SecurityInvariantTests.swift
- PinemeterTests/ProviderErrorWorkflowTests.swift
- PinemeterTests/AppModelTests.swift
- PinemeterTests/ChatGPTUsageServiceTests.swift
- .gsd/milestones/M002/slices/S05/S05-ASSESSMENT.md
- .gsd/REQUIREMENTS.md
- .gsd/QUEUE.md
- .gsd/milestones/M002/slices/S05/S05-SUMMARY.md
