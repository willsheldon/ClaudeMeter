---
estimated_steps: 1
estimated_files: 10
skills_used: []
---

# T02: Inventoried Claude session acquisition, validation, reuse, display, clearing, and recovery paths.

Map manual paste, browser cookie import, Safe Storage pre-prompt, local SessionKey validation, remote validation, organization selection, Keychain write/read, Claude API Cookie header reuse, UI status/display, and clear/recovery behavior for the Claude session key.

## Inputs

- `.gsd/milestones/M001/slices/S02/S02-RESEARCH.md`

## Expected Output

- `Pinemeter/Views/Setup/SetupWizardView.swift`
- `Pinemeter/Views/Settings/SettingsView.swift`
- `Pinemeter/App/AppModel.swift`
- `Pinemeter/App/SessionKeyImportPromptCoordinator.swift`
- `Pinemeter/Services/SessionKeyImportService.swift`
- `Pinemeter/Services/Protocols/SessionKeyImportServiceProtocol.swift`
- `Pinemeter/Models/SessionKey.swift`
- `Pinemeter/Services/UsageService.swift`
- `Pinemeter/Services/NetworkService.swift`
- `Pinemeter/Models/Errors/AppError.swift`

## Verification

rg -n 'sessionKey|SessionKey|Import from Browser|BrowserCookie|claude\.ai|Cookie|clearSessionKey|validateAndSaveSessionKey|fetchOrganizations|request\(' Pinemeter PinemeterTests

## Observability Impact

Identifies Claude credential acquisition/reuse/recovery surfaces and potential diagnostic metadata.
