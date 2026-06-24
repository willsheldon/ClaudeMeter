---
id: S02
parent: M003
milestone: M003
provides:
  - A shared, tested provider credential recovery boundary for Claude and ChatGPT retry, reconnect, repair, and clear actions.
  - Sanitized provider-specific recovery feedback usable by setup, settings, and downstream menu bar workflows.
requires:
  - slice: S01
    provides: Provider-aware credential status surfaces and next-action metadata consumed by S02 recovery actions.
affects:
  - S03
  - S04
key_files:
  - Pinemeter/App/AppModel.swift
  - Pinemeter/Models/CredentialState.swift
  - Pinemeter/Services/SessionKeyImportService.swift
  - Pinemeter/Repositories/ChatGPTSessionRepository.swift
  - Pinemeter/Views/Settings/SettingsView.swift
  - Pinemeter/Views/Setup/SetupWizardView.swift
  - PinemeterTests/AppModelTests.swift
  - PinemeterTests/ProviderErrorWorkflowTests.swift
  - PinemeterTests/SecurityInvariantTests.swift
key_decisions:
  - Unsupported ChatGPT repair is rejected at the AppModel boundary with a sanitized LocalizedError rather than implicitly falling back to reconnect.
  - Provider action buttons in Settings and Setup route through `AppModel.performProviderCredentialAction`; combined browser import remains the bulk reconnect/import surface.
patterns_established:
  - Provider recovery UI invokes a shared AppModel orchestration boundary instead of directly touching credential services or repositories.
  - Provider/action compatibility is enforced centrally and returns sanitized provider-scoped feedback.
  - Credential-equivalent material remains behind repository/service boundaries while UI state carries only safe status and next-action information.
observability_surfaces:
  - Provider-scoped recovery action state and sanitized feedback messages expose progress, success, and failure categories for unattended diagnosis.
  - Provider workflow and security invariant tests act as executable diagnostics for routing and redaction regressions.
drill_down_paths:
  - .gsd/milestones/M003/slices/S02/tasks/T01-SUMMARY.md
  - .gsd/milestones/M003/slices/S02/tasks/T02-SUMMARY.md
  - .gsd/milestones/M003/slices/S02/tasks/T03-SUMMARY.md
  - .gsd/milestones/M003/slices/S02/tasks/T04-SUMMARY.md
duration: ""
verification_result: passed
completed_at: 2026-06-23T22:06:12.349Z
blocker_discovered: false
---

# S02: Provider recovery actions

**Provider recovery actions now route Claude and ChatGPT retry, reconnect, repair, and clear flows through a shared AppModel orchestration boundary with sanitized provider-scoped feedback.**

## What Happened

S02 started with an audit of existing Claude and ChatGPT recovery entry points across AppModel, credential services, repositories, setup, settings, and tests. The implementation then centralized provider credential actions behind `AppModel.performProviderCredentialAction`, enforcing provider/action compatibility at the orchestration boundary and preserving secret handling inside `SessionKeyImportService`, `ChatGPTSessionRepository`, Keychain, and provider usage services. Settings and setup recovery buttons were wired through that shared boundary so user-facing retry, reconnect, repair, and clear actions produce provider-specific progress, success, and failure feedback without direct view access to credential material. Final verification confirmed the existing implementation, copy, and redaction invariants without requiring additional source changes in closeout.

## Verification

Fresh slice-level verification was run through `gsd_exec` evidence `b67a2c33-34e1-4feb-8840-9e82906831b5`: `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` exited 0; symbol checks found the shared provider action boundary and UI state wiring in AppModel, models, and views; test coverage checks found provider recovery, unsupported ChatGPT repair, security invariant, redaction, and sanitized feedback coverage; and a literal credential scan found no hard-coded full credential literals. Earlier task evidence also covered focused AppModel, provider workflow, and security invariant test suites plus recovery-copy review.

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

T02 also updated `Pinemeter/Views/Setup/SetupWizardView.swift` because the existing setup action handler bypassed the new AppModel orchestration boundary. T03 added a focused provider workflow regression test to protect the UI wiring contract. Closeout verification required no source edits.

## Known Limitations

This slice proves provider recovery routing and sanitized local feedback, not live browser import with real provider credentials or release-signed Keychain behavior. Full first-run, reset, partial-provider, two-provider, and expired-session walkthroughs remain planned for S04.

## Follow-ups

S04 should exercise the reset and expired-session UAT flows end-to-end, including live or browser-mediated provider reconnect where safe. S03 should consume the provider-aware state and failure categories when polishing menu bar multi-provider usage states.

## Files Created/Modified

- `Pinemeter/App/AppModel.swift` — Centralized provider credential recovery action orchestration and sanitized action feedback state.
- `Pinemeter/Models/CredentialState.swift` — Modeled provider credential action kinds and provider-aware credential state used by recovery flows.
- `Pinemeter/Views/Settings/SettingsView.swift` — Routed provider recovery buttons through the shared AppModel action boundary with provider-specific feedback.
- `Pinemeter/Views/Setup/SetupWizardView.swift` — Routed setup repair and clear flows through AppModel rather than direct view-service coupling.
- `PinemeterTests/AppModelTests.swift` — Added or updated AppModel coverage for provider credential action behavior.
- `PinemeterTests/ProviderErrorWorkflowTests.swift` — Covered provider recovery workflows, unsupported action handling, and UI wiring expectations.
- `PinemeterTests/SecurityInvariantTests.swift` — Protected credential redaction and non-disclosure invariants for recovery flows.
