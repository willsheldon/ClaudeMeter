# S03: Security review baseline

**Goal:** Produce a ranked security review baseline for current credential and session handling, reconciling the S02 settings-persistence discrepancy, locking key credential-free persistence and redaction invariants with executable tests, and handing clear fix/defer recommendations to S05, S07, and M002 without implementing the durable credential redesign.
**Demo:** After this: a ranked security findings report identifies credential, Keychain, logging, persistence, and recovery risks with fix or defer recommendations.

## Must-Haves

- `S03-ASSESSMENT.md` exists and ranks credential/session findings with location, threat category, exploit scenario, severity, evidence, and fix/defer recommendation.
- The report explicitly reconciles the S02 claim about settings credential rehydration against current `AppSettings` and `SettingsRepository` behavior.
- Findings cover Keychain storage attributes and retained compatibility identifier, SwiftUI raw credential state and reveal flows, ChatGPT cookie/access-token handling, user-visible/logged error propagation, and WKWebView session-key retention cleanup risk.
- Executable XCTest coverage locks at least these invariants: `AppSettings`/settings persistence remains credential-free, credential-shaped values are not added to generic user-facing security error descriptions, and ChatGPT cookie normalization is treated as credential-bearing.
- No task logs, surfaces, persists, or writes real secret values; tests use synthetic sentinel strings only.
- M002-owned durable credential acquisition/persistence work is clearly separated from M001 review findings.

## Proof Level

- This slice proves: Reviewed security baseline artifact plus targeted executable XCTest invariants. Verification should use `xcodebuild test` against focused security/settings/ChatGPT tests; final milestone verification remains responsible for the full clean build and full test suite.

## Integration Closure

Consumes S02 credential/session inventory and produces `S03-ASSESSMENT.md` plus security invariant tests for downstream S05 provider/error audit, S07 final verification, and M002 credential redesign planning. Roadmap remains unchanged because current source confirms the slice boundary is still review-baseline work rather than durable credential implementation.

## Verification

- Preserves existing structured/status logging while documenting a redaction invariant: request headers, Cookie values, Bearer tokens, Claude session keys, ChatGPT session cookies, and imported credential material must not be logged or displayed. Adds tests that use synthetic credential-shaped sentinels only.

## Tasks

- [x] **T01: Added a security invariant test proving AppSettings UserDefaults persistence remains credential-free.** `est:1h`
  ---
  skills_used:
    - verify-before-complete
  ---
  Why: S02 reports saved credential material being rehydrated into settings UI state, while S03 research indicates current `AppSettings` and `SettingsRepository` are preference-only. This discrepancy must be settled first so the security report ranks the actual risk instead of a stale assumption.
  - Files: `Pinemeter/Models/AppSettings.swift`, `Pinemeter/Repositories/SettingsRepository.swift`, `Pinemeter/Views/Settings/SettingsView.swift`, `Pinemeter/App/AppModel.swift`, `PinemeterTests/SecurityInvariantTests.swift`
  - Verify: xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests

- [ ] **T02: Rank Claude Keychain, UI state, and WebView credential risks** `est:1.5h`
  ---
  skills_used:
    - verify-before-complete
  ---
  Why: The highest-value Claude-side risks are around storage attributes, compatibility identifiers, raw SwiftUI state/reveal flows, and `WKWebView` session-key retention. These need evidence-backed severity and fix/defer recommendations before downstream work changes provider/error flows.
  - Files: `Pinemeter/Repositories/KeychainRepository.swift`, `Pinemeter/Views/Settings/SettingsView.swift`, `Pinemeter/Views/Setup/SetupWizardView.swift`, `Pinemeter/Services/WebViewNetworkService.swift`, `.gsd/milestones/M001/slices/S03/S03-ASSESSMENT.md`
  - Verify: xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests

- [ ] **T03: Rank ChatGPT token handling and error redaction risks** `est:1.5h`
  ---
  skills_used:
    - verify-before-complete
  ---
  Why: ChatGPT session cookies and access tokens are credential-equivalent, and the error/logging paths that display localized descriptions can become disclosure channels if future code wraps request or header values. S03 needs ranked findings plus regression tests around generic descriptions.
  - Files: `Pinemeter/Services/ChatGPTUsageService.swift`, `Pinemeter/Services/Protocols/ChatGPTUsageServiceProtocol.swift`, `Pinemeter/Models/Errors/AppError.swift`, `Pinemeter/Models/Errors/NetworkError.swift`, `Pinemeter/Models/Errors/KeychainError.swift`, `Pinemeter/Views/Settings/SettingsView.swift`, `PinemeterTests/SecurityInvariantTests.swift`, `.gsd/milestones/M001/slices/S03/S03-ASSESSMENT.md`
  - Verify: xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests

- [ ] **T04: Finalize ranked security assessment and downstream handoff** `est:1h`
  ---
  skills_used:
    - verify-before-complete
  ---
  Why: S03's primary deliverable is a baseline security report that downstream slices can consume without rediscovery. The final task must normalize rankings, separate M001 review findings from M002 implementation work, and verify the executable invariants alongside relevant existing settings and ChatGPT tests.
  - Files: `.gsd/milestones/M001/slices/S03/S03-ASSESSMENT.md`, `PinemeterTests/SecurityInvariantTests.swift`, `PinemeterTests/SettingsRepositoryTests.swift`, `PinemeterTests/ChatGPTUsageServiceTests.swift`
  - Verify: xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests -only-testing:PinemeterTests/SettingsRepositoryTests -only-testing:PinemeterTests/ChatGPTUsageServiceTests

## Files Likely Touched

- Pinemeter/Models/AppSettings.swift
- Pinemeter/Repositories/SettingsRepository.swift
- Pinemeter/Views/Settings/SettingsView.swift
- Pinemeter/App/AppModel.swift
- PinemeterTests/SecurityInvariantTests.swift
- Pinemeter/Repositories/KeychainRepository.swift
- Pinemeter/Views/Setup/SetupWizardView.swift
- Pinemeter/Services/WebViewNetworkService.swift
- .gsd/milestones/M001/slices/S03/S03-ASSESSMENT.md
- Pinemeter/Services/ChatGPTUsageService.swift
- Pinemeter/Services/Protocols/ChatGPTUsageServiceProtocol.swift
- Pinemeter/Models/Errors/AppError.swift
- Pinemeter/Models/Errors/NetworkError.swift
- Pinemeter/Models/Errors/KeychainError.swift
- PinemeterTests/SettingsRepositoryTests.swift
- PinemeterTests/ChatGPTUsageServiceTests.swift
