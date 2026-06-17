---
estimated_steps: 4
estimated_files: 3
skills_used: []
---

# T02: Guarded legacy ClaudeMeter credential identifiers with source comments and executable source-level invariants.

skills_used: [decompose-into-slices]

Why: S04 identified com.claudemeter.sessionkey and the com.claudemeter keychain access group as credential compatibility invariants. A mechanical cleanup rename here could orphan stored credentials or break access-group access.

Do: Add concise source comments next to the KeychainRepository service name and Pinemeter.entitlements access group explaining that these legacy ClaudeMeter identifiers are intentional credential compatibility surfaces deferred to M002 migration work. Extend SecurityInvariantTests with source-level invariants that read tracked source files, not Keychain state, and assert the exact legacy service/access-group strings remain present with explanatory compatibility language. Preserve S05 diagnostic-redaction tests and avoid any Keychain mutation, migration, provider redesign, or credential logging.

Done when: SecurityInvariantTests pass and fail loudly if a future cleanup renames the credential service/access group without changing the invariant tests and adding a migration plan.

## Inputs

- `Pinemeter/Repositories/KeychainRepository.swift`
- `Pinemeter/Resources/Pinemeter.entitlements`
- `PinemeterTests/SecurityInvariantTests.swift`
- `.gsd/milestones/M001/slices/S04/S04-SUMMARY.md`
- `.gsd/milestones/M001/slices/S05/S05-SUMMARY.md`

## Expected Output

- `Pinemeter/Repositories/KeychainRepository.swift`
- `Pinemeter/Resources/Pinemeter.entitlements`
- `PinemeterTests/SecurityInvariantTests.swift`

## Verification

xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests

## Observability Impact

Strengthens local test observability around credential compatibility without exposing or touching credential material.
