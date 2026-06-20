# S02: Claude Keychain repair flow

**Goal:** Make Claude credential reuse durable across the Pinemeter rename and signing changes, including a safe repair path for existing Keychain items.
**Demo:** User can repair or re save the Claude session key under the current signed app identity without deleting unrelated Keychain items.

## Must-Haves

- Legacy `com.claudemeter.sessionkey` service compatibility is preserved.
- Claude session key save, load, update, delete, and repair paths are covered by tests with synthetic credentials.
- Repair flow re saves only the selected account credential under the current app identity.
- User visible failures explain recovery steps without disclosing credential material.

## Proof Level

- This slice proves: Repository tests plus app model or service tests proving repair behavior and sanitized failures.

## Integration Closure

Consumes S01 state contract and exposes Claude repair status to setup or settings callers.

## Verification

- Records sanitized last Claude credential operation status and failure category without secret values.

## Tasks

- [x] **T01: Added an explicit Claude session key repair API to the Keychain repository with typed create/update outcomes.** `est:medium`
  Extend the Keychain repository protocol and implementation with an explicit repair or re save operation for Claude session keys. Preserve the legacy `com.claudemeter.sessionkey` service identifier and avoid broad Keychain deletes.
  - Files: `Pinemeter/Repositories/Protocols/KeychainRepositoryProtocol.swift`, `Pinemeter/Repositories/KeychainRepository.swift`, `PinemeterTests/TestDoubles/KeychainRepositoryFake.swift`, `PinemeterTests/KeychainRepositoryTests.swift`
  - Verify: xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/KeychainRepositoryTests

- [x] **T02: Wired Claude credential repair through the session import service and AppModel state.** `est:medium`
  Add a Claude credential service operation that checks current state, repairs or re saves the selected account credential, and maps Keychain errors into sanitized credential state failures produced by S01.
  - Files: `Pinemeter/Services/SessionKeyImportService.swift`, `Pinemeter/Services/Protocols/SessionKeyImportServiceProtocol.swift`, `Pinemeter/App/AppModel.swift`, `PinemeterTests/AppModelTests.swift`, `PinemeterTests/ProviderErrorWorkflowTests.swift`
  - Verify: xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/ProviderErrorWorkflowTests

- [x] **T03: Added SecurityInvariantTests coverage and durable knowledge for the Claude Keychain prompt repair path under the official Autimo signed app identity.** `est:small`
  Add tests and documentation evidence for the Keychain prompt scenario: ad hoc signed credentials can be re saved under the official Autimo signed app identity without changing the legacy service identifier.
  - Files: `PinemeterTests/SecurityInvariantTests.swift`, `.gsd/KNOWLEDGE.md`
  - Verify: xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests

## Files Likely Touched

- Pinemeter/Repositories/Protocols/KeychainRepositoryProtocol.swift
- Pinemeter/Repositories/KeychainRepository.swift
- PinemeterTests/TestDoubles/KeychainRepositoryFake.swift
- PinemeterTests/KeychainRepositoryTests.swift
- Pinemeter/Services/SessionKeyImportService.swift
- Pinemeter/Services/Protocols/SessionKeyImportServiceProtocol.swift
- Pinemeter/App/AppModel.swift
- PinemeterTests/AppModelTests.swift
- PinemeterTests/ProviderErrorWorkflowTests.swift
- PinemeterTests/SecurityInvariantTests.swift
- .gsd/KNOWLEDGE.md
