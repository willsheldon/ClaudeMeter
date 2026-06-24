---
id: M003
title: "Multi-provider workflow polish"
status: complete
completed_at: 2026-06-24T17:35:37.600Z
key_decisions:
  - Use surface-neutral `stateText` and `detailText` on `AppProviderCredentialStatus` while preserving existing aliases as wrappers.
  - Route provider action buttons in Settings and Setup through `AppModel.performProviderCredentialAction`.
  - Keep `isSetupComplete` as Claude-only setup state while adding generalized provider-aware menu routing through AppModel.
  - Separate safe automated provider workflow UAT from live checks that require real provider credentials.
key_files:
  - Pinemeter/App/AppModel.swift
  - Pinemeter/Models/CredentialState.swift
  - Pinemeter/Views/Settings/SettingsView.swift
  - Pinemeter/Views/Setup/SetupWizardView.swift
  - Pinemeter/Views/MenuBar/UsagePopoverView.swift
  - Pinemeter/Views/MenuBar/MenuBarPopoverView.swift
  - PinemeterTests/AppModelTests.swift
  - PinemeterTests/ProviderErrorWorkflowTests.swift
  - PinemeterTests/SecurityInvariantTests.swift
  - scripts/provider_status_surface_audit.py
  - scripts/provider_workflow_copy_audit.py
  - .gsd/milestones/M003/slices/S04/S04-UAT.md
  - .gsd/milestones/M003/M003-VALIDATION.md
lessons_learned:
  - A true first-run reset must clear both UserDefaults and the exact Claude and ChatGPT Keychain items; preferences alone are insufficient.
  - Provider workflow audits are useful as enforcement plus advisory surfaces: exit status gates blocking issues while advisory findings remain visible for copy review.
  - Live credential UAT must be explicitly separated from safe auto-mode checks to avoid storing or exposing credential material.
---

# M003: Multi-provider workflow polish

**M003 closed the Claude and ChatGPT multi-provider workflow polish milestone with provider-aware status, recovery actions, menu states, and repeatable UAT diagnostics.**

## What Happened

M003 unified the existing Claude and ChatGPT monitoring flows into a coherent multi-provider product surface. S01 established sanitized provider credential status surfaces for setup and settings. S02 added shared AppModel-routed recovery actions for retry, reconnect, repair, and clear behavior without exposing credential material. S03 extended menu bar routing and usage presentation for configured, partial, loading, error, and hidden-provider states. S04 closed the milestone with reset-scope documentation, provider workflow audits, and a rerunnable UAT checklist that separates automated evidence from live credential checks requiring human follow-up.

## Success Criteria Results

- Setup and settings provider-aware status/recovery: met by S01/S02 and fresh provider status surface audit PASS.
- Menu bar multi-provider states: met by S03 and fresh XCTest coverage.
- Provider refresh/retry/clear/reconnect observability and AppModel/service routing: met by S02/S04 and fresh audit/test evidence.
- First-run/reset/expired-session UAT: met by S04 UAT artifact with explicit automated and human-follow-up checks.

## Definition of Done Results

- All M003 slices complete: S01-S04 complete in GSD status.
- All M003 tasks complete: 17/17 complete in GSD status.
- Fresh verification run: `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` completed in this turn.
- Static audits: `python3 scripts/provider_status_surface_audit.py` exited 0 with PASS; `python3 scripts/provider_workflow_copy_audit.py` exited 0 with advisory findings only.
- Formal validation: `.gsd/milestones/M003/M003-VALIDATION.md` recorded verdict `pass`.

## Requirement Outcomes

M003 advances the multi-provider workflow requirements through provider-aware status, recovery, menu presentation, reset diagnostics, and UAT evidence. No requirement was invalidated or re-scoped during closure. Requirement update tooling was not used because project memory warns the DB row set may be incomplete for `.gsd/REQUIREMENTS.md`.

## Deviations

None blocking. Workflow copy audit reports advisory copy-review findings but exits 0 and did not block milestone completion.

## Follow-ups

Proceed to M004: Gemini monitoring extension, beginning with S01 Gemini provider contract. Carry forward M003's provider status, recovery, menu routing, and UAT patterns.
