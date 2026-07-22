---
id: S03
parent: M003
milestone: M003
provides:
  - Provider-aware menu usage state and regression coverage for Claude-only, ChatGPT-only, mixed-provider, hidden ChatGPT, unavailable ChatGPT storage, and credential-disappearance demotion.
requires:
  - slice: S01
    provides: Sanitized provider credential status and setup state used by menu routing.
affects:
  - S04
key_files:
  - Pinemeter/App/AppModel.swift
  - Pinemeter/Views/MenuBar/MenuBarPopoverView.swift
  - Pinemeter/Views/MenuBar/UsagePopoverView.swift
  - Pinemeter/Views/MenuBar/UsageCardView.swift
  - Pinemeter/Views/MenuBar/ChatGPTUsageCardView.swift
  - PinemeterTests/AppModelTests.swift
  - PinemeterTests/ChatGPTAppModelTests.swift
  - PinemeterTests/MenuBarIconRendererTests.swift
  - PinemeterTests/TestSupport/MenuBarIconSnapshotRenderer.swift
key_decisions:
  - Keep isSetupComplete as Claude-only setup state while adding hasConfiguredUsageProvider for generalized menu routing.
  - Use AppModel as the single provider-aware menu state surface for routing, title/loading copy, refresh disabled state, and refresh fan-out.
  - Use existing AppModel and ChatGPTAppModel test surfaces for deterministic menu-state regressions instead of fragile UI-only assertions.
patterns_established:
  - Provider-aware menu state is derived centrally in AppModel and consumed by SwiftUI views.
  - Partial provider configuration is treated as useful when at least one visible provider is configured.
  - Credential-equivalent provider state remains sanitized and tested through model-level boundaries.
observability_surfaces:
  - Deterministic AppModel state and XCTest assertions expose healthy or regressed menu behavior for automation.
drill_down_paths:
  - .gsd/milestones/M003/slices/S03/tasks/T01-SUMMARY.md
  - .gsd/milestones/M003/slices/S03/tasks/T02-SUMMARY.md
  - .gsd/milestones/M003/slices/S03/tasks/T03-SUMMARY.md
  - .gsd/milestones/M003/slices/S03/tasks/T04-SUMMARY.md
duration: ""
verification_result: passed
completed_at: 2026-06-23T22:26:49.824Z
blocker_discovered: false
---

# S03: Menu bar multi-provider usage

**Provider-aware menu bar usage routing, titles, refresh behavior, and regression coverage now represent Claude-only, ChatGPT-only, mixed-provider, loading, error, and empty states.**

## What Happened

S03 started by auditing the existing menu bar assumptions and documenting the desired display matrix for no-provider, Claude-only, ChatGPT-only, both-provider, loading, and error states. Implementation then moved the generalized menu decision into AppModel with provider-aware state such as configured provider detection, dashboard title/loading copy, and a unified refresh entry point, while keeping the legacy Claude setup gate scoped to Claude credentials. MenuBarPopoverView and UsagePopoverView now route configured Claude or ChatGPT providers to the usage surface instead of treating ChatGPT-only as setup incomplete, and refresh behavior fans out only to visible configured providers. Regression coverage was added through AppModel and ChatGPTAppModel tests for partial setup, hidden ChatGPT usage, unavailable ChatGPT storage, mixed-provider state, and demotion when ChatGPT credentials disappear. Final task verification found no additional scope-relevant source changes were needed.

## Verification

Fresh slice closeout verification was run through gsd_exec. Full suite: `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` exited 0 in evidence `8bc4a4e7-9274-45a4-84b4-544856fb5021`. Deterministic source assertions for provider-aware menu routing, dashboard titles, refresh fan-out, hidden/unavailable ChatGPT coverage, and credential-disappearance demotion regressions exited 0 in evidence `a13c95db-241f-47e9-b0b2-0cfd5568a6e7`. Earlier task evidence also covered the planned targeted AppModel, ChatGPTAppModel, MenuBarIconRenderer, and menu copy scans.

## Requirements Advanced

None.

## Requirements Validated

None.

## New Requirements Surfaced

- None.

## Requirements Invalidated or Re-scoped

None.

## Operational Readiness

None.

## Deviations

T02 added AppModel provider-aware helper properties and a unified refresh method beyond the narrow view-file expectation so views bind to a deterministic state surface rather than duplicating provider checks. No other deviations.

## Known Limitations

Live menu bar visual review with real credentials and expired-session workflow diagnostics are deferred to S04. This slice proves the deterministic AppModel/menu behavior and regression coverage, not live provider API availability.

## Follow-ups

S04 should use these deterministic provider states as the baseline for reset, first-run, partial-provider, two-provider, and expired-session UAT.

## Files Created/Modified

- `Pinemeter/App/AppModel.swift` — Central provider-aware menu usage state, dashboard copy, refresh fan-out, and ChatGPT demotion behavior.
- `Pinemeter/Views/MenuBar/MenuBarPopoverView.swift` — Routes configured Claude or ChatGPT providers to the usage popover rather than using a Claude-only setup gate.
- `Pinemeter/Views/MenuBar/UsagePopoverView.swift` — Consumes provider-aware dashboard title/loading/refresh state.
- `PinemeterTests/AppModelTests.swift` — Regression coverage for provider-aware menu state and configured-provider refresh behavior.
- `PinemeterTests/ChatGPTAppModelTests.swift` — Regression coverage for ChatGPT bootstrap, hidden usage, unavailable storage, and sanitized status behavior.
