---
estimated_steps: 1
estimated_files: 5
skills_used: []
---

# T01: Repaired T01's verification contract so auto-mode can discover and run host-owned checks.

Map current AppModel credential state helpers and every SettingsView/SetupWizardView usage that presents provider credential state. Identify direct provider-specific formatting, stale Claude-only copy, and any path that could display raw credential material.

## Inputs

- `Pinemeter/App/AppModel.swift`
- `Pinemeter/Views/Settings/SettingsView.swift`
- `Pinemeter/Views/Setup/SetupWizardView.swift`

## Expected Output

- `Pinemeter/App/AppModel.swift`
- `Pinemeter/Views/Settings/SettingsView.swift`
- `Pinemeter/Views/Setup/SetupWizardView.swift`
- `PinemeterTests/AppModelTests.swift`
- `scripts/provider_status_surface_audit.py`

## Verification

python3 scripts/provider_status_surface_audit.py
xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests
rg -n "session|cookie|key|Claude|ChatGPT|providerCredential" Pinemeter/Views Pinemeter/App

## Observability Impact

Adds a tracked static audit script that makes provider credential status surface sanitization host-verifiable.
