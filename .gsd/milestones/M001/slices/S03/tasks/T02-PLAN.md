---
estimated_steps: 16
estimated_files: 5
skills_used: []
---

# T02: Ranked Claude Keychain, SwiftUI credential-state, WebView session-retention, and logging redaction risks in the S03 assessment.

---
skills_used:
  - verify-before-complete
---
Why: The highest-value Claude-side risks are around storage attributes, compatibility identifiers, raw SwiftUI state/reveal flows, and `WKWebView` session-key retention. These need evidence-backed severity and fix/defer recommendations before downstream work changes provider/error flows.

Do:
- Review `KeychainRepository` for service/account identifiers, accessibility class, synchronizable setting, update/delete behavior, and migration sensitivity. Treat `com.claudemeter.sessionkey` as a compatibility-sensitive identifier that must not be silently renamed in M001.
- Review `SettingsView` and `SetupWizardView` for raw `@State` credential strings, reveal toggles, validation/import flows, clearing after save/cancel, and user-visible messages.
- Review `WebViewNetworkService` request lifecycle for `currentSessionKey` assignment, cookie injection, success/failure/timeout cleanup, and logger usage.
- Draft or update `S03-ASSESSMENT.md` sections for Claude Keychain storage, SwiftUI display/local-state exposure, and WebView lifecycle retention. Each finding should include location, threat category, exploit scenario, severity, evidence, remediation, and fix/defer recommendation.
- If a small cleanup such as clearing `currentSessionKey` is obviously missing, document it as a finding and recommend whether it belongs in S03 follow-up or M002; do not broaden into durable credential redesign.

Q3 Threat Surface: Keychain storage accessibility, local UI exposure, memory retention, reveal/display behavior, and request cookie injection.
Q4 Requirement Impact: Advances R004 with ranked findings while preserving R003's inventory categories.
Q5 Failure Modes: Silent identifier rename could break existing credentials; WebView failures could retain credential state longer than necessary; reveal toggles can expose secrets during screen sharing.
Q7 Negative Tests: Existing and new tests must not use real secret values; recommendations must distinguish compatibility exceptions from rename omissions.

Done when: Claude-side findings are ranked with concrete evidence and explicit fix/defer ownership, and targeted security invariant tests still pass.

## Inputs

- `Pinemeter/Repositories/KeychainRepository.swift`
- `Pinemeter/Repositories/Protocols/KeychainRepositoryProtocol.swift`
- `Pinemeter/Views/Settings/SettingsView.swift`
- `Pinemeter/Views/Setup/SetupWizardView.swift`
- `Pinemeter/Services/WebViewNetworkService.swift`
- `PinemeterTests/SecurityInvariantTests.swift`
- `.gsd/milestones/M001/slices/S02/S02-ASSESSMENT.md`

## Expected Output

- `.gsd/milestones/M001/slices/S03/S03-ASSESSMENT.md`

## Verification

xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests

## Observability Impact

Confirms Claude credential logging boundaries and records that request/header dumps remain prohibited.
