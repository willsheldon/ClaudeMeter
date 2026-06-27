---
id: T03
parent: S02
milestone: M004
key_files:
  - Pinemeter/App/AppModel.swift
  - PinemeterTests/AppModelTests.swift
key_decisions:
  - Stored Gemini API-key availability is the AppModel Gemini usage configuration signal; raw key material remains behind GeminiAPIKeyRepository/GeminiUsageService.
duration: 
verification_result: passed
completed_at: 2026-06-24T20:46:37.150Z
blocker_discovered: false
---

# T03: Integrated Gemini API-key backed usage state into AppModel refresh, credential status, and clear/reconnect surfaces with focused AppModel coverage.

**Integrated Gemini API-key backed usage state into AppModel refresh, credential status, and clear/reconnect surfaces with focused AppModel coverage.**

## What Happened

Wired Gemini dependencies into `AppModel` by injecting `GeminiAPIKeyRepositoryProtocol` and `GeminiUsageServiceProtocol`, defaulting production initialization to `GeminiAPIKeyRepository` plus `GeminiUsageService`. Added Gemini runtime state (`geminiUsageData`, `isRefreshingGemini`, `geminiErrorMessage`, `hasGeminiAPIKey`) and made stored API-key availability the AppModel configuration signal without adding any AppSettings persistence for raw key material or Gemini status.

Bootstrap now validates the Gemini API-key repository, maps sanitized acquisition status into `CredentialState`, refreshes Gemini usage when a saved key exists, and starts periodic/wake refresh loops when any provider is configured. `refreshConfiguredUsageProviders` now refreshes Gemini alongside Claude and visible ChatGPT. Added AppModel Gemini credential lifecycle helpers to load, validate/save, refresh, and clear the API key through repository/service boundaries, plus clear support through `performProviderCredentialAction` while leaving reconnect/repair unsupported until a user-facing Gemini entry flow is added.

Updated `AppModelTests` to cover Gemini-aware provider menu text, configured provider refresh orchestration, missing-key refresh failure behavior, and a full Gemini credential lifecycle including invalid validation rejection, save/refresh, bootstrap reuse, clear, and reacquire. Added test-only Gemini usage service and API key repository fakes.

## Failure Modes
- Gemini credential storage failure: AppModel consumes only `GeminiAPIKeyAcquisitionStatus` from the repository and maps unavailable storage to sanitized `CredentialState` via `credentialState(from:checkedAt:)`; raw key material is not surfaced.
- Missing Gemini API key: `refreshGeminiUsage()` validates repository state, clears `hasGeminiAPIKey`, nils usage data, and sets missing credential state. Covered by `test_refreshConfiguredUsageProviders_missingGeminiAPIKeyRemovesProviderFromMenuState`.
- Invalid Gemini API key: `validateAndSaveGeminiAPIKey` returns false without saving, and `refreshGeminiUsage` maps service invalid-key errors to `.invalid` plus `.providerRejected`. Covered by `test_geminiCredentialLifecycle_recoversFromInvalidClearAndReacquire`.
- Network/API failures: Gemini service errors remain sanitized `GeminiUsageError` descriptions; AppModel stores only `geminiErrorMessage`/credential category, and `SecurityInvariantTests` verifies user-facing Gemini errors do not disclose credential-shaped fragments.

## Load Profile
- Expected load is a menu-bar refresh loop per configured provider. At 10x shorter intervals or multiple wake events, external provider calls are the first resource to saturate. AppModel protects against overlapping Gemini fetches with `isRefreshingGemini` and uses the same central refresh loop/wake observer pattern as Claude and ChatGPT rather than spawning independent loops per provider.

## Negative Tests
- Missing Gemini API key during refresh removes Gemini from configured provider menu state: `PinemeterTests/AppModelTests.swift` `test_refreshConfiguredUsageProviders_missingGeminiAPIKeyRemovesProviderFromMenuState`.
- Invalid Gemini API key validation does not persist key material and marks provider rejected: `PinemeterTests/AppModelTests.swift` `test_geminiCredentialLifecycle_recoversFromInvalidClearAndReacquire`.
- Sanitized Gemini error descriptions and AppSettings separation remain enforced: `PinemeterTests/SecurityInvariantTests.swift` Gemini acquisition and user-facing error tests.
- Existing ChatGPT and Claude provider tests continue to run under the focused AppModel suite, guarding regressions to prior providers.

## Observability Impact
AppModel now exposes Gemini usage/refresh/error state and sanitized Gemini credential state through the same observable surface used by Claude and ChatGPT.

## Verification

Ran the required focused verification command for AppModel and security invariants. The command exited 0 and included passing AppModel/SecurityInvariant tests, including Gemini security invariant cases.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/SecurityInvariantTests` | 0 | ✅ pass | 13254ms |

## Deviations

No AppSettings Gemini toggle was added; AppModel treats a stored Gemini API key as the Gemini usage configuration signal to preserve the credential boundary established by prior tasks.

## Known Issues

Gemini reconnect/repair actions remain unsupported in AppModel because this task did not include a user-facing Gemini API key entry flow; clear is wired for existing saved credentials.

## Files Created/Modified

- `Pinemeter/App/AppModel.swift`
- `PinemeterTests/AppModelTests.swift`
