---
id: T01
parent: S04
milestone: M002
key_files:
  - Pinemeter/App/AppModel.swift
  - Pinemeter/Repositories/Protocols/ChatGPTSessionRepositoryProtocol.swift
  - PinemeterTests/AppModelTests.swift
  - PinemeterTests/ChatGPTAppModelTests.swift
key_decisions:
  - Use an app-specific `AppProviderCredentialStatus` wrapper to avoid collision with an existing/imported `ProviderCredentialStatus` symbol while preserving the AppModel `providerCredentialStatuses` surface.
  - Map ChatGPT acquisition statuses into the shared `CredentialState` domain so views consume one sanitized credential status model for both providers.
duration: 
verification_result: passed
completed_at: 2026-06-18T22:01:24.788Z
blocker_discovered: false
---

# T01: Added sanitized provider credential status view models to AppModel for Claude and ChatGPT credential recovery UI.

**Added sanitized provider credential status view models to AppModel for Claude and ChatGPT credential recovery UI.**

## What Happened

Implemented centralized credential status state in `AppModel` without exposing raw credential material to views. Added `ProviderCredentialActionKind` and `AppProviderCredentialStatus` as sanitized UI-facing view models, exposed `providerCredentialStatuses`, and added durable `chatGPTCredentialState` alongside existing Claude credential state. Mapped ChatGPT session acquisition states and failure categories into generic `CredentialState` so setup/settings surfaces can show health, last sanitized failure, recovery suggestions, and action availability from AppModel state. Updated Claude and ChatGPT validation, bootstrap, refresh, and clear paths to publish sanitized credential health for success, missing, invalid, and storage-unavailable cases.

## Failure Modes
- External dependencies: Keychain-backed repositories (`KeychainRepositoryProtocol`, `ChatGPTSessionRepositoryProtocol`) and provider validation/fetch services (`UsageServiceProtocol`, `ChatGPTUsageServiceProtocol`).
- ChatGPT repository validation returning `.storageUnavailable` with `keychainReadFailed` maps to `chatGPTCredentialState.health == .unavailable` and `failureCategory == .storageUnavailable`, verified by `ChatGPTAppModelTests.test_bootstrap_withChatGPTStorageUnavailablePublishesSanitizedStatus`.
- Provider rejection during Claude validation maps to `claudeCredentialState.health == .invalid` and `.providerRejected`, verified by `AppModelTests.test_userWithInvalidSessionKey_staysInSetup`.
- Provider rejection during ChatGPT validation maps to `chatGPTCredentialState.health == .invalid` and `.providerRejected`, verified by `ChatGPTAppModelTests.test_validateAndSaveChatGPTSessionCookie_withInvalidCookiePublishesSanitizedProviderRejection`.
- Missing ChatGPT session paths map through acquisition status to `.missing`/`.missing`; clear operations also publish missing state without reading secrets in views.

## Load Profile
This task has no meaningful runtime load dimension. The new status view models are computed from two in-memory credential state values and do not add polling, network calls, filesystem traversal, pagination, caching pressure, or collection growth.

## Negative Tests
- Invalid Claude session key: `PinemeterTests/AppModelTests.swift` case `test_userWithInvalidSessionKey_staysInSetup` asserts setup remains incomplete and sanitized provider-rejected state is published.
- Sanitization boundary: `PinemeterTests/AppModelTests.swift` case `test_providerCredentialStatusViewModelsExposeSanitizedClaudeAndChatGPTState` asserts provider status text does not contain a raw secret-like failure string and exposes only sanitized status/action labels.
- ChatGPT secure storage unavailable: `PinemeterTests/ChatGPTAppModelTests.swift` case `test_bootstrap_withChatGPTStorageUnavailablePublishesSanitizedStatus` asserts storage failure maps to sanitized unavailable state and repair/reconnect/clear actions.
- Invalid ChatGPT cookie: `PinemeterTests/ChatGPTAppModelTests.swift` case `test_validateAndSaveChatGPTSessionCookie_withInvalidCookiePublishesSanitizedProviderRejection` asserts the raw cookie is not included in searchable status text and invalid provider-rejection state is published.

## Observability Impact
Centralized user-visible credential status in AppModel as sanitized app state. The new state can be inspected through `providerCredentialStatuses`, `claudeCredentialState`, and `chatGPTCredentialState` without touching raw secrets.

## Verification

Ran the required targeted xcodebuild test command for `PinemeterTests/AppModelTests` and `PinemeterTests/ChatGPTAppModelTests`; it completed successfully. A prior red/build check showed the new API was initially absent/conflicting, then the implementation was corrected and the required verification passed.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/ChatGPTAppModelTests` | 0 | ✅ pass | 11601ms |

## Deviations

The planned expected outputs listed only `AppModel.swift` and tests, but implementing ChatGPT-to-generic credential state mapping also required updating `Pinemeter/Repositories/Protocols/ChatGPTSessionRepositoryProtocol.swift`. No UI files were modified in this task because the contract was to add centralized model state for later setup/settings consumption.

## Known Issues

None.

## Files Created/Modified

- `Pinemeter/App/AppModel.swift`
- `Pinemeter/Repositories/Protocols/ChatGPTSessionRepositoryProtocol.swift`
- `PinemeterTests/AppModelTests.swift`
- `PinemeterTests/ChatGPTAppModelTests.swift`
