# S03: Gemini setup and settings UI

**Goal:** Expose Gemini setup and recovery through existing provider-aware UI patterns.
**Demo:** Settings and setup display Gemini status and actions beside Claude and ChatGPT.

## Must-Haves

- Setup and settings show Gemini credential status and recovery actions.
- Provider UI code remains data-driven enough to avoid third-provider duplication.
- View/model tests cover Gemini plus mixed provider states.

## Proof Level

- This slice proves: integration

## Integration Closure

AppModel provider status arrays, SettingsView, and SetupWizardView include Gemini consistently.

## Verification

- Improves visible provider setup diagnostics for a third provider.

## Tasks

- [ ] **T01: Extend provider status UI to Gemini** `est:medium`
  Update setup and settings provider status sections to include Gemini through shared provider status collections rather than one-off Gemini-specific UI blocks where avoidable.
  - Files: `Pinemeter/Views/Settings/SettingsView.swift`, `Pinemeter/Views/Setup/SetupWizardView.swift`, `Pinemeter/App/AppModel.swift`
  - Verify: `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/ProviderErrorWorkflowTests`

- [ ] **T02: Add Gemini recovery UI tests** `est:medium`
  Add or update tests covering Gemini missing, configured, invalid, reconnect, clear, and retry UI/model behavior, including mixed provider states.
  - Files: `PinemeterTests/ProviderErrorWorkflowTests.swift`, `PinemeterTests/AppModelTests.swift`, `PinemeterTests/SecurityInvariantTests.swift`
  - Verify: `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/ProviderErrorWorkflowTests -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/SecurityInvariantTests`

- [ ] **T03: Verify setup and settings provider matrix** `est:small`
  Run full tests and inspect setup/settings copy for stale two-provider assumptions, secret terms, and unclear Gemini next actions.
  - Files: `Pinemeter/Views/Settings/SettingsView.swift`, `Pinemeter/Views/Setup/SetupWizardView.swift`, `PinemeterTests`
  - Verify: `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` and `rg -n "Claude|ChatGPT|Gemini|provider|cookie|key" Pinemeter/Views/Settings Pinemeter/Views/Setup` reviewed for expected copy.

## Files Likely Touched

- Pinemeter/Views/Settings/SettingsView.swift
- Pinemeter/Views/Setup/SetupWizardView.swift
- Pinemeter/App/AppModel.swift
- PinemeterTests/ProviderErrorWorkflowTests.swift
- PinemeterTests/AppModelTests.swift
- PinemeterTests/SecurityInvariantTests.swift
- PinemeterTests
