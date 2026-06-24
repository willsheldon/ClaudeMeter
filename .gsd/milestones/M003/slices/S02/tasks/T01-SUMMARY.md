---
id: T01
parent: S02
milestone: M003
key_files:
  - Pinemeter/App/AppModel.swift
  - Pinemeter/Services/SessionKeyImportService.swift
  - Pinemeter/Services/ChatGPTUsageService.swift
  - Pinemeter/Repositories/ChatGPTSessionRepository.swift
  - Pinemeter/Repositories/KeychainRepository.swift
key_decisions:
  - Treat T01 as an audit-only mapping task; defer source changes to later S02 tasks that implement the provider action API.
duration: 
verification_result: passed
completed_at: 2026-06-23T21:52:45.861Z
blocker_discovered: false
---

# T01: Mapped current Claude and ChatGPT recovery action entry points, target provider action API gaps, and safety risks for S02 follow-up implementation.

**Mapped current Claude and ChatGPT recovery action entry points, target provider action API gaps, and safety risks for S02 follow-up implementation.**

## What Happened

## Current Action Entry Points

### Shared provider-aware status surface
- `Pinemeter/App/AppModel.swift:6` defines `ProviderCredentialActionKind` with the current recovery verbs: `.reconnect`, `.repair`, and `.clear`.
- `Pinemeter/App/AppModel.swift:26` nests `AppProviderCredentialStatus.Action`, which gives setup/settings surfaces a sanitized display title without exposing credential material.
- `Pinemeter/App/AppModel.swift:137` publishes `providerCredentialStatuses`, producing one Claude status and one ChatGPT status from `claudeCredentialState` and `chatGPTCredentialState`.
- `Pinemeter/App/AppModel.swift:565` maps health state to current action availability: missing/unknown gets reconnect, valid/refreshRecommended gets reconnect and clear, invalid/expired/unavailable gets Claude reconnect/repair/clear and ChatGPT reconnect/clear.

### Claude recovery paths
- Refresh: `Pinemeter/App/AppModel.swift:240` gates Claude usage refresh on `isSetupComplete`, invokes `usageService.fetchUsage(forceRefresh:)`, and currently records only `errorMessage` on failure rather than updating `claudeCredentialState` into an invalid/expired/unavailable diagnostic state.
- Validate/save: `Pinemeter/App/AppModel.swift:390` validates format, validates against provider, fetches organizations, saves through `KeychainRepository`, updates setup state/settings, and forces usage refresh.
- Browser import: `Pinemeter/App/AppModel.swift:428` and `Pinemeter/App/AppModel.swift:432` import Claude session keys via `SessionKeyImportService`, then call `validateAndSaveSessionKey`.
- Provider-wide browser import: `Pinemeter/App/AppModel.swift:474` tries Claude first through `importAndSaveSessionKey(from:)`, then ChatGPT through `importAndSaveChatGPTSessionCookie(from:)`, returning per-provider status.
- Repair: `Pinemeter/App/AppModel.swift:508` sets Claude state to `.validating`, delegates to `SessionKeyImportService.repairSavedSessionKey(account:)`, updates `claudeCredentialState`, and refreshes usage only if the repaired state is usable.
- Clear: `Pinemeter/App/AppModel.swift:526` deletes the Claude default account via `KeychainRepository`, clears cached organization/setup state, resets Claude diagnostic state to missing, clears usage/error state, and cancels the refresh loop.
- Keychain repair boundary: `Pinemeter/Services/SessionKeyImportService.swift:112` retrieves the existing saved Claude key, re-validates the `SessionKey` format, then calls `KeychainRepository.repairClaudeSessionKey` without exposing raw credential material outside the service/repository boundary.
- Durable Keychain implementation: `Pinemeter/Repositories/KeychainRepository.swift:42` repairs using update-then-add under the legacy `com.claudemeter.sessionkey` service and selected account, avoiding broad deletes.

### ChatGPT recovery paths
- Refresh: `Pinemeter/App/AppModel.swift:272` validates the repository state if `hasChatGPTSessionCookie` is false, fetches ChatGPT usage, marks the credential valid on success, and maps missing/invalid session cookie failures into credential state; non-auth failures only set `chatGPTErrorMessage` and do not currently update `chatGPTCredentialState`.
- Validate/save manual cookie: `Pinemeter/App/AppModel.swift:333` trims the raw cookie, calls `chatGPTUsageService.validateSessionCookie`, saves only after validation succeeds, marks usage shown, and refreshes usage.
- Clear: `Pinemeter/App/AppModel.swift:364` clears only `ChatGPTUsageService.defaultSessionAccount`, disables ChatGPT usage display, clears ChatGPT usage/error data, and resets state to missing.
- Browser import: `Pinemeter/App/AppModel.swift:443` and `Pinemeter/App/AppModel.swift:447` import ChatGPT cookies via `SessionKeyImportService`, normalize with `ChatGPTUsageService.cookieHeader`, save via `ChatGPTSessionRepository`, mark state valid, and refresh usage.
- Session acquisition repository: `Pinemeter/Repositories/ChatGPTSessionRepository.swift:20` stores durable cookies in Keychain, transient access tokens only in actor memory, and sanitized acquisition status in UserDefaults.
- ChatGPT service validation/refresh: `Pinemeter/Services/ChatGPTUsageService.swift:42` loads from the repository, `Pinemeter/Services/ChatGPTUsageService.swift:62` clears repository state on missing/invalid session cookie failures, and `Pinemeter/Services/ChatGPTUsageService.swift:104` treats missing/invalid/401/403 validation failures as false while bubbling other network/response errors.

### View entry points and direct coupling to address next
- Setup: `Pinemeter/Views/Setup/SetupWizardView.swift:217` invokes provider-wide import, `Pinemeter/Views/Setup/SetupWizardView.swift:272` switches on action kinds locally, `Pinemeter/Views/Setup/SetupWizardView.swift:290` handles Claude repair locally, and `Pinemeter/Views/Setup/SetupWizardView.swift:320` clears credentials by switching on provider.
- Settings: `Pinemeter/Views/Settings/SettingsView.swift:629` invokes provider-wide import, `Pinemeter/Views/Settings/SettingsView.swift:690` imports Claude directly, `Pinemeter/Views/Settings/SettingsView.swift:742` repairs Claude directly, `Pinemeter/Views/Settings/SettingsView.swift:758` switches on action kinds locally, and `Pinemeter/Views/Settings/SettingsView.swift:791` imports ChatGPT directly.
- `Pinemeter/Views/MenuBar/UsagePopoverView.swift:30` and `Pinemeter/Views/MenuBar/UsagePopoverView.swift:67` refresh Claude and ChatGPT independently instead of going through a provider recovery/action API.

## Target Provider Action API

S02 should consolidate the view-triggered action routing behind AppModel/service boundaries rather than duplicating provider/action switches in views. A target shape is:

- `AppModel.performCredentialAction(_ kind: ProviderCredentialActionKind, for provider: CredentialProvider, source: BrowserImportSource = .defaultBrowser) async -> ProviderCredentialActionOutcome`.
- Outcomes should be sanitized and provider-aware, e.g. imported/repaired/refreshed/cleared/failed with optional `offersFullDiskAccessSettings` for browser import failures.
- The action router should centralize supported combinations:
  - Claude reconnect: browser import + validate/save + refresh.
  - Claude repair: existing saved key retrieve + format validation + Keychain update/add repair + refresh only when usable.
  - Claude clear: delete default account, clear cached organization/setup state, cancel or restart refresh loop safely.
  - Claude refresh: explicit refresh action or outcome path should update credential state on auth/storage failures.
  - ChatGPT reconnect: browser/manual import path + normalized cookie save + refresh.
  - ChatGPT clear: clear ChatGPT account only, clear transient usage and settings flag.
  - ChatGPT refresh: explicit refresh should update sanitized credential state for missing/invalid/network/storage categories.
- Views should render `providerCredentialStatuses` and dispatch selected actions to AppModel, not decide which AppModel primitive is safe for each provider.

## Safety Gaps

- Views duplicate action routing. Setup and Settings each maintain local `handleCredentialAction` switches, which can drift as new actions are added and currently embeds provider safety rules in UI files rather than AppModel.
- There is no single provider action API that validates action/provider combinations. Invalid combinations such as ChatGPT repair are prevented only by `credentialActions(for:)`, not by a central execution boundary.
- Claude `refreshUsage` catches provider/auth/storage failures as plain `errorMessage` and does not update `claudeCredentialState`; this weakens unattended diagnosis for expired/invalid/unavailable Claude credentials.
- ChatGPT `refreshChatGPTUsage` updates credential state for missing and invalid cookies, but other failures leave the previous credential state intact and only set `chatGPTErrorMessage`; network/storage categories are less explicit than the repository diagnostic model.
- `importAndSaveChatGPTSessionCookie(from:)` saves imported browser cookies before provider validation, relying on subsequent refresh to detect invalidity. This is acceptable for browser-import UX only if the action outcome clearly records a sanitized validation failure and downstream clear/reconnect options remain available.
- Clear operations are provider-safe today (`KeychainRepository.delete(account: "default")` versus `ChatGPTSessionRepository.clear(account: "chatgpt.com")`), but those invariants are scattered across AppModel and view-specific wrappers.

## Failure Modes

- Browser cookie import depends on local browser cookie stores, macOS privacy permissions, and browser Keychain decryption. `Pinemeter/Services/SessionKeyImportService.swift:22` and `Pinemeter/Services/SessionKeyImportService.swift:71` catch `BrowserCookieError.accessDenied`, `.notFound`, and `.loadFailed`, preserving provider-specific access-denied messages for Safari and Chromium Keychain-backed browsers.
- Claude validation/import depends on provider/network calls through `UsageService`. `Pinemeter/App/AppModel.swift:390` bubbles format, provider rejection, organization lookup, and network errors to callers; provider rejection updates `claudeCredentialState`, but network/storage failures are not yet categorized in state.
- ChatGPT validation/refresh depends on `chatgpt.com` HTTP APIs. `Pinemeter/Services/ChatGPTUsageService.swift:104` returns false for missing/invalid/401/403 and bubbles other failures; `Pinemeter/Services/ChatGPTUsageService.swift:202` maps malformed responses to `.invalidResponse` and transport failures to `.networkUnavailable`.
- Keychain operations can fail on save/update/read/delete. `Pinemeter/Repositories/KeychainRepository.swift:42` returns update/create repair results or throws specific `KeychainError`; `Pinemeter/Repositories/ChatGPTSessionRepository.swift:20` persists sanitized storage-unavailable categories for ChatGPT reads/writes/deletes.
- Refresh loop and wake observer invoke provider refreshes asynchronously at `Pinemeter/App/AppModel.swift:597` and `Pinemeter/App/AppModel.swift:638`; both guard against duplicate per-provider refresh flags, but central action routing should make retry/reconnect/clear outcomes explicit.

## Load Profile

This audit has no runtime load-bearing implementation. The relevant 10x pressure points for downstream work are bounded external operations rather than in-memory throughput:
- Browser import scans multiple browser stores sequentially in `SessionKeyImportService`; at 10x browser/source count the first saturation point is local filesystem/Keychain access and privacy prompts. Protection is sequential iteration and early return on the first usable credential.
- Usage refresh can be triggered by manual actions, refresh loop, and wake observer. The current protection is `isRefreshing` and `isRefreshingChatGPT` guards in `AppModel`, but a central provider action API should preserve these guards for explicit retry/reconnect flows.
- ChatGPT usage fetch makes two HTTP requests per validation/refresh (`/api/auth/session` then `/backend-api/wham/usage`); no retry storm exists today, but the action API should avoid parallel duplicate refreshes.

## Negative Tests

Existing negative coverage found during the audit:
- `PinemeterTests/AppModelTests.swift:284` verifies recovery actions are exposed for boundary credential states.
- `PinemeterTests/ProviderErrorWorkflowTests.swift:61` and `PinemeterTests/ProviderErrorWorkflowTests.swift:82` verify provider credential statuses expose sanitized reconnect/repair/clear combinations for invalid and storage-unavailable states.
- `PinemeterTests/ProviderErrorWorkflowTests.swift:116` verifies setup handles repair and clear actions without calling old direct validation functions.
- `PinemeterTests/ChatGPTAppModelTests.swift:46` verifies invalid ChatGPT cookie validation publishes sanitized provider rejection.
- `PinemeterTests/ChatGPTAppModelTests.swift:107` verifies ChatGPT refresh failure does not overwrite Claude usage or error.
- `PinemeterTests/ChatGPTAppModelTests.swift:134` verifies ChatGPT clear deletes only the ChatGPT account and hides usage.
- `PinemeterTests/ChatGPTSessionRepositoryTests.swift:65`, `PinemeterTests/ChatGPTSessionRepositoryTests.swift:77`, and `PinemeterTests/ChatGPTSessionRepositoryTests.swift:89` cover missing, invalid, and clear states for durable ChatGPT session storage.
- `PinemeterTests/ChatGPTUsageServiceTests.swift:176`, `PinemeterTests/ChatGPTUsageServiceTests.swift:196`, and `PinemeterTests/ChatGPTUsageServiceTests.swift:210` cover missing/invalid/expired ChatGPT session failure paths and repository clearing.
- `PinemeterTests/KeychainRepositoryTests.swift:27`, `PinemeterTests/KeychainRepositoryTests.swift:39`, and `PinemeterTests/KeychainRepositoryTests.swift:52` cover Claude repair create/update/account scoping.
- `PinemeterTests/SecurityInvariantTests.swift:188` through `PinemeterTests/SecurityInvariantTests.swift:224` cover sanitized error copy/categories for provider, network, and Keychain failures.

## Observability Impact

This audit maps the existing sanitized observability surfaces that S02 should preserve and extend:
- `CredentialState` via `providerCredentialStatuses` is the UI-safe status/action surface.
- `ChatGPTSessionRepository` persists sanitized acquisition state and error category in UserDefaults, separate from credential material.
- `SessionKeyImportService.repairSavedSessionKey` emits sanitized OSLog messages for Claude repair storage/unknown failures without logging secrets.
- The next implementation step should make recovery action outcomes durable enough for unattended diagnosis while continuing to exclude raw session keys, cookies, headers, and access tokens.

## Verification

Ran a repository-local diagnostic scan with `gsd_exec` to enumerate recovery action call sites, view coupling, and negative/error test coverage across AppModel, services, repositories, setup/settings views, and tests. The scan completed successfully and produced the cited file references used in the audit summary. No code changes were required for this audit-only task.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `gsd_exec: rg recovery action/import/clear call sites and negative/error tests in Pinemeter and PinemeterTests` | 0 | ✅ pass | 87ms |

## Deviations

No source edits were made because T01's verification contract is an audit summary listing action entry points, target API, and safety gaps with file references.

## Known Issues

Follow-up implementation should add a central AppModel provider action API, enforce provider/action compatibility at the execution boundary, and update credential diagnostic state for Claude auth/storage refresh failures and non-auth ChatGPT refresh failures.

## Files Created/Modified

- `Pinemeter/App/AppModel.swift`
- `Pinemeter/Services/SessionKeyImportService.swift`
- `Pinemeter/Services/ChatGPTUsageService.swift`
- `Pinemeter/Repositories/ChatGPTSessionRepository.swift`
- `Pinemeter/Repositories/KeychainRepository.swift`
