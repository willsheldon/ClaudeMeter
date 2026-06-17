---
estimated_steps: 1
estimated_files: 4
skills_used: []
---

# T01: Add Claude credential repair repository API

Extend the Keychain repository protocol and implementation with an explicit repair or re save operation for Claude session keys. Preserve the legacy `com.claudemeter.sessionkey` service identifier and avoid broad Keychain deletes.

## Inputs

- `Pinemeter/Repositories/KeychainRepository.swift`
- `.gsd/milestones/M001/slices/S02/S02-ASSESSMENT.md`

## Expected Output

- `Pinemeter/Repositories/Protocols/KeychainRepositoryProtocol.swift`
- `Pinemeter/Repositories/KeychainRepository.swift`
- `PinemeterTests/KeychainRepositoryTests.swift`

## Verification

xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/KeychainRepositoryTests

## Observability Impact

Exposes repair outcomes as status categories instead of raw OSStatus details containing context.
