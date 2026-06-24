---
estimated_steps: 1
estimated_files: 5
skills_used: []
---

# T04: Ran full provider status verification and confirmed setup/settings credential status surfaces remain sanitized.

Run the full test suite and inspect provider status strings for stale Claude-only assumptions or secret leakage. Fix only issues directly tied to this slice.

## Inputs

- `Pinemeter/App/AppModel.swift`
- `Pinemeter/Views/Settings/SettingsView.swift`
- `Pinemeter/Views/Setup/SetupWizardView.swift`

## Expected Output

- `Pinemeter/App/AppModel.swift`
- `Pinemeter/Views/Settings/SettingsView.swift`
- `Pinemeter/Views/Setup/SetupWizardView.swift`
- `PinemeterTests/AppModelTests.swift`
- `PinemeterTests/ProviderErrorWorkflowTests.swift`

## Verification

`xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` plus `rg -n "sk-|session-token|__Secure|cookie" Pinemeter/Views PinemeterTests` with findings reviewed for test fixtures only.

## Observability Impact

Confirms provider status polish preserves redaction and test coverage.
