# S03 Research: Security review baseline

## Summary

S03 should produce a ranked security baseline for credential/session handling, not implement the full durable credential redesign. Current code separates Claude credentials from preferences better than the inlined S02 downstream note suggests: `AppSettings` appears preference-only, and Claude session keys are retrieved from Keychain at usage time. The highest-confidence risks are instead: Keychain accessibility class and retained legacy service identifier, raw credential material held in SwiftUI `@State` for manual entry/reveal flows, ChatGPT cookie/access-token handling outside Keychain, broad user-facing localized error propagation, and future logging/request-dump regressions around credential-bearing headers.

Important discrepancy to validate early: the preloaded S02 summary says settings reload full saved Claude and ChatGPT credential material into SwiftUI state for editing/display. In current source, `Pinemeter/Models/AppSettings.swift` and `Pinemeter/Repositories/SettingsRepository.swift` do not show raw credential fields; settings are JSON-encoded preference data in UserDefaults. Treat S02's claim as either stale, referring to transient SettingsView state, or referring to a different branch state until proven otherwise.

## Recommendation

Plan S03 as a review-and-proof slice with small validation tasks, not broad refactoring. Recommended task order:

1. Reconcile S02 credential rehydration claim against current source and persisted keys; classify whether UserDefaults persistence of secrets exists today.
2. Rank Keychain storage risk: legacy service identifier `com.claudemeter.sessionkey`, `kSecAttrAccessibleAfterFirstUnlock`, synchronizable disabled, no access control/biometry, no migration plan yet.
3. Rank UI exposure and recovery risk: Settings and Setup keep raw secrets in `@State`, support reveal toggles, show validation/error messages, and should move toward replace-not-display in M002.
4. Rank ChatGPT risk: cookie is accepted manually, normalized into Cookie headers, exchanged for an access token, and appears to lack durable secure storage in the current code paths reviewed.
5. Add or specify regression checks that no secret values are encoded in `AppSettings`, logged by retry/error paths, or exposed via user-visible error messages.

Use the bundled `security-review` skill framing for each finding: location, threat category, exploit scenario, severity, remediation, and fix/defer recommendation. Use the `observability` skill cautiously: preserve structured/status logging, but require redaction tests before adding any request/error diagnostics.

Optional skill discovery result: no install performed. A potentially relevant external skill was found via `npx skills find "macOS Swift Keychain security"`: `npx skills add dpearson2699/swift-ios-skills@swift-security`.

## Requirements and Constraints

- R003: credential/session acquisition, storage, reuse, display, logging, clearing, and recovery surfaces were inventoried in S02; S03 consumes and validates that inventory.
- R004: S03 must capture ranked security review findings.
- M001 audits/reviews; M002 owns durable app-owned credential acquisition and persistence.
- macOS 14+ SwiftUI menu bar app.
- Keep UI state in `@MainActor @Observable` types and non-UI work in actor services/repositories.
- App credential/session material should not be logged, displayed, or persisted in plaintext.
- No new M001 work should log, surface, or persist secret values in plaintext.
- Agent-managed project secrets are only for project operations and must remain in AWS SSM Parameter Store; do not create `.env` or plaintext secret files.
- Compatibility-sensitive identifiers are intentionally retained for now; do not silently rename Keychain/cache/access-group identifiers without a migration plan.

## Implementation Landscape

### Credential storage and preferences

- `Pinemeter/Repositories/KeychainRepository.swift` (lines 10-112): actor-isolated Claude session key storage. Uses generic password items, account-scoped keys, service name `com.claudemeter.sessionkey`, `kSecAttrAccessibleAfterFirstUnlock`, `kSecAttrSynchronizable: false`, duplicate save -> update, retrieve/update/delete/exists helpers.
- `Pinemeter/Repositories/Protocols/KeychainRepositoryProtocol.swift` (lines 1-28): seam for save/retrieve/update/delete/exists; existing fakes make tests feasible without real Keychain.
- `Pinemeter/Models/SessionKey.swift` (lines 1-50): `SessionKey` is intentionally not `Codable` to prevent accidental serialization and validates `sk-ant-` format/minimum length.
- `Pinemeter/Models/AppSettings.swift` (lines 10-123): current settings model is `Codable`, `Equatable`, `Sendable`; fields observed are preferences such as refresh interval, notification thresholds, first launch, cached organization ID, Sonnet/ChatGPT display toggles, icon style/color. Coding keys include legacy `show_openai_usage` compatibility decode.
- `Pinemeter/Repositories/SettingsRepository.swift` (lines 9-67): actor over `UserDefaults`, stores JSON under `app_settings`, returns defaults on decode failure, and separately stores notification state. No raw credential fields observed in this repository during research.

### Main orchestration

- `Pinemeter/App/AppModel.swift` (lines 1-342): `@MainActor @Observable` UI model. Holds settings, usage data, loading flags, `errorMessage`, `chatGPTErrorMessage`, setup flags, and service/repository dependencies. Saves settings via a debounced task after changes. Uses Keychain and usage services for Claude; uses ChatGPT usage service for ChatGPT. Review methods around initialization, setup completion, validation, clear/delete, refresh, and error assignment.
- Relevant seams in AppModel: Keychain existence/setup state, `completeSetup`/save path, session validation, imported session handling, ChatGPT validation/refresh, settings save debounce, `setError`-style user-visible state.

### SwiftUI credential entry/display

- `Pinemeter/Views/Settings/SettingsView.swift` (lines 1-889): largest credential surface. Local `@State` includes `sessionKey`, `isSessionKeyShown`, validation/import flags/messages, ChatGPT token chunks, full cookie header, `isChatGPTSessionCookieShown`, and ChatGPT validation flags. UI includes `TextField`/`SecureField` reveal toggles, import buttons, validation/save/clear flows, and `error.localizedDescription` propagation in handlers near the bottom of the file.
- `Pinemeter/Views/Setup/SetupWizardView.swift` (lines 1-226): first-run Claude credential surface. Local `@State` includes `sessionKeyInput`, import/validation flags, and error messages. Uses `SecureField`, accepts raw session key or pasted Cookie header, imports from local browser cookies, validates, saves setup, and offers Full Disk Access recovery.

### Import, network, and provider services

- `Pinemeter/Services/SessionKeyImportService.swift` (lines 1-98): actor using SweetCookieKit. Queries `claude.ai` cookies, tracks access-denied states, distinguishes Safari vs browser-keychain access denial, imports `sessionKey` cookie, validates via `SessionKey`, returns `ImportedSessionKey(value, sourceDescription)`. Declares `Logger(subsystem: "com.pinemeter", category: "SessionKeyImportService")`; no direct secret logging observed in inspected paths.
- `Pinemeter/Services/NetworkService.swift` (lines 10-82): URLSession actor for Claude API. Enforces HTTPS, constructs `Cookie: sessionKey=<value>` header, sets generic headers, maps status codes to `NetworkError`, decodes JSON. This is a high-value no-request-dump/no-header-log boundary.
- `Pinemeter/Services/WebViewNetworkService.swift` (lines 1-259): WKWebView-based network implementation. Holds `currentSessionKey: String?` in memory while requests run and uses logger category `WebViewNetworkService`. Review memory clearing and diagnostic paths here separately from URLSession.
- `Pinemeter/Services/UsageService.swift` (lines 10-174): Claude usage orchestration. Retrieves session key from Keychain account `default`, validates into `SessionKey`, uses cache, fetches organizations/usage, retries on network/rate-limit/URL errors, logs generic retry/status messages and `URLError.localizedDescription`; authentication failure logs generic text and throws user-facing AppError.
- `Pinemeter/Services/ChatGPTUsageService.swift` (lines 1-196): ChatGPT usage flow. Accepts raw session token/full Cookie header/split NextAuth chunks, normalizes via `cookieHeader(from:)`, calls `/api/auth/session`, extracts transient access token, then calls usage endpoint with Bearer authorization through `ChatGPTHTTPClient`. HTTP client sets `Cookie`, `Referer`, `Origin`, `User-Agent`, and optional `Authorization` headers; enforces HTTPS and maps status codes.
- `Pinemeter/Services/Protocols/ChatGPTUsageServiceProtocol.swift` (lines 1-18): test seam for ChatGPT fetch/validate and HTTP client request.

### Error and logging surfaces

- `Pinemeter/Models/Errors/AppError.swift` (lines 8-64): user-facing app errors; wraps `NetworkError` and `KeychainError` localized descriptions.
- `Pinemeter/Models/Errors/NetworkError.swift` (lines 8-41): generic network error descriptions; currently no raw request/header values.
- `Pinemeter/Models/Errors/KeychainError.swift` (lines 8-35): includes OSStatus values in messages but not credential values.
- Logger declarations found in SessionKey import, NetworkService, UsageService, and WebViewNetworkService. Direct scans did not show obvious secret-value logging, but request/header logging must remain prohibited.

### Tests and fakes

- `PinemeterTests/AppModelTests.swift` (lines 1-420): existing AppModel coverage and dependency injection patterns.
- `PinemeterTests/ChatGPTUsageServiceTests.swift` (lines 1-196): likely starting point for cookie normalization/access-token behavior tests.
- `PinemeterTests/SettingsRepositoryTests.swift` (lines 1-75): starting point for asserting settings encode/decode remains credential-free.
- Test doubles exist for `KeychainRepositoryFake`, `SettingsRepositoryFake`, `SessionKeyImportServiceStub`, `UsageServiceStub`, and network stubs under `PinemeterTests/TestDoubles/`.

## Ranked Findings to Validate/Plan

### 1. High: Keychain item is available after first unlock and uses legacy service identifier

- Location: `Pinemeter/Repositories/KeychainRepository.swift` lines 13, 21-28.
- Threat category: credential storage / local compromise window.
- Exploit scenario: a local process running after first unlock may access a stored session key if app or Keychain access controls are insufficient; legacy `com.claudemeter.sessionkey` complicates migration and ownership semantics after rename.
- Evidence: `kSecAttrAccessibleAfterFirstUnlock`, `kSecAttrSynchronizable: false`, service `com.claudemeter.sessionkey`.
- Recommendation: In S03, rank and defer implementation to M002 unless a minimal test/documentation change is in scope. M002 should evaluate `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` or access control flags, migration from legacy service, and clear fallback/recovery behavior.

### 2. High: Raw credentials are held in SwiftUI state and can be revealed/displayed

- Location: `SettingsView.swift` lines 8-22, 104-118, ChatGPT fields around 220+, handlers near 690-760; `SetupWizardView.swift` lines 7-12, 43-93, 116+.
- Threat category: information disclosure / shoulder surfing / memory retention / accidental UI persistence.
- Exploit scenario: a user or screen-sharing/session recording exposes a session key or ChatGPT cookie via reveal toggles or raw text fields; state remains in memory longer than necessary after save/validation.
- Evidence: local `@State` raw strings for Claude session key and ChatGPT token/cookie parts, reveal toggles switching `SecureField` to `TextField`, validation and import flows store raw strings in view state.
- Recommendation: S03 should rank and recommend M002 replace-not-display flows, state clearing after save/validation/import, and no prepopulation of existing secret values. If current source does not preload stored secrets into fields, preserve that as a security invariant with tests.

### 3. High: ChatGPT session cookie/access token handling lacks Keychain-backed ownership boundary

- Location: `ChatGPTUsageService.swift` lines 44-196; `SettingsView.swift` ChatGPT state/action sections.
- Threat category: credential storage/reuse / token handling.
- Exploit scenario: raw ChatGPT cookies are accepted and transformed into Cookie headers, then exchanged for a Bearer access token. If stored or surfaced via settings/UI/logs, this is equivalent to credential disclosure.
- Evidence: `cookieHeader(from:)` accepts raw token/full header/split chunks; `ChatGPTHTTPClient.request` sets `Cookie` and optional `Authorization` headers.
- Recommendation: Rank as M002-owned unless an existing secure storage path is found. Plan M002 to store ChatGPT session material in Keychain or a provider-specific secure repository, clear UI state, and test no UserDefaults persistence.

### 4. Medium: Error propagation uses localized descriptions that could become secret-bearing if future underlying errors change

- Location: `UsageService.swift` lines 95-130; `AppError.swift` lines 8-64; Settings/Setup handlers using `error.localizedDescription`; ChatGPT errors lines 5-29.
- Threat category: information disclosure through logs/UI diagnostics.
- Exploit scenario: future errors wrap a failed request, cookie header, imported source, or raw response and get displayed/logged via `localizedDescription` without redaction.
- Evidence: UsageService logs `URLError.localizedDescription`; AppError forwards wrapped localized descriptions; SettingsView and SetupWizard set validation/error messages from localized descriptions.
- Recommendation: S03 should recommend a redaction invariant and tests around known secret-shaped strings. Preserve current generic status logging; avoid request dumps.

### 5. Medium: WKWebView network service retains session key in a property during requests

- Location: `WebViewNetworkService.swift` lines 16-21 and request/evaluation flow through line 259.
- Threat category: memory retention / lifecycle cleanup.
- Exploit scenario: a failed or timed-out WKWebView request leaves `currentSessionKey` populated longer than needed or available to later callbacks.
- Evidence: `private var currentSessionKey: String?` exists in a long-lived `@MainActor` NSObject service.
- Recommendation: Validate cleanup on success/failure/timeout and rank as fix if missing; likely an executable S03 or M002 task because the seam is small.

### 6. Medium: Browser cookie import requires careful recovery messaging and permission handling

- Location: `SessionKeyImportService.swift` lines 18-98; `SessionKeyImportServiceProtocol.swift` lines 1-35; Setup/Settings import handlers.
- Threat category: local data access / privacy / recovery UX.
- Exploit scenario: import flow scans browser cookie stores and may need Full Disk Access or Keychain access; overbroad recovery text could normalize granting broad local permissions without explaining scope.
- Evidence: SweetCookieKit query for `claude.ai`; distinct access-denied cases; browser-keychain denial includes browser display name.
- Recommendation: Rank as defer/follow-up if messages are acceptable; ensure no cookie values or file paths are logged/displayed.

### 7. Low/Medium: Settings decode failure silently resets preferences

- Location: `SettingsRepository.swift` lines 20-34.
- Threat category: recovery/availability, possible security state reset if future security preferences are added.
- Exploit scenario: corrupted or older settings silently fall back to defaults, potentially re-enabling surfaces if future privacy/security settings are stored in AppSettings.
- Evidence: decode catch returns `.default` with no diagnostic.
- Recommendation: Low today because settings appear preference-only. If future credential-safety preferences are added, add observable non-secret diagnostics and migration tests.

## Natural Seams for Tasks

1. **Persistence proof task**: `AppSettings` + `SettingsRepository` + `SettingsRepositoryTests`. Prove settings are credential-free today and add/plan guard tests using synthetic secret-shaped values.
2. **Keychain risk task**: `KeychainRepository` + `KeychainRepositoryProtocol` + fake. Document current attributes and rank migration choices; optionally add tests that query construction stays synchronizable false and uses expected service until M002 migration.
3. **UI exposure task**: `SettingsView` + `SetupWizardView`. Inventory reveal toggles, raw `@State`, state clearing, and whether stored secrets are ever preloaded. Plan replace-not-display UX for M002.
4. **ChatGPT credential task**: `ChatGPTUsageService` + `ChatGPTUsageServiceTests` + Settings ChatGPT UI. Validate cookie normalization, access-token handling, and no diagnostics include cookie/token material.
5. **Logging/error task**: `UsageService`, `NetworkService`, `WebViewNetworkService`, `AppError`, `NetworkError`, UI handlers. Define redaction invariant and test likely log/UI pathways where practical.
6. **WKWebView cleanup task**: `WebViewNetworkService`. Verify `currentSessionKey` is nilled on all completion paths and add a focused fix/test if not.

## First Proof

Start with a no-code or tiny-test proof that resolves the S02 discrepancy:

- Assert `AppSettings` has no fields matching `session`, `cookie`, `token`, `key`, `credential`, or provider-specific secret names except non-secret display toggles.
- Assert `SettingsRepository` only saves `AppSettings` JSON and notification state to UserDefaults.
- Add/plan a regression test in `SettingsRepositoryTests` that encoding default/current settings does not contain secret-shaped test strings and that decode compatibility still works.
- Then verify UI state is not initialized from stored secrets; if any prepopulation exists in `SettingsView.onAppear` or AppModel load paths, rank it High.

This proof gives the planner a stable foundation: either S02's highest concern is confirmed and must be fixed, or it is downgraded to an invariant to preserve.

## Verification Plan

- Static scans:
  - `rg -n "sessionKey|session_key|chatGPTSession|cookie|Cookie|token|Authorization|Bearer|UserDefaults|Keychain|kSecAttrAccessible|Logger|localizedDescription" Pinemeter -g '*.swift'`
  - `rg -n "print\(|Logger|os_log|allHTTPHeaderFields|debugDescription|localizedDescription" Pinemeter -g '*.swift'`
- Unit tests:
  - `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SettingsRepositoryTests`
  - `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/ChatGPTUsageServiceTests`
  - Add targeted AppModel tests with existing fakes if S03 includes executable guards.
- Full verification before completing S03 tasks:
  - `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug`
- Manual review checks:
  - No new logs include raw session keys, ChatGPT cookies, Bearer tokens, Cookie headers, or imported cookie values.
  - New findings report ranks each issue with severity, exploit scenario, evidence, and fix/defer recommendation.
  - M002-owned items are explicitly deferred with enough implementation detail that M002 does not need rediscovery.

## Sources

- Memory query: `Security review baseline Keychain credential logging macOS Swift` returned M001 decision that M001 inventories/reviews credential/session handling while M002 owns durable credential acquisition/persistence.
- Skills loaded: `security-review` and `observability`.
- Skill discovery command: `npx skills find "macOS Swift Keychain security"`; promising install command only: `npx skills add dpearson2699/swift-ios-skills@swift-security`.
- S02 dependency context: preloaded S02 summary and `.gsd/milestones/M001/slices/S02/S02-ASSESSMENT.md` (brief assessment confirming S03 should rank credential, Keychain, logging, persistence, and recovery risks).
- Source files inspected:
  - `Pinemeter/Repositories/KeychainRepository.swift` lines 1-112
  - `Pinemeter/Repositories/Protocols/KeychainRepositoryProtocol.swift` lines 1-28
  - `Pinemeter/Repositories/SettingsRepository.swift` lines 1-67
  - `Pinemeter/Repositories/Protocols/SettingsRepositoryProtocol.swift` lines 1-22
  - `Pinemeter/Models/AppSettings.swift` lines 1-123
  - `Pinemeter/Models/SessionKey.swift` lines 1-50
  - `Pinemeter/App/AppModel.swift` lines 1-342
  - `Pinemeter/Views/Settings/SettingsView.swift` lines 1-889
  - `Pinemeter/Views/Setup/SetupWizardView.swift` lines 1-226
  - `Pinemeter/Services/SessionKeyImportService.swift` lines 1-98
  - `Pinemeter/Services/Protocols/SessionKeyImportServiceProtocol.swift` lines 1-35
  - `Pinemeter/Services/NetworkService.swift` lines 1-82
  - `Pinemeter/Services/WebViewNetworkService.swift` lines 1-259
  - `Pinemeter/Services/UsageService.swift` lines 1-174
  - `Pinemeter/Services/ChatGPTUsageService.swift` lines 1-196
  - `Pinemeter/Services/Protocols/ChatGPTUsageServiceProtocol.swift` lines 1-18
  - `Pinemeter/Models/Errors/AppError.swift` lines 1-64
  - `Pinemeter/Models/Errors/NetworkError.swift` lines 1-41
  - `Pinemeter/Models/Errors/KeychainError.swift` lines 1-35
  - `PinemeterTests/AppModelTests.swift` lines 1-420
  - `PinemeterTests/ChatGPTUsageServiceTests.swift` lines 1-196
  - `PinemeterTests/SettingsRepositoryTests.swift` lines 1-75
  - `PinemeterTests/TestDoubles/*` files discovered as existing seams for fakes/stubs.
- Persisted scan evidence:
  - `.gsd/exec/46babf63-3e19-4d09-8772-c2131af8e339.stdout` broad security term scan
  - `.gsd/exec/f23e4076-0b46-47c2-9360-03f11c37f2c3.stdout` exact credential symbol locations
  - `.gsd/exec/f288570c-ad9a-4c63-abfd-a7cf3a1f97df.stdout` numbered source excerpts
  - `.gsd/exec/30541bb4-db76-490d-a70f-0a9237d80d79.stdout` focused AppModel excerpts
  - `.gsd/exec/72c04262-2f49-435a-bd5e-fd1c47dc93fe.stdout` focused SettingsView excerpts
