---
id: T01
parent: S03
milestone: M003
key_files:
  - Pinemeter/Views/MenuBar/MenuBarPopoverView.swift
  - Pinemeter/Views/MenuBar/UsagePopoverView.swift
  - Pinemeter/Views/MenuBar/UsageCardView.swift
  - Pinemeter/Views/MenuBar/ChatGPTUsageCardView.swift
  - Pinemeter/Views/MenuBar/MenuBarIconView.swift
  - Pinemeter/App/AppModel.swift
  - PinemeterTests/AppModelTests.swift
  - .gsd/exec/5cc67c43-c3f7-44e9-8378-4c0e2e9b91d7.stdout
key_decisions:
  - Treat `isSetupComplete` as the current Claude-only setup gate, not a generalized provider-ready state.
  - Use the audited display matrix as the downstream implementation target for menu diagnostics and provider-aware popover routing.
duration: 
verification_result: passed
completed_at: 2026-06-23T22:10:23.520Z
blocker_discovered: false
---

# T01: Audited menu bar provider assumptions and documented the current display-state matrix for no-provider, Claude-only, ChatGPT-only, both-provider, loading, and error states.

**Audited menu bar provider assumptions and documented the current display-state matrix for no-provider, Claude-only, ChatGPT-only, both-provider, loading, and error states.**

## What Happened

Inspected the menu bar popover, usage popover/cards, menu bar icon, AppModel setup/bootstrap, and related AppModel tests. The audit found these provider-state assumptions:

- No provider: `MenuBarPopoverView` gates the usage UI only on `appModel.isSetupComplete`, so users without a Claude session key see `SetupWizardView`.
- Claude-only: `isSetupComplete` becomes true when the default Claude session key exists, `UsagePopoverView` renders, and Claude metrics appear when `usageData` exists. The top-level heading is hard-coded to `Claude Usage`.
- ChatGPT-only: `AppModel.bootstrap` validates ChatGPT credentials and the refresh loop can run when `hasChatGPTSessionCookie` is true, but `MenuBarPopoverView` still routes to setup because `isSetupComplete` remains Claude-only. This is the primary partial-provider behavior gap for downstream implementation.
- Both providers: `UsagePopoverView` can show Claude and ChatGPT metric sections when both data objects exist and ChatGPT display is enabled.
- Loading: the usage popover uses a generic `Loading usage data...` empty-content state; the refresh button spinner/disabled state is keyed to Claude `isRefreshing` only, not `isRefreshingChatGPT`.
- Error: Claude errors render as a top banner from `errorMessage`; ChatGPT errors render inline from `chatGPTErrorMessage` only when `settings.isChatGPTUsageShown` is enabled.

## Failure Modes

External/runtime dependencies inspected for this audit were provider credential stores, provider usage services, settings persistence, notification threshold evaluation, refresh-loop timing, and macOS wake notifications. Current failure paths are visible in `AppModel`: Claude fetch failures bubble into `errorMessage`; missing/invalid ChatGPT session cookies clear ChatGPT data and set sanitized credential state/error text; generic ChatGPT usage failures set `chatGPTErrorMessage`; settings saves are best-effort; refresh-loop sleep errors are ignored. The audit specifically identified that ChatGPT-only success currently fails the menu routing dependency because setup completion is Claude-only even though ChatGPT refresh can operate independently.

## Load Profile

This audit introduced no new runtime load. The inspected runtime load dimension is periodic provider refresh: at 10x expected refresh demand, provider API/network calls would saturate first because Claude and ChatGPT refreshes are independently invoked on manual refresh, interval refresh, and wake refresh. Existing protections observed are per-provider in-flight guards (`isRefreshing`, `isRefreshingChatGPT`) and user-configurable refresh interval; there is no shared provider refresh state for the popover UI yet.

## Negative Tests

No new tests were added because this task was an audit-only unit. Existing negative/edge coverage identified: `test_bootstrap_withoutSessionKey_showsSetupState` asserts missing Claude session keeps setup incomplete, and ChatGPT credential action tests cover reconnect/clear provider separation. The uncovered negative surface for downstream work is a ChatGPT-only credential state asserting the popover routes to a usage-capable provider display rather than the Claude setup wizard.

## Verification

Ran a deterministic audit script through `gsd_exec` that scanned the referenced menu bar, usage card, AppModel, and test files for the current provider gates, refresh conditions, display copy, error surfaces, and test anchors. The script exited 0 and printed the desired display matrix for no provider, Claude-only, ChatGPT-only, both-provider, loading, and error states.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `gsd_exec python audit menu bar provider assumptions and display-state surfaces for M003/S03/T01` | 0 | ✅ pass | 138ms |

## Deviations

No source edits were made; the task plan requested an audit and the verification contract required the summary to record provider assumptions and the display matrix.

## Known Issues

ChatGPT-only users currently remain behind the Claude setup gate in `MenuBarPopoverView`; the header still reads `Claude Usage` even when both providers or ChatGPT-only usage is relevant; refresh spinner/disabled state does not include ChatGPT refresh activity.

## Files Created/Modified

- `Pinemeter/Views/MenuBar/MenuBarPopoverView.swift`
- `Pinemeter/Views/MenuBar/UsagePopoverView.swift`
- `Pinemeter/Views/MenuBar/UsageCardView.swift`
- `Pinemeter/Views/MenuBar/ChatGPTUsageCardView.swift`
- `Pinemeter/Views/MenuBar/MenuBarIconView.swift`
- `Pinemeter/App/AppModel.swift`
- `PinemeterTests/AppModelTests.swift`
- `.gsd/exec/5cc67c43-c3f7-44e9-8378-4c0e2e9b91d7.stdout`
