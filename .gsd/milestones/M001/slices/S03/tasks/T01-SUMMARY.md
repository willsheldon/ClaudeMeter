---
id: T01
parent: S03
milestone: M001
key_files:
  - PinemeterTests/SecurityInvariantTests.swift
key_decisions:
  - Treat the S02 discrepancy as a narrowed finding: AppSettings/UserDefaults persistence is currently preference-only, while credential risk remains in transient UI/app state and Keychain/session handling rather than SettingsRepository.
duration: 
verification_result: mixed
completed_at: 2026-06-17T02:56:55.259Z
blocker_discovered: false
---

# T01: Added a security invariant test proving AppSettings UserDefaults persistence remains credential-free.

**Added a security invariant test proving AppSettings UserDefaults persistence remains credential-free.**

## What Happened

Inspected AppSettings, SettingsRepository, SettingsView, AppModel, SettingsRepositoryTests, and the S02 assessment context to reconcile the persistence discrepancy. AppSettings currently defines preference-only Codable fields (refresh interval, notification settings, cached org ID, usage visibility flags, icon settings), and SettingsRepository persists only encoded AppSettings under the UserDefaults key app_settings. SettingsView/AppModel contain credential-related UI/app state such as sessionKey and ChatGPT cookie handling, but those values are not part of AppSettings and are not saved through SettingsRepository. Added PinemeterTests/SecurityInvariantTests.swift to save representative AppSettings through the real SettingsRepository/UserDefaults path, decode the raw persisted JSON payload as UTF-8, and assert it contains neither credential-bearing field names nor synthetic secret-shaped fragments: sessionKey, chatGPTSessionCookie, accessToken, __Secure-next-auth, Cookie, Bearer, and sk-ant-. The reconciliation conclusion for later S03 assessment is: UserDefaults settings persistence risk is currently low and preference-only; transient UI state risk remains present for SettingsView/AppModel credential handling; S02 should be corrected or narrowed if it claimed raw Claude/ChatGPT credential material is rehydrated from AppSettings/UserDefaults rather than transient state or Keychain-backed flows.

## Failure Modes
- Filesystem/UserDefaults dependency: the test creates an isolated UserDefaults suite and fails via XCTUnwrap if the suite or app_settings data is unavailable, making persistence-path breakage explicit.
- Encoding dependency: SettingsRepository.save is async throws; the test uses try await so encoding failures bubble to XCTest instead of being hidden.
- Malformed/non-UTF8 payload dependency: the test fails via XCTUnwrap if the saved settings payload cannot be inspected as UTF-8 JSON.

## Load Profile


## Negative Tests
- PinemeterTests/SecurityInvariantTests.swift::test_appSettingsPersistenceDoesNotEncodeCredentialMaterial asserts credential/session field names and secret-shaped sentinel fragments are absent from the persisted AppSettings payload.
- The test covers accidental future Codable expansion into credential material by inspecting the raw saved payload, not just a decoded AppSettings value.

## Observability Impact
- Added an executable regression guard for the redaction/persistence invariant without printing credential values; verification evidence is available through the recorded gsd_exec runs.

## Verification

Ran the targeted XCTest command from the task plan. The first run failed at compile time because SettingsRepository.save is async throws and the new test used await without try. After changing the call to try await, the targeted xcodebuild test passed. A diagnostic source scan also confirmed the persistence/UI-state split for reconciliation notes.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests` | 65 | ❌ fail: initial compile failure, save call needed try await | 8891ms |
| 2 | `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests` | 0 | ✅ pass | 6704ms |
| 3 | `python3 source scan for credential/settings terms in AppSettings, SettingsRepository, SettingsView, AppModel` | 0 | ✅ pass: reconciliation evidence collected | 78ms |

## Deviations

None.

## Known Issues

The test proves AppSettings/UserDefaults persistence is credential-free, but it does not redesign or eliminate transient credential UI/app state; that remains assessment/follow-up work for later S03 tasks and downstream credential redesign.

## Files Created/Modified

- `PinemeterTests/SecurityInvariantTests.swift`
