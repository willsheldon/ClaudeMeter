---
estimated_steps: 1
estimated_files: 5
skills_used: []
---

# T03: Ran the final M003 verification suite and fixed the stale provider status audit test-name guard.

Run full xcodebuild tests plus provider copy/redaction audit. Capture failures with root-cause notes and fix only M003-scope issues before completing the slice.

## Inputs

- `PinemeterTests`
- `Pinemeter/Views`
- `Pinemeter/App/AppModel.swift`

## Expected Output

- `Pinemeter/App/AppModel.swift`
- `Pinemeter/Views/Settings/SettingsView.swift`
- `Pinemeter/Views/Setup/SetupWizardView.swift`
- `Pinemeter/Views/MenuBar/UsagePopoverView.swift`
- `PinemeterTests`

## Verification

`xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` plus provider copy/redaction audit commands recorded in the task summary.

## Observability Impact

Produces final automated evidence for the milestone.
