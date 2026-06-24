---
estimated_steps: 1
estimated_files: 3
skills_used: []
---

# T03: Verify setup and settings provider matrix

Run full tests and inspect setup/settings copy for stale two-provider assumptions, secret terms, and unclear Gemini next actions.

## Inputs

- `Pinemeter/Views/Settings/SettingsView.swift`
- `Pinemeter/Views/Setup/SetupWizardView.swift`

## Expected Output

- `Pinemeter/Views/Settings/SettingsView.swift`
- `Pinemeter/Views/Setup/SetupWizardView.swift`
- `PinemeterTests`

## Verification

`xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` and `rg -n "Claude|ChatGPT|Gemini|provider|cookie|key" Pinemeter/Views/Settings Pinemeter/Views/Setup` reviewed for expected copy.

## Observability Impact

Confirms provider setup diagnostics remain understandable.
