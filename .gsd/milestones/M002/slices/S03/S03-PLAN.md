# S03: ChatGPT session acquisition boundary

**Goal:** Define and implement the durable boundary for ChatGPT session cookies and transient access tokens so the app can recover status without credential leakage.
**Demo:** App can classify and persist ChatGPT session acquisition state through a secure boundary without storing ChatGPT credential material in settings.

## Must-Haves

- ChatGPT cookies and Bearer access tokens are treated as credential equivalent.
- Durable persisted data uses Keychain or an explicitly secure repository, never UserDefaults settings.
- WebView acquired session material has a clear extraction, validation, persistence, and clearing path.
- Tests prove no cookie, token, or header value reaches user facing errors or logs.

## Proof Level

- This slice proves: Service and repository tests with synthetic cookie and token sentinels plus redaction assertions.

## Integration Closure

Consumes S01 state contract and provides a ChatGPT credential state surface compatible with existing ChatGPTUsageService behavior.

## Verification

- Adds sanitized ChatGPT credential acquisition status and last error category for diagnostics.

## Tasks

- [ ] **T01: Design ChatGPT secure session repository** `est:medium`
  Introduce a repository protocol and implementation for ChatGPT credential equivalent session material. Use a secure storage boundary, avoid AppSettings, and define clear save, load, validate, and clear operations with synthetic test data.
  - Files: `Pinemeter/Repositories/Protocols/ChatGPTSessionRepositoryProtocol.swift`, `Pinemeter/Repositories/ChatGPTSessionRepository.swift`, `PinemeterTests/ChatGPTSessionRepositoryTests.swift`
  - Verify: xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/ChatGPTSessionRepositoryTests

- [ ] **T02: Persist WebView acquired ChatGPT sessions** `est:medium`
  Connect WebView session extraction to the secure ChatGPT session repository. Persist only credential equivalent material through the secure boundary and provide clear invalidation behavior when validation fails.
  - Files: `Pinemeter/Services/WebViewNetworkService.swift`, `Pinemeter/Services/ChatGPTUsageService.swift`, `Pinemeter/Services/Protocols/ChatGPTUsageServiceProtocol.swift`, `PinemeterTests/ChatGPTUsageServiceTests.swift`
  - Verify: xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/ChatGPTUsageServiceTests

- [ ] **T03: Prove ChatGPT redaction invariants** `est:small`
  Add tests with synthetic cookie and Bearer token sentinels proving user facing errors, diagnostics, and settings persistence never include ChatGPT credential material.
  - Files: `PinemeterTests/SecurityInvariantTests.swift`, `PinemeterTests/SettingsRepositoryTests.swift`, `PinemeterTests/ProviderErrorWorkflowTests.swift`
  - Verify: xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests -only-testing:PinemeterTests/ProviderErrorWorkflowTests

## Files Likely Touched

- Pinemeter/Repositories/Protocols/ChatGPTSessionRepositoryProtocol.swift
- Pinemeter/Repositories/ChatGPTSessionRepository.swift
- PinemeterTests/ChatGPTSessionRepositoryTests.swift
- Pinemeter/Services/WebViewNetworkService.swift
- Pinemeter/Services/ChatGPTUsageService.swift
- Pinemeter/Services/Protocols/ChatGPTUsageServiceProtocol.swift
- PinemeterTests/ChatGPTUsageServiceTests.swift
- PinemeterTests/SecurityInvariantTests.swift
- PinemeterTests/SettingsRepositoryTests.swift
- PinemeterTests/ProviderErrorWorkflowTests.swift
