---
id: T02
parent: S03
milestone: M002
key_files:
  - Pinemeter/Services/ChatGPTUsageService.swift
  - Pinemeter/Services/WebViewNetworkService.swift
  - Pinemeter/Services/Protocols/ChatGPTUsageServiceProtocol.swift
  - Pinemeter/App/AppModel.swift
  - PinemeterTests/ChatGPTUsageServiceTests.swift
  - PinemeterTests/ChatGPTAppModelTests.swift
key_decisions:
  - ChatGPT app-facing acquisition now uses `ChatGPTSessionRepository` as the durable boundary instead of the legacy generic `chatgpt` Keychain account.
  - WebView cookie-store extraction logs only sanitized acquisition outcomes and persists only normalized ChatGPT session cookies through the repository.
duration: 
verification_result: passed
completed_at: 2026-06-18T21:52:12.206Z
blocker_discovered: false
---

# T02: Connected ChatGPT WebView/session acquisition and usage refresh flows to the secure ChatGPT session repository boundary.

**Connected ChatGPT WebView/session acquisition and usage refresh flows to the secure ChatGPT session repository boundary.**

## What Happened

Implemented repository-backed ChatGPT usage acquisition by adding `fetchUsage()` to `ChatGPTUsageService`, loading durable session cookies from `ChatGPTSessionRepository`, storing only the validated transient access token back through the repository actor, and clearing persisted state when validation reports missing or invalid credentials. AppModel now uses the same ChatGPT repository boundary for bootstrap, manual validation/save, refresh, load, and clear operations instead of the legacy generic `"chatgpt"` Keychain account. WebViewNetworkService now inspects the WebKit cookie store after successful JSON extraction and persists only normalized ChatGPT session-token cookies through `ChatGPTSessionRepository`, with sanitized logs for missing, persisted, invalid, and storage-failure paths.

## Failure Modes
- ChatGPT auth API returns no usable access token: `ChatGPTUsageService.fetchUsage()` throws `ChatGPTUsageError.invalidSessionCookie`, clears the repository-backed session for repository-loaded flows, and AppModel marks `hasChatGPTSessionCookie` false without exposing cookie or token values.
- No persisted ChatGPT session exists: repository `notFound` maps to `ChatGPTUsageError.missingSessionCookie`; AppModel leaves ChatGPT usage hidden/unloaded and the repository status remains sanitized as missing/notFound.
- Secure storage fails: repository secure-storage failures map to `networkUnavailable` on load and are logged by WebView only as sanitized failure categories when save fails.
- WebView cookie store contains no ChatGPT session cookie or malformed split-cookie material: WebView logs sanitized missing/normalization messages and does not persist any credential material.
- Network/HTTP/decoding failures from usage requests continue to bubble through the existing `ChatGPTUsageError`/client error path without storing raw response, cookie, or token material.

## Load Profile
- Runtime load is bounded by one repository load, one auth request, one usage request, and at most one repository save per ChatGPT refresh. At 10x refresh frequency, the external ChatGPT auth/usage APIs saturate before local actor/keychain operations; protection remains the app's existing refresh cadence plus actor-serialized repository access. WebView cookie extraction is opportunistic after a completed WebView request and only scans the current WebKit cookie list once per successful extraction.

## Negative Tests
- `PinemeterTests/ChatGPTUsageServiceTests.swift::test_fetchUsage_withoutPersistedSessionReportsMissingSession` covers absent repository state and sanitized missing status.
- `PinemeterTests/ChatGPTUsageServiceTests.swift::test_fetchUsage_withPersistedSessionClearsRepositoryWhenSessionIsInvalid` covers invalid auth/session responses and repository clearing.
- Existing `test_fetchUsage_withoutAccessToken_treatsCookieAsInvalid` covers explicit-cookie invalid access-token responses.
- Existing cookie-header tests cover raw token, full cookie header, and split-cookie normalization boundaries.
- `PinemeterTests/ChatGPTAppModelTests.swift` now covers bootstrap, manual save, invalid save rejection, refresh failure isolation, and clearing through the ChatGPT session repository boundary.

## Verification

Ran the required targeted ChatGPTUsageService test command successfully. Also ran related ChatGPTAppModelTests because AppModel/protocol seams were updated to use the repository-backed boundary. Both commands exited 0.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/ChatGPTUsageServiceTests` | 0 | ✅ pass | 10136ms |
| 2 | `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/ChatGPTAppModelTests` | 0 | ✅ pass | 5019ms |

## Deviations

Extended the task beyond the two service files to update `AppModel`, the ChatGPT usage service protocol, and AppModel tests so app-visible session acquisition and clearing also use the new secure repository boundary instead of the legacy generic Keychain account.

## Known Issues

None.

## Files Created/Modified

- `Pinemeter/Services/ChatGPTUsageService.swift`
- `Pinemeter/Services/WebViewNetworkService.swift`
- `Pinemeter/Services/Protocols/ChatGPTUsageServiceProtocol.swift`
- `Pinemeter/App/AppModel.swift`
- `PinemeterTests/ChatGPTUsageServiceTests.swift`
- `PinemeterTests/ChatGPTAppModelTests.swift`
