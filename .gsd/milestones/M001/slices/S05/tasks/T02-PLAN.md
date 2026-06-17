---
estimated_steps: 16
estimated_files: 8
skills_used: []
---

# T02: Qualify Claude credential errors and recovery copy

---
skills_used: [tdd, verify-before-complete]
---
Why: S02/S03 established that the app has both Claude and ChatGPT credential material. Generic `session key` wording in Claude-only setup, error, and recovery paths is now provider-ambiguous and can send users to the wrong recovery workflow.

Do:
- Add focused XCTest coverage in `PinemeterTests/ProviderErrorWorkflowTests.swift` for Claude-specific localized copy on `AppError.noSessionKey`, `AppError.sessionKeyInvalid`, `AppError.recoveryAction`, `NetworkError.authenticationFailed`, and any tiny provider/error helper introduced for recovery-button visibility.
- Extend `PinemeterTests/SessionKeyTests.swift` to assert Claude-specific validation error descriptions for invalid prefix, too-short values, and validation failure.
- Update `Pinemeter/Models/Errors/AppError.swift`, `Pinemeter/Models/Errors/NetworkError.swift`, and `Pinemeter/Models/SessionKey.swift` so Claude-only credential failures say `Claude session key`.
- Update user-facing Claude-only setup/settings/menu recovery copy in `Pinemeter/Views/Setup/SetupWizardView.swift`, `Pinemeter/Views/Settings/SettingsView.swift`, and `Pinemeter/Views/MenuBar/UsagePopoverView.swift` where the phrase is specifically about Claude credentials. Keep ChatGPT section copy unchanged except for avoiding accidental genericization.
- If the popover keeps substring-based recovery detection, keep the change minimal and covered by tests; do not introduce a broad typed provider error model in S05.

Done when: focused provider/error and SessionKey tests pass, and no app behavior beyond copy/recovery labels is intentionally changed.

Q3 Threat Surface: Do not add any credential display, persistence, logging, or diagnostic output.
Q4 Requirement Impact: Directly advances R006 and supports R003/R004 by reducing ambiguous recovery paths without exposing secret material.
Q5 Failure Modes: Preserve existing fallback/retry behavior; only labels and localized descriptions should change.
Q6 Load Profile: No new network calls or background refresh behavior.
Q7 Negative Tests: Tests should fail if Claude-specific errors regress to generic `Session key` copy or ChatGPT copy is mislabeled as Claude.

## Inputs

- `scripts/provider_workflow_copy_audit.py`
- `Pinemeter/Models/Errors/AppError.swift`
- `Pinemeter/Models/Errors/NetworkError.swift`
- `Pinemeter/Models/SessionKey.swift`
- `Pinemeter/Views/MenuBar/UsagePopoverView.swift`
- `Pinemeter/Views/Setup/SetupWizardView.swift`
- `Pinemeter/Views/Settings/SettingsView.swift`
- `PinemeterTests/SessionKeyTests.swift`

## Expected Output

- `Pinemeter/Models/Errors/AppError.swift`
- `Pinemeter/Models/Errors/NetworkError.swift`
- `Pinemeter/Models/SessionKey.swift`
- `Pinemeter/Views/MenuBar/UsagePopoverView.swift`
- `Pinemeter/Views/Setup/SetupWizardView.swift`
- `Pinemeter/Views/Settings/SettingsView.swift`
- `PinemeterTests/ProviderErrorWorkflowTests.swift`
- `PinemeterTests/SessionKeyTests.swift`

## Verification

xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/ProviderErrorWorkflowTests -only-testing:PinemeterTests/SessionKeyTests

## Observability Impact

Makes Claude credential failures clearer in UI and tests while preserving existing retry/import flows.
