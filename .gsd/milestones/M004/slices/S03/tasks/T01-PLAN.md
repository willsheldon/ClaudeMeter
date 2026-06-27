---
estimated_steps: 1
estimated_files: 3
skills_used: []
---

# T01: Extended shared provider credential status behavior and setup/settings copy so Gemini API-key status appears beside Claude and ChatGPT without exposing credential material.

Update setup and settings provider status sections to include Gemini through shared provider status collections rather than one-off Gemini-specific UI blocks where avoidable.

## Inputs

- `Pinemeter/Views/Settings/SettingsView.swift`
- `Pinemeter/Views/Setup/SetupWizardView.swift`
- `Pinemeter/App/AppModel.swift`

## Expected Output

- `Pinemeter/Views/Settings/SettingsView.swift`
- `Pinemeter/Views/Setup/SetupWizardView.swift`

## Verification

`xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/ProviderErrorWorkflowTests`

## Observability Impact

Surfaces Gemini setup state without secret exposure.
