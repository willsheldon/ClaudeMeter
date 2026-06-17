---
estimated_steps: 1
estimated_files: 5
skills_used: []
---

# T03: Created the Pinemeter identity exception map for persistent runtime identifiers and compatibility-sensitive names.

Inventory and decide each risky runtime identifier discovered in research: bundle ID, keychain service name, keychain access group/entitlements, Application Support cache directory, public export path, logger subsystem, UserDefaults/sandbox implications, and GitHub repository URLs. Apply only low-risk renames or compatibility-preserving migrations; otherwise leave the old identifier and document it as an explicit S01 exception for S02/M002/S07. Add tests only if runtime migration behavior is changed. Save the identity map as a slice assessment artifact so downstream credential and verification slices do not rediscover it.

## Inputs

- `.gsd/milestones/M001/slices/S01/S01-RESEARCH.md`
- `ClaudeMeter/Repositories/KeychainRepository.swift`
- `ClaudeMeter/Repositories/CacheRepository.swift`

## Expected Output

- `ClaudeMeter/Repositories/KeychainRepository.swift`
- `ClaudeMeter/Repositories/CacheRepository.swift`
- `ClaudeMeter/Services/NetworkService.swift`
- `ClaudeMeter/Resources/ClaudeMeter.entitlements`
- `ClaudeMeter.xcodeproj/project.pbxproj`

## Verification

rg -n --glob '!.git/**' --glob '!.gsd/**' 'com\.claudemeter|\.claudemeter|eddmann/ClaudeMeter|ClaudeMeter' Pinemeter PinemeterTests Pinemeter.xcodeproj README.md site .github CHANGELOG.md work-to-date.md
If runtime migration code changes: xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug

## Observability Impact

Documents logger subsystem and persistent storage continuity so later agents can diagnose missing credentials/cache after rename.
