---
id: S04
parent: M004
milestone: M004
provides:
  - Menu bar popover state and rendering can display Gemini usage alongside Claude and ChatGPT with independent loading, unavailable, and error states.
requires:
  - slice: S02
    provides: Gemini credential and usage service seams with normalized usage and sanitized errors.
  - slice: S03
    provides: Gemini setup and settings UI state used to determine configured and partial-provider presentation.
affects:
  - S05
key_files:
  - Pinemeter/App/AppModel.swift
  - Pinemeter/Views/MenuBar/UsagePopoverView.swift
  - Pinemeter/Views/MenuBar/UsageCardView.swift
  - Pinemeter/Views/MenuBar/MenuBarPopoverView.swift
  - PinemeterTests/AppModelTests.swift
key_decisions:
  - Kept provider display combination coverage at the AppModel state boundary so UI state can be verified without snapshot-testing every provider permutation.
  - Centralized popover content availability in AppModel rather than duplicating provider state checks in UsagePopoverView.
patterns_established:
  - Provider-aware menu state composes configured-provider display, loading, unavailable, and error states across Claude, ChatGPT, and Gemini.
  - AppModel tests are the authoritative regression surface for provider menu combinations.
observability_surfaces:
  - AppModel exposes Gemini refresh, error, and popover-content state for tests and UI inspection; no external runtime health endpoint is introduced for this local SwiftUI menu-bar slice.
drill_down_paths:
  - .gsd/milestones/M004/slices/S04/tasks/T01-SUMMARY.md
  - .gsd/milestones/M004/slices/S04/tasks/T02-SUMMARY.md
  - .gsd/milestones/M004/slices/S04/tasks/T03-SUMMARY.md
duration: ""
verification_result: passed
completed_at: 2026-06-24T21:39:43.711Z
blocker_discovered: false
---

# S04: Gemini menu usage integration

**Gemini usage now participates in menu popover state, refresh/error presentation, and provider-combination tests alongside Claude and ChatGPT.**

## What Happened

S04 connected Gemini usage state into the menu-bar integration boundary rather than treating Gemini as a special-case branch. AppModel now exposes popover/menu state that accounts for Gemini usage, Gemini loading, Gemini unavailability, and Gemini refresh errors while still composing with Claude and ChatGPT states. The menu popover rendering path consumes that provider-aware state so Gemini cards can appear beside existing providers. Regression coverage was added at the AppModel state boundary for Gemini-only, Claude plus Gemini, ChatGPT plus Gemini, all-provider, and Gemini refresh-error combinations, giving downstream workflow UAT a stable surface to validate.

## Verification

Slice-level verification passed with `gsd_exec` evidence 5ad35ca0-d3f3-46b3-95c0-7321c3a1eb8f: `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/MenuBarIconRendererTests` exited 0. Task evidence also shows T01 AppModel tests and T02 targeted AppModel/MenuBarIconRenderer tests passed. T03 attempted full-suite verification, but the full suite is currently blocked by an unrelated `CopyableErrorPresentationTests.test_userFacingErrorSurfacesUseCopyableErrorText()` failure; `gsd_exec` evidence bf6c5624-390c-4d15-98da-8df7e5af7448 confirms that test still fails in isolation outside the Gemini menu integration surface.

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

T03 full-suite verification is blocked by an unrelated CopyableErrorPresentationTests failure that reproduces in isolation. S04 closeout uses the passing targeted AppModel and MenuBarIconRenderer verification for the slice integration surface and records the unrelated blocker as not proven by this UAT.

## Known Limitations

Live Gemini workflow behavior is intentionally deferred to S05. The repository also has a known unrelated full-suite blocker in CopyableErrorPresentationTests that remains unresolved by this slice.

## Follow-ups

S05 should run workflow-level UAT for Gemini setup, refresh, recovery, and coexistence. A separate non-S04 follow-up should address CopyableErrorPresentationTests so the full suite can return to green.

## Files Created/Modified

- `Pinemeter/App/AppModel.swift` — Adds provider-aware menu/popover state that includes Gemini usage and Gemini refresh/error conditions.
- `Pinemeter/Views/MenuBar/UsagePopoverView.swift` — Renders Gemini-aware usage state through the popover content path.
- `Pinemeter/Views/MenuBar/UsageCardView.swift` — Participates in provider card rendering for menu usage states.
- `Pinemeter/Views/MenuBar/MenuBarPopoverView.swift` — Integrates the provider-aware popover content surface.
- `PinemeterTests/AppModelTests.swift` — Adds Gemini-only, mixed-provider, all-provider, and Gemini-error regression coverage.
