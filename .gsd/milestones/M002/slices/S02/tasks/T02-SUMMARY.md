---
id: T02
parent: S02
milestone: M002
key_files:
  - Pinemeter/Services/Protocols/SessionKeyImportServiceProtocol.swift
  - Pinemeter/Services/SessionKeyImportService.swift
  - Pinemeter/App/AppModel.swift
  - PinemeterTests/AppModelTests.swift
  - PinemeterTests/TestDoubles/SessionKeyImportServiceStub.swift
  - PinemeterTests/TestDoubles/KeychainRepositoryFake.swift
key_decisions:
  - Represent Claude repair as a sanitized CredentialState returned from SessionKeyImportService rather than throwing Keychain errors through AppModel.
  - Delegate actual Keychain repair/re-save to the existing KeychainRepository.repairClaudeSessionKey primitive.
duration: 
verification_result: passed
completed_at: 2026-06-18T21:09:15.705Z
blocker_discovered: false
---

# T02: Wired Claude credential repair through the session import service and AppModel state.

**Wired Claude credential repair through the session import service and AppModel state.**

## What Happened

Added a non-throwing Claude session-key repair operation to the session import service protocol and implemented it in SessionKeyImportService using the existing Keychain repair primitive. AppModel now exposes observable Claude credential state, initializes it during bootstrap, updates it on successful save and clear, and delegates explicit repair attempts through the service layer. AppModel tests cover successful repair/re-save with usage refresh and Keychain failure mapping to sanitized storageUnavailable credential state.

## Verification

Ran focused verification: `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/ProviderErrorWorkflowTests` and received `T02_VERIFICATION_PASS`.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/ProviderErrorWorkflowTests` | 0 | ✅ pass | 7700ms |

## Deviations

Also updated SessionKeyImportServiceProtocol and KeychainRepositoryFake because the service-layer contract and focused tests require protocol conformance.

## Known Issues

None.

## Files Created/Modified

- `Pinemeter/Services/Protocols/SessionKeyImportServiceProtocol.swift`
- `Pinemeter/Services/SessionKeyImportService.swift`
- `Pinemeter/App/AppModel.swift`
- `PinemeterTests/AppModelTests.swift`
- `PinemeterTests/TestDoubles/SessionKeyImportServiceStub.swift`
- `PinemeterTests/TestDoubles/KeychainRepositoryFake.swift`
