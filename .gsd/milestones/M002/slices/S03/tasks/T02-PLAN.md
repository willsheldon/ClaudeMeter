---
estimated_steps: 1
estimated_files: 4
skills_used: []
---

# T02: Connected ChatGPT WebView/session acquisition and usage refresh flows to the secure ChatGPT session repository boundary.

Connect WebView session extraction to the secure ChatGPT session repository. Persist only credential equivalent material through the secure boundary and provide clear invalidation behavior when validation fails.

## Inputs

- `Pinemeter/Services/WebViewNetworkService.swift`
- `Pinemeter/Services/ChatGPTUsageService.swift`

## Expected Output

- `Pinemeter/Services/WebViewNetworkService.swift`
- `Pinemeter/Services/ChatGPTUsageService.swift`
- `PinemeterTests/ChatGPTUsageServiceTests.swift`

## Verification

xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/ChatGPTUsageServiceTests

## Observability Impact

Reports ChatGPT acquisition success, missing session, invalid session, and cleared state without secret values.
