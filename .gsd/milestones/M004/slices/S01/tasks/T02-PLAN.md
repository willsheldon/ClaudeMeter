---
estimated_steps: 1
estimated_files: 4
skills_used: []
---

# T02: Add Gemini provider contract tests

Write failing then passing tests for Gemini provider identity, credential state labels, action availability, usage status states, and sanitized diagnostic categories.

## Inputs

- `Pinemeter/Models/CredentialState.swift`
- `PinemeterTests/CredentialStateTests.swift`

## Expected Output

- `Pinemeter/Models/CredentialState.swift`
- `PinemeterTests/CredentialStateTests.swift`
- `PinemeterTests/AppModelTests.swift`

## Verification

`xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/CredentialStateTests -only-testing:PinemeterTests/AppSettingsTests -only-testing:PinemeterTests/AppModelTests`

## Observability Impact

Defines Gemini state and redaction expectations.
