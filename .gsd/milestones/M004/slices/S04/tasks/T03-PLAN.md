---
estimated_steps: 1
estimated_files: 4
skills_used: []
---

# T03: Added AppModel regression tests for Gemini-only, mixed Gemini provider combinations, all-provider display state, and Gemini refresh error display state.

Add tests for Gemini-only, Claude plus Gemini, ChatGPT plus Gemini, all providers, and Gemini error states, then run full verification.

## Inputs

- `PinemeterTests/AppModelTests.swift`
- `PinemeterTests/MenuBarIconRendererTests.swift`

## Expected Output

- `PinemeterTests/AppModelTests.swift`

## Verification

`xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug`

## Observability Impact

Provides regression coverage for provider combinations.
