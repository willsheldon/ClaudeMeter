# S05 Research: Provider and error workflow audit

## Summary

S05 is a targeted codebase audit, not a provider workflow redesign. The current app has two real provider flows: Claude.ai usage via `UsageService`/`NetworkService` using a `sessionKey` cookie, and optional ChatGPT quota usage via `ChatGPTUsageService` using a NextAuth session cookie plus transient Bearer token. The main work should be to classify provider-specific copy as valid vs stale, apply low-risk text/diagnostic fixes, and leave deeper provider abstraction or durable credential redesign to M002/M003.

Highest-value findings for the planner:

1. **Ambiguous generic “session key” copy exists in shared/user-facing error paths** (`AppError`, `NetworkError`, `SessionKeyError`, setup/settings validation, popover recovery button). Because ChatGPT also has a session cookie, Claude-specific errors should say **Claude session key** where they are specifically about Claude credentials. This is a safe S05 copy fix with tests.
2. **README and site still describe Pinemeter primarily as Claude-only**, while app code/settings already expose optional ChatGPT quota usage. Public copy should be updated to “Claude.ai usage with optional ChatGPT quota visibility” or similar. Avoid implying Gemini or generic provider support in M001.
3. **Provider-specific service boundaries are explicit but asymmetric**: Claude uses `UsageService` + generic `NetworkService`; ChatGPT uses `ChatGPTUsageService` + `ChatGPTHTTPClientProtocol`. Do not force unification in S05. S04 handoff recommends designing provider interfaces separately before broad unification.
4. **Error classification is currently string/LocalizedError based**. `AppModel` stores `errorMessage` and `chatGPTErrorMessage` strings, and `UsagePopoverView` decides whether to show “Update Session Key” by substring matching `invalid|expired|authentication`. S05 may make copy less ambiguous, but a typed provider-aware error model belongs to M003 unless a tiny helper is needed to keep S05 fixes testable.
5. **Logging redaction remains a provider/error workflow concern.** `NetworkService` logs full HTTP/decode response bodies for Claude endpoint failures. That is not an obvious secret today, but S03 flags future diagnostics/request dumps as sensitive. If S05 touches diagnostics, prefer redacted status/endpoint/byte-count logging over response-body logging, with a focused security invariant test. Do not log cookies, session keys, or Bearer tokens.

## Active Requirements and Handoffs

- **R006 owned by S05:** audit stale Claude-only or provider-ambiguous setup, status, error, and recovery messages; apply obvious safe copy fixes.
- **R003 supported:** keep credential/session surface categories intact; do not introduce plaintext credential persistence or display beyond existing flows.
- **R004 supported:** preserve S03 security invariants: ChatGPT cookies and access tokens are credential-equivalent; user-facing errors/logs must not disclose credential-shaped fragments.

Dependency intelligence consumed:

- S02 provides the credential flow map and warns that Settings/UI state holds raw Claude/ChatGPT credential material during edit/reveal flows.
- S03 adds tests for credential-free settings persistence and credential-shaped disclosure in `SecurityInvariantTests.swift`; extend this suite rather than creating a parallel security test style.
- S04 warns against premature provider unification and recommends structured, non-secret failure context if provider services are touched.

## Skill Discovery and Applied Rules

Available project skills were checked from the preloaded list. The `observability` skill was loaded because S05 touches unattended refresh/error/diagnostic paths. Relevant rules applied to the research:

- Prefer **explicit failure modes** over swallowed or string-only errors.
- Add the **right signal at decision points**, not broad logging everywhere.
- Never put credential-bearing material in logs; diagnostics should be structured and redacted.

No new skill was installed. A `superpowers-agent` version/list command was attempted first per project bootstrap instructions but blocked by the planning-dispatch read-only shell policy; do not spend executor time on skill installation for this slice.

## Implementation Landscape

### Provider services and credentials

- `Pinemeter/Services/UsageService.swift`
  - Claude-specific base URL: `https://claude.ai/api`.
  - Retrieves Keychain account `default`, constructs `SessionKey`, fetches organizations and usage.
  - Maps missing Keychain entry to `AppError.noSessionKey`, authentication failure to `AppError.sessionKeyInvalid`, retry exhaustion to `AppError.networkError`.
  - Existing logger messages include safe-ish generic messages like “Authentication failed - session key invalid”, but should become “Claude session key invalid” if user-facing/diagnostic copy is adjusted.

- `Pinemeter/Services/NetworkService.swift`
  - Generic-looking name, but actually Claude-specific: sets `Cookie: sessionKey=...`, `Origin: https://claude.ai`, `Referer: https://claude.ai`, and `Host`-relevant headers.
  - Throws generic `NetworkError` values, whose descriptions currently say “Session key is invalid or expired”.
  - Logs HTTP/decode response bodies: `HTTP status from endpoint: responseBody` and `Failed to decode ... Response: responseBody`. This is the most important diagnostic/redaction watch-out if S05 changes error handling.

- `Pinemeter/Services/ChatGPTUsageService.swift`
  - Provider-specific and appropriately named.
  - `ChatGPTUsageError` descriptions are provider-specific: missing/invalid cookie, invalid response, HTTP status, network unavailable.
  - Accepts raw token/full Cookie header/split NextAuth chunks through `cookieHeader(from:)`.
  - Fetches `/api/auth/session` to get transient access token, then `/backend-api/wham/usage` with `Authorization: Bearer ...`.

- `Pinemeter/Services/Protocols/ChatGPTUsageServiceProtocol.swift`
  - Clean seam for ChatGPT fetch/validate and HTTP client tests.

- `Pinemeter/Services/Protocols/SessionKeyImportServiceProtocol.swift`
  - Claude-specific import errors are valid provider-specific copy: “No Claude browser session found”, “imported Claude session key”.
  - Some recovery copy says “paste your session” generically. Safe to make “paste your Claude session” if touching.

### App state and recovery surfaces

- `Pinemeter/App/AppModel.swift`
  - Main `@MainActor @Observable` UI state.
  - Stores `errorMessage: String?` for Claude and `chatGPTErrorMessage: String?` for ChatGPT.
  - `refreshUsage` assigns `error.localizedDescription` to `errorMessage`.
  - `refreshChatGPTUsage` loads Keychain account `chatgpt`, fetches ChatGPT usage, and assigns `error.localizedDescription` to `chatGPTErrorMessage`.
  - `validateAndSaveChatGPTSessionCookie` saves the raw trimmed input to Keychain only after validation and toggles `settings.isChatGPTUsageShown = true`.
  - No typed error classification reaches the views today.

- `Pinemeter/Views/MenuBar/UsagePopoverView.swift`
  - Displays `Text("Claude Usage")` and optional ChatGPT section.
  - Shows `appModel.errorMessage` directly.
  - Shows “Retry” for any Claude error.
  - Shows “Update Session Key” when the error string contains `invalid`, `expired`, or `authentication`; make this “Update Claude Session Key” if changing copy. Typed provider error handling is a future M003 improvement unless S05 adds a small helper.
  - Displays `ChatGPT: \(chatGPTErrorMessage)` for ChatGPT errors.

### Setup and settings copy

- `Pinemeter/Views/Setup/SetupWizardView.swift`
  - Correctly Claude-specific setup: “Monitor your Claude.ai plan usage”, “Claude Session”, “Import from browser signed in to claude.ai”.
  - Ambiguous phrases: “Session format valid”, “Invalid session format”, “Importing session key”, “Validating session key”, “Session key cannot be empty”, “Session key is invalid or expired”. Since this setup is currently Claude-only, these can safely become “Claude session key …”.
  - Error handling often propagates localized descriptions. Preserve S03 credential redaction tests when changing.

- `Pinemeter/Views/Settings/SettingsView.swift`
  - Has separate `Claude Session` and `ChatGPT Usage` sections.
  - Ambiguous phrases in the Claude section: “Import from browser or paste your Claude session” (okay), placeholders and validation messages around “session key”, “Imported from …”, “Failed to clear”. Safe copy improvement: qualify user-visible key messages as “Claude session key”.
  - ChatGPT section already says “Stores your ChatGPT session cookie in Keychain” and has “Show values”/“Hide values”; S03 treats reveal as known risk, but redesign is M002/M003.
  - ChatGPT messages are specific enough: “ChatGPT session cookie saved”, “ChatGPT session cookie validation failed”.

### Error model files

- `Pinemeter/Models/Errors/AppError.swift`
  - `noSessionKey`: “No session key found. Please complete setup.” -> likely “No Claude session key found. Please complete setup.”
  - `sessionKeyInvalid`: “Session key is invalid or expired. Please update in settings.” -> likely “Claude session key is invalid or expired. Please update it in Settings.”
  - `recoveryAction`: “Update Session Key” -> likely “Update Claude Session Key”.
  - `networkError` and `keychainError` pass through nested localized descriptions, so update nested types too.

- `Pinemeter/Models/Errors/NetworkError.swift`
  - `authenticationFailed`: “Session key is invalid or expired” -> likely “Claude session key is invalid or expired” because current `NetworkService` is Claude-specific despite generic naming.
  - Other network descriptions are provider-neutral and okay.

- `Pinemeter/Models/Errors/KeychainError.swift`
  - `notFound`: “Session key not found in Keychain” is ambiguous because the same repository stores account `default` and `chatgpt`. This enum has no provider/account context, so changing it to Claude-specific may be inaccurate for ChatGPT. Prefer leaving as-is unless wrapping at call sites.

- `Pinemeter/Models/SessionKey.swift`
  - Claude session key validation type. Descriptions can become “Claude session key must start with 'sk-ant-'”, “Claude session key is too short”, “Claude session key could not be validated with Claude API”. Safe and testable.

### Public docs/site copy

- `README.md`
  - Still opens with “Keep track of your Claude.ai plan usage at a glance.”
  - Features omit optional ChatGPT quota usage despite implemented settings/popover support.
  - Safe S05 fix: add one feature bullet for optional ChatGPT quota visibility; keep primary Claude positioning until M003/M004.

- `site/index.html`
  - Meta/title/description/keywords are Claude-only.
  - Safe S05 fix: update description/features to mention optional ChatGPT quota monitoring without claiming generic provider support.

### Compatibility identifiers not S05 copy fixes

- `Pinemeter/Repositories/KeychainRepository.swift`: service name `com.claudemeter.sessionkey`.
- `Pinemeter/Repositories/CacheRepository.swift`: `com.claudemeter` app-support path and `~/.claudemeter/usage.json` public export.
- `Pinemeter/Resources/Pinemeter.entitlements`: app group `com.claudemeter`.

S02/S03 classify these as compatibility-sensitive retained identifiers, not stale copy. Do not rename them in S05.

## Natural Seams for Planning

1. **Audit artifact task**
   - Inputs: source scans above, S02/S03/S04 summaries.
   - Output: `.gsd/milestones/M001/slices/S05/S05-ASSESSMENT.md` with a table of setup/status/error/recovery surfaces: file, current copy, classification, fix/defer, security note.
   - This can be first or last, but planners should make sure final assessment reflects actual fixes.

2. **Claude session key copy clarification**
   - Files: `Pinemeter/Models/Errors/AppError.swift`, `Pinemeter/Models/Errors/NetworkError.swift`, `Pinemeter/Models/SessionKey.swift`, `Pinemeter/Views/Setup/SetupWizardView.swift`, `Pinemeter/Views/Settings/SettingsView.swift`, `Pinemeter/Views/MenuBar/UsagePopoverView.swift`.
   - Purpose: qualify Claude-specific messages/actions as “Claude session key” where ChatGPT ambiguity exists.
   - Keep valid provider-specific Claude references. Do not make copy generic “provider” unless the code path truly handles both providers.

3. **Public docs/site provider accuracy**
   - Files: `README.md`, `site/index.html`.
   - Purpose: mention optional ChatGPT quota usage while retaining accurate Claude-primary positioning.
   - Avoid marketing claims for Gemini or generic provider support.

4. **Focused tests for provider/error copy and redaction**
   - Files: `PinemeterTests/SecurityInvariantTests.swift`, possibly `PinemeterTests/AppModelTests.swift` / `PinemeterTests/ChatGPTAppModelTests.swift` if view-model behavior changes.
   - Purpose: update/add tests that assert user-facing error descriptions do not disclose credential-shaped fragments and that Claude vs ChatGPT error copy remains provider-specific.
   - Existing tests already assert redaction for `AppError`, `ChatGPTUsageError`, `NetworkError`, and `KeychainError` descriptions; extend those rather than duplicating.

5. **Optional diagnostic redaction fix**
   - Files: `Pinemeter/Services/NetworkService.swift`, `PinemeterTests/SecurityInvariantTests.swift` or a new focused service test if feasible.
   - Purpose: avoid logging full HTTP/decode response bodies if planner decides this is in S05 scope. Safer minimal change: log status/endpoint/response byte count and decoding error, not body content.
   - If not touched, record as deferred to S06/M002/M003 in S05 assessment.

## First Proof

The best first proof is a focused test run around error/security invariants before and after copy edits:

```sh
xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug \
  -only-testing:PinemeterTests/SecurityInvariantTests \
  -only-testing:PinemeterTests/AppModelTests \
  -only-testing:PinemeterTests/ChatGPTAppModelTests
```

Why first: the most likely regression from S05 is not a compile failure; it is accidentally weakening the S03 redaction invariant or changing tested `localizedDescription`/app-state behavior.

## Verification Recommendations

Minimum slice verification:

1. Focused tests:

```sh
xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug \
  -only-testing:PinemeterTests/SecurityInvariantTests \
  -only-testing:PinemeterTests/AppModelTests \
  -only-testing:PinemeterTests/ChatGPTAppModelTests \
  -only-testing:PinemeterTests/ChatGPTUsageServiceTests \
  -only-testing:PinemeterTests/UsageServiceTests
```

2. Static scan for stale/ambiguous copy after fixes:

```sh
rg -n "No session key|Session key is invalid|Update Session Key|Validating session key|Importing session key|Invalid session format|Session cookie cannot be empty" Pinemeter PinemeterTests README.md site
```

Expected: no unqualified Claude credential copy remains in Claude-specific user-facing paths, except compatibility/internal names explicitly documented.

3. Artifact coverage check:

```sh
python3 - <<'PY'
from pathlib import Path
p = Path('.gsd/milestones/M001/slices/S05/S05-ASSESSMENT.md')
text = p.read_text()
for needle in ['SetupWizardView.swift','SettingsView.swift','UsagePopoverView.swift','AppError.swift','NetworkService.swift','ChatGPTUsageService.swift','README.md','site/index.html','deferred']:
    assert needle in text, needle
PY
```

4. If diagnostics/logging are changed, add/verify a test or source scan that no log string includes `Cookie:`, `sessionKey=`, `Bearer`, `__Secure-next-auth`, or raw response-body dump paths.

## Risks and Constraints

- **Do not rename compatibility identifiers** (`com.claudemeter.sessionkey`, `~/.claudemeter`, app group) in S05. Those are migration-sensitive and already documented by S02/S03.
- **Do not redesign credentials**. M002 owns durable credential acquisition/storage/recovery.
- **Do not implement generic provider architecture**. M003 owns provider-aware workflow redesign; S04 says to use interface design before unifying provider services.
- **Keep UI state on `@MainActor @Observable` types**; services/repositories remain actor isolated.
- **Secrets policy:** do not create `.env` files or plaintext secret stores. S05 should not need secrets.
- **Provider terminology rule:** use provider-specific terms when the flow is provider-specific; use generic terms only when code truly covers multiple providers.

## Research Evidence

- `gsd_exec c1490b94-c40c-48b2-98be-8116380128fc` — broad provider/error/status/setup/recovery scan across Swift and public docs.
- `gsd_exec 6a4758ac-eb34-4169-85da-19a9909d76f5` — targeted provider/error string extraction.
- `gsd_exec f104f66f-e1f3-47f9-a367-74574720b757` — concise service/view string literal inventory.
- `gsd_exec 31d021e1-b4b1-4c60-939d-2437b83b8c88` — setup/settings/popover user-copy anchors.
- `gsd_exec 0a6e6e46-621b-4634-bc01-0f16b2774e5c` — `AppModel` provider flow summary.
- `gsd_exec 0be66d5e-3322-4e31-ab9d-b40ede6e5335` — docs/site provider setup copy scan.
- `gsd_exec 25a0fe6a-2163-41e1-8b84-9bef1eb0b489` — lingering product/compatibility identifier scan.
- `gsd_exec 355924bd-4e6f-43c3-aa41-01e9db8827bf` — existing provider/error/security test anchor scan.
