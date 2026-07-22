# S02: Gemini credential and usage service — UAT

**Milestone:** M004
**Written:** 2026-06-24T20:48:29.736Z

# S02: Gemini credential and usage service — UAT

**Milestone:** M004
**Written:** 2026-06-24

## UAT Type

- UAT mode: runtime-executable
- Why this mode is sufficient: This slice ships repository, actor service, AppModel integration, and security invariants rather than user-facing views. Runtime XCTest coverage exercises the provider service boundary, credential status, AppModel refresh/clear behavior, and static secret-persistence safeguards without requiring a browser or live Gemini credentials.

## Preconditions

- Run from the M004 worktree root.
- Xcode and the Pinemeter scheme are available.
- No live Gemini API key is required; tests use fakes and fixture responses.

## Smoke Test

Run:

```sh
xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/GeminiUsageServiceTests
```

Expected: Gemini usage service tests pass, proving the service can normalize successful quota responses and sanitized error states without live credentials.

## Test Cases

### 1. Credential boundary remains secure

1. Run `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests -only-testing:PinemeterTests/GeminiCredentialBoundaryTests`.
2. Inspect failures, if any, for AppSettings persistence, Codable credential values, or diagnostics containing raw credential material.
3. **Expected:** Tests pass and Gemini API-key material is stored only through the Gemini Keychain repository boundary.

### 2. Usage service normalizes Gemini outcomes

1. Run `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/GeminiUsageServiceTests`.
2. Confirm test cases cover success, auth failure, quota unavailable, and network failure.
3. **Expected:** Service returns normalized usage or sanitized failure categories; raw API keys do not appear in persisted diagnostics.

### 3. AppModel exposes Gemini state without credential material

1. Run `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests`.
2. Confirm Gemini credential availability drives configured state, refresh behavior, and clear behavior.
3. **Expected:** AppModel reflects Gemini configured/unconfigured states and refresh results while UI-facing state never contains raw API-key material.

## Edge Cases

### Quota endpoint lacks quota fields

1. Use the Gemini usage service tests that return model availability without quota fields.
2. **Expected:** The service treats valid credentials with missing quota data as `quotaUnavailable`, preserving sanitized diagnostics rather than failing as an unknown error.

### Credential clear path

1. Use AppModel Gemini clear tests or a fake Gemini repository that records delete calls.
2. **Expected:** Clearing Gemini removes stored credential availability and resets usage/configuration state without broad credential deletion outside the Gemini repository boundary.

## Failure Signals

- `SecurityInvariantTests` fail for AppSettings persistence, Codable Gemini API-key values, or raw secret material in diagnostics.
- `GeminiUsageServiceTests` fail to map auth, quota, or network failures to sanitized errors.
- `AppModelTests` show Gemini refresh or clear behavior regressing other providers or exposing raw credential material.
- Static scans find Gemini API-key, token, secret, or cookie fields in `AppSettings` or logging statements.

## Not Proven By This UAT

- Live Gemini API quota semantics against a production Google account.
- User-facing Gemini API-key entry, reconnect, or repair UX; those are deferred to S03/S04.
- Menu bar rendering of Gemini usage alongside Claude and ChatGPT; that is downstream S04 work.

## Notes for Tester

Gemini reconnect/repair is intentionally not user-facing yet. Treat stored Gemini API-key availability as the configuration signal for this slice; do not expect a settings toggle or browser-based Google session flow.
