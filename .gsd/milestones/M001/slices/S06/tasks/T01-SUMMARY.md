---
id: T01
parent: S06
milestone: M001
key_files:
  - Pinemeter/Repositories/CacheRepository.swift
  - PinemeterTests/CacheRepositoryTests.swift
key_decisions:
  - Kept legacy public export writes for milestone compatibility while moving primary public export to ~/.pinemeter/usage.json.
  - Migrated legacy private cache lazily on getLastKnown only when the new private cache is absent.
duration: 
verification_result: passed
completed_at: 2026-06-17T16:07:56.405Z
blocker_discovered: false
---

# T01: CacheRepository now writes Pinemeter-owned cache/export paths while preserving ClaudeMeter legacy compatibility.

**CacheRepository now writes Pinemeter-owned cache/export paths while preserving ClaudeMeter legacy compatibility.**

## What Happened

Added an injectable CacheRepository initializer that accepts FileManager plus app-support and home base URLs while preserving the production default initializer. The repository now stores the private cache under com.pinemeter/usage_cache.json, exports public usage JSON to ~/.pinemeter/usage.json, continues writing the legacy ~/.claudemeter/usage.json export, migrates legacy com.claudemeter/usage_cache.json data when the new cache is absent, and invalidates both new and legacy private/public artifacts. Added focused CacheRepository tests covering fresh writes, legacy private migration, new-cache precedence, legacy public export compatibility, and disk artifact invalidation.

## Verification

Ran the required focused verification command via gsd_exec wrapper: xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/CacheRepositoryTests -only-testing:PinemeterTests/UsageServiceTests. It passed with exit code 0. Evidence ID: 2ff494e3-66ab-40f5-9010-ea7720438b01.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/CacheRepositoryTests -only-testing:PinemeterTests/UsageServiceTests` | 0 | ✅ pass | 8672ms |

## Deviations

None.

## Known Issues

None.

## Files Created/Modified

- `Pinemeter/Repositories/CacheRepository.swift`
- `PinemeterTests/CacheRepositoryTests.swift`
