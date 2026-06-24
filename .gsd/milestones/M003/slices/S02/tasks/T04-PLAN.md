---
estimated_steps: 1
estimated_files: 5
skills_used: []
---

# T04: Verified provider recovery workflows, provider-specific copy, and credential redaction invariants without requiring source changes.

Run focused and full tests, then inspect recovery copy/logging for provider specificity and redaction. Fix direct leaks or stale Claude-only recovery text found during verification.

## Inputs

- `PinemeterTests/ProviderErrorWorkflowTests.swift`
- `PinemeterTests/SecurityInvariantTests.swift`

## Expected Output

- `Pinemeter/App/AppModel.swift`
- `Pinemeter/Views/Settings/SettingsView.swift`
- `Pinemeter/Views/Setup/SetupWizardView.swift`
- `PinemeterTests/ProviderErrorWorkflowTests.swift`
- `PinemeterTests/SecurityInvariantTests.swift`

## Verification

`xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` and `rg -n "Reconnect|Repair|Clear|Claude|ChatGPT|cookie|session key" Pinemeter PinemeterTests` reviewed for expected copy only.

## Observability Impact

Confirms recovery behavior has durable test evidence.
