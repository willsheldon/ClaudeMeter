---
estimated_steps: 1
estimated_files: 4
skills_used: []
---

# T01: Add credential lifecycle regression tests

Add lifecycle tests covering first setup, valid reuse, invalid credential recovery, repair after signing identity change, clear, and re acquisition across Claude and ChatGPT credential paths using synthetic credential material.

## Inputs

- `Pinemeter/App/AppModel.swift`
- `Pinemeter/Services/ChatGPTUsageService.swift`
- `Pinemeter/Repositories/KeychainRepository.swift`

## Expected Output

- `PinemeterTests/SecurityInvariantTests.swift`
- `PinemeterTests/ProviderErrorWorkflowTests.swift`
- `PinemeterTests/AppModelTests.swift`
- `PinemeterTests/ChatGPTUsageServiceTests.swift`

## Verification

xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests -only-testing:PinemeterTests/ProviderErrorWorkflowTests -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/ChatGPTUsageServiceTests

## Observability Impact

Proves lifecycle failures remain diagnosable without secret leakage.
