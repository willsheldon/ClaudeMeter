---
estimated_steps: 1
estimated_files: 5
skills_used: []
---

# T02: Add credential status service boundary

Introduce protocols or service interfaces that report provider credential state without exposing raw secret values. Map existing Claude session key and ChatGPT session availability into the new contract without changing acquisition behavior.

## Inputs

- `Pinemeter/Repositories/KeychainRepository.swift`
- `Pinemeter/Services/ChatGPTUsageService.swift`
- `Pinemeter/Services/WebViewNetworkService.swift`

## Expected Output

- `Pinemeter/Services/Protocols/CredentialStatusServiceProtocol.swift`
- `Pinemeter/Services/CredentialStatusService.swift`
- `PinemeterTests/CredentialStatusServiceTests.swift`

## Verification

xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/CredentialStatusServiceTests

## Observability Impact

Centralizes non secret provider credential state for later UI and logs.
