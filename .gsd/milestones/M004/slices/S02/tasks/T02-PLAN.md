---
estimated_steps: 1
estimated_files: 6
skills_used: []
---

# T02: Implement Gemini repository and usage service

Add Gemini repository/service implementations and test doubles following actor/repository conventions. Normalize usage success and sanitized errors without persisting raw tokens/cookies in settings.

## Inputs

- `Pinemeter/Services/ChatGPTUsageService.swift`
- `Pinemeter/Repositories/ChatGPTSessionRepository.swift`
- `Pinemeter/Services/UsageService.swift`

## Expected Output

- `Pinemeter/Services/GeminiUsageService.swift`
- `Pinemeter/Services/Protocols/GeminiUsageServiceProtocol.swift`
- `PinemeterTests/GeminiUsageServiceTests.swift`

## Verification

`xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests` plus new Gemini service tests.

## Observability Impact

Adds sanitized Gemini fetch/acquisition failure categories.
