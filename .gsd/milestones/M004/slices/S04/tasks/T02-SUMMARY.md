---
id: T02
parent: S04
milestone: M004
key_files:
  - Pinemeter/App/AppModel.swift
  - Pinemeter/Views/MenuBar/UsagePopoverView.swift
  - PinemeterTests/AppModelTests.swift
key_decisions:
  - Centralized popover content availability in AppModel so UsagePopoverView does not need to duplicate provider state checks.
duration: 
verification_result: passed
completed_at: 2026-06-24T21:31:51.505Z
blocker_discovered: false
---

# T02: Gemini usage and error states now render in the menu popover alongside configured providers.

**Gemini usage and error states now render in the menu popover alongside configured providers.**

## What Happened

Added a testable AppModel presentation boundary for popover content availability that includes Gemini data and Gemini error states. Updated UsagePopoverView to use that boundary, render Gemini quota data in its own provider section, show Gemini provider errors with the existing warning styling, and reuse a provider error row for ChatGPT and Gemini.

## Verification

Passed required targeted tests: `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/MenuBarIconRendererTests -only-testing:PinemeterTests/AppModelTests`. Also verified the new focused AppModel test passed after first observing the expected missing-property red failure.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `xcodebuild test -quiet -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/MenuBarIconRendererTests -only-testing:PinemeterTests/AppModelTests` | 0 | ✅ pass | 5567ms |

## Deviations

Added a small AppModel computed presentation boundary and a focused AppModel test in addition to the expected popover file change so the SwiftUI content gate is unit-covered.

## Known Issues

None.

## Files Created/Modified

- `Pinemeter/App/AppModel.swift`
- `Pinemeter/Views/MenuBar/UsagePopoverView.swift`
- `PinemeterTests/AppModelTests.swift`
