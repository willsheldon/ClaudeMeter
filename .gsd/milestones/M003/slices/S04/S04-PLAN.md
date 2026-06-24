# S04: Workflow UAT and diagnostics

**Goal:** Close the milestone with repeatable workflow evidence and diagnostics for the next agent.
**Demo:** A documented reset and UAT flow proves first-run, partial-provider, two-provider, and expired-session behavior.

## Must-Haves

- Local reset instructions cover preferences plus exact Claude and ChatGPT Keychain items.
- UAT checks cover first-run, one-provider, two-provider, expired ChatGPT session, and clear/reconnect flows.
- Milestone validation has Contract, Integration, Operational, and UAT evidence.

## Proof Level

- This slice proves: final-assembly

## Integration Closure

All provider workflow surfaces are exercised together through tests and UAT evidence.

## Verification

- Records repeatable diagnostic and UAT artifacts for future provider expansion.

## Tasks

- [x] **T01: Wrote the provider workflow UAT checklist for reset, partial-provider, full-provider, expired-session, and clear/reconnect states.** `est:small`
  Create a UAT checklist for M003 that covers clean first-run reset, Claude-only, ChatGPT-only, both providers, expired ChatGPT session, and provider clear/reconnect behavior. Include the exact local reset scope for UserDefaults and Keychain items from project memory.
  - Files: `.gsd/milestones/M003/slices/S04/S04-UAT.md`
  - Verify: Checklist includes bundle id `com.eddmann.Pinemeter`, Claude service `com.claudemeter.sessionkey` account `default`, and ChatGPT service `com.pinemeter.chatgpt.session` account `chatgpt.com`, with no secret values.

- [x] **T02: Added safe automated reset and redaction checks for provider credential workflows.** `est:medium`
  Add or update tests/scripts that verify redaction and document safe local reset checks without deleting real user data during automated tests. Use synthetic credentials and existing test doubles.
  - Files: `PinemeterTests/SecurityInvariantTests.swift`, `PinemeterTests/ProviderErrorWorkflowTests.swift`, `scripts/provider_workflow_copy_audit.py`
  - Verify: `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests -only-testing:PinemeterTests/ProviderErrorWorkflowTests` and `python3 scripts/provider_workflow_copy_audit.py` if present/applicable.

- [x] **T03: Ran the final M003 verification suite and fixed the stale provider status audit test-name guard.** `est:medium`
  Run full xcodebuild tests plus provider copy/redaction audit. Capture failures with root-cause notes and fix only M003-scope issues before completing the slice.
  - Files: `Pinemeter/App/AppModel.swift`, `Pinemeter/Views/Settings/SettingsView.swift`, `Pinemeter/Views/Setup/SetupWizardView.swift`, `Pinemeter/Views/MenuBar/UsagePopoverView.swift`, `PinemeterTests`
  - Verify: `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` plus provider copy/redaction audit commands recorded in the task summary.

- [x] **T04: Recorded non-destructive M003 UAT evidence and milestone readiness notes.** `est:small`
  Execute the non-destructive parts of the UAT checklist, record evidence using GSD UAT tooling where possible, and prepare milestone validation notes covering Contract, Integration, Operational, and UAT classes.
  - Files: `.gsd/milestones/M003/slices/S04/S04-UAT.md`, `.gsd/milestones/M003/M003-VALIDATION.md`
  - Verify: GSD UAT result records PASS, FAIL, or NEEDS-HUMAN for each checklist item with objective evidence references where automated.

## Files Likely Touched

- .gsd/milestones/M003/slices/S04/S04-UAT.md
- PinemeterTests/SecurityInvariantTests.swift
- PinemeterTests/ProviderErrorWorkflowTests.swift
- scripts/provider_workflow_copy_audit.py
- Pinemeter/App/AppModel.swift
- Pinemeter/Views/Settings/SettingsView.swift
- Pinemeter/Views/Setup/SetupWizardView.swift
- Pinemeter/Views/MenuBar/UsagePopoverView.swift
- PinemeterTests
- .gsd/milestones/M003/M003-VALIDATION.md
