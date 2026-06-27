# S01: Gemini provider contract

**Goal:** Establish the Gemini provider shape before wiring UI or network calls.
**Demo:** The app has a Gemini provider identity, model contract, and failing tests that define credential and usage states.

## Must-Haves

- CredentialProvider and related provider models include Gemini safely.
- Gemini usage and error models define expected states without raw secret fields.
- Tests capture the contract for configured, missing, invalid, loading, and unavailable states.

## Proof Level

- This slice proves: contract

## Integration Closure

Provider model, credential state, constants, and test fixtures can represent Gemini without changing existing provider semantics.

## Verification

- Defines sanitized Gemini diagnostic categories up front.

## Tasks

- [x] **T01: Mapped the current Claude and ChatGPT provider seams that Gemini must neutralize before implementation.** `est:small`
  Map current provider identity, credential state, usage data, settings, and test fixture seams before adding Gemini. Identify where Claude and ChatGPT assumptions must become provider-neutral.
  - Files: `Pinemeter/Models/CredentialState.swift`, `Pinemeter/Models/UsageData.swift`, `Pinemeter/Models/AppSettings.swift`, `Pinemeter/App/AppModel.swift`, `PinemeterTests`
  - Verify: Task summary records extension points and risks with file references.

- [x] **T02: Added Gemini provider credential contract coverage and minimal provider status support.** `est:medium`
  Write failing then passing tests for Gemini provider identity, credential state labels, action availability, usage status states, and sanitized diagnostic categories.
  - Files: `Pinemeter/Models/CredentialState.swift`, `PinemeterTests/CredentialStateTests.swift`, `PinemeterTests/AppSettingsTests.swift`, `PinemeterTests/AppModelTests.swift`
  - Verify: `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/CredentialStateTests -only-testing:PinemeterTests/AppSettingsTests -only-testing:PinemeterTests/AppModelTests`

- [x] **T03: Verified provider contract compatibility after Gemini contract-state additions.** `est:small`
  Run focused and full tests to ensure adding Gemini contract state does not break Claude or ChatGPT behavior.
  - Files: `Pinemeter/Models`, `PinemeterTests`
  - Verify: `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug`

## Files Likely Touched

- Pinemeter/Models/CredentialState.swift
- Pinemeter/Models/UsageData.swift
- Pinemeter/Models/AppSettings.swift
- Pinemeter/App/AppModel.swift
- PinemeterTests
- PinemeterTests/CredentialStateTests.swift
- PinemeterTests/AppSettingsTests.swift
- PinemeterTests/AppModelTests.swift
- Pinemeter/Models
