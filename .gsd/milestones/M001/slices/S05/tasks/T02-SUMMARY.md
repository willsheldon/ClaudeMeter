---
id: T02
parent: S05
milestone: M001
key_files:
  - Pinemeter/Models/Errors/AppError.swift
  - Pinemeter/Models/Errors/NetworkError.swift
  - Pinemeter/Models/SessionKey.swift
  - Pinemeter/Views/MenuBar/UsagePopoverView.swift
  - Pinemeter/Views/Setup/SetupWizardView.swift
  - Pinemeter/Views/Settings/SettingsView.swift
  - PinemeterTests/ProviderErrorWorkflowTests.swift
  - PinemeterTests/SessionKeyTests.swift
key_decisions:
  - Keep recovery detection as a tiny Claude-specific string helper rather than introducing a broad typed provider error model in S05.
duration: 
verification_result: passed
completed_at: 2026-06-17T15:41:24.042Z
blocker_discovered: false
---

# T02: Qualified Claude credential errors, setup/settings recovery copy, and popover recovery-button detection with focused regression tests.

**Qualified Claude credential errors, setup/settings recovery copy, and popover recovery-button detection with focused regression tests.**

## What Happened

Implemented the T02 provider-copy changes narrowly against Claude credential surfaces only. Added `PinemeterTests/ProviderErrorWorkflowTests.swift` to lock `AppError.noSessionKey`, `AppError.sessionKeyInvalid`, `AppError.recoveryAction`, `NetworkError.authenticationFailed`, and the small `ClaudeCredentialRecoveryCopy` helper to Claude-specific copy. Extended `PinemeterTests/SessionKeyTests.swift` to assert Claude-specific `SessionKeyError` descriptions for invalid prefix, too-short values, and validation failure.

Updated `AppError`, `NetworkError`, and `SessionKeyError` localized descriptions to say `Claude session key` for Claude-only credential failures. Updated setup wizard and settings Claude session copy where it was explicitly about the Claude credential. ChatGPT session-cookie copy remains unchanged. Replaced the popover's broad substring-based recovery-button check with a tiny tested helper that requires the message to mention Claude before showing `Update Claude Session Key`, avoiding accidental ChatGPT recovery routing while preserving existing retry/settings behavior.

## Failure Modes
No new external dependencies, network calls, filesystem writes, subprocesses, credential display, persistence, logging, or diagnostic output were added. Existing validation/import/retry failure paths still bubble through the existing `SessionKeyError`, `NetworkError`, and `AppError` localized descriptions; this task only changes their labels/copy. The popover helper explicitly avoids showing the Claude update button for ChatGPT authentication/session-token failures.

## Load Profile
No runtime load dimension changed. The only runtime logic added is a constant-time string check for an already-present error banner; no background refresh, network request, polling, caching, or resource-intensive behavior was added.

## Negative Tests
`PinemeterTests/ProviderErrorWorkflowTests.swift` covers regression to generic credential copy for `AppError` and `NetworkError`, verifies the recovery button label is Claude-specific, and asserts ChatGPT session-token/authentication errors do not trigger Claude credential recovery. `PinemeterTests/SessionKeyTests.swift` covers invalid-format, too-short, and validation-failed SessionKey error descriptions so they fail if copy regresses to generic `Session key` wording.

## Verification

Ran the focused task verification command with an authoritative exit code: `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/ProviderErrorWorkflowTests -only-testing:PinemeterTests/SessionKeyTests`. The command exited 0 and the digest showed ProviderErrorWorkflowTests cases passing. An earlier red run compile-failed on the intentionally missing `ClaudeCredentialRecoveryCopy` helper, confirming the new provider workflow tests exercised the intended surface before implementation.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/ProviderErrorWorkflowTests -only-testing:PinemeterTests/SessionKeyTests` | 0 | ✅ pass | 9661ms |

## Deviations

Added the tiny `ClaudeCredentialRecoveryCopy` helper inside the already-planned `Pinemeter/Views/MenuBar/UsagePopoverView.swift` rather than a new source file, keeping the S05 change minimal and avoiding a broad provider error model.

## Known Issues

None.

## Files Created/Modified

- `Pinemeter/Models/Errors/AppError.swift`
- `Pinemeter/Models/Errors/NetworkError.swift`
- `Pinemeter/Models/SessionKey.swift`
- `Pinemeter/Views/MenuBar/UsagePopoverView.swift`
- `Pinemeter/Views/Setup/SetupWizardView.swift`
- `Pinemeter/Views/Settings/SettingsView.swift`
- `PinemeterTests/ProviderErrorWorkflowTests.swift`
- `PinemeterTests/SessionKeyTests.swift`
