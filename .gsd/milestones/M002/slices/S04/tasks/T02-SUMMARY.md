---
id: T02
parent: S04
milestone: M002
key_files:
  - Pinemeter/Views/Settings/SettingsView.swift
  - PinemeterTests/AppModelTests.swift
key_decisions:
  - Drive Settings credential recovery controls from `AppProviderCredentialStatus` so UI copy and actions stay sanitized and consistent with AppModel state.
duration: 
verification_result: passed
completed_at: 2026-06-18T22:05:19.257Z
blocker_discovered: false
---

# T02: Added Settings credential recovery rows for Claude and optional ChatGPT using sanitized provider status view models.

**Added Settings credential recovery rows for Claude and optional ChatGPT using sanitized provider status view models.**

## What Happened

Updated `SettingsView` to show a new Claude-first Credential Recovery section above the existing credential editors. Each provider row renders only sanitized status text from `AppProviderCredentialStatus`, uses health-specific icons/colors, and exposes action buttons from the tested action model: Claude reconnect imports from browser, repair runs the existing Keychain repair flow, clear removes the saved session key; ChatGPT reconnect focuses the existing cookie entry flow and clear removes the stored optional cookie. No Gemini copy or capability was introduced.

Added AppModel test coverage for the credential action matrix across unknown, missing, validating, valid, refresh-recommended, invalid, expired, and unavailable Claude states, including a guard that searchable status text does not contain the test credential value.

## Failure Modes
External dependencies remain behind AppModel services/repositories: Claude browser import can fail or require Full Disk Access and the existing `SessionKeyImportError` path is surfaced in `sessionKeyValidationMessage`; Claude repair can fail on Keychain write and `repairClaudeSessionKeyFromSettings` now converts the refreshed sanitized provider status into user-visible copy; clear operations can fail and continue to display localized failure messages. ChatGPT reconnect performs no network operation from the recovery row; it reveals the existing cookie input and validation remains in the existing save path. Evidence includes existing AppModel negative tests for invalid keys/imports, missing organization, and repair storage failure plus the new action-matrix test.

## Load Profile
No meaningful runtime load dimension was introduced. The recovery UI renders the fixed provider status list currently produced by AppModel (Claude and optional ChatGPT), so the first saturation point is ordinary SwiftUI view rendering, not an external resource. No rate limiting, paging, or pooling is applicable.

## Negative Tests
`PinemeterTests/AppModelTests.swift` now includes `test_providerCredentialStatusesExposeRecoveryActionsForBoundaryStates`, covering malformed/boundary credential health states and verifying no raw credential value appears in searchable sanitized text. Existing negative tests in the same file cover invalid Claude session keys, invalid imported keys, missing organization, failed Claude Keychain repair, and clearing session state.

## Verification

Ran the authoritative targeted verification command: `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests`. The first two attempts exposed compile issues introduced during implementation (`CredentialHealth` vs `CredentialHealthState`, then the same stale type in the test table). After correcting those, the targeted AppModel test suite passed with exit code 0.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests` | 0 | ✅ pass | 7798ms |

## Deviations

None.

## Known Issues

No known issues. UI behavior was wired through existing AppModel recovery methods; no separate UI automation was available for the native macOS settings view in this task.

## Files Created/Modified

- `Pinemeter/Views/Settings/SettingsView.swift`
- `PinemeterTests/AppModelTests.swift`
