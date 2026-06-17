# S02: Credential surface inventory

**Goal:** Produce a precise credential/session surface inventory for Claude and ChatGPT covering acquisition, validation, storage, reuse, display, logging, clearing, recovery, and retained compatibility identifiers.
**Demo:** After this: a concrete inventory shows where Claude and GPT credentials or session material are obtained, stored, reused, displayed, logged, cleared, and recovered.

## Must-Haves

- Inventory artifact maps Claude session key and ChatGPT session cookie/token flows from input/import through validation, Keychain storage, API reuse, UI display, logging/error handling, and clearing.
- Keychain accounts, service/access-group, accessibility/synchronization attributes, settings/UserDefaults fields, cache/export identifiers, and S01 retained compatibility exceptions are explicitly documented.
- UI/local-state exposure points are identified, including any saved credential rehydration into settings fields.
- Logging/error scans are recorded and any obvious secret exposure findings are ranked for S03.
- Artifact is detailed enough for S03 security review and M002 durable credential work without rediscovery.

## Proof Level

- This slice proves: Artifact-level proof plus source scans; no behavior changes expected unless an obvious safe copy fix is discovered.

## Integration Closure

S02 provides the credential/session inventory consumed by S03 security review and S05 provider/error workflow audit.

## Verification

- Inventory must identify logger/error surfaces and whether they include secret material, provider context, account names, browser source labels, or recovery instructions.

## Tasks

- [x] **T01: Inventoried Keychain storage and settings persistence for Claude and ChatGPT credentials.** `est:medium`
  Map all storage locations and persistence semantics: Keychain service name, accounts, accessibility class, synchronizable flag, exists/retrieve/save/update/delete behavior, retained access group, and non-secret settings fields such as cached organization ID and ChatGPT display preference. Include S01 compatibility identifiers in the map.
  - Files: `Pinemeter/Repositories/KeychainRepository.swift`, `Pinemeter/Repositories/Protocols/KeychainRepositoryProtocol.swift`, `Pinemeter/App/AppModel.swift`, `Pinemeter/Models/AppSettings.swift`, `Pinemeter/Repositories/SettingsRepository.swift`, `Pinemeter/Resources/Pinemeter.entitlements`
  - Verify: rg -n 'save\(sessionKey|retrieve\(account|delete\(account|exists\(account|kSecAttrService|kSecAttrAccessible|kSecAttrSynchronizable|cachedOrganizationId|isChatGPTUsageShown|keychain-access-groups' Pinemeter PinemeterTests

- [x] **T02: Inventoried Claude session acquisition, validation, reuse, display, clearing, and recovery paths.** `est:medium`
  Map manual paste, browser cookie import, Safe Storage pre-prompt, local SessionKey validation, remote validation, organization selection, Keychain write/read, Claude API Cookie header reuse, UI status/display, and clear/recovery behavior for the Claude session key.
  - Files: `Pinemeter/Views/Setup/SetupWizardView.swift`, `Pinemeter/Views/Settings/SettingsView.swift`, `Pinemeter/App/AppModel.swift`, `Pinemeter/App/SessionKeyImportPromptCoordinator.swift`, `Pinemeter/Services/SessionKeyImportService.swift`, `Pinemeter/Services/Protocols/SessionKeyImportServiceProtocol.swift`, `Pinemeter/Models/SessionKey.swift`, `Pinemeter/Services/UsageService.swift`, `Pinemeter/Services/NetworkService.swift`, `Pinemeter/Models/Errors/AppError.swift`
  - Verify: rg -n 'sessionKey|SessionKey|Import from Browser|BrowserCookie|claude\.ai|Cookie|clearSessionKey|validateAndSaveSessionKey|fetchOrganizations|request\(' Pinemeter PinemeterTests

- [x] **T03: Inventoried ChatGPT cookie acquisition, validation, token derivation, reuse, display, clearing, and recovery paths.** `est:medium`
  Map split NextAuth cookie parts, full Cookie header paste, raw token handling, validation, Keychain account `chatgpt`, auth-session request, access-token derivation, quota request, UI display/status, and clear/recovery behavior for ChatGPT quota monitoring.
  - Files: `Pinemeter/Views/Settings/SettingsView.swift`, `Pinemeter/App/AppModel.swift`, `Pinemeter/Services/ChatGPTUsageService.swift`, `Pinemeter/Services/Protocols/ChatGPTUsageServiceProtocol.swift`, `Pinemeter/Models/ChatGPTUsageData.swift`, `Pinemeter/Models/API/ChatGPTAPIResponses.swift`, `PinemeterTests/ChatGPTUsageServiceTests.swift`, `PinemeterTests/ChatGPTAppModelTests.swift`
  - Verify: rg -n 'chatGPTSessionCookie|ChatGPT|__Secure-next-auth|cookieHeader|accessToken|auth/session|codex/settings/usage|clearChatGPTSessionCookie|validateSessionCookie' Pinemeter PinemeterTests

- [x] **T04: Inventoried display, logging, error, test, and export exposure risks for credential material.** `est:medium`
  Scan and document where credential values can be displayed, held in SwiftUI state, copied into test doubles, included in errors, logged, exported, or persisted outside Keychain. Rank obvious findings for S03, especially full saved credentials rehydrated into settings fields.
  - Files: `Pinemeter/Views/Settings/SettingsView.swift`, `Pinemeter/Views/Setup/SetupWizardView.swift`, `Pinemeter/Services/NetworkService.swift`, `Pinemeter/Services/UsageService.swift`, `Pinemeter/Services/ChatGPTUsageService.swift`, `Pinemeter/Services/SessionKeyImportService.swift`, `PinemeterTests/TestDoubles/KeychainRepositoryFake.swift`, `PinemeterTests/TestDoubles/NetworkServiceStub.swift`, `PinemeterTests/TestDoubles/SessionKeyImportServiceStub.swift`
  - Verify: rg -n 'logger\.|Logger\(|print\(|debugPrint|NSLog|localizedDescription|sessionKey|sessionCookie|cookieHeader|accessToken|Cookie|SecureField|TextField' Pinemeter PinemeterTests

- [x] **T05: Wrote the final credential/session surface inventory artifact for downstream security and auth planning.** `est:medium`
  Synthesize T01-T04 into a durable S02 assessment artifact with tables for Claude and ChatGPT covering acquisition, storage, reuse, display, logging, clearing, recovery, and open questions. Include file references and downstream recommendations for S03/M002/S05. Run final scans and avoid code changes unless a truly safe documentation/copy fix is necessary.
  - Files: `.gsd/milestones/M001/slices/S02/S02-RESEARCH.md`
  - Verify: test -f .gsd/milestones/M001/slices/S02/S02-ASSESSMENT.md
rg -n 'default|chatgpt|com\.claudemeter\.sessionkey|kSecAttrAccessibleAfterFirstUnlock|__Secure-next-auth|sessionKey|Cookie header|accessToken|clearSessionKey|clearChatGPTSessionCookie' .gsd/milestones/M001/slices/S02/S02-ASSESSMENT.md

## Files Likely Touched

- Pinemeter/Repositories/KeychainRepository.swift
- Pinemeter/Repositories/Protocols/KeychainRepositoryProtocol.swift
- Pinemeter/App/AppModel.swift
- Pinemeter/Models/AppSettings.swift
- Pinemeter/Repositories/SettingsRepository.swift
- Pinemeter/Resources/Pinemeter.entitlements
- Pinemeter/Views/Setup/SetupWizardView.swift
- Pinemeter/Views/Settings/SettingsView.swift
- Pinemeter/App/SessionKeyImportPromptCoordinator.swift
- Pinemeter/Services/SessionKeyImportService.swift
- Pinemeter/Services/Protocols/SessionKeyImportServiceProtocol.swift
- Pinemeter/Models/SessionKey.swift
- Pinemeter/Services/UsageService.swift
- Pinemeter/Services/NetworkService.swift
- Pinemeter/Models/Errors/AppError.swift
- Pinemeter/Services/ChatGPTUsageService.swift
- Pinemeter/Services/Protocols/ChatGPTUsageServiceProtocol.swift
- Pinemeter/Models/ChatGPTUsageData.swift
- Pinemeter/Models/API/ChatGPTAPIResponses.swift
- PinemeterTests/ChatGPTUsageServiceTests.swift
- PinemeterTests/ChatGPTAppModelTests.swift
- PinemeterTests/TestDoubles/KeychainRepositoryFake.swift
- PinemeterTests/TestDoubles/NetworkServiceStub.swift
- PinemeterTests/TestDoubles/SessionKeyImportServiceStub.swift
- .gsd/milestones/M001/slices/S02/S02-RESEARCH.md
