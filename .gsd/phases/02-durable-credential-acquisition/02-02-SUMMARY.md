---
id: S02
parent: M002
milestone: M002
provides:
  - Claude credential repair/re-save primitive for setup and settings recovery UX.
  - Sanitized Claude repair state for downstream provider-aware credential setup and lifecycle verification slices.
requires:
  - slice: S01
    provides: Consumes the credential state contract for sanitized provider credential health and failure categories.
affects:
  []
key_files:
  - Pinemeter/Repositories/Protocols/KeychainRepositoryProtocol.swift
  - Pinemeter/Repositories/KeychainRepository.swift
  - PinemeterTests/TestDoubles/KeychainRepositoryFake.swift
  - PinemeterTests/KeychainRepositoryTests.swift
  - Pinemeter/Services/Protocols/SessionKeyImportServiceProtocol.swift
  - Pinemeter/Services/SessionKeyImportService.swift
  - Pinemeter/App/AppModel.swift
  - PinemeterTests/AppModelTests.swift
  - PinemeterTests/ProviderErrorWorkflowTests.swift
  - PinemeterTests/SecurityInvariantTests.swift
  - .gsd/KNOWLEDGE.md
key_decisions:
  - Represent Claude Keychain repair outcomes as typed created/updated results rather than raw success OSStatus values.
  - Implement repair as scoped update-then-add under the legacy `com.claudemeter.sessionkey` service identifier with no broad delete fallback.
  - Expose Claude repair through sanitized CredentialState in SessionKeyImportService and AppModel instead of throwing raw Keychain errors through UI state.
  - Capture signing and legacy-service expectations as security invariants rather than mutating real user Keychain state in tests.
patterns_established:
  - Provider credential repair should cross service and UI boundaries as sanitized credential state, not raw credential material or low-level storage errors.
  - Keychain compatibility repairs should be scoped to selected account/service identifiers and avoid destructive cleanup of unrelated entries.
observability_surfaces:
  - Sanitized Claude credential operation status and failure category in app state.
  - Regression tests covering repair health, sanitized recovery failures, and signing/legacy-service invariants.
drill_down_paths:
  []
duration: ""
verification_result: passed
completed_at: 2026-06-18T21:34:20.645Z
blocker_discovered: false
---

# S02: Claude Keychain repair flow

**Claude credentials can now be repaired or re-saved under the current signed Pinemeter identity while preserving legacy Keychain compatibility and avoiding unrelated item deletion.**

## What Happened

S02 added a complete Claude Keychain repair path across repository, service, and app-model layers. The Keychain repository now exposes a typed `repairClaudeSessionKey(_:account:)` operation that preserves the legacy `com.claudemeter.sessionkey` service identifier, performs account-scoped update-then-add behavior, and reports whether the credential was created or updated without exposing OSStatus details on success. The session import service and AppModel now surface this repair path as sanitized `CredentialState` so setup/settings callers can recover Claude credentials without passing raw Keychain errors or credential material through UI state.

Task coverage also added security invariants for the official Autimo signed app identity and the Keychain prompt regression: tests assert the project does not default to ad-hoc signing for release identity assumptions and that repair keeps the legacy service rather than migrating or deleting arbitrary Keychain rows. User-visible failures are represented by provider-aware, sanitized credential state categories and recovery copy.

## Operational Readiness

Health signal: targeted repository, AppModel/provider workflow, and security invariant tests pass for Claude credential save/load/update/delete/repair and sanitized recovery behavior. At runtime, callers observe the Claude credential state and the last Claude credential operation status/failure category rather than secret values.

Failure signal: a repair failure is surfaced as a sanitized Claude credential failure state or provider-aware recovery message; test regressions in `KeychainRepositoryTests`, `AppModelTests`, `ProviderErrorWorkflowTests`, or `SecurityInvariantTests` indicate broken repair semantics, leaked raw errors, stale provider copy, or signing/legacy-service drift.

Recovery procedure: prompt the user to run the Claude repair or re-save flow for the selected Claude account; if Keychain access remains denied, clear only the Claude credential via the app-owned credential clear action and re-import the session key. Do not delete unrelated Keychain items and do not log or persist credential material.

Monitoring gaps: there is no production metrics dashboard or paging integration for menu-bar credential repair yet; this slice relies on observable sanitized state, tests, and user-visible recovery copy until later provider credential lifecycle verification and UX slices add broader diagnostics.

## Verification

Fresh slice-level verification passed via `gsd_exec` evidence `f6e340e0-7944-4f17-ae26-ac083a8c2b62`: `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/KeychainRepositoryTests -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/ProviderErrorWorkflowTests -only-testing:PinemeterTests/SecurityInvariantTests` exited 0. This covers Keychain repair primitives, AppModel repair state, provider recovery copy, and security invariants for signing and legacy service preservation.

## Requirements Advanced

- R010 — Adds durable Claude credential repair/re-save behavior so valid credential material can be retained and recovered without repeated manual entry.

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

No production metrics dashboard or alerting exists for credential repair yet; health is observable through sanitized app state and regression tests until later M002 slices add broader lifecycle verification and UX polish.

## Follow-ups

S04 should expose provider-aware repair/reconnect/clear controls using the sanitized Claude credential state. S05 should include end-to-end lifecycle verification for acquisition, reuse, repair, clear, invalid credential handling, and redaction.

## Files Created/Modified

- `Pinemeter/Repositories/Protocols/KeychainRepositoryProtocol.swift` — Added typed Claude credential repair contract.
- `Pinemeter/Repositories/KeychainRepository.swift` — Implemented legacy-service, account-scoped Claude repair behavior.
- `Pinemeter/Services/Protocols/SessionKeyImportServiceProtocol.swift` — Exposed Claude repair operation through service boundary.
- `Pinemeter/Services/SessionKeyImportService.swift` — Mapped repository repair into sanitized credential state.
- `Pinemeter/App/AppModel.swift` — Wired Claude credential repair state into observable app model.
- `PinemeterTests/KeychainRepositoryTests.swift` — Covered Claude repair create/update and scoped behavior.
- `PinemeterTests/AppModelTests.swift` — Covered AppModel repair state behavior.
- `PinemeterTests/ProviderErrorWorkflowTests.swift` — Covered provider-aware sanitized recovery copy.
- `PinemeterTests/SecurityInvariantTests.swift` — Added signing and legacy Keychain service invariants.
- `.gsd/KNOWLEDGE.md` — Recorded durable Claude Keychain prompt repair context.
