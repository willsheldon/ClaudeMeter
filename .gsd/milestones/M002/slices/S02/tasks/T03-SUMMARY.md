---
id: T03
parent: S02
milestone: M002
key_files:
  - PinemeterTests/SecurityInvariantTests.swift
  - .gsd/KNOWLEDGE.md
key_decisions:
  - Captured the Claude prompt regression as source-level security invariants rather than mutating real user Keychain state in tests.
  - Documented that repair preserves the legacy ClaudeMeter service identifier while relying on the official Autimo signed app identity and entitlements for access scope.
duration: 
verification_result: passed
completed_at: 2026-06-18T21:32:56.731Z
blocker_discovered: false
---

# T03: Added SecurityInvariantTests coverage and durable knowledge for the Claude Keychain prompt repair path under the official Autimo signed app identity.

**Added SecurityInvariantTests coverage and durable knowledge for the Claude Keychain prompt repair path under the official Autimo signed app identity.**

## What Happened

Extended `PinemeterTests/SecurityInvariantTests.swift` with regression invariants that verify signed Pinemeter builds use the official Autimo Developer ID identity and team identifier, reject ad-hoc signing as the project default, and ensure `repairClaudeSessionKey` keeps the legacy Keychain service identifier without hard-coded access-group rewrites or broad `SecItemDelete` repair behavior. Appended `.gsd/KNOWLEDGE.md` with the durable lesson for future agents: ad-hoc-saved Claude credentials should be repaired by re-saving under the official Autimo identity while preserving `com.claudemeter.sessionkey`.

## Failure Modes

- Filesystem/source fixture dependency: the tests read `Pinemeter.xcodeproj/project.pbxproj` and `Pinemeter/Repositories/KeychainRepository.swift` through the existing `sourceContents(relativePath:)` helper. Missing or unreadable files throw through XCTest and fail the regression suite.
- Signing configuration dependency: if the project drifts away from manual Autimo Developer ID signing, uses another team, or defaults to ad-hoc `CODE_SIGN_IDENTITY = "-"`, the new signing invariant fails with a targeted assertion message.
- Keychain repair source dependency: if repair stops using `serviceName`, hard-codes `kSecAttrAccessGroup`, or introduces `SecItemDelete` in the repair body, the new repair invariant fails with a targeted assertion message.
- Subprocess dependency: `xcodebuild test` failure bubbles through the verification command exit code and logs; no secret values are emitted by these source-level invariants.

## Load Profile

## Negative Tests

- `test_signedPinemeterBuildsUseOfficialAutimoIdentityForClaudeKeychainRepair` negatively asserts that ad-hoc signing (`CODE_SIGN_IDENTITY = "-"`) is not the project default for Claude repair coverage.
- `test_claudeSessionRepairKeepsLegacyServiceIdentifierAndAvoidsAccessGroupRewrite` negatively asserts the repair path does not hard-code `kSecAttrAccessGroup` and does not call `SecItemDelete` in the repair body.
- Existing SecurityInvariantTests continue to guard credential disclosure and persistence boundaries while the new cases protect the signing/Keychain prompt regression path.

## Verification

Ran the authoritative targeted verification command via `gsd_exec`: `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests`. The command exited 0 and emitted `T03_SECURITY_INVARIANTS_PASS`.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests` | 0 | ✅ pass | 8382ms |

## Deviations

None.

## Known Issues

None.

## Files Created/Modified

- `PinemeterTests/SecurityInvariantTests.swift`
- `.gsd/KNOWLEDGE.md`
