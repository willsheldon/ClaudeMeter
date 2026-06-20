---
id: T03
parent: S03
milestone: M002
key_files:
  - PinemeterTests/SecurityInvariantTests.swift
  - PinemeterTests/ProviderErrorWorkflowTests.swift
key_decisions:
  - (none)
duration: 
verification_result: passed
completed_at: 2026-06-18T21:55:09.234Z
blocker_discovered: false
---

# T03: Added ChatGPT credential redaction invariant tests for persisted acquisition diagnostics, AppSettings separation, and user-facing error copy.

**Added ChatGPT credential redaction invariant tests for persisted acquisition diagnostics, AppSettings separation, and user-facing error copy.**

## What Happened

Extended `PinemeterTests/SecurityInvariantTests.swift` with ChatGPT-specific synthetic cookie and Bearer-token sentinels. The new coverage proves that successful acquisition status persists only sanitized state/category metadata outside `app_settings`, and that invalid acquisition diagnostics persist only the failure category without echoing access-token material. Extended `PinemeterTests/ProviderErrorWorkflowTests.swift` with ChatGPT user-facing error copy assertions so credential-shaped cookie and Bearer token fragments are not surfaced through localized descriptions.

## Failure Modes
- Keychain/session save rejects blank ChatGPT cookie input: `test_chatGPTInvalidAcquisitionDiagnosticsPersistOnlyFailureCategory` verifies the repository throws `ChatGPTSessionRepositoryError.invalidSessionCookie`, records sanitized `.invalid` / `.invalidSessionCookie` diagnostics, and does not persist the Bearer token sentinel.
- Settings persistence boundary: `test_chatGPTAcquisitionStatusPersistenceIsSanitizedAndSeparateFromAppSettings` verifies acquisition diagnostics do not create or write `app_settings`, preventing diagnostic state from leaking into user settings.

## Load Profile

## Negative Tests
- Blank ChatGPT session cookie with a credential-shaped Bearer token is rejected and sanitized in `PinemeterTests/SecurityInvariantTests.swift::test_chatGPTInvalidAcquisitionDiagnosticsPersistOnlyFailureCategory`.
- ChatGPT localized error descriptions for missing, invalid, invalid response, HTTP failure, and network unavailable cases are checked against synthetic cookie and Bearer token sentinels in `PinemeterTests/ProviderErrorWorkflowTests.swift::test_chatGPTUsageErrorsDoNotEchoCookieOrBearerTokenSentinels`.
- AppSettings coding and persistence remain free of credential boundary fields and credential-shaped values in the existing SecurityInvariantTests coverage, now complemented by the ChatGPT acquisition-status persistence test.

## Observability Impact
The tests guard the sanitized diagnostic surface as ChatGPT acquisition status and failure categories expand, ensuring future diagnostics remain useful without exposing cookie or access-token material.

## Verification

Ran the required targeted XCTest command. `SecurityInvariantTests` and `ProviderErrorWorkflowTests` passed, including the new ChatGPT redaction invariant tests.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests -only-testing:PinemeterTests/ProviderErrorWorkflowTests` | 0 | ✅ pass | 9143ms |

## Deviations

None.

## Known Issues

None.

## Files Created/Modified

- `PinemeterTests/SecurityInvariantTests.swift`
- `PinemeterTests/ProviderErrorWorkflowTests.swift`
