# S02 Research: Credential surface inventory

## Summary

S02 should inventory, not redesign, credential/session handling. M001 memory confirms durable app-owned credential acquisition belongs to M002; this slice should map current acquisition, storage, reuse, display, logging, clearing, recovery, and migration-sensitive identifiers with enough precision that S03 security review and M002 auth work do not rediscover the same surfaces.

S01 renamed the app to Pinemeter but intentionally retained compatibility-sensitive runtime identifiers:

- Keychain service: `com.claudemeter.sessionkey`.
- Keychain access group in `Pinemeter/Resources/Pinemeter.entitlements`: `$(AppIdentifierPrefix)com.claudemeter`.
- Cache/export paths in `Pinemeter/Repositories/CacheRepository.swift`: `com.claudemeter` Application Support directory and `~/.claudemeter/usage.json`.

Primary files to inspect/record:

- `Pinemeter/App/AppModel.swift` — orchestrates credential load/save/clear/reuse state.
- `Pinemeter/Repositories/KeychainRepository.swift` — stores/retrieves/deletes all current credential material.
- `Pinemeter/Services/SessionKeyImportService.swift` — imports Claude session key from local browser cookies.
- `Pinemeter/App/SessionKeyImportPromptCoordinator.swift` — pre-prompts before browser Safe Storage Keychain access.
- `Pinemeter/Views/Setup/SetupWizardView.swift` — first-launch Claude session input/import UI.
- `Pinemeter/Views/Settings/SettingsView.swift` — Claude session, ChatGPT cookie input, display, validation, and clearing UI.
- `Pinemeter/Services/UsageService.swift` and `Pinemeter/Services/NetworkService.swift` — Claude session reuse in API calls.
- `Pinemeter/Services/ChatGPTUsageService.swift` — ChatGPT cookie reuse, token derivation, and quota API calls.
- Tests/fakes under `PinemeterTests/` — test doubles can expose expected account names and storage semantics.

## Credential surface map

### Claude session key

**Acquisition**

- Manual paste in setup/settings:
  - `Pinemeter/Views/Setup/SetupWizardView.swift` accepts user input in setup.
  - `Pinemeter/Views/Settings/SettingsView.swift` stores local `sessionKey` UI state, saves via `validateAndSaveSessionKey()`.
- Browser import:
  - `Pinemeter/Services/SessionKeyImportService.swift` queries browser cookies for domain suffix `claude.ai`, cookie name `sessionKey`, using SweetCookieKit.
  - `Pinemeter/App/SessionKeyImportPromptCoordinator.swift` explains Pinemeter will ask macOS Keychain to decrypt browser session cookies.
  - Imported value is normalized through `SessionKey(cookie.value)`.

**Validation before storage**

- `AppModel.validateAndSaveSessionKey(_:)` constructs `SessionKey`, calls `usageService.validateSessionKey(sessionKey)`, then `usageService.fetchOrganizations(sessionKey:)` and requires an organization UUID.
- `SessionKey` performs local format/validation normalization and returns provider-specific validation errors.

**Storage**

- `KeychainRepository.save(sessionKey:account:)` stores UTF-8 data under `kSecClassGenericPassword` with:
  - `kSecAttrAccount = "default"` for Claude.
  - `kSecAttrService = "com.claudemeter.sessionkey"` retained for compatibility.
  - `kSecAttrAccessible = kSecAttrAccessibleAfterFirstUnlock`.
  - `kSecAttrSynchronizable = false`.
- `AppSettings.cachedOrganizationId` persists the organization UUID in UserDefaults via `SettingsRepository`; the Claude session key itself is not in `AppSettings`.

**Reuse**

- `AppModel.refreshUsage()` calls `usageService.fetchUsage(forceRefresh:)`.
- `UsageService` retrieves session key from Keychain and passes it to `NetworkService`.
- `NetworkService.request(... sessionKey:)` sends the Claude key as `Cookie: sessionKey=<value>` to `https://claude.ai/api` endpoints.

**Display/UI exposure**

- `SettingsView.loadSettings()` calls `appModel.loadSessionKey()` and assigns the full saved Claude session key back into local `sessionKey` UI state. The field is likely secure in UI, but this is still an in-memory display/edit surface.
- Status labels show only configured/saved state, not the key value.
- Setup/settings validation messages include error descriptions, not key values.

**Clearing**

- `AppModel.clearSessionKey()` deletes Keychain account `default`, clears cached org ID, resets setup flags and usage data, clears `errorMessage`, and cancels refresh task.
- `SettingsView.clearSessionKey()` clears local `sessionKey` UI state and validation messages after calling the app model.

**Recovery/failure**

- Missing/invalid session key surfaces through `AppError.noSessionKey`, `SessionKeyError`, `SessionKeyImportError`, and `NetworkError` paths.
- Browser import distinguishes access denied, Safari access denied, browser Keychain access denied with browser name, no session found, and invalid imported key.

### ChatGPT session cookie

**Acquisition**

- `SettingsView` collects either:
  - split `__Secure-next-auth.session-token.0` and `.1` values,
  - a full Cookie header,
  - or a raw unsplit token.
- `combinedChatGPTCookieInput` and `ChatGPTUsageService.cookieHeader(from:)` normalize the input.

**Validation before storage**

- `AppModel.validateAndSaveChatGPTSessionCookie(_:)` trims input, calls `chatGPTUsageService.validateSessionCookie(trimmedCookie)`, then saves only if valid.
- `ChatGPTUsageService.fetchUsage(sessionCookie:)` first requests `/api/auth/session` with cookie header and requires an access token before quota request.

**Storage**

- Same `KeychainRepository` and service name, with `account = "chatgpt"`.
- Stored value is the raw trimmed cookie input, which may be a raw token, split cookie string, or full Cookie header depending on user input.
- `AppSettings.isChatGPTUsageShown` persists a display preference; it does not store the cookie.

**Reuse**

- `AppModel.refreshChatGPTUsage()` retrieves Keychain account `chatgpt` and passes it to `ChatGPTUsageService.fetchUsage(sessionCookie:)`.
- `ChatGPTUsageService.cookieHeader(from:)` builds a Cookie header.
- `ChatGPTUsageService` derives an access token from `/api/auth/session` response and uses it for the usage/quota request. The access token appears to remain in memory only for the async call.

**Display/UI exposure**

- `SettingsView.loadSettings()` calls `appModel.loadChatGPTSessionCookie()` and assigns the saved cookie into `chatGPTSessionTokenPart0`. This can display/re-hydrate the entire saved cookie/token into a UI field for editing.
- The UI uses specific cookie labels and helper copy. Validation messages do not include cookie values.

**Clearing**

- `AppModel.clearChatGPTSessionCookie()` deletes Keychain account `chatgpt`, clears `hasChatGPTSessionCookie`, `chatGPTUsageData`, and `chatGPTErrorMessage`.
- `SettingsView.clearChatGPTSessionCookie()` also clears local token/header state and validation message.

**Recovery/failure**

- `ChatGPTUsageError` distinguishes missing cookie, invalid cookie, invalid response, HTTP error, and network unavailable. User-visible copy tells the user to update the session in Settings.

## Logging and secret exposure notes

- `NetworkService`, `UsageService`, `SessionKeyImportService`, and `WebViewNetworkService` use `Logger(subsystem: "com.pinemeter", ...)` after S01.
- Initial scan did not find obvious direct logging/printing of session key, cookie header, access token, or raw credential values.
- `SessionKeyImportService` returns `sourceDescription` from browser store labels; this is not a secret but should be treated as user environment metadata.
- Biggest current exposure surface is not logging; it is UI/local-state rehydration of full saved Claude and ChatGPT credentials into settings fields.

## Natural seams for S02 tasks

1. **Keychain/storage inventory task**
   - Files: `KeychainRepository.swift`, `KeychainRepositoryProtocol.swift`, `AppModel.swift`, `SettingsRepository.swift`, `AppSettings.swift`.
   - Output: account names, service/access-group, accessibility class, synchronizable flag, settings/UserDefaults fields, delete semantics.

2. **Claude acquisition/reuse inventory task**
   - Files: `SetupWizardView.swift`, `SettingsView.swift`, `SessionKeyImportService.swift`, `SessionKeyImportPromptCoordinator.swift`, `SessionKey.swift`, `UsageService.swift`, `NetworkService.swift`.
   - Output: manual paste, browser import, validation, organization selection, Cookie header reuse, clearing, recovery/error map.

3. **ChatGPT acquisition/reuse inventory task**
   - Files: `SettingsView.swift`, `ChatGPTUsageService.swift`, `AppModel.swift`, related tests.
   - Output: split cookie/full header/raw token handling, validation, Keychain account, auth-session access token derivation, quota request, clearing, recovery/error map.

4. **Exposure/logging/display inventory task**
   - Files: `SettingsView.swift`, setup view, services, tests/fakes.
   - Output: where values can be displayed, held in state, logged, included in errors, exported, or copied into test doubles.

5. **Final inventory artifact task**
   - Produce `S02-ASSESSMENT.md` or `S02-SUMMARY.md` with a table covering acquisition, storage, reuse, display, logging, clearing, and recovery for Claude and ChatGPT.
   - Explicitly include S01 retained identifiers as compatibility surfaces.

## First proof

The highest-value first proof is a table of current Keychain accounts and consumers:

| Account | Material | Writer | Readers | Clearer | Notes |
|---|---|---|---|---|---|
| `default` | Claude `sessionKey` | `AppModel.validateAndSaveSessionKey` | `AppModel.loadSessionKey`, `UsageService` via Keychain | `AppModel.clearSessionKey` | Service `com.claudemeter.sessionkey`; org UUID separately cached in settings. |
| `chatgpt` | ChatGPT session cookie/token/header | `AppModel.validateAndSaveChatGPTSessionCookie` | `AppModel.loadChatGPTSessionCookie`, `AppModel.refreshChatGPTUsage` | `AppModel.clearChatGPTSessionCookie` | Same service; saved value shape depends on user input. |

## Verification suggestions

S02 is mostly artifact/inventory work, but should verify with source scans:

```bash
rg -n 'save\(sessionKey|retrieve\(account|delete\(account|exists\(account' Pinemeter PinemeterTests
rg -n 'sessionKey|chatGPTSessionCookie|sessionCookie|cookieHeader|accessToken|Cookie' Pinemeter PinemeterTests
rg -n 'logger\.|print\(|debugPrint|NSLog|localizedDescription' Pinemeter PinemeterTests
```

If inventory work changes no code, verification is a complete artifact with file:line references and scans. If any safe copy fixes are made, rerun:

```bash
xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug
```

## Sources / evidence

- `gsd_exec 00175010-509a-4de7-8109-d8ad9e0d2c1a`: broad credential/session keyword scan.
- `gsd_exec e9569980-dff6-4064-ace5-3b650f1b5761`: AppModel credential method scan.
- `gsd_exec 05f3a367-52f6-46ce-9b59-7b843823c1e1`: Setup/Settings credential UI scan.
- `gsd_exec 5eb681e2-c090-4dc7-b347-74f5ab11afe0`: exact ChatGPT settings input/save/clear lines.
- `gsd_exec dcfe3be7-6489-4752-bbcf-ac50222d5ebd`: logging/display risk scan.
- S01 assessment: `.gsd/milestones/M001/slices/S01/S01-ASSESSMENT.md` for retained compatibility identifiers.
