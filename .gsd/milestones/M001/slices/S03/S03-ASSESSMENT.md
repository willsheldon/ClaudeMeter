# S03 Assessment

**Milestone:** M001  
**Slice:** S03  
**Task:** T02  
**Verdict:** Claude-side credential risks ranked for downstream fix/defer planning

## Scope

This assessment ranks Claude credential handling risks in three areas: Keychain storage identifiers and attributes, SwiftUI credential entry/display state, and `WKWebView` request/session-key lifecycle. It preserves the S02 conclusion that `AppSettings`/`UserDefaults` persistence is currently preference-only, while credential risk remains concentrated in Keychain/session handling and transient UI/app state.

## Ranked Findings

### 1. Medium: WebView session key can remain in actor state and injected cookies after failures

- **Location:** `Pinemeter/Services/WebViewNetworkService.swift:20`, `:64-67`, `:85`, `:91-95`, `:217-224`, `:237-253`
- **Threat category:** Information disclosure / session retention / failure cleanup.
- **Exploit scenario:** A Claude session key is assigned to `currentSessionKey` before a request (`:67`) and injected into the `WKWebView` cookie store (`:85`). Timeout and navigation-failure paths resume the continuation (`:95`, `:217-224`) but the evidence does not show guaranteed clearing of `currentSessionKey` or removal/expiry of the injected cookie on success, HTTP failure, timeout, or provisional navigation failure. A later request, diagnostic inspection, or retained `WKWebView` data store could therefore keep credential material alive longer than intended.
- **Severity:** Medium. The exposure is local-process/session-lifetime rather than confirmed durable persistence, but it affects high-value Claude session material and is on failure paths that users cannot easily observe.
- **Evidence:** Source evidence shows `currentSessionKey` storage (`WebViewNetworkService.swift:20`), assignment before load (`:64-67`), cookie injection (`:85`), timeout continuation (`:91-95`), navigation failure logging (`:217-224`), and HTTP status handling (`:237-253`). No source evidence in the reviewed lifecycle lines proves cleanup after each terminal path.
- **Remediation:** Add a single terminal cleanup helper that clears `currentSessionKey`, expires/removes the injected Claude session cookie from the `WKWebsiteDataStore`, nils/resumes continuation exactly once, and is called from success, decode failure, timeout, navigation failure, provisional failure, cancellation/deinit, and terminal HTTP-auth failure paths.
- **Fix/defer recommendation:** **Fix in S03 follow-up if small and isolated; otherwise make M002 a hard requirement before durable provider/session redesign.** The change is narrow but touches async `WKNavigationDelegate` lifecycle and should be covered by targeted negative tests using synthetic sentinel values only.

### 2. Medium: SwiftUI credential entry state and reveal controls expose raw session keys in local UI state

- **Location:** `Pinemeter/Views/Settings/SettingsView.swift:8-12`, `:104-121`, `:133-141`, `:665`, `:691-704`, `:733-740`, `:765-768`; `Pinemeter/Views/Setup/SetupWizardView.swift:7`, `:43`, `:117-137`, `:170-208`
- **Threat category:** Local UI exposure / shoulder surfing / screen sharing / transient memory retention.
- **Exploit scenario:** The Settings view stores raw Claude session material in `@State private var sessionKey` (`SettingsView.swift:8`) and includes a show/hide toggle (`:104-118`) plus import/validation save flows (`:133-141`, `:691-740`). The setup wizard likewise keeps raw input in `@State private var sessionKeyInput` (`SetupWizardView.swift:7`) and validates/imports it (`:170-208`). During screen sharing or unattended sessions, reveal state can display a full key; after save/import/cancel/error, raw state may remain unless every terminal path explicitly clears it.
- **Severity:** Medium. This is user-local and requires screen/process access, but the material is a high-value session credential and SwiftUI state is intentionally long-lived for the view lifetime.
- **Evidence:** Source evidence shows raw state fields and reveal UI in Settings, plus setup wizard raw input and save/import paths. Existing S02/T01 evidence narrows durable persistence risk: `AppSettings` persistence is preference-only and the security invariant test exists to prevent credential-shaped material from entering `UserDefaults`.
- **Remediation:** Clear credential `@State` after successful save/import, cancel/dismiss, clear-key completion, and validation/import failure where practical; reset reveal toggles to hidden on view appearance and after terminal actions; avoid echoing imported values in user-visible messages; prefer placeholder/masked status messages such as “session key saved” over displaying credential-derived substrings.
- **Fix/defer recommendation:** **Fix UI clearing/reveal resets in S05 or an S03 follow-up; defer broader secure-input redesign to M002.** The immediate work is state hygiene, not a durable credential architecture rewrite.

### 3. Low to Medium: Keychain service identifier is compatibility-sensitive and storage attributes should be explicit policy

- **Location:** `Pinemeter/Repositories/KeychainRepository.swift:13`, `:24-27`, `:45`, `:71-78`, `:90-93`, `:105`
- **Threat category:** Credential availability / migration safety / local data protection policy.
- **Exploit scenario:** The Keychain service name is currently `com.claudemeter.sessionkey` (`:13`) and appears across query, save, update, delete, and existence-check paths (`:24`, `:45`, `:71`, `:90`, `:105`). Silently renaming it during the app rename to Pinemeter would strand existing credentials or create duplicate credential records. Accessibility is `kSecAttrAccessibleAfterFirstUnlock` (`:26`) and synchronizable is disabled (`:27`), which is a defensible local-only default but should be documented so future changes do not accidentally enable iCloud sync or weaker accessibility.
- **Severity:** Low to Medium. Current evidence shows non-synchronizable storage and explicit accessibility, which is good. The risk is mostly future migration/compatibility and policy drift, with possible availability breakage if the identifier is renamed silently.
- **Evidence:** `serviceName` is hard-coded to the compatibility name (`KeychainRepository.swift:13`); keychain item queries include `kSecAttrAccessibleAfterFirstUnlock` and `kSecAttrSynchronizable: false` (`:24-27`); update/delete use the same service (`:71-78`, `:90-93`).
- **Remediation:** Treat `com.claudemeter.sessionkey` as a compatibility contract for M001. If renamed later, implement an explicit read-old/write-new migration with deletion of the old item after confirmed write, and test both old and new identifiers with synthetic key-shaped values. Document the intended accessibility and non-synchronizable policy.
- **Fix/defer recommendation:** **Defer rename/migration to M002; preserve identifier in M001.** Add tests only if a migration is introduced.

### 4. Low: WebView logging avoids request/header dumps in reviewed lines, but response-body logging must remain redaction-gated

- **Location:** `Pinemeter/Services/WebViewNetworkService.swift:16`, `:45`, `:64`, `:146`, `:176`, `:183`, `:199`, `:217-224`, `:253`
- **Threat category:** Logging disclosure.
- **Exploit scenario:** If future diagnostics log request headers, Cookie values, Bearer tokens, Claude session keys, ChatGPT session cookies, or imported credential material, application logs could become a credential disclosure vector. Current reviewed request lifecycle logs endpoint/status/error text but not the explicit session key or cookie value in the evidence lines.
- **Severity:** Low for current reviewed lines, high if the invariant regresses.
- **Evidence:** Logger use is present, including “Making request to: endpoint” (`:64`), decode error response body logging (`:45`), JavaScript/navigation errors (`:146`, `:217-224`), Cloudflare/status messages (`:176`, `:183`, `:253`). No reviewed line logs `currentSessionKey` or the cookie value directly.
- **Remediation:** Keep the redaction invariant explicit: request headers, `Cookie` values, Bearer tokens, Claude session keys, ChatGPT session cookies, and imported credential material must not be logged or displayed. If response-body logging is kept for diagnostics, ensure response data cannot include credential echoes or route it through a redactor before logging.
- **Fix/defer recommendation:** **Preserve in S03 tests and hand to S07 observability.** Do not add verbose request/header logging without redaction tests.

## Failure Modes

| Dependency | Failure path | Handling evidence | Security recommendation |
|---|---|---|---|
| macOS Keychain | Item missing, duplicate item, update/delete failure, policy drift | `KeychainRepository` uses a stable service identifier (`:13`), non-synchronizable storage (`:27`), and explicit update/delete calls (`:78`, `:93`). | Preserve `com.claudemeter.sessionkey` in M001; any M002 rename must be an explicit migration with rollback/cleanup tests. |
| SwiftUI credential forms | Validation failure, import failure, cancel/dismiss, reveal toggle left visible | Settings and setup views hold raw `@State` strings and have validate/import/reveal flows. | Clear raw `@State` and hide reveal controls on every terminal path; never include credential material in validation/import messages. |
| `WKWebView` request lifecycle | Timeout, navigation failure, provisional failure, 401/429/other HTTP response, decode/JS extraction failure | `WebViewNetworkService` assigns `currentSessionKey`, injects a cookie, has timeout and delegate failure paths, and logs lifecycle events. | Add centralized terminal cleanup for actor state, cookie store, and continuation handling; test with synthetic sentinel credentials. |
| OSLog / diagnostics | Error/status logs could accidentally include secrets if request dumps are added | Reviewed lines log endpoint/status/error/response body but not the session key/cookie directly. | Keep request headers, Cookie values, Bearer tokens, Claude session keys, ChatGPT cookies, and imported credential material prohibited from logs/displays. |

## Load Profile

This task is a security assessment and does not introduce runtime load. The only runtime load-relevant reviewed surface is `WebViewNetworkService`, where the first 10x pressure point would be retained `WKWebView` session state/cookies and pending continuations during repeated failures or timeouts. The protection should be lifecycle cleanup rather than scaling infrastructure: one request terminal path should release session state, clear injected cookies, and prevent orphaned continuations before the next request starts.

## Negative Tests

| Negative scenario | Existing or recommended coverage | Notes |
|---|---|---|
| Credential-shaped values must not be persisted in `AppSettings`/`UserDefaults`. | Existing `PinemeterTests/SecurityInvariantTests.swift` from T01. | Uses synthetic sentinel values only and reconciles the S02 persistence discrepancy. |
| Request/header/cookie/token values must not be logged. | Recommended S03/S07 follow-up tests around logger/redactor boundaries. | Must use synthetic Claude/ChatGPT/Bearer-shaped sentinels only. |
| WebView timeout/failure must clear `currentSessionKey` and injected cookies. | Recommended S03 follow-up or M002 tests if cleanup implementation is added. | Cover timeout, navigation failure, provisional failure, decode failure, and HTTP auth failure. |
| Keychain service rename must not strand credentials. | Recommended only when M002 introduces migration. | Test old `com.claudemeter.sessionkey` read and new identifier write/delete with synthetic values. |
| Reveal/cancel/save/import UI flows must clear raw state and hide revealed secrets. | Recommended S05 or M002 UI-state tests. | Verify validation failure and cancel paths as well as success paths. |

## Observability Impact

This assessment confirms the Claude credential logging boundary: structured/status logging may remain, but request headers, `Cookie` values, Bearer tokens, Claude session keys, ChatGPT session cookies, and imported credential material must not be logged or displayed. Future observability work should add redaction tests before increasing request/response logging detail.

## Downstream Ownership

- **S03 follow-up:** Add narrow WebView lifecycle cleanup and negative tests if feasible without durable credential redesign.
- **S05:** Ensure provider/error flows do not echo credential material and handle validation/import failures with state clearing.
- **S07:** Preserve logging/status observability while enforcing redaction for headers, cookies, bearer tokens, session keys, and imported credential material.
- **M002:** Own durable credential redesign, Keychain service migration if any, and broader secure-input lifecycle changes.
