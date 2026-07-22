---
id: S02
parent: M004
milestone: M004
provides:
  - A secure Gemini API-key repository/service seam, normalized Gemini usage/error model, AppModel refresh and clear integration, and focused test coverage for downstream settings and menu UI slices.
requires:
  - slice: S01
    provides: Gemini provider identity, model contract, and credential/usage state definitions.
affects:
  - S03
  - S04
  - S05
key_files:
  - Pinemeter/Repositories/Protocols/GeminiAPIKeyRepositoryProtocol.swift
  - Pinemeter/Repositories/GeminiAPIKeyRepository.swift
  - Pinemeter/Services/Protocols/GeminiUsageServiceProtocol.swift
  - Pinemeter/Services/GeminiUsageService.swift
  - Pinemeter/Models/API/GeminiAPIKey.swift
  - Pinemeter/App/AppModel.swift
  - Pinemeter/App/PinemeterApp.swift
  - Pinemeter/Services/CredentialStatusService.swift
  - PinemeterTests/GeminiUsageServiceTests.swift
  - PinemeterTests/GeminiCredentialBoundaryTests.swift
  - PinemeterTests/SecurityInvariantTests.swift
  - PinemeterTests/AppModelTests.swift
  - PinemeterTests/TestDoubles
key_decisions:
  - Gemini credentials are API keys, not persisted Google browser sessions, and are stored only through the dedicated Keychain repository service `com.pinemeter.gemini.api-key` with default account `gemini`.
  - `GeminiAPIKey` is a non-Codable credential value; diagnostics and AppModel state expose sanitized enum/category information only.
  - Stored Gemini API-key availability is the AppModel configuration signal; no separate AppSettings toggle was added.
  - Valid Gemini credentials with missing quota fields normalize to `quotaUnavailable` rather than leaking raw responses or failing as an unknown error.
patterns_established:
  - Provider credential-equivalent material is isolated behind repository protocols and actor services while AppModel exposes only sanitized provider state.
  - Security invariants combine XCTest coverage with static scans to guard against accidental settings persistence or logging of provider secrets.
observability_surfaces:
  - Sanitized Gemini acquisition diagnostics persist state/error categories without raw API-key material.
  - Gemini usage state and errors are normalized for AppModel consumers, providing health/failure state to downstream UI surfaces.
drill_down_paths:
  - .gsd/milestones/M004/slices/S02/tasks/T01-SUMMARY.md
  - .gsd/milestones/M004/slices/S02/tasks/T02-SUMMARY.md
  - .gsd/milestones/M004/slices/S02/tasks/T03-SUMMARY.md
duration: ""
verification_result: passed
completed_at: 2026-06-24T20:48:29.735Z
blocker_discovered: false
---

# S02: Gemini credential and usage service

**Gemini now has an API-key Keychain credential boundary, actor-backed usage service, sanitized diagnostics, and AppModel refresh/clear integration under focused tests.**

## What Happened

S02 established Gemini as a credential-backed usage provider without letting credential-equivalent material leak into settings, diagnostics, or UI-facing state. T01 defined the boundary: Gemini credentials are API keys, stored behind `GeminiAPIKeyRepositoryProtocol` using the dedicated Keychain service `com.pinemeter.gemini.api-key` and default account `gemini`, with AppModel and credential-status surfaces exposing only sanitized credential state. T02 implemented the concrete Keychain repository and actor usage service, including a non-Codable `GeminiAPIKey` value, sanitized acquisition diagnostics in UserDefaults, normalized success and failure outcomes, and tests for success, auth failure, quota-unavailable, and network behavior. T03 wired the repository/service seams into AppModel initialization, refresh orchestration, credential status, and clear behavior so downstream UI slices can consume provider state without touching raw key material.

The resulting integration gives downstream slices a provider-aware service boundary: UI code can ask AppModel whether Gemini is configured, refresh Gemini usage through normalized state, and clear saved Gemini credentials, while raw API-key material remains confined to `GeminiAPIKeyRepository` and `GeminiUsageService`. No AppSettings Gemini toggle was added; stored API-key availability is the configuration signal by design.

## Verification

Fresh slice-level verification was run through `gsd_exec` evidence `588657b0-e2a3-4e21-8005-6371f58b052d` with `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/SecurityInvariantTests -only-testing:PinemeterTests/GeminiUsageServiceTests -only-testing:PinemeterTests/GeminiCredentialBoundaryTests`. The command exited 0 and reported `** TEST SUCCEEDED **`. The same evidence ran static scans confirming no Gemini secret/API-key persistence patterns in `Pinemeter/Models/AppSettings.swift` or related model files, excluding the dedicated non-Codable key value, and no Gemini secret logging patterns in app or test sources.

Task-level verification also passed: T01 covered Gemini credential/status boundary tests and confirmed AppSettings contains no Gemini credential/API-key fields; T02 covered `SecurityInvariantTests` and `GeminiUsageServiceTests`; T03 covered focused `AppModelTests` and `SecurityInvariantTests` for Gemini refresh, credential status, and clear/reconnect surfaces.

## Requirements Advanced

None.

## Requirements Validated

None.

## New Requirements Surfaced

None.

## Requirements Invalidated or Re-scoped

None.

## Operational Readiness

None.

## Deviations

No AppSettings Gemini toggle was added. AppModel treats the presence of a stored Gemini API key as the Gemini configuration signal so credential-equivalent material remains confined to the repository/service boundary. Gemini reconnect/repair surfaces remain unsupported until the later user-facing setup slice.

## Known Limitations

Live Gemini API quota behavior is defensive because available responses may not include explicit quota fields; the service reports `quotaUnavailable` for valid credentials when quota fields are absent. User-facing API-key entry, reconnect/repair UX, settings presentation, and menu bar rendering are deferred to downstream slices.

## Follow-ups

S03 should add a user-facing Gemini API-key setup/settings flow that writes only through the repository boundary and reads only sanitized AppModel state. S04 should display Gemini refresh/usage states in the menu while preserving the same no-secret UI contract. S05 should add live or end-to-end workflow UAT for setup, refresh, recovery, and coexistence with Claude and ChatGPT.

## Files Created/Modified

- `Pinemeter/Repositories/Protocols/GeminiAPIKeyRepositoryProtocol.swift` — Defines Gemini API-key repository protocol and credential boundary contract.
- `Pinemeter/Repositories/GeminiAPIKeyRepository.swift` — Implements dedicated Keychain-backed Gemini API-key storage.
- `Pinemeter/Services/Protocols/GeminiUsageServiceProtocol.swift` — Defines actor/service protocol for Gemini usage acquisition and sanitized outcomes.
- `Pinemeter/Services/GeminiUsageService.swift` — Fetches/normalizes Gemini usage, auth failure, quota unavailable, and network failure states.
- `Pinemeter/App/AppModel.swift` — Wires Gemini credential availability, refresh orchestration, usage state, and clear behavior into app state.
- `Pinemeter/App/PinemeterApp.swift` — Provides Gemini repository/service dependencies during app initialization.
- `Pinemeter/Services/CredentialStatusService.swift` — Includes Gemini credential state in provider status calculation.
- `PinemeterTests/GeminiUsageServiceTests.swift` — Covers Gemini usage success and sanitized failure normalization.
- `PinemeterTests/GeminiCredentialBoundaryTests.swift` — Covers credential boundary and API-key storage assumptions.
- `PinemeterTests/SecurityInvariantTests.swift` — Adds/validates invariants preventing Gemini secret persistence or diagnostic leakage.
- `PinemeterTests/AppModelTests.swift` — Covers Gemini AppModel refresh, configured state, and clear behavior.
