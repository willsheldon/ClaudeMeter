# S01: Credential state contract

**Goal:** Create a provider credential state model and service boundary that all acquisition, repair, status, and UI flows can share.
**Demo:** Developer can inspect a central credential state contract that represents Claude and ChatGPT credential health without exposing secret values.

## Must-Haves

- Credential state distinguishes missing, present, invalid, expired, repairable, and unknown states per provider.
- State and errors are sanitized and cannot include session keys, cookies, Bearer tokens, or credential shaped values.
- AppSettings and SettingsRepository remain preference only and credential free.
- Existing Claude and ChatGPT flows can be mapped to the new state contract without behavior regressions.

## Proof Level

- This slice proves: Contract and unit tests for state transitions, redaction, and SettingsRepository credential free persistence.

## Integration Closure

Introduces the shared contract used by later slices but does not change acquisition behavior yet.

## Verification

- Adds sanitized credential status values suitable for future diagnostics without logging secrets.

## Tasks

- [ ] **T01: Add credential state domain model** `est:small`
  Define provider credential identity, credential health states, sanitized failure categories, and display safe descriptions. Keep the model independent of SwiftUI and storage so services and UI can share it.
  - Files: `Pinemeter/Models/CredentialState.swift`, `PinemeterTests/CredentialStateTests.swift`
  - Verify: xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/CredentialStateTests

- [ ] **T02: Add credential status service boundary** `est:medium`
  Introduce protocols or service interfaces that report provider credential state without exposing raw secret values. Map existing Claude session key and ChatGPT session availability into the new contract without changing acquisition behavior.
  - Files: `Pinemeter/Services/Protocols/CredentialStatusServiceProtocol.swift`, `Pinemeter/Services/CredentialStatusService.swift`, `Pinemeter/App/AppModel.swift`, `PinemeterTests/TestDoubles/KeychainRepositoryFake.swift`, `PinemeterTests/CredentialStatusServiceTests.swift`
  - Verify: xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/CredentialStatusServiceTests

- [ ] **T03: Lock credential free settings invariants** `est:small`
  Extend security tests to ensure the new credential state boundary does not cause AppSettings or SettingsRepository to persist credential material, cookies, Bearer tokens, or session key sentinels.
  - Files: `PinemeterTests/SecurityInvariantTests.swift`, `PinemeterTests/SettingsRepositoryTests.swift`
  - Verify: xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests -only-testing:PinemeterTests/SettingsRepositoryTests

## Files Likely Touched

- Pinemeter/Models/CredentialState.swift
- PinemeterTests/CredentialStateTests.swift
- Pinemeter/Services/Protocols/CredentialStatusServiceProtocol.swift
- Pinemeter/Services/CredentialStatusService.swift
- Pinemeter/App/AppModel.swift
- PinemeterTests/TestDoubles/KeychainRepositoryFake.swift
- PinemeterTests/CredentialStatusServiceTests.swift
- PinemeterTests/SecurityInvariantTests.swift
- PinemeterTests/SettingsRepositoryTests.swift
