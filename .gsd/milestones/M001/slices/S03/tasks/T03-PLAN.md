---
estimated_steps: 15
estimated_files: 8
skills_used: []
---

# T03: Ranked ChatGPT cookie, Bearer-token, and generic error redaction risks and pinned user-facing disclosure invariants with synthetic sentinel tests.

---
skills_used:
  - verify-before-complete
---
Why: ChatGPT session cookies and access tokens are credential-equivalent, and the error/logging paths that display localized descriptions can become disclosure channels if future code wraps request or header values. S03 needs ranked findings plus regression tests around generic descriptions.

Do:
- Review `ChatGPTUsageService`, `ChatGPTUsageServiceProtocol`, `SettingsView` ChatGPT actions, and current `ChatGPTUsageServiceTests` for raw token/full-cookie/split-cookie handling, Cookie header normalization, access-token extraction, and storage/reuse boundaries.
- Review `AppError`, `NetworkError`, `KeychainError`, and user-facing handlers that assign `error.localizedDescription` for places where future request/header details could leak to UI or logs.
- Extend `PinemeterTests/SecurityInvariantTests.swift` with tests using synthetic credential-shaped sentinel strings that assert current generic user-facing error descriptions do not contain `sk-ant-`, `__Secure-next-auth`, `Cookie:`, `Bearer`, or access-token-like sentinels.
- Update `S03-ASSESSMENT.md` with ChatGPT credential handling and error/logging redaction findings, including fix/defer recommendations for Keychain-backed ChatGPT storage, replace-not-display settings flows, and redaction tests before adding diagnostics.

Q3 Threat Surface: ChatGPT Cookie and Bearer Authorization headers, transient access tokens, localized error display, logger diagnostic expansion.
Q4 Requirement Impact: Advances R004 and supplies S05 with provider/error audit risk categories.
Q5 Failure Modes: Future diagnostics might log or display request headers; a failed ChatGPT validation could accidentally surface a cookie or access token; cookie normalization output is credential-bearing.
Q7 Negative Tests: Assert generic error descriptions do not contain credential-shaped sentinel values and keep test fixture values synthetic.

Done when: ChatGPT and redaction findings are ranked, the invariant tests cover generic error disclosure boundaries, and focused tests pass.

## Inputs

- `Pinemeter/Services/ChatGPTUsageService.swift`
- `Pinemeter/Services/Protocols/ChatGPTUsageServiceProtocol.swift`
- `Pinemeter/Models/Errors/AppError.swift`
- `Pinemeter/Models/Errors/NetworkError.swift`
- `Pinemeter/Models/Errors/KeychainError.swift`
- `Pinemeter/Views/Settings/SettingsView.swift`
- `PinemeterTests/ChatGPTUsageServiceTests.swift`
- `PinemeterTests/SecurityInvariantTests.swift`
- `.gsd/milestones/M001/slices/S02/S02-ASSESSMENT.md`
- `.gsd/milestones/M001/slices/S03/S03-ASSESSMENT.md`

## Expected Output

- `PinemeterTests/SecurityInvariantTests.swift`
- `.gsd/milestones/M001/slices/S03/S03-ASSESSMENT.md`

## Verification

xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests

## Observability Impact

Documents a redaction invariant for future logging/error diagnostics and adds tests that avoid emitting real credential values.
