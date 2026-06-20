---
estimated_steps: 1
estimated_files: 2
skills_used: []
---

# T03: Added regression tests that keep AppSettings and SettingsRepository free of credential state and credential material persistence.

Extend security tests to ensure the new credential state boundary does not cause AppSettings or SettingsRepository to persist credential material, cookies, Bearer tokens, or session key sentinels.

## Inputs

- `Pinemeter/Models/AppSettings.swift`
- `Pinemeter/Repositories/SettingsRepository.swift`
- `Pinemeter/Services/CredentialStatusService.swift`

## Expected Output

- `PinemeterTests/SecurityInvariantTests.swift`
- `PinemeterTests/SettingsRepositoryTests.swift`

## Verification

xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests -only-testing:PinemeterTests/SettingsRepositoryTests

## Observability Impact

Prevents future diagnostics or settings persistence from carrying secrets.
