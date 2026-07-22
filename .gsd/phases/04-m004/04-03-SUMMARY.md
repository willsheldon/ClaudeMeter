---
id: S03
parent: M004
milestone: M004
provides:
  - Gemini-aware setup and settings status presentation with recovery actions, backed by AppModel provider status collections and tests.
requires:
  - slice: S02
    provides: Gemini credential and usage service seams plus secure credential state needed for setup/settings status.
affects:
  - S04
  - S05
key_files:
  - Pinemeter/App/AppModel.swift
  - Pinemeter/Views/Settings/SettingsView.swift
  - Pinemeter/Views/Setup/SetupWizardView.swift
  - PinemeterTests/AppModelTests.swift
  - PinemeterTests/ProviderErrorWorkflowTests.swift
  - PinemeterTests/SecurityInvariantTests.swift
  - PinemeterTests/ChatGPTAppModelTests.swift
key_decisions: []
patterns_established:
  - Provider setup/settings UI should consume shared provider status collections so adding a third provider does not require separate one-off UI sections.
  - Provider-facing setup/settings copy should describe credential status and recovery actions without mentioning or exposing credential material.
observability_surfaces:
  - Setup/settings provider status rows act as user-visible diagnostics for missing, invalid, configured, retry, reconnect, clear, and mixed-provider states.
drill_down_paths:
  - .gsd/milestones/M004/slices/S03/tasks/T01-SUMMARY.md
  - .gsd/milestones/M004/slices/S03/tasks/T02-SUMMARY.md
  - .gsd/milestones/M004/slices/S03/tasks/T03-SUMMARY.md
duration: ""
verification_result: passed
completed_at: 2026-06-24T21:23:51.063Z
blocker_discovered: false
---

# S03: Gemini setup and settings UI

**Settings and setup now present Gemini credential status and recovery actions through the shared provider UI matrix beside Claude and ChatGPT.**

## What Happened

S03 extended the provider-aware setup and settings path so Gemini participates in the same visible credential-status and recovery workflows as Claude and ChatGPT. AppModel now supplies Gemini-aware provider status collections for UI consumers, SettingsView and SetupWizardView render Gemini status and actions through shared provider sections, and focused model/UI workflow tests cover missing, configured, invalid, retry, reconnect, clear, and mixed-provider states. Final cleanup aligned stale ChatGPT bootstrap expectations with the new three-provider empty-state copy so full-suite verification exercises the Gemini-aware provider matrix rather than the old two-provider assumption.

## Verification

Fresh slice closeout verification ran through gsd_exec evidence e6477428-b08d-4513-8c69-445d29aa8d39. `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` exited 0 and reported `** TEST SUCCEEDED **`. The provider-copy scan `rg -n "Claude|ChatGPT|Gemini|provider|cookie|key" Pinemeter/Views/Settings Pinemeter/Views/Setup` found 90 provider references; stale two-provider copy checks found 0 matches and secret-term checks found 0 matches in setup/settings copy.

## Requirements Advanced

None.

## Requirements Validated

None.

## New Requirements Surfaced

None.

## Requirements Invalidated or Re-scoped

None.

## Operational Readiness

None.

## Deviations

T03 adjusted two stale expectations in PinemeterTests/ChatGPTAppModelTests.swift after full-suite verification exposed they still expected the old Claude/ChatGPT-only empty-state message. No source-code deviations outside the planned setup/settings/provider test scope were required.

## Known Limitations

This slice does not prove live Gemini usage refresh, menu bar rendering, or end-to-end real-credential setup; those are owned by S04 and S05.

## Follow-ups

S04 should consume the Gemini-aware AppModel provider status and settings/setup behavior when integrating Gemini usage into the menu bar popover. S05 should add live/workflow UAT that proves setup, refresh, recovery, and coexistence with real or simulated provider flows.

## Files Created/Modified

- `Pinemeter/App/AppModel.swift` — Supplies Gemini-aware provider status collections for setup/settings consumers.
- `Pinemeter/Views/Settings/SettingsView.swift` — Renders Gemini credential status and recovery actions through shared provider-aware settings UI.
- `Pinemeter/Views/Setup/SetupWizardView.swift` — Shows Gemini setup/status beside Claude and ChatGPT without exposing credential material.
- `PinemeterTests/AppModelTests.swift` — Covers Gemini provider status and mixed-provider model behavior.
- `PinemeterTests/ProviderErrorWorkflowTests.swift` — Covers Gemini missing, configured, invalid, retry, reconnect, clear, and recovery workflows.
- `PinemeterTests/SecurityInvariantTests.swift` — Maintains security invariants around credential material exposure.
- `PinemeterTests/ChatGPTAppModelTests.swift` — Aligns ChatGPT bootstrap expectations with the three-provider empty-state message.
