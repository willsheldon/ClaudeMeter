---
id: T01
parent: S03
milestone: M004
key_files:
  - Pinemeter/App/AppModel.swift
  - Pinemeter/Views/Settings/SettingsView.swift
  - Pinemeter/Views/Setup/SetupWizardView.swift
  - PinemeterTests/AppModelTests.swift
key_decisions:
  - (none)
duration: 
verification_result: passed
completed_at: 2026-06-24T20:56:04.898Z
blocker_discovered: false
---

# T01: Extended shared provider credential status behavior and setup/settings copy so Gemini API-key status appears beside Claude and ChatGPT without exposing credential material.

**Extended shared provider credential status behavior and setup/settings copy so Gemini API-key status appears beside Claude and ChatGPT without exposing credential material.**

## What Happened

Updated the provider credential action policy so API-key credentials use the shared provider status collection without advertising browser-session reconnect or repair actions that cannot work for Gemini. Missing/unknown Gemini API-key state now appears as a status-only setup row, while saved/problem Gemini API-key states expose only the shared Clear recovery action. Updated Settings and Setup copy to explain that browser import checks Claude/ChatGPT while Gemini API-key status appears through the same provider status rows.

## Failure Modes
- External dependency: Keychain-backed/session credential stores used by existing provider actions. This task did not add a new external dependency; it narrows Gemini API-key recovery actions so unsupported reconnect/repair paths are not presented in UI. Direct calls to unsupported Gemini reconnect still throw `AppProviderCredentialActionError.unsupportedAction` without including credential-like material.
- UI failure path: stale Gemini API-key states are surfaced through sanitized `CredentialState` detail text and shared status rows; no raw API key values are rendered in status/search text.

## Load Profile
This task has no meaningful runtime load dimension. It adds one constant provider status row and static copy; the resource profile is bounded by the existing three-provider status collection.

## Negative Tests
- `PinemeterTests/AppModelTests.swift` verifies Gemini remains in `providerCredentialStatuses`, missing Gemini API-key status has no unsupported reconnect action, and invalid Gemini API-key state exposes only Clear.
- `PinemeterTests/AppModelTests.swift` verifies direct `.reconnect` for Gemini is rejected as an unsupported action without leaking API-key-shaped material.
- Existing provider workflow tests continue to cover shared setup/settings provider status rendering and sanitized action exposure.

## Verification

Ran the required focused verification command through `gsd_exec`: `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/ProviderErrorWorkflowTests`. The command exited 0; digest showed provider status UI workflow tests passing.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/ProviderErrorWorkflowTests` | 0 | ✅ pass | 12994ms |

## Deviations

None.

## Known Issues

None.

## Files Created/Modified

- `Pinemeter/App/AppModel.swift`
- `Pinemeter/Views/Settings/SettingsView.swift`
- `Pinemeter/Views/Setup/SetupWizardView.swift`
- `PinemeterTests/AppModelTests.swift`
