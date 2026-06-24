---
estimated_steps: 1
estimated_files: 4
skills_used: []
---

# T01: Add Gemini usage display state

Add Gemini usage state and refresh state to AppModel/menu state in a way that composes with Claude and ChatGPT rather than branching every provider combination manually.

## Inputs

- `Pinemeter/App/AppModel.swift`
- `Pinemeter/Models/UsageData.swift`

## Expected Output

- `Pinemeter/App/AppModel.swift`
- `PinemeterTests/AppModelTests.swift`

## Verification

`xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests`

## Observability Impact

Adds observable Gemini loading, success, and error state.
