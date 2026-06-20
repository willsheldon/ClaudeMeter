---
estimated_steps: 1
estimated_files: 5
skills_used: []
---

# T02: Wired Claude credential repair through the session import service and AppModel state.

Add a Claude credential service operation that checks current state, repairs or re saves the selected account credential, and maps Keychain errors into sanitized credential state failures produced by S01.

## Inputs

- `Pinemeter/Services/SessionKeyImportService.swift`
- `Pinemeter/App/AppModel.swift`

## Expected Output

- `Pinemeter/Services/SessionKeyImportService.swift`
- `Pinemeter/App/AppModel.swift`
- `PinemeterTests/AppModelTests.swift`

## Verification

xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/ProviderErrorWorkflowTests

## Observability Impact

Makes Claude repair attempts visible as sanitized state transitions.
