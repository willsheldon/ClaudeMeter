---
id: T02
parent: S06
milestone: M001
key_files:
  - Pinemeter/Repositories/KeychainRepository.swift
  - Pinemeter/Resources/Pinemeter.entitlements
  - PinemeterTests/SecurityInvariantTests.swift
  - Pinemeter/Repositories/CacheRepository.swift
key_decisions:
  - Source-level tests intentionally read tracked files and assert both exact legacy identifiers and explanatory compatibility language.
duration: 
verification_result: passed
completed_at: 2026-06-17T16:09:36.045Z
blocker_discovered: false
---

# T02: Guarded legacy ClaudeMeter credential identifiers with source comments and executable source-level invariants.

**Guarded legacy ClaudeMeter credential identifiers with source comments and executable source-level invariants.**

## What Happened

Added concise compatibility comments next to the Keychain service identifier and keychain access group explaining that the legacy ClaudeMeter values are intentional credential compatibility surfaces deferred to M002 migration work. Extended SecurityInvariantTests with source-file invariants that assert the exact legacy service and access-group strings remain present and documented with compatibility language. During verification, the test target initially failed to compile on an unrelated CacheRepository test helper visibility issue; the production initializer was made explicitly internal so the existing @testable test helper remains visible without changing runtime behavior.

## Verification

Ran `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests`; final run succeeded with exit code 0.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests` | 0 | ✅ pass | 9051ms |

## Deviations

Made the existing CacheRepository test-support initializer explicitly internal to unblock compilation of the test target; no credential behavior changed.

## Known Issues

None.

## Files Created/Modified

- `Pinemeter/Repositories/KeychainRepository.swift`
- `Pinemeter/Resources/Pinemeter.entitlements`
- `PinemeterTests/SecurityInvariantTests.swift`
- `Pinemeter/Repositories/CacheRepository.swift`
