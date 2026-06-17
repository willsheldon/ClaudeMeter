---
estimated_steps: 1
estimated_files: 3
skills_used: []
---

# T01: Add provider credential status view model

Add or extend app model state so settings and setup can show Claude and ChatGPT credential health, last sanitized failure, and available actions without reading secrets directly in views.

## Inputs

- `Pinemeter/App/AppModel.swift`
- `Pinemeter/Views/Settings/SettingsView.swift`
- `Pinemeter/Views/Setup/SetupWizardView.swift`

## Expected Output

- `Pinemeter/App/AppModel.swift`
- `PinemeterTests/AppModelTests.swift`
- `PinemeterTests/ChatGPTAppModelTests.swift`

## Verification

xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/ChatGPTAppModelTests

## Observability Impact

Centralizes user visible credential status as sanitized app state.
