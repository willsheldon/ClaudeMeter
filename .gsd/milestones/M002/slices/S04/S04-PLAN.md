# S04: Credential setup and recovery UX

**Goal:** Connect durable credential state and repair operations to the setup and settings UI so users can recover from missing, invalid, or stale credentials.
**Demo:** Settings or setup shows provider credential status with reconnect, repair, and clear actions using labels that do not expose secrets.

## Must-Haves

- UI shows Claude and ChatGPT credential status using intuitive provider labels and non secret descriptions.
- Users can reconnect, repair, or clear credentials per provider.
- Repeated prompts are avoided when valid durable credentials already exist.
- Accessibility labels and failure copy are provider aware but do not overpromise future Gemini support.

## Proof Level

- This slice proves: SwiftUI view model or app model tests for status actions plus manual review of user facing copy.

## Integration Closure

Integrates S02 and S03 service surfaces into existing SetupWizardView and SettingsView patterns.

## Verification

- Shows sanitized status and recovery actions in UI while preserving no secret logging.

## Tasks

- [ ] **T01: Add provider credential status view model** `est:medium`
  Add or extend app model state so settings and setup can show Claude and ChatGPT credential health, last sanitized failure, and available actions without reading secrets directly in views.
  - Files: `Pinemeter/App/AppModel.swift`, `PinemeterTests/AppModelTests.swift`, `PinemeterTests/ChatGPTAppModelTests.swift`
  - Verify: xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/ChatGPTAppModelTests

- [ ] **T02: Update settings credential recovery controls** `est:medium`
  Update SettingsView with provider credential rows for status, reconnect, repair, and clear actions. Keep copy Claude first with optional ChatGPT quota visibility and do not imply Gemini support yet.
  - Files: `Pinemeter/Views/Settings/SettingsView.swift`, `PinemeterTests/AppModelTests.swift`
  - Verify: xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests

- [ ] **T03: Update setup wizard credential recovery** `est:medium`
  Update SetupWizardView so valid durable credentials skip repeated prompts, missing credentials ask for setup, and repairable credentials offer repair. Add accessibility labels for provider status and actions.
  - Files: `Pinemeter/Views/Setup/SetupWizardView.swift`, `PinemeterTests/AppModelTests.swift`, `PinemeterTests/ProviderErrorWorkflowTests.swift`
  - Verify: xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/ProviderErrorWorkflowTests

## Files Likely Touched

- Pinemeter/App/AppModel.swift
- PinemeterTests/AppModelTests.swift
- PinemeterTests/ChatGPTAppModelTests.swift
- Pinemeter/Views/Settings/SettingsView.swift
- Pinemeter/Views/Setup/SetupWizardView.swift
- PinemeterTests/ProviderErrorWorkflowTests.swift
