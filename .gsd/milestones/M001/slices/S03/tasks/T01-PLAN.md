---
estimated_steps: 15
estimated_files: 5
skills_used: []
---

# T01: Added a security invariant test proving AppSettings UserDefaults persistence remains credential-free.

---
skills_used:
  - verify-before-complete
---
Why: S02 reports saved credential material being rehydrated into settings UI state, while S03 research indicates current `AppSettings` and `SettingsRepository` are preference-only. This discrepancy must be settled first so the security report ranks the actual risk instead of a stale assumption.

Do:
- Inspect `Pinemeter/Models/AppSettings.swift`, `Pinemeter/Repositories/SettingsRepository.swift`, `Pinemeter/Views/Settings/SettingsView.swift`, and `Pinemeter/App/AppModel.swift` enough to determine whether raw Claude or ChatGPT credential values are persisted in UserDefaults or merely held transiently in view/app state.
- Add `PinemeterTests/SecurityInvariantTests.swift` with a focused XCTest that encodes/saves representative `AppSettings` and asserts the encoded settings payload does not contain credential-bearing field names or synthetic secret values such as `sessionKey`, `chatGPTSessionCookie`, `accessToken`, `__Secure-next-auth`, `Cookie`, `Bearer`, or `sk-ant-`.
- Use only synthetic redacted sentinel strings; do not introduce real credentials.
- Capture the reconciliation conclusion as notes for the later S03 assessment: UserDefaults persistence risk, transient UI state risk, and whether S02 needs correction.

Q3 Threat Surface: UserDefaults settings persistence and accidental Codable expansion into credential material.
Q4 Requirement Impact: Advances R004 and preserves R003 evidence by converting S02 inventory into a validated security finding.
Q5 Failure Modes: A future settings key could add secret material; test should fail if encoded settings begins carrying credential-looking fields.
Q7 Negative Tests: Assert secret-shaped field names and sentinel values are absent from encoded settings data.

Done when: the new security invariant test compiles and fails if `AppSettings` begins encoding credential/session material, and the assessment notes for T04 can clearly state whether settings persistence currently stores secrets.

## Inputs

- `Pinemeter/Models/AppSettings.swift`
- `Pinemeter/Repositories/SettingsRepository.swift`
- `Pinemeter/Views/Settings/SettingsView.swift`
- `Pinemeter/App/AppModel.swift`
- `PinemeterTests/SettingsRepositoryTests.swift`
- `.gsd/milestones/M001/slices/S02/S02-ASSESSMENT.md`

## Expected Output

- `PinemeterTests/SecurityInvariantTests.swift`

## Verification

xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests

## Observability Impact

Adds a regression guard that settings persistence remains credential-free without logging or printing any secret values.
