---
estimated_steps: 1
estimated_files: 6
skills_used: []
---

# T01: Inventoried Keychain storage and settings persistence for Claude and ChatGPT credentials.

Map all storage locations and persistence semantics: Keychain service name, accounts, accessibility class, synchronizable flag, exists/retrieve/save/update/delete behavior, retained access group, and non-secret settings fields such as cached organization ID and ChatGPT display preference. Include S01 compatibility identifiers in the map.

## Inputs

- `.gsd/milestones/M001/slices/S02/S02-RESEARCH.md`
- `.gsd/milestones/M001/slices/S01/S01-ASSESSMENT.md`

## Expected Output

- `Pinemeter/Repositories/KeychainRepository.swift`
- `Pinemeter/Repositories/Protocols/KeychainRepositoryProtocol.swift`
- `Pinemeter/App/AppModel.swift`
- `Pinemeter/Models/AppSettings.swift`
- `Pinemeter/Repositories/SettingsRepository.swift`
- `Pinemeter/Resources/Pinemeter.entitlements`

## Verification

rg -n 'save\(sessionKey|retrieve\(account|delete\(account|exists\(account|kSecAttrService|kSecAttrAccessible|kSecAttrSynchronizable|cachedOrganizationId|isChatGPTUsageShown|keychain-access-groups' Pinemeter PinemeterTests

## Observability Impact

Documents credential storage identifiers and migration-sensitive names for future diagnostics.
