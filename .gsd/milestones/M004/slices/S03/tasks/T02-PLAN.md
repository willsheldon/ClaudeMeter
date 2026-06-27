---
estimated_steps: 1
estimated_files: 3
skills_used: []
---

# T02: Added Gemini recovery UI and model tests for missing, configured, invalid, retry, reconnect, clear, and mixed-provider behavior.

Add or update tests covering Gemini missing, configured, invalid, reconnect, clear, and retry UI/model behavior, including mixed provider states.

## Inputs

- `PinemeterTests/ProviderErrorWorkflowTests.swift`
- `PinemeterTests/AppModelTests.swift`

## Expected Output

- `PinemeterTests/ProviderErrorWorkflowTests.swift`
- `PinemeterTests/AppModelTests.swift`

## Verification

`xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/ProviderErrorWorkflowTests -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/SecurityInvariantTests`

## Observability Impact

Locks Gemini UI and recovery state into automated evidence.
