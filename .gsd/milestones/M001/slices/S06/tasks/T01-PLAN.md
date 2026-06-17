---
estimated_steps: 4
estimated_files: 2
skills_used: []
---

# T01: CacheRepository now writes Pinemeter-owned cache/export paths while preserving ClaudeMeter legacy compatibility.

skills_used: [decompose-into-slices, tdd]

Why: CacheRepository still owns non-secret cache/export paths under ClaudeMeter names even though README public export copy now points to Pinemeter. This is the safest stale ownership cleanup because it does not touch credentials, Keychain, provider auth, or diagnostics.

Do: Add a testable CacheRepository initializer or equivalent seam that accepts FileManager plus app-support and home base URLs while preserving the production default initializer. Move the primary private disk cache to a Pinemeter-owned app-support directory such as com.pinemeter/usage_cache.json. Move the primary public export to .pinemeter/usage.json. Preserve compatibility by reading/migrating old com.claudemeter/usage_cache.json when the new cache is absent and by continuing to write the legacy .claudemeter/usage.json export for at least this milestone. Keep the actor boundary and CacheRepositoryProtocol behavior unchanged.

Done when: Focused tests prove fresh writes create the new private/public paths, legacy private cache data is read or migrated when only the old path exists, legacy public export compatibility is preserved, invalidate removes the relevant cache/export artifacts, and UsageServiceTests still pass. Do not modify KeychainRepository.swift or Pinemeter.entitlements in this task.

## Inputs

- `Pinemeter/Repositories/CacheRepository.swift`
- `Pinemeter/Repositories/Protocols/CacheRepositoryProtocol.swift`
- `Pinemeter/Services/UsageService.swift`
- `PinemeterTests/TestDoubles/CacheRepositoryFake.swift`
- `PinemeterTests/UsageServiceTests.swift`

## Expected Output

- `Pinemeter/Repositories/CacheRepository.swift`
- `PinemeterTests/CacheRepositoryTests.swift`

## Verification

xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/CacheRepositoryTests -only-testing:PinemeterTests/UsageServiceTests

## Observability Impact

Adds focused test failures for cache path drift and legacy migration regressions; no runtime telemetry or logging is added.
