# S03 Final Security Assessment

**Milestone:** M001  
**Slice:** S03  
**Task:** T04  
**Verdict:** Final ranked security baseline completed; executable credential-free persistence and redaction invariants are in place.

## Executive Summary

S03 reviewed the current Claude and ChatGPT credential/session lifecycle and produced a ranked security baseline for downstream implementation work. The highest current risks are local handling and diagnostic-expansion risks rather than confirmed `AppSettings`/`UserDefaults` credential persistence: ChatGPT session cookies are credential-equivalent and currently flow through raw Settings state, ChatGPT access tokens are transient but sensitive to future logging, Claude WebView session keys can remain in actor/cookie state after terminal paths, and reveal/entry controls can expose raw session material locally.

The S02 discrepancy is reconciled as follows: `AppSettings`/`UserDefaults` persistence is currently preference-only, and `PinemeterTests/SecurityInvariantTests.swift` now pins that invariant with synthetic credential-shaped sentinels. Credential risk remains in acquisition, transient UI state, Keychain/session handling, provider request construction, WebView/cookie lifecycle, display/reveal behavior, logging/error expansion, clearing, and recovery/migration planning.

No real credential or session values were logged, persisted, copied into fixtures, or included in this report. All tests and examples use synthetic credential-shaped values only. Legacy identifiers such as `com.claudemeter.sessionkey`, WebKit/cache behavior, and any existing access-group/cache identifiers are compatibility-sensitive until a dedicated migration plan exists.

## Methodology

- Reviewed S02 inventory output and prior S03 task findings.
- Cross-checked each finding against the S02 lifecycle categories: acquisition, storage, reuse, display, logging/error handling, clearing, and recovery.
- Ranked findings by current exploitability, credential value, persistence/durability, and likelihood of downstream regression.
- Preserved review-only boundaries: S03 records findings and executable invariants but does not claim durable credential redesign or complete remediation.
- Added or preserved negative tests that use synthetic-only credential-shaped sentinels to prevent `AppSettings` persistence and user-facing error descriptions from disclosing credential material.

## Scope and Assumptions

### In Scope

- Claude session key storage, display, WebView injection, and cleanup risks.
- ChatGPT session-cookie normalization, access-token reuse, Settings UI state, and provider request construction.
- User-facing error descriptions and future diagnostic/logging redaction boundaries.
- Compatibility implications of retained Keychain service identifiers and cache/session identifiers.
- Downstream handoff recommendations for S05, S07, and M002.

### Out of Scope

- Implementing a durable credential redesign.
- Migrating Claude or ChatGPT credentials to a new storage model.
- Runtime browser/WebView verification of cookie removal on every terminal path.
- Renaming Keychain services or changing compatibility-sensitive identifiers.

## Lifecycle Cross-Check

| Lifecycle category | Current evidence | Assessment | Downstream owner |
|---|---|---|---|
| Acquisition | Claude and ChatGPT credentials are entered/imported through Settings/setup UI; ChatGPT raw/full/split cookies are normalized before provider use. | Raw acquisition values are credential-equivalent and should become replace-not-display flows. | S05, M002 |
| Storage | `AppSettings`/`UserDefaults` is preference-only; Claude uses Keychain service `com.claudemeter.sessionkey`; ChatGPT saved-cookie handling needs replace-only secure storage. | UserDefaults credential-free invariant is pinned; Keychain identifiers are compatibility-sensitive. | S05, M002 |
| Reuse | ChatGPT session cookies become `Cookie` headers; access tokens become transient `Authorization: Bearer` headers; Claude session keys are injected into WebView cookies. | Reuse paths are legitimate but must be treated as secret-bearing request construction. | S07, M002 |
| Display | Settings/setup state and reveal controls can display raw Claude and ChatGPT values. | Local disclosure risk remains until replace-not-display UX and terminal clearing are implemented. | S05 |
| Logging/error handling | Current localized errors are generic; future diagnostics could leak Cookie, Bearer, session-key, or imported credential material. | Redaction invariant is pinned for user-facing errors and must gate future observability. | S07 |
| Clearing | Settings clear paths exist, but raw state/reveal reset coverage is incomplete; WebView terminal cleanup is not proven across all failures. | Clearing is a medium-risk remediation area. | S05, M002 |
| Recovery/migration | Legacy Keychain service name is stable and non-synchronizable; no migration plan exists. | Preserve compatibility in M001; migrate only with explicit read-old/write-new/delete-old tests. | M002 |

## Finding Table

| Rank | Severity | Finding | Primary lifecycle categories | Recommendation |
|---|---|---|---|---|
| 1 | Medium | ChatGPT session cookie is credential-equivalent and can be loaded/revealed in Settings state. | Acquisition, storage, display, clearing | Fix in S05 if settings/provider flows are touched; otherwise defer secure storage redesign to M002. |
| 2 | Medium | ChatGPT access tokens are transient but future diagnostics could leak Bearer values. | Reuse, logging/error handling | Preserve S03 tests; require S07 redaction before richer diagnostics. |
| 3 | Medium | Claude WebView session key can remain in actor state and injected cookies after failures. | Reuse, clearing, recovery | Add lifecycle cleanup in S03 follow-up or make M002 hard requirement. |
| 4 | Medium | SwiftUI credential entry state and reveal controls expose raw session keys locally. | Acquisition, display, clearing | Fix UI clearing/reveal resets in S05; defer broader secure-input redesign to M002. |
| 5 | Low to Medium | Keychain service identifier is compatibility-sensitive and storage policy should stay explicit. | Storage, recovery/migration | Defer rename/migration to M002; preserve identifier in M001. |
| 6 | Low | Generic localized errors are redaction-safe now, but wrapper errors must not include request/header details. | Logging/error handling, display | Keep generic errors; add central redactor before diagnostics. |

## Detailed Findings

### 1. Medium: ChatGPT session cookie is normalized into credential-bearing Cookie headers and should move to replace-not-display Keychain flows

- **Location:** `Pinemeter/Services/ChatGPTUsageService.swift:38-119`; `Pinemeter/Views/Settings/SettingsView.swift:15-21`, `:194-235`, `:545-562`, `:669-697`, `:730-754`
- **Threat category:** Credential-equivalent cookie handling / local UI exposure / storage boundary drift.
- **Exploit scenario:** `ChatGPTUsageService.cookieHeader(from:)` accepts a raw token, a full `Cookie:` header, or split `__Secure-next-auth.session-token.N` chunks, then returns a normalized Cookie header suitable for authentication. That output is credential-bearing. Settings currently loads any saved ChatGPT cookie back into `@State` and can reveal full values via the “Show values” toggle, so a saved credential can be redisplayed rather than treated as replace-only secret material.
- **Severity:** Medium. The exposure is local UI/process scoped, but ChatGPT session cookies are credential-equivalent and are reusable against `chatgpt.com`.
- **Evidence:** Existing `PinemeterTests/ChatGPTUsageServiceTests.swift` verifies raw, full-header, split-cookie, and newline-prefixed normalization cases. Security invariant tests assert credential-shaped fragments are not disclosed through generic user-facing errors.
- **Remediation:** Keep ChatGPT session cookies in Keychain-backed storage only; change Settings to a replace-not-display flow that shows configured status without loading saved cookie values into text fields; clear `chatGPTSessionTokenPart0`, `chatGPTSessionTokenPart1`, `chatGPTFullCookieHeader`, and hide `isChatGPTSessionCookieShown` after save, clear, validation failure, cancel/dismiss, and view appearance.
- **Fix/defer recommendation:** **Fix in S05 if settings/provider flows are already being touched; otherwise defer broader secure-input redesign to M002.** Do not add durable cookie persistence outside Keychain.

### 2. Medium: ChatGPT access tokens are transient but future diagnostics could leak Bearer Authorization values

- **Location:** `Pinemeter/Services/ChatGPTUsageService.swift:44-60`, `:139-160`; `PinemeterTests/SecurityInvariantTests.swift`
- **Threat category:** Information disclosure through request diagnostics / bearer-token logging.
- **Exploit scenario:** The auth/session response access token is trimmed and immediately embedded in `Authorization: Bearer ...` for the WHAM usage request. Current reviewed code does not log the authorization header, but any future request dump, HTTP diagnostic wrapper, or user-facing error that includes request headers could disclose a reusable access token.
- **Severity:** Medium. Current code keeps the token transient, but the token is credential-equivalent while valid and is a high-risk diagnostic expansion point.
- **Evidence:** `PinemeterTests/SecurityInvariantTests.swift` uses synthetic `Bearer` and access-token-shaped sentinels to assert generic user-facing errors do not contain those fragments.
- **Remediation:** Treat `Cookie` and `Authorization` as always-redacted headers; add a central redactor before any provider HTTP logging; preserve generic `ChatGPTUsageError` descriptions and never wrap underlying request/header values into localized descriptions.
- **Fix/defer recommendation:** **Preserve in S03 tests and hand to S07 observability.** Any new diagnostics must land with redaction tests first.

### 3. Medium: WebView session key can remain in actor state and injected cookies after failures

- **Location:** `Pinemeter/Services/WebViewNetworkService.swift:20`, `:64-67`, `:85`, `:91-95`, `:217-224`, `:237-253`
- **Threat category:** Information disclosure / session retention / failure cleanup.
- **Exploit scenario:** A Claude session key is assigned to actor state before a request and injected into the `WKWebView` cookie store. Timeout and navigation-failure paths resume the continuation, but prior review did not find guaranteed clearing of actor state or removal/expiry of the injected cookie on success, HTTP failure, timeout, or provisional navigation failure.
- **Severity:** Medium. The exposure is local-process/session-lifetime rather than confirmed durable persistence, but it affects high-value Claude session material and failure paths that users cannot easily observe.
- **Evidence:** T02 source review identified actor session state, cookie injection, timeout continuation, navigation failure logging, and HTTP status handling. No reviewed lifecycle line proved cleanup after each terminal path.
- **Remediation:** Add a single terminal cleanup helper that clears actor credential state, expires/removes the injected Claude session cookie from the `WKWebsiteDataStore`, nils/resumes continuation exactly once, and is called from success, decode failure, timeout, navigation failure, provisional failure, cancellation/deinit, and terminal HTTP-auth failure paths.
- **Fix/defer recommendation:** **Fix in S03 follow-up if small and isolated; otherwise make M002 a hard requirement before durable provider/session redesign.**

### 4. Medium: SwiftUI credential entry state and reveal controls expose raw session keys in local UI state

- **Location:** `Pinemeter/Views/Settings/SettingsView.swift:7-12`, `:104-121`, `:133-141`, `:665`, `:691-704`, `:733-740`, `:765-768`; `Pinemeter/Views/Setup/SetupWizardView.swift`
- **Threat category:** Local UI exposure / shoulder surfing / screen sharing / transient memory retention.
- **Exploit scenario:** Settings and setup views store raw Claude session material in `@State` strings and include reveal controls. During screen sharing or unattended sessions, reveal state can display a full key; after save/import/cancel/error, raw state may remain unless every terminal path explicitly clears it.
- **Severity:** Medium. This is user-local and requires screen/process access, but the material is a high-value session credential and SwiftUI state is intentionally long-lived for the view lifetime.
- **Evidence:** T02 source review identified raw state fields and reveal UI in Settings plus setup wizard raw input and save/import paths. Existing S02/T01 evidence narrows durable persistence risk: `AppSettings` persistence is preference-only and the security invariant test prevents credential-shaped material from entering `UserDefaults`.
- **Remediation:** Clear credential `@State` after successful save/import, cancel/dismiss, clear-key completion, and validation/import failure where practical; reset reveal toggles to hidden on view appearance and after terminal actions; avoid echoing imported values in user-visible messages.
- **Fix/defer recommendation:** **Fix UI clearing/reveal resets in S05 or an S03 follow-up; defer broader secure-input redesign to M002.**

### 5. Low to Medium: Keychain service identifier is compatibility-sensitive and storage attributes should be explicit policy

- **Location:** `Pinemeter/Repositories/KeychainRepository.swift:13`, `:24-27`, `:45`, `:71-78`, `:90-93`, `:105`
- **Threat category:** Credential availability / migration safety / local data protection policy.
- **Exploit scenario:** The Keychain service name is currently `com.claudemeter.sessionkey`; silently renaming it during the app rename to Pinemeter would strand existing credentials or create duplicate credential records. Accessibility is `kSecAttrAccessibleAfterFirstUnlock` and synchronizable is disabled, which is defensible but should remain explicit policy.
- **Severity:** Low to Medium. Current evidence shows non-synchronizable storage and explicit accessibility. The risk is future migration/compatibility and policy drift.
- **Evidence:** T02 source review identified the compatibility service name and non-synchronizable Keychain query attributes across query, save, update, delete, and existence-check paths.
- **Remediation:** Treat `com.claudemeter.sessionkey` as a compatibility contract for M001. If renamed later, implement an explicit read-old/write-new migration with deletion of the old item after confirmed write, and test both identifiers with synthetic key-shaped values.
- **Fix/defer recommendation:** **Defer rename/migration to M002; preserve identifier in M001.**

### 6. Low: Generic localized errors are currently redaction-safe, but wrapper errors must not include request/header details

- **Location:** `Pinemeter/Models/Errors/AppError.swift:18-34`; `Pinemeter/Models/Errors/NetworkError.swift:18-35`; `Pinemeter/Models/Errors/KeychainError.swift:16-27`; `Pinemeter/Services/ChatGPTUsageService.swift:12-26`; `Pinemeter/Views/Settings/SettingsView.swift:621-633`, `:749-752`
- **Threat category:** User-facing disclosure / logging disclosure.
- **Exploit scenario:** Current error descriptions are generic and mostly status-code only, but Settings interpolates `error.localizedDescription` into validation failure UI. If future network/provider code wraps underlying request headers, raw cookies, Bearer tokens, session keys, or imported credential material into localized errors, UI and logs become credential disclosure channels.
- **Severity:** Low for current reviewed error models; potentially high if future diagnostics include request/header dumps.
- **Evidence:** `AppError`, `NetworkError`, `KeychainError`, and `ChatGPTUsageError` return generic descriptions. `SecurityInvariantTests` passes synthetic credential-shaped underlying errors into generic error paths and asserts user-facing descriptions do not contain `sk-ant-`, `__Secure-next-auth`, `Cookie:`, `Bearer`, or access-token-shaped sentinels.
- **Remediation:** Keep localized errors generic. Introduce a redactor before adding diagnostic context to errors/logs. Prefer opaque failure categories and status codes over request/header/body text in user-facing messages.
- **Fix/defer recommendation:** **Fix-before-diagnostics invariant.** S07 observability can add more detail only with redaction tests.

## Fix and Defer Recommendations

### Fix in S05

- Convert Claude and ChatGPT credential entry toward replace-not-display UX.
- Clear raw SwiftUI credential state after save/import/clear/cancel/validation failure.
- Hide reveal toggles on appearance and after terminal credential actions.
- Keep ChatGPT validation errors generic and avoid echoing provider request/header values.

### Fix in S07

- Preserve structured/status logging while enforcing redaction before diagnostics expand.
- Add logger/redactor tests that include synthetic `Cookie`, `Authorization: Bearer`, Claude session-key, ChatGPT cookie, access-token, and imported-credential fragments.
- Do not log request headers, credential-bearing cookies, bearer tokens, raw session keys, imported credential material, or unredacted upstream errors.

### Defer to M002

- Durable credential redesign for Claude and ChatGPT.
- ChatGPT Keychain-backed replace-only storage model.
- Any Keychain service rename/migration from `com.claudemeter.sessionkey`.
- Runtime WebView/cookie cleanup verification across success, timeout, cancellation, decode failure, navigation failure, provisional failure, and HTTP-auth failure.
- Broader secure-input lifecycle changes that require architectural migration.

## Failure Modes

| Dependency | Failure path | Handling evidence | Security recommendation |
|---|---|---|---|
| ChatGPT auth/session API | Blank cookie, 401/403 invalid session, missing/empty access token, malformed response, network failure | `ChatGPTUsageService.fetchUsage` throws `missingSessionCookie` for blank input, maps missing access token to `invalidSessionCookie`, and `ChatGPTHTTPClient` maps auth failures and transport/decode failures to generic `ChatGPTUsageError` cases. | Keep user-facing ChatGPT errors generic; do not include Cookie or Bearer values when surfacing validation failure in Settings. |
| ChatGPT WHAM usage API | HTTP non-2xx, malformed quota response, connection timeout/loss | `ChatGPTHTTPClient` reports generic status or invalid/unavailable errors without request/header values. | If adding diagnostics for WHAM failures, redact `Cookie` and `Authorization` headers before logging. |
| Settings ChatGPT credential fields | Validation failure, saved-cookie reload, reveal toggle left visible, clear failure | Settings stores raw cookie input in `@State`, loads saved cookie into a field, can reveal values, and displays `error.localizedDescription` for validation failures. | Convert to replace-not-display status flow; clear raw fields and hide reveal toggles on terminal paths. |
| macOS Keychain | Item missing, duplicate item, update/delete failure, policy drift | Claude Keychain review found a stable service identifier, non-synchronizable storage, and explicit update/delete calls. | Preserve `com.claudemeter.sessionkey` in M001; any M002 rename must be an explicit migration with rollback/cleanup tests. |
| `WKWebView` request lifecycle | Timeout, navigation failure, provisional failure, 401/429/other HTTP response, decode/JS extraction failure | WebView review found actor session state, cookie injection, timeout and delegate failure paths, and lifecycle logging. | Add centralized terminal cleanup for actor state, cookie store, and continuation handling; test with synthetic sentinel credentials. |
| OSLog / diagnostics | Error/status logs could accidentally include secrets if request dumps are added | Reviewed provider/error code does not currently log Cookie, Authorization, or session-key values directly. | Keep request headers, Cookie values, Bearer tokens, Claude session keys, ChatGPT cookies, access tokens, and imported credential material prohibited from logs/displays. |

## Load Profile

This task is a security assessment and test hardening task; it does not introduce runtime load. The only 10x runtime pressure point in reviewed code is repeated provider validation/fetch failure: ChatGPT failures could repeatedly construct credential-bearing Cookie/Bearer headers, and WebView failures could retain cookie/session state or pending continuations. The protection should be lifecycle cleanup and redacted diagnostics, not scaling infrastructure.

## Negative Tests

| Negative scenario | Existing or added coverage | Notes |
|---|---|---|
| Credential-shaped values must not be persisted in `AppSettings`/`UserDefaults`. | `PinemeterTests/SecurityInvariantTests.swift::test_appSettingsPersistenceDoesNotEncodeCredentialMaterial`. | Uses synthetic sentinel field/value fragments and reconciles the S02 persistence discrepancy. |
| Generic app/network/keychain errors must not disclose underlying credential-shaped details. | `test_userFacingAppErrorDescriptionsDoNotDiscloseCredentialShapedFragments` and `test_userFacingNetworkAndKeychainDescriptionsDoNotDiscloseCredentialShapedFragments`. | Includes a synthetic underlying error containing Claude, Cookie, Bearer, and access-token shaped values; generic descriptions must not echo it. |
| ChatGPT validation/fetch errors must not disclose Cookie or Bearer-shaped values. | `test_userFacingChatGPTErrorDescriptionsDoNotDiscloseCredentialShapedFragments`. | Covers `missingSessionCookie`, `invalidSessionCookie`, `invalidResponse`, HTTP status, and network-unavailable descriptions. |
| ChatGPT cookie normalization accepts raw, full-header, split, and newline/Cookie-prefixed input. | `PinemeterTests/ChatGPTUsageServiceTests.swift` cookie-header tests. | Confirms normalization output is credential-bearing and must not be logged/displayed. |
| Request/header/cookie/token values must not be logged. | Recommended S07 follow-up tests around logger/redactor boundaries. | Must use synthetic Claude/ChatGPT/Bearer-shaped sentinels only. |
| WebView timeout/failure must clear actor session state and injected cookies. | Recommended S03 follow-up or M002 tests if cleanup implementation is added. | Cover timeout, navigation failure, provisional failure, decode failure, and HTTP auth failure. |

## Observability Impact

This assessment documents the redaction invariant for future observability work: structured/status logging may remain, but request headers, `Cookie` values, Bearer tokens, Claude session keys, ChatGPT session cookies, transient ChatGPT access tokens, and imported credential material must not be logged or displayed. The security invariant tests pin generic user-facing error descriptions before S07 adds any richer diagnostics.

## Downstream Handoff

### S05 Handoff

S05 should consume findings 1 and 4 first. Implement replace-not-display credential settings flows where practical, prevent saved ChatGPT cookie values from rehydrating into editable text fields, clear raw credential `@State` on terminal paths, hide reveal toggles by default, and preserve generic validation failures. S05 should not introduce plaintext durable cookie/session persistence.

### S07 Handoff

S07 should treat this report as the logging contract. Existing structured/status logging may continue, but any new HTTP/provider/WebView diagnostics must pass through a redactor and include tests proving request headers, `Cookie` values, Bearer tokens, Claude session keys, ChatGPT session cookies, transient access tokens, and imported credential material are excluded from logs and user-facing messages.

### M002 Handoff

M002 should own durable credential redesign: Keychain-backed ChatGPT storage, replace-only credential UX, explicit Claude Keychain migration if service identifiers change, and runtime WebView/cookie cleanup verification. Compatibility-sensitive identifiers, including `com.claudemeter.sessionkey` and any retained cache/session/access-group identifiers, should remain stable until M002 defines and tests migration behavior.

## Known Limitations

- S03 is a review and invariant-hardening slice, not a durable credential remediation slice.
- WebView cookie/session cleanup still needs runtime verification in a follow-up or M002.
- ChatGPT replace-not-display storage is recommended but not implemented here.
- Redaction tests currently cover user-facing error descriptions and credential-free settings persistence; future logging/redactor surfaces need their own tests before diagnostics expand.
- No real credentials were used; all test sentinels are synthetic and intentionally nonfunctional.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---|---|---|---|
| 1 | `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests -only-testing:PinemeterTests/SettingsRepositoryTests -only-testing:PinemeterTests/ChatGPTUsageServiceTests` | 0 | Passed focused security/settings/ChatGPT XCTest run (`gsd_exec` evidence `23f94c01-a21d-4b30-838c-1c6d2f4771b8`) | 129762ms |
