---
id: S01
parent: M002
milestone: M002
provides:
  - Central credential state model for Claude and ChatGPT credential health.
  - Non-secret credential status service boundary for future setup, repair, reconnect, and clear flows.
  - Regression tests preserving AppSettings and SettingsRepository as credential-free preference storage.
requires:
  []
affects:
  - S02
  - S03
  - S04
  - S05
key_files:
  - Pinemeter/Models/CredentialState.swift
  - Pinemeter/Services/Protocols/CredentialStatusServiceProtocol.swift
  - Pinemeter/Services/CredentialStatusService.swift
  - Pinemeter/App/AppModel.swift
  - PinemeterTests/CredentialStateTests.swift
  - PinemeterTests/CredentialStatusServiceTests.swift
  - PinemeterTests/SecurityInvariantTests.swift
  - PinemeterTests/SettingsRepositoryTests.swift
  - PinemeterTests/TestDoubles/KeychainRepositoryFake.swift
key_decisions:
  - Credential state is a Foundation-only domain model with no SwiftUI, storage, or raw credential dependencies.
  - Credential status service maps provider availability through existence checks only, avoiding retrieval of raw credential material.
  - Settings persistence remains preference-only; credential-shaped keys and values are rejected or dropped by regression tests.
patterns_established:
  - Represent credential health as sanitized provider-scoped state that is safe for UI and diagnostics.
  - Use repository existence checks for credential status instead of reading secret payloads.
  - Pin credential-free AppSettings and SettingsRepository behavior with security regression tests.
observability_surfaces:
  - Display-safe provider, health state, failure category, title, description, and recovery suggestion values are available for future diagnostics.
  - Automated tests act as the current health signal for the contract and persistence invariants.
drill_down_paths:
  - .gsd/milestones/M002/slices/S01/tasks/T01-SUMMARY.md
  - .gsd/milestones/M002/slices/S01/tasks/T02-SUMMARY.md
  - .gsd/milestones/M002/slices/S01/tasks/T03-SUMMARY.md
duration: ""
verification_result: passed
completed_at: 2026-06-18T21:01:12.019Z
blocker_discovered: false
---

# S01: Credential state contract

**Created and verified a central, provider-aware credential state contract and status boundary for Claude and ChatGPT without exposing or persisting credential material.**

## What Happened

Slice S01 established the shared credential state contract needed by later durable credential acquisition work. T01 added a Foundation-only domain model for credential providers, credential identity, health states, sanitized failure categories, display-safe descriptions, and recovery suggestions. T02 added a non-secret credential status service protocol and implementation that maps Claude and ChatGPT credential availability through existing Keychain existence checks without retrieving raw session keys, cookies, or tokens. T03 added regression coverage proving AppSettings and SettingsRepository remain preference-only surfaces, including legacy or poisoned settings payloads that contain credential-shaped keys or values. Together these changes provide a central, provider-aware health contract for missing, present, invalid, expired, repairable, and unknown credential states while preserving M001 redaction and settings persistence invariants.

## Verification

Fresh slice-level verification was run with `gsd_exec` evidence `a4a5ec0a-4ff2-49f9-98e4-1a4a5d093b79`: `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/CredentialStateTests -only-testing:PinemeterTests/CredentialStatusServiceTests -only-testing:PinemeterTests/SecurityInvariantTests -only-testing:PinemeterTests/SettingsRepositoryTests`. Exit code 0. The selected test suites passed, covering the credential state model, sanitized descriptions, status service mapping, no-secret retrieval behavior, AppSettings credential-free encoding, and SettingsRepository credential-free persistence.

## Requirements Advanced

- R010 — Established the provider-aware state contract and non-secret status boundary needed for durable credential acquisition and reuse flows in later M002 slices.

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

This slice defines the shared contract and status boundary only; it does not change credential acquisition, repair, reconnect, or clearing behavior yet.

## Follow-ups

Use the S01 credential state contract in S02 Claude Keychain repair flow, S03 ChatGPT session acquisition boundary, S04 setup and recovery UX, and S05 lifecycle verification.

## Files Created/Modified

- `Pinemeter/Models/CredentialState.swift` — Defines provider credential identity, health states, sanitized failure categories, and display-safe state descriptions.
- `Pinemeter/Services/Protocols/CredentialStatusServiceProtocol.swift` — Defines the non-secret credential status service boundary.
- `Pinemeter/Services/CredentialStatusService.swift` — Maps Claude and ChatGPT credential availability through keychain existence checks without exposing secrets.
- `Pinemeter/App/AppModel.swift` — Integrates the credential status service boundary for app-level dependency access.
- `PinemeterTests/CredentialStateTests.swift` — Covers credential state labels, health descriptions, sanitized failure categories, and Codable behavior.
- `PinemeterTests/CredentialStatusServiceTests.swift` — Covers provider status mapping, provider ordering, missing/present states, and no-secret retrieval behavior.
- `PinemeterTests/SecurityInvariantTests.swift` — Adds invariants that AppSettings does not encode credential-state fields or credential-shaped values.
- `PinemeterTests/SettingsRepositoryTests.swift` — Adds legacy/poisoned payload regression coverage proving credential-shaped settings material is dropped on save.
- `PinemeterTests/TestDoubles/KeychainRepositoryFake.swift` — Supports status service tests with fake keychain existence behavior and no-secret retrieval assertions.
