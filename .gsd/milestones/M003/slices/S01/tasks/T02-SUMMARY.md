---
id: T02
parent: S01
milestone: M003
key_files:
  - Pinemeter/App/AppModel.swift
  - Pinemeter/Views/Setup/SetupWizardView.swift
  - Pinemeter/Views/Settings/SettingsView.swift
  - PinemeterTests/AppModelTests.swift
key_decisions:
  - Expose surface-neutral `stateText` and `detailText` on `AppProviderCredentialStatus`, while preserving existing `statusTitle`, `statusDescription`, and setup prompt aliases as wrappers.
duration: 
verification_result: passed
completed_at: 2026-06-23T03:12:06.615Z
blocker_discovered: false
---

# T02: Unified provider credential status presentation text for setup and settings without exposing credential material.

**Unified provider credential status presentation text for setup and settings without exposing credential material.**

## What Happened

Refined `AppProviderCredentialStatus` so setup and settings can consume the same sanitized provider name, credential name, state text, detail text, and action labels for Claude and ChatGPT. Kept the existing setup/status aliases as compatibility wrappers over the unified fields, then moved `SetupWizardView` and `SettingsView` to render `stateText` and `detailText` directly.

Added AppModel tests that pin the shared presentation contract for provider names, credential names, state text, detail text, action display labels, and secret redaction. The tests cover ready, missing, unavailable/repairable, and boundary action states while ensuring raw credential-like fragments do not appear in searchable or detail text.

## Failure Modes

- Dependency: stored credential state from Keychain/session repositories can be missing, invalid, expired, unavailable, validating, or unknown. The presentation model handles each `CredentialHealthState` by producing sanitized state/detail text and appropriate actions without requiring raw credential access.
- Dependency: provider acquisition/storage can fail with a categorized failure such as `storageUnavailable` or `providerRejected`. The model uses sanitized `CredentialFailureCategory` titles/descriptions/recovery suggestions; tests assert storage failure renders `Check Keychain access and try again.` and does not leak `sk-ant-secret` or `TestConstants.sessionKeyValue`.
- Dependency: UI surfaces can drift if setup and settings use separate text properties. Setup and settings now render `stateText` and `detailText`, with legacy properties delegated to those same fields.

## Load Profile


## Negative Tests

- `PinemeterTests/AppModelTests.swift::test_providerCredentialStatusViewModelsExposeSanitizedClaudeAndChatGPTState` asserts raw credential-like fragments are absent from searchable and detail text when an upstream error message contains `raw sk-ant-secret must not appear`.
- `PinemeterTests/AppModelTests.swift::test_providerCredentialStatusSetupPromptsDistinguishReadyMissingAndRepairableCredentials` asserts missing credentials do not ask users to paste or manually enter secrets and repairable storage failures do not expose `TestConstants.sessionKeyValue` in accessibility text.
- `PinemeterTests/AppModelTests.swift::test_providerCredentialStatusesExposeRecoveryActionsForBoundaryStates` asserts action sets for unknown, missing, validating, valid, refresh-recommended, invalid, expired, and unavailable health states, including the validating boundary where no action should be offered.

## Verification

Ran the task verification command through `gsd_exec`: `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/CredentialStateTests`. The targeted AppModel and CredentialState test suites passed, compiling the app and validating the unified sanitized presentation behavior.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/CredentialStateTests` | 0 | ✅ pass | 20021ms |

## Deviations

Updated `Pinemeter/Views/Setup/SetupWizardView.swift` and `Pinemeter/Views/Settings/SettingsView.swift` in addition to the expected AppModel/tests outputs so both real setup and settings surfaces consume the unified presentation fields.

## Known Issues

None.

## Files Created/Modified

- `Pinemeter/App/AppModel.swift`
- `Pinemeter/Views/Setup/SetupWizardView.swift`
- `Pinemeter/Views/Settings/SettingsView.swift`
- `PinemeterTests/AppModelTests.swift`
