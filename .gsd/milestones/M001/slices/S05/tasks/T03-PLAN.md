---
estimated_steps: 15
estimated_files: 2
skills_used: []
---

# T03: Redact Claude network failure diagnostics

---
skills_used: [tdd, verify-before-complete]
---
Why: S03 flagged future diagnostics/request dumps as credential-sensitive, and S05 research found `NetworkService` logs full HTTP/decode response bodies. Even if current Claude response bodies are not known secrets, provider/error workflow diagnostics should not normalize body logging around credential-authenticated endpoints.

Do:
- Update `Pinemeter/Services/NetworkService.swift` logging so HTTP status and decoding failures report redacted structured context such as endpoint path, status code, and response byte count rather than full response body contents.
- Do not log Cookie headers, `sessionKey`, Bearer tokens, raw request headers, or response bodies.
- Extend `PinemeterTests/SecurityInvariantTests.swift` with a focused source-level invariant that uses `#filePath`-relative source lookup and scans only `Pinemeter/Services/NetworkService.swift` for prohibited response-body logging patterns and credential-shaped log fragments.
- Keep `NetworkError` semantics and retry behavior unchanged.

Done when: focused security and provider/error tests pass.

Q3 Threat Surface: Reduces diagnostic leakage risk on authenticated Claude API failures.
Q4 Requirement Impact: Supports R004 security recommendations and R006 provider/error workflow audit.
Q5 Failure Modes: Maintain enough diagnostic signal to debug status/decoding failures without body dumps; do not swallow errors.
Q6 Load Profile: No runtime cost beyond simple byte-count/status logging.
Q7 Negative Tests: Security invariant should fail if future code logs `responseBody`, `Cookie:`, `sessionKey`, or `Bearer` in `NetworkService` diagnostics.

## Inputs

- `Pinemeter/Services/NetworkService.swift`
- `PinemeterTests/SecurityInvariantTests.swift`
- `PinemeterTests/ProviderErrorWorkflowTests.swift`

## Expected Output

- `Pinemeter/Services/NetworkService.swift`
- `PinemeterTests/SecurityInvariantTests.swift`

## Verification

xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests -only-testing:PinemeterTests/ProviderErrorWorkflowTests

## Observability Impact

Replaces high-risk body-level diagnostics with safer redacted failure context.
