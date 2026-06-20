---
id: T03
parent: S01
milestone: M002
key_files:
  - PinemeterTests/SecurityInvariantTests.swift
  - PinemeterTests/SettingsRepositoryTests.swift
key_decisions:
  - (none)
duration: 
verification_result: passed
completed_at: 2026-06-18T20:59:46.136Z
blocker_discovered: false
---

# T03: Added regression tests that keep AppSettings and SettingsRepository free of credential state and credential material persistence.

**Added regression tests that keep AppSettings and SettingsRepository free of credential state and credential material persistence.**

## What Happened

Extended `SecurityInvariantTests` with AppSettings Codable/source invariants that reject credential-state boundary fields, session key/cookie/token names, bearer/cookie sentinels, and credential-shaped values in persisted settings payloads. Added `SettingsRepositoryTests.test_loadingLegacyPayloadWithCredentialShapedKeysDropsCredentialMaterialOnSave` to prove legacy or poisoned settings JSON can decode through `AppSettings` and re-save without preserving credential-shaped unknown keys or values.

### Failure Modes
- UserDefaults filesystem-backed persistence: tests use isolated suites and assert the encoded `app_settings` payload contains no credential material after save.
- Malformed or poisoned legacy payload shape: `SettingsRepository` decodes through `AppSettings`; unknown credential-shaped JSON keys are ignored by Codable and dropped on re-save.
- Source coupling regression: `SecurityInvariantTests.test_settingsRepositoryDoesNotReferenceCredentialStateOrCredentialMaterial` reads `Pinemeter/Repositories/SettingsRepository.swift` and fails if credential status service/model or secret-shaped names are introduced into the repository.

### Load Profile

### Negative Tests
- Credential-shaped persistence fragments are denied in `PinemeterTests/SecurityInvariantTests.swift` via `assertNoCredentialPersistenceFragments`.
- Credential-state boundary keys such as `credential_state`, `credential_status`, `session_key`, `session_cookie`, and `access_token` are denied in encoded `AppSettings`.
- Poisoned legacy settings containing `sk-ant-*`, `__Secure-next-auth*`, and `Bearer *` values are loaded and re-saved in `PinemeterTests/SettingsRepositoryTests.swift`; assertions verify those fragments are removed from the resulting payload.

## Verification

Ran the task-plan focused test command. The first post-test-edit run failed as expected during the TDD red step because the new helper was missing. After adding the helper and the repository regression test, the focused `SecurityInvariantTests` and `SettingsRepositoryTests` command passed with exit code 0.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests -only-testing:PinemeterTests/SettingsRepositoryTests` | 0 | ✅ pass | 6672ms |

## Deviations

None.

## Known Issues

None.

## Files Created/Modified

- `PinemeterTests/SecurityInvariantTests.swift`
- `PinemeterTests/SettingsRepositoryTests.swift`
