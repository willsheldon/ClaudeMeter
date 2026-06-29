---
id: T01
parent: S01
milestone: M004
key_files:
  - Pinemeter/Models/CredentialState.swift
  - Pinemeter/Models/UsageData.swift
  - Pinemeter/Models/AppSettings.swift
  - Pinemeter/App/AppModel.swift
  - PinemeterTests/ChatGPTAppModelTests.swift
  - PinemeterTests/ProviderErrorWorkflowTests.swift
  - PinemeterTests/TestDoubles/UsageServiceStub.swift
key_decisions:
  - Treat `CredentialProvider` as the existing sanitized identity seed, but do not assume adding `.gemini` alone is sufficient because AppModel and tests are still provider-specific.
duration: 
verification_result: passed
completed_at: 2026-06-24T20:08:15.864Z
blocker_discovered: false
---

# T01: Mapped the current Claude and ChatGPT provider seams that Gemini must neutralize before implementation.

**Mapped the current Claude and ChatGPT provider seams that Gemini must neutralize before implementation.**

## What Happened

Audited the existing provider model and found that `CredentialProvider` in `Pinemeter/Models/CredentialState.swift` is already the central sanitized identity enum, with provider-neutral `CredentialIdentity`, `CredentialHealthState`, and `CredentialFailureCategory` categories suitable for Gemini diagnostics. The extension risk is that downstream behavior is not yet provider-neutral: `Pinemeter/App/AppModel.swift` stores separate `usageData` and `chatGPTUsageData`, separate refreshing flags and error strings, separate Claude and ChatGPT credential states, two usage service protocols, hard-coded provider status ordering, hard-coded dashboard copy for Claude and ChatGPT, provider-specific refresh loop branches, and provider-specific credential actions.

`Pinemeter/Models/UsageData.swift` remains Claude-shaped with session, weekly, and Sonnet limits, while ChatGPT already uses a separate `ChatGPTUsageData` domain model. Gemini will likely need either a third usage data type plus provider-aware rendering, or a provider-neutral usage-card contract above the provider-specific domain models. `Pinemeter/Models/AppSettings.swift` has a single user-facing ChatGPT visibility key (`show_chatgpt_usage`) plus Claude/Sonnet settings; adding Gemini should follow the safe decode pattern for old settings and be persisted through `SettingsRepository` and surfaced in `SettingsView` when user-facing.

Test fixture seams are available but currently provider-specific: Claude tests use `UsageServiceStub` in `PinemeterTests/TestDoubles/UsageServiceStub.swift`, while ChatGPT tests define local `ChatGPTUsageServiceStub` and `ChatGPTSessionRepositoryFake` in `PinemeterTests/ChatGPTAppModelTests.swift`. Existing negative tests in `PinemeterTests/ProviderErrorWorkflowTests.swift` already protect sanitized credential copy and raw credential redaction for provider credential workflows.

## Failure Modes
- Keychain and credential storage failures already flow through sanitized `CredentialFailureCategory.storageUnavailable` and are tested by `ChatGPTAppModelTests.test_bootstrap_withChatGPTStorageUnavailablePublishesSanitizedStatus`; Gemini should map any credential repository failures to the same category instead of exposing raw storage errors.
- Provider rejection and malformed credential states should map to `.providerRejected` or `.invalidFormat`; ChatGPT invalid-cookie tests show the intended pattern without saving invalid credentials.
- Network/provider outages should map to sanitized provider usage errors and avoid overwriting other providers' usage state; `test_refreshChatGPTUsage_failureDoesNotOverwriteClaudeUsageOrError` demonstrates the existing separate-state failure path.
- Browser import failures currently bubble as `SessionKeyImportError` through provider-specific import branches in `AppModel.importProviderSessions`; Gemini browser import will need an additional provider outcome or a provider-indexed outcome to avoid expanding hard-coded tuple-like results.

## Load Profile
- Runtime load is bounded by provider count and refresh cadence. At 10x providers, `AppModel.startRefreshLoop`, `startWakeObserver`, `refreshConfiguredUsageProviders`, and `providerCredentialStatuses` would saturate first because each provider is branched manually and refreshes serially from one task.
- No load protection was added in this audit-only task. The mapped mitigation for Gemini is a provider-registered refresh/status contract that can enforce per-provider throttling, cancellation, and visibility checks instead of adding more `if provider` branches.

## Negative Tests
- Credential copy must not expose raw credential material: `ProviderErrorWorkflowTests.test_chatGPTUsageErrorsDoNotEchoCookieOrBearerTokenSentinels`, `test_credentialRecoverySetupCopyDoesNotExposeRawCredentialMaterial`, and `test_clearCredentialWorkflowCopyIsProviderSpecificAndCredentialFree` cover current sanitized negative surfaces.
- Invalid credential input must not persist: `ChatGPTAppModelTests.test_validateAndSaveChatGPTSessionCookie_withInvalidCookieDoesNotSave` covers the ChatGPT pattern Gemini should mirror.
- Provider-specific credential recovery must not accidentally trigger another provider's flow: `ProviderErrorWorkflowTests.test_claudeRecoveryCopy_detectsOnlyClaudeCredentialAuthenticationMessages` documents the current Claude-specific recovery guard.

## Verification

Ran gsd_exec inventory and verification diagnostics. The final corrected verification confirmed the required source files exist and that provider identity, AppModel hard-coded seams, separate usage protocols, ChatGPT settings persistence, negative sanitized tests, and Claude/ChatGPT fixture seams were all located. The first verification attempt failed only because the script used incorrect test-name substrings; it was corrected after inspecting the available source context.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `gsd_exec python provider audit verification (initial script)` | 1 | ❌ fail - assertion used incorrect negative-test substrings; source seams passed before the name mismatch | 106ms |
| 2 | `gsd_exec python provider audit verification corrected` | 0 | ✅ pass - source seams, fixture seams, and negative-test coverage located | 92ms |

## Deviations

No source files were modified. The task was an audit/mapping task, and its expected output is captured in this task summary rather than code changes.

## Known Issues

Gemini implementation remains blocked on future tasks neutralizing AppModel's provider-specific state and refresh/action branches. `CredentialStatusService` iterates `CredentialProvider.allCases`, so adding a Gemini enum case before its credential identity and keychain account mapping exist would affect status reporting immediately.

## Files Created/Modified

- `Pinemeter/Models/CredentialState.swift`
- `Pinemeter/Models/UsageData.swift`
- `Pinemeter/Models/AppSettings.swift`
- `Pinemeter/App/AppModel.swift`
- `PinemeterTests/ChatGPTAppModelTests.swift`
- `PinemeterTests/ProviderErrorWorkflowTests.swift`
- `PinemeterTests/TestDoubles/UsageServiceStub.swift`
