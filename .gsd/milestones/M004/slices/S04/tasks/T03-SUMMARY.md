---
id: T03
parent: S04
milestone: M004
key_files:
  - PinemeterTests/AppModelTests.swift
key_decisions:
  - Kept provider display combination coverage at the AppModel state boundary so tests assert the user-visible provider names, dashboard titles, loading copy, and popover-content availability without requiring UI snapshot changes.
duration: 
verification_result: mixed
completed_at: 2026-06-24T21:37:56.168Z
blocker_discovered: false
---

# T03: Added AppModel regression tests for Gemini-only, mixed Gemini provider combinations, all-provider display state, and Gemini refresh error display state.

**Added AppModel regression tests for Gemini-only, mixed Gemini provider combinations, all-provider display state, and Gemini refresh error display state.**

## What Happened

Added focused provider-display coverage in `PinemeterTests/AppModelTests.swift` for the AppModel menu/popover state introduced by prior S04 tasks. The new tests assert Gemini-only display strings and popover content availability, Claude plus Gemini ordering/messages, ChatGPT plus Gemini ordering/messages, all-provider ordering/messages, and a Gemini refresh failure path that preserves Gemini as configured while exposing the error through `geminiErrorMessage` and `hasUsagePopoverContent`.

## Failure Modes
- External dependencies for this task are test-only service stubs plus the XCTest/xcodebuild subprocess. The Gemini negative path uses `AppModelGeminiUsageServiceStub(fetchUsageResult: .failure(GeminiUsageError.networkUnavailable))` and verifies the failure is surfaced as a sanitized user-facing `geminiErrorMessage`, sets Gemini credential health to `.unavailable`, keeps Gemini configured, and keeps popover content inspectable.
- The required xcodebuild subprocess failure path was exercised: full-suite `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` failed twice with exit 65 due to `CopyableErrorPresentationTests.test_userFacingErrorSurfacesUseCopyableErrorText()`, including an isolated run of that same unrelated test reproducing the failure. The edited AppModel test class passed independently.

## Load Profile

## Negative Tests
- `PinemeterTests/AppModelTests.swift::test_providerDisplayCombinations_includeGeminiErrorState` covers a Gemini provider fetch failure (`GeminiUsageError.networkUnavailable`) and asserts no usage data is shown, an error is surfaced, credential health becomes unavailable, and Gemini remains represented in configured provider menu/popover state.
- Existing `test_usagePopoverContentAvailabilityIncludesGeminiDataAndErrors` remains as a direct boundary check that Gemini error text alone is enough to make popover content available.

## Verification

Ran the required full-suite verification command through `gsd_exec`; it failed twice with exit 65 on the unrelated `CopyableErrorPresentationTests.test_userFacingErrorSurfacesUseCopyableErrorText()` test. Ran focused verification for `PinemeterTests/AppModelTests`, which passed and covers the edited provider-display test surface. Also ran the isolated failing `CopyableErrorPresentationTests` case, which reproduced the same failure outside the edited AppModel tests.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` | 65 | ❌ fail — unrelated `CopyableErrorPresentationTests.test_userFacingErrorSurfacesUseCopyableErrorText()` failure | 29629ms |
| 2 | `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests` | 0 | ✅ pass | 6651ms |
| 3 | `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` | 65 | ❌ fail — same unrelated `CopyableErrorPresentationTests.test_userFacingErrorSurfacesUseCopyableErrorText()` failure on retry | 20425ms |
| 4 | `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/CopyableErrorPresentationTests/test_userFacingErrorSurfacesUseCopyableErrorText` | 65 | ❌ fail — isolated unrelated failure reproduces | 13428ms |

## Deviations

Added only `PinemeterTests/AppModelTests.swift`; `PinemeterTests/MenuBarIconRendererTests.swift` was inspected by task input but did not require changes because provider display state is exposed through AppModel computed menu/popover properties.

## Known Issues

The full test suite currently fails on `CopyableErrorPresentationTests.test_userFacingErrorSurfacesUseCopyableErrorText()`, which reproduces when isolated and is outside this task's edited AppModel provider-combination coverage.

## Files Created/Modified

- `PinemeterTests/AppModelTests.swift`
