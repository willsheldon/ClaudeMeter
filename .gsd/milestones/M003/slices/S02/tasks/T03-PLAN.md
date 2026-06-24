---
estimated_steps: 1
estimated_files: 4
skills_used: []
---

# T03: Wired provider recovery buttons in Settings and Setup through the shared AppModel provider credential action boundary with provider-scoped sanitized feedback.

Connect SettingsView and SetupWizardView provider action buttons to the AppModel provider recovery API, with provider-specific progress, success, and failure messages that never include raw secret material.

## Inputs

- `Pinemeter/Views/Settings/SettingsView.swift`
- `Pinemeter/Views/Setup/SetupWizardView.swift`
- `Pinemeter/App/AppModel.swift`

## Expected Output

- `Pinemeter/Views/Settings/SettingsView.swift`
- `Pinemeter/Views/Setup/SetupWizardView.swift`

## Verification

`xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests -only-testing:PinemeterTests/ProviderErrorWorkflowTests`

## Observability Impact

Makes recovery action state visible and sanitized.
