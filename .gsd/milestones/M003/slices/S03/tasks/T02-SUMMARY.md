---
id: T02
parent: S03
milestone: M003
key_files:
  - Pinemeter/App/AppModel.swift
  - Pinemeter/Views/MenuBar/MenuBarPopoverView.swift
  - Pinemeter/Views/MenuBar/UsagePopoverView.swift
  - PinemeterTests/AppModelTests.swift
  - PinemeterTests/TestDoubles/UsageServiceStub.swift
key_decisions:
  - Use AppModel as the single provider-aware menu state surface for routing, title/loading copy, refresh disabled state, and refresh fan-out.
  - Keep `isSetupComplete` as Claude-only setup state while adding `hasConfiguredUsageProvider` for the generalized menu popover decision.
duration: 
verification_result: mixed
completed_at: 2026-06-23T22:19:16.576Z
blocker_discovered: false
---

# T02: Added provider-aware menu usage state so ChatGPT-only and mixed-provider setups route to the usage popover with provider-specific titles, loading text, refresh behavior, and tests.

**Added provider-aware menu usage state so ChatGPT-only and mixed-provider setups route to the usage popover with provider-specific titles, loading text, refresh behavior, and tests.**

## What Happened

Implemented a deterministic AppModel surface for menu usage state: Claude and ChatGPT configuration are now represented separately, `hasConfiguredUsageProvider` determines whether the menu bar popover shows usage versus setup, `configuredUsageProviderNames` drives provider-specific display copy, and `refreshConfiguredUsageProviders(forceRefresh:)` refreshes only configured visible providers. `MenuBarPopoverView` now uses the generalized configured-provider gate instead of the Claude-only `isSetupComplete` gate. `UsagePopoverView` now uses AppModel-provided title/loading/accessibility text, disables/shows progress when any configured provider is refreshing, and sends refresh through the unified configured-provider method.

Added AppModel coverage for no-provider, ChatGPT-only, and both-provider menu states, plus refresh fan-out behavior that proves ChatGPT-only refresh does not call Claude and both-provider refresh calls both providers. Extended usage test doubles with call-count tracking so refresh behavior is observable without sleeps or UI inspection.

## Failure Modes
- Claude usage fetch failure remains handled by existing `refreshUsage(forceRefresh:)`: the error is sanitized into `errorMessage`, `usageData` remains nil, and `isRefreshing` is cleared in `defer`.
- ChatGPT usage fetch failure remains handled by existing `refreshChatGPTUsage()`: the error is sanitized into `chatGPTErrorMessage`, `chatGPTUsageData` remains nil, credential state is updated, and `isRefreshingChatGPT` is cleared in `defer`.
- Provider absent or hidden state is handled before external calls: `refreshConfiguredUsageProviders(forceRefresh:)` skips Claude when `isSetupComplete` is false and skips ChatGPT unless a session cookie exists and ChatGPT usage is shown, preventing unnecessary failed network/keychain paths.

## Load Profile
- Runtime load dimension is limited to a menu bar refresh action over at most two configured providers. At 10x user refresh attempts, the saturating resource would be provider network/API calls; existing per-provider `isRefreshing` guards prevent overlapping refreshes for the same provider, and the unified method only fans out to configured visible providers.

## Negative Tests
- `AppModelTests.test_providerAwareMenuState_routesConfiguredProvidersToUsageSurface` covers the no-provider boundary, ChatGPT-only setup without Claude, and both-provider display copy.
- `AppModelTests.test_refreshConfiguredUsageProviders_refreshesOnlyVisibleConfiguredProviders` covers the negative path where Claude is not configured and must not be refreshed, then verifies both providers refresh once Claude becomes configured.
- Existing AppModel and ChatGPTAppModel tests continue to cover invalid/missing credential and sanitized error paths for both providers.

## Verification

Ran the task-specified targeted test command with `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/ChatGPTAppModelTests`. Initial run failed with Swift test compile errors from `await` inside XCTest autoclosures; actor reads were hoisted into local constants. The rerun passed with exit code 0.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/ChatGPTAppModelTests` | 65 | ❌ fail - test compile issue from await inside XCTest autoclosures; fixed before rerun | 9215ms |
| 2 | `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/ChatGPTAppModelTests` | 0 | ✅ pass | 8089ms |

## Deviations

Added provider-aware AppModel helper properties and a unified refresh method beyond the two input files so the views bind to a deterministic state surface rather than duplicating provider checks.

## Known Issues

None.

## Files Created/Modified

- `Pinemeter/App/AppModel.swift`
- `Pinemeter/Views/MenuBar/MenuBarPopoverView.swift`
- `Pinemeter/Views/MenuBar/UsagePopoverView.swift`
- `PinemeterTests/AppModelTests.swift`
- `PinemeterTests/TestDoubles/UsageServiceStub.swift`
