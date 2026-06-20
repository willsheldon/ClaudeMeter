---
estimated_steps: 1
estimated_files: 3
skills_used: []
---

# T03: Updated the setup wizard to use sanitized durable credential status for ready, missing, and repairable Claude session states.

Update SetupWizardView so valid durable credentials skip repeated prompts, missing credentials ask for setup, and repairable credentials offer repair. Add accessibility labels for provider status and actions.

## Inputs

- `Pinemeter/Views/Setup/SetupWizardView.swift`
- `Pinemeter/App/AppModel.swift`

## Expected Output

- `Pinemeter/Views/Setup/SetupWizardView.swift`
- `PinemeterTests/AppModelTests.swift`
- `PinemeterTests/ProviderErrorWorkflowTests.swift`

## Verification

xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/ProviderErrorWorkflowTests

## Observability Impact

Turns credential state into actionable recovery UX with sanitized failure copy.
