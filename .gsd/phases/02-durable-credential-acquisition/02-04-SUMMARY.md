---
id: S04
parent: M002
milestone: M002
provides:
  - Settings and setup UX for Claude and ChatGPT credential status, recovery, repair/setup, and clear actions.
  - A downstream S05 verification target for full lifecycle credential UX validation.
requires:
  - slice: S02
    provides: Claude Keychain repair and compatibility surfaces consumed by setup recovery UX.
  - slice: S03
    provides: ChatGPT session acquisition status boundary consumed by settings credential status UX.
affects:
  - S05
key_files:
  - Pinemeter/App/AppModel.swift
  - Pinemeter/Views/Settings/SettingsView.swift
  - Pinemeter/Views/Setup/SetupWizardView.swift
  - PinemeterTests/AppModelTests.swift
  - PinemeterTests/ChatGPTAppModelTests.swift
  - PinemeterTests/ProviderErrorWorkflowTests.swift
key_decisions:
  - Credential UX surfaces consume sanitized AppModel provider status models rather than reading raw credential material in SwiftUI views.
patterns_established:
  - Provider credential recovery UI is driven by sanitized status/action view models.
observability_surfaces:
  - Targeted AppModel, ChatGPTAppModel, and ProviderErrorWorkflow tests cover status/action behavior and provider-aware sanitized copy.
  - Manual source marker check verifies expected UX surfaces and absence of obvious raw credential persistence/logging patterns.
drill_down_paths:
  - .gsd/milestones/M002/slices/S04/tasks/T01-SUMMARY.md
  - .gsd/milestones/M002/slices/S04/tasks/T02-SUMMARY.md
  - .gsd/milestones/M002/slices/S04/tasks/T03-SUMMARY.md
duration: ""
verification_result: passed
completed_at: 2026-06-18T22:14:08.173Z
blocker_discovered: false
---

# S04: Credential setup and recovery UX

**Settings and setup now expose provider-aware credential status, recovery, repair, reconnect/setup, and clear controls through sanitized AppModel view models.**

## What Happened

Slice S04 connects the credential state and recovery surfaces from earlier M002 slices into user-facing setup and settings flows. AppModel now provides sanitized provider credential status models for Claude and ChatGPT with health, non-secret descriptions, last sanitized failure state, and permitted actions. SettingsView renders Claude and ChatGPT credential rows with provider labels, status text, and available clear/recovery actions without displaying credential material. SetupWizardView uses durable Claude credential status to avoid repeated prompts when a valid saved credential exists, to ask for setup when missing, and to offer repair when the credential is repairable. Accessibility labels and provider-aware failure copy were included, while Gemini-specific promises remain out of scope for this slice.

## Verification

Passed slice-level verification through gsd_exec evidence:

- `4e3fd4cd-5b90-4831-a35d-1bca51b67a9f`: `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/ChatGPTAppModelTests -only-testing:PinemeterTests/ProviderErrorWorkflowTests` exited 0. The targeted AppModel, ChatGPT credential state, and provider error workflow tests passed.
- `0746e500-e1d5-4af1-99e3-5e66719e700e`: reviewed S04 task summaries and checked SettingsView and SetupWizardView provider copy/action coverage.
- `5911bcef-1363-4ca8-8f37-a8d75be365b7`: checked changed UI/model/test files for expected sanitized UX markers and obvious raw credential persistence/logging patterns; no raw secret persistence or logging findings and no expected markers missing.

A preliminary checker run `c0fb902c6ce` failed because it searched for an incorrect symbol name; the corrected marker check passed in `5911bcef-1363-4ca8-8f37-a8d75be365b7`.

## Requirements Advanced

- R010 — Advanced durable credential retention UX by avoiding repeated prompts when valid saved credentials are present and by exposing recovery/clear flows for provider credential states.

## Requirements Validated

None.

## New Requirements Surfaced

None.

## Requirements Invalidated or Re-scoped

None.

## Operational Readiness

None.

## Deviations

None.

## Known Limitations

Operational monitoring remains test/manual-review based; no runtime telemetry dashboard was added in this UX slice.

## Follow-ups

S05 should perform full lifecycle verification across acquisition, reuse, repair, clear, invalid credential, and redaction paths.

## Files Created/Modified

- `Pinemeter/App/AppModel.swift` — Added sanitized provider credential status/action state for setup and settings.
- `Pinemeter/Views/Settings/SettingsView.swift` — Rendered provider credential recovery rows and actions.
- `Pinemeter/Views/Setup/SetupWizardView.swift` — Used durable sanitized credential status for setup prompt/ready/repair states.
- `PinemeterTests/AppModelTests.swift` — Covered AppModel credential recovery status/actions.
- `PinemeterTests/ChatGPTAppModelTests.swift` — Covered ChatGPT credential status behavior.
- `PinemeterTests/ProviderErrorWorkflowTests.swift` — Covered provider-aware credential recovery copy.
