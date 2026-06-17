---
estimated_steps: 1
estimated_files: 3
skills_used: []
---

# T03: Prove ChatGPT redaction invariants

Add tests with synthetic cookie and Bearer token sentinels proving user facing errors, diagnostics, and settings persistence never include ChatGPT credential material.

## Inputs

- `Pinemeter/Services/ChatGPTUsageService.swift`
- `Pinemeter/Repositories/SettingsRepository.swift`

## Expected Output

- `PinemeterTests/SecurityInvariantTests.swift`
- `PinemeterTests/ProviderErrorWorkflowTests.swift`

## Verification

xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests -only-testing:PinemeterTests/ProviderErrorWorkflowTests

## Observability Impact

Guards against ChatGPT token or cookie leakage as diagnostics expand.
