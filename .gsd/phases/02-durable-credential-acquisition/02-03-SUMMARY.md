---
id: S03
parent: M002
milestone: M002
provides:
  - A secure ChatGPT session repository boundary for S04 setup and recovery UX.
  - Sanitized ChatGPT credential state and diagnostics for S05 lifecycle verification.
requires:
  - slice: S01
    provides: Credential state contract consumed for provider-aware ChatGPT acquisition state.
affects:
  []
key_files:
  - Pinemeter/Repositories/Protocols/ChatGPTSessionRepositoryProtocol.swift
  - Pinemeter/Repositories/ChatGPTSessionRepository.swift
  - Pinemeter/Services/WebViewNetworkService.swift
  - Pinemeter/Services/ChatGPTUsageService.swift
  - Pinemeter/Services/Protocols/ChatGPTUsageServiceProtocol.swift
  - Pinemeter/App/AppModel.swift
  - PinemeterTests/ChatGPTSessionRepositoryTests.swift
  - PinemeterTests/ChatGPTUsageServiceTests.swift
  - PinemeterTests/ChatGPTAppModelTests.swift
  - PinemeterTests/SecurityInvariantTests.swift
  - PinemeterTests/SettingsRepositoryTests.swift
  - PinemeterTests/ProviderErrorWorkflowTests.swift
key_decisions:
  - ChatGPT session cookies are durable credential-equivalent material stored through the Keychain-backed ChatGPT session repository boundary.
  - ChatGPT Bearer access tokens are transient actor-memory material only and are not persisted.
  - ChatGPT acquisition diagnostics persist only sanitized state and failure categories.
patterns_established:
  - Provider session material should flow through provider-specific secure repositories rather than settings.
  - Synthetic credential sentinels prove redaction and persistence boundaries without using real secrets.
observability_surfaces:
  - Sanitized ChatGPT acquisition status.
  - Sanitized ChatGPT last error category.
  - Invalid-session clearing behavior exercised by usage-service tests.
drill_down_paths:
  []
duration: ""
verification_result: passed
completed_at: 2026-06-18T21:56:44.562Z
blocker_discovered: false
---

# S03: ChatGPT session acquisition boundary

**Implemented and verified a Keychain-backed ChatGPT session boundary that persists durable cookies securely, keeps access tokens transient, and exposes only sanitized acquisition diagnostics.**

## What Happened

## What Happened

S03 established the ChatGPT credential-equivalent boundary needed by durable credential acquisition. `ChatGPTSessionRepositoryProtocol` and `ChatGPTSessionRepository` now define save, load, validation, diagnostics, and clear operations for ChatGPT session material. Durable ChatGPT session cookies are stored through a dedicated Keychain-backed repository boundary, while Bearer access tokens are treated as transient actor memory and are not persisted to `AppSettings`, UserDefaults settings, logs, user-facing errors, or GSD artifacts.

The ChatGPT WebView and usage-refresh paths were connected to the repository boundary. WebView cookie extraction now has an explicit extraction, validation, persistence, and clearing path; `ChatGPTUsageService` can use persisted session cookies, clear invalid sessions, and expose sanitized acquisition status without leaking raw credential values. Security invariant tests were added for synthetic cookie and Bearer-token sentinels, settings separation, diagnostics redaction, and provider-facing error copy.

## Operational Readiness

Health signal: ChatGPT acquisition and usage flows expose sanitized acquisition state and last error category, allowing operators or future diagnostics to distinguish valid, missing, invalid, and cleared ChatGPT session states without displaying credential material. The slice verification suite exercises repository save/load/clear, usage-service persisted-session reuse, invalid-session clearing, settings separation, and redaction invariants.

Failure signal: A broken slice would surface as failing `ChatGPTSessionRepositoryTests`, `ChatGPTUsageServiceTests`, `SecurityInvariantTests`, `ProviderErrorWorkflowTests`, or `SettingsRepositoryTests`, especially failures that show session material in settings, diagnostics, localized errors, or logs, or failures that leave invalid ChatGPT sessions uncleared.

Recovery procedure: If ChatGPT session acquisition is unhealthy, clear the ChatGPT session through the repository-backed clear path and reacquire from WebView cookie extraction; if validation fails, rely on the usage service invalidation path to clear stored session material and report only the sanitized failure category. Monitoring gap: this slice adds sanitized state and test coverage but does not yet add a user-facing recovery dashboard; S04 is expected to present provider-aware reconnect, repair, and clear controls.

## Downstream Notes

S04 can consume the ChatGPT credential state surface alongside the S01 credential contract and S02 Claude repair surface. S05 should include lifecycle evidence for ChatGPT session acquisition, reuse, invalidation, clear, and redaction using the same synthetic sentinel pattern.

## Verification

Fresh slice-level verification was run through `gsd_exec` evidence `e91f4d6d-c75d-4dbd-9533-c92d053e6990` with command: `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/ChatGPTSessionRepositoryTests -only-testing:PinemeterTests/ChatGPTUsageServiceTests -only-testing:PinemeterTests/SecurityInvariantTests -only-testing:PinemeterTests/ProviderErrorWorkflowTests -only-testing:PinemeterTests/SettingsRepositoryTests`. Exit code 0. The test output ended with passing ChatGPT usage-service test cases and no stderr.

## Requirements Advanced

- R010 — ChatGPT session material can now be acquired, retained, reused, invalidated, and cleared through an app-owned secure boundary without repeated manual credential entry when durable session material is valid.

## Requirements Validated

None.

## New Requirements Surfaced

None.

## Requirements Invalidated or Re-scoped

None.

## Operational Readiness

None.

## Deviations

None.

## Known Limitations

S03 proves the secure backend boundary and sanitized diagnostics. Provider-aware user-facing reconnect, repair, and clear controls are intentionally deferred to S04; full credential lifecycle verification is deferred to S05.

## Follow-ups

S04 should surface ChatGPT credential status and recovery actions using the sanitized state from this slice. S05 should produce end-to-end lifecycle evidence for acquisition, reuse, invalidation, clearing, and redaction.

## Files Created/Modified

- `Pinemeter/Repositories/Protocols/ChatGPTSessionRepositoryProtocol.swift` — Defines the ChatGPT secure session repository contract.
- `Pinemeter/Repositories/ChatGPTSessionRepository.swift` — Implements Keychain-backed ChatGPT session persistence and transient access-token handling.
- `Pinemeter/Services/WebViewNetworkService.swift` — Connects WebView cookie extraction to sanitized ChatGPT acquisition and persistence.
- `Pinemeter/Services/ChatGPTUsageService.swift` — Uses persisted ChatGPT sessions and clears invalid session material.
- `PinemeterTests/SecurityInvariantTests.swift` — Adds synthetic ChatGPT credential redaction and settings-separation invariant coverage.
