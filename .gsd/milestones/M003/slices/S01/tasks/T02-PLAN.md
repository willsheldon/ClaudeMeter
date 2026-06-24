---
estimated_steps: 1
estimated_files: 4
skills_used: []
---

# T02: Unified provider credential status presentation text for setup and settings without exposing credential material.

Refine AppModel sanitized provider credential status helpers so setup and settings can render the same provider name, credential name, state text, detail text, and actions for Claude and ChatGPT without access to raw credentials.

## Inputs

- `Pinemeter/App/AppModel.swift`
- `Pinemeter/Models/CredentialState.swift`

## Expected Output

- `Pinemeter/App/AppModel.swift`
- `PinemeterTests/AppModelTests.swift`

## Verification

`xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/CredentialStateTests`

## Observability Impact

Provides sanitized status text and action state for diagnostics.
