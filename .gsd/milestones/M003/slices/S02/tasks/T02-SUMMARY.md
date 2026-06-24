---
id: T02
parent: S02
milestone: M003
key_files:
  - Pinemeter/App/AppModel.swift
  - Pinemeter/Views/Setup/SetupWizardView.swift
  - PinemeterTests/AppModelTests.swift
  - PinemeterTests/ProviderErrorWorkflowTests.swift
key_decisions:
  - Unsupported ChatGPT repair is rejected at the AppModel boundary with a sanitized LocalizedError instead of falling back to reconnect implicitly.
duration: 
verification_result: mixed
completed_at: 2026-06-23T21:58:42.419Z
blocker_discovered: false
---

# T02: Centralized provider credential recovery actions in AppModel and routed setup repair/clear flows through that sanitized orchestration boundary.

**Centralized provider credential recovery actions in AppModel and routed setup repair/clear flows through that sanitized orchestration boundary.**

## What Happened

Added `AppModel.performProviderCredentialAction(_:for:)` as the provider-aware recovery action boundary. Claude reconnect imports from the default browser, repair delegates to the existing scoped session-key repair path, and clear delegates to the existing scoped Keychain delete path. ChatGPT reconnect imports through `SessionKeyImportService` and persists through `ChatGPTSessionRepository`, clear delegates to the repository-backed clear path, and unsupported ChatGPT repair now throws `AppProviderCredentialActionError.unsupportedAction` with provider/action copy only.

Updated setup recovery action handling so repair and clear use the new AppModel orchestration surface instead of invoking Claude-specific or provider-specific helper methods directly. Existing browser import remains the reconnect path for setup.

Added tests covering Claude repair through scoped Keychain repair, ChatGPT reconnect through the session repository boundary, provider-scoped clear behavior, unsupported ChatGPT repair sanitization, and setup workflow routing through AppModel.

## Failure Modes
- Browser credential import can fail because browser data is unavailable, malformed, inaccessible, or lacks Full Disk Access. The new orchestrator intentionally bubbles the existing import errors from `importAndSaveSessionKey()` and `importAndSaveChatGPTSessionCookie()` so setup can display sanitized localized failures.
- Keychain/session repository operations can fail during repair or clear. Claude repair continues to return a sanitized `CredentialState` from `SessionKeyImportService.repairSavedSessionKey(account:)`; Claude and ChatGPT clear bubble repository errors to the caller without embedding credential material.
- Unsupported provider/action pairs are rejected explicitly: ChatGPT repair throws `AppProviderCredentialActionError.unsupportedAction(provider:action:)`, verified not to include raw cookie sentinels.

## Load Profile
Provider recovery actions are user-triggered setup/settings operations rather than a repeated background workload. At 10x expected usage, the first saturated resource would be serialized Keychain/browser-import access, but AppModel routes each action through existing one-shot service/repository calls and setup disables action buttons while busy, so there is no new polling loop, queue, cache, or unbounded accumulation introduced by this task.

## Negative Tests
- `test_performProviderCredentialAction_repairsClaudeThroughScopedSessionKeyRepair` covers the repair path preserving the saved Claude key and refreshing usage.
- `test_performProviderCredentialAction_reconnectsChatGPTThroughSessionRepositoryBoundary` covers ChatGPT reconnect using the repository boundary and avoiding searchable credential leakage.
- `test_performProviderCredentialAction_clearsOnlyRequestedProviderCredential` covers provider-scoped clear behavior so clearing ChatGPT does not clear Claude.
- `test_performProviderCredentialAction_rejectsUnsupportedChatGPTRepairWithoutCredentialLeak` covers malformed/unsupported action input and sanitized error copy.
- `test_setupProviderStatusCardsExposeSharedRepairAndClearActionsWithoutManualCredentials` covers setup workflow routing through AppModel without manual credential entry surfaces.

## Verification

Focused AppModel and provider workflow tests passed through gsd_exec evidence e19803a0-1584-41aa-9db2-ea63f5178bb7.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/ProviderErrorWorkflowTests` | 65 | ❌ red-check fail before implementation | 6472ms |
| 2 | `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/ProviderErrorWorkflowTests` | 0 | ✅ pass | 10757ms |

## Deviations

Also updated `Pinemeter/Views/Setup/SetupWizardView.swift` because the existing setup action handler was bypassing the new AppModel orchestration boundary; this was necessary to satisfy the slice contract that recovery actions are routed through AppModel/service boundaries.

## Known Issues

None.

## Files Created/Modified

- `Pinemeter/App/AppModel.swift`
- `Pinemeter/Views/Setup/SetupWizardView.swift`
- `PinemeterTests/AppModelTests.swift`
- `PinemeterTests/ProviderErrorWorkflowTests.swift`
