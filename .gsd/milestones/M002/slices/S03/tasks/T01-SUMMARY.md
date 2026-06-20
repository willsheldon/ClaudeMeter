---
id: T01
parent: S03
milestone: M002
key_files:
  - Pinemeter/Repositories/Protocols/ChatGPTSessionRepositoryProtocol.swift
  - Pinemeter/Repositories/ChatGPTSessionRepository.swift
  - PinemeterTests/ChatGPTSessionRepositoryTests.swift
key_decisions:
  - ChatGPT session cookies are durable Keychain material, while ChatGPT access tokens are transient actor memory only.
  - Only sanitized ChatGPT acquisition state and failure categories are persisted for diagnostics; no raw cookie or token material is stored in `AppSettings`.
duration: 
verification_result: passed
completed_at: 2026-06-18T21:39:54.727Z
blocker_discovered: false
---

# T01: Added a Keychain-backed ChatGPT session repository boundary with transient access-token handling and sanitized acquisition diagnostics.

**Added a Keychain-backed ChatGPT session repository boundary with transient access-token handling and sanitized acquisition diagnostics.**

## What Happened

Implemented `ChatGPTSessionRepositoryProtocol` and `ChatGPTSessionRepository` as the durable boundary for ChatGPT credential-equivalent session material. The repository stores the ChatGPT session cookie in a dedicated Keychain service, keeps access tokens actor-memory-only so they do not survive repository recreation, and persists only sanitized acquisition state and failure category outside `AppSettings` for recovery/diagnostics. Added `ChatGPTSessionRepositoryTests` using synthetic credential-shaped values to prove save/load/validate/clear behavior, transient-token non-persistence, sanitized status/debug output, and negative paths.

## Failure Modes

External dependencies and failure paths addressed:
- Keychain write via `SecItemAdd`/`SecItemUpdate`: duplicate items update in place; non-success statuses persist `.storageUnavailable` with `.keychainWriteFailed` and throw `ChatGPTSessionRepositoryError.secureStorageUnavailable`.
- Keychain read via `SecItemCopyMatching`: missing item persists/returns `.missing` with `.notFound`; other non-success statuses persist/return `.storageUnavailable` with `.keychainReadFailed`; malformed/blank stored cookie maps to `.invalidSessionCookie`.
- Keychain delete via `SecItemDelete`: missing is treated as successful clear; other non-success statuses persist `.storageUnavailable` with `.keychainDeleteFailed` and throw.
- UserDefaults sanitized status persistence: only enum raw values for state/error category are written; no cookie, token, bearer, or header material is stored in status.

## Load Profile

Runtime load is low and bounded by one Keychain item per ChatGPT session account plus one sanitized status record. The first saturating resource under 10x expected load would be synchronous Keychain operation latency, protected by actor serialization and per-account single-item updates rather than unbounded in-memory accumulation. Transient access tokens are held in an actor dictionary keyed by account and cleared on `clear`; expected app usage is one default ChatGPT account, with tests covering unique synthetic accounts.

## Negative Tests

Covered in `PinemeterTests/ChatGPTSessionRepositoryTests.swift`:
- `test_saveRejectsBlankCookieAndRecordsSanitizedFailureCategory` rejects malformed blank cookies and records sanitized `.invalidSessionCookie` status.
- `test_validateClassifiesMissingSessionWithoutThrowing` covers missing durable Keychain session and returns sanitized `.notFound` without throwing.
- `test_clearRemovesDurableCookieAndTransientAccessToken` covers the cleared/missing boundary after deletion.
- `assertSanitized` is used across status tests to ensure synthetic cookie/token fragments, cookie header names, and bearer markers never appear in status descriptions.

## Observability Impact

Added sanitized `ChatGPTSessionAcquisitionStatus`, `ChatGPTSessionAcquisitionState`, and `ChatGPTSessionFailureCategory` for diagnostics and downstream UI/status recovery without credential leakage.

## Verification

Ran the required focused XCTest command for `PinemeterTests/ChatGPTSessionRepositoryTests`. The final run passed after resolving compile issues and preserving invalid acquisition status during validation.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/ChatGPTSessionRepositoryTests` | 0 | ✅ pass | 5747ms |

## Deviations

Persisted sanitized acquisition status in a repository-owned `UserDefaults` key namespace rather than `AppSettings`, matching the task requirement to avoid storing ChatGPT credential material in settings while allowing status recovery.

## Known Issues

None.

## Files Created/Modified

- `Pinemeter/Repositories/Protocols/ChatGPTSessionRepositoryProtocol.swift`
- `Pinemeter/Repositories/ChatGPTSessionRepository.swift`
- `PinemeterTests/ChatGPTSessionRepositoryTests.swift`
