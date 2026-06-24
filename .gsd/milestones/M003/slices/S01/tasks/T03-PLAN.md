---
estimated_steps: 1
estimated_files: 4
skills_used: []
---

# T03: Rendered shared provider credential status actions in setup and pinned setup/settings status surfaces to the sanitized shared model.

Update SettingsView and SetupWizardView to consume AppModel provider credential statuses for Claude and ChatGPT, removing duplicated stale copy where possible and keeping all secret material out of SwiftUI state.

## Inputs

- `Pinemeter/App/AppModel.swift`
- `Pinemeter/Views/Settings/SettingsView.swift`
- `Pinemeter/Views/Setup/SetupWizardView.swift`

## Expected Output

- `Pinemeter/Views/Settings/SettingsView.swift`
- `Pinemeter/Views/Setup/SetupWizardView.swift`
- `PinemeterTests/ProviderErrorWorkflowTests.swift`

## Verification

`xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/ProviderErrorWorkflowTests -only-testing:PinemeterTests/SecurityInvariantTests`

## Observability Impact

Makes visible provider state consistent and redactable.
