---
estimated_steps: 1
estimated_files: 9
skills_used: []
---

# T04: Inventoried display, logging, error, test, and export exposure risks for credential material.

Scan and document where credential values can be displayed, held in SwiftUI state, copied into test doubles, included in errors, logged, exported, or persisted outside Keychain. Rank obvious findings for S03, especially full saved credentials rehydrated into settings fields.

## Inputs

- `.gsd/milestones/M001/slices/S02/S02-RESEARCH.md`

## Expected Output

- `Pinemeter/Views/Settings/SettingsView.swift`
- `Pinemeter/Views/Setup/SetupWizardView.swift`
- `Pinemeter/Services/NetworkService.swift`
- `Pinemeter/Services/UsageService.swift`
- `Pinemeter/Services/ChatGPTUsageService.swift`
- `Pinemeter/Services/SessionKeyImportService.swift`
- `PinemeterTests/TestDoubles/KeychainRepositoryFake.swift`
- `PinemeterTests/TestDoubles/NetworkServiceStub.swift`
- `PinemeterTests/TestDoubles/SessionKeyImportServiceStub.swift`

## Verification

rg -n 'logger\.|Logger\(|print\(|debugPrint|NSLog|localizedDescription|sessionKey|sessionCookie|cookieHeader|accessToken|Cookie|SecureField|TextField' Pinemeter PinemeterTests

## Observability Impact

Feeds S03 with concrete logging/display/error exposure surfaces.
