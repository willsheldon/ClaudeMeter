---
estimated_steps: 1
estimated_files: 2
skills_used: []
---

# T03: Verify Claude prompt regression path

Add tests and documentation evidence for the Keychain prompt scenario: ad hoc signed credentials can be re saved under the official Autimo signed app identity without changing the legacy service identifier.

## Inputs

- `Pinemeter.xcodeproj/project.pbxproj`
- `Pinemeter/Repositories/KeychainRepository.swift`

## Expected Output

- `PinemeterTests/SecurityInvariantTests.swift`
- `.gsd/KNOWLEDGE.md`

## Verification

xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests

## Observability Impact

Captures the signing identity repair path as durable knowledge for future agents.
