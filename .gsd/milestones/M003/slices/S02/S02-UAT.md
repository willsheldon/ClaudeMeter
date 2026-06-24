# S02: Provider recovery actions — UAT

**Milestone:** M003
**Written:** 2026-06-23T22:06:12.350Z

# S02: Provider recovery actions — UAT

**Milestone:** M003
**Written:** 2026-06-23

## UAT Type

- UAT mode: runtime-executable
- Why this mode is sufficient: Provider recovery actions are AppModel/service-boundary workflows in a macOS SwiftUI app; the executable test suite exercises the orchestration boundary, provider-specific error handling, and credential redaction invariants without requiring live credential material.

## Preconditions

- Run from the repository root in the M003 worktree.
- Xcode command line tools and the Pinemeter scheme are available.
- No live Claude session key or ChatGPT session cookie is required; tests use sanitized fixtures and repository/service doubles.

## Smoke Test

Run `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/ProviderErrorWorkflowTests -only-testing:PinemeterTests/SecurityInvariantTests`. Expected: command exits 0 and provider recovery/security invariant tests pass.

## Test Cases

### 1. Provider recovery actions route through AppModel

1. Run the focused provider workflow tests.
2. Inspect failures, if any, for direct view/service coupling or unsupported action behavior.
3. **Expected:** Settings and setup action paths invoke the shared AppModel provider credential action boundary; unsupported provider/action combinations are rejected with sanitized provider-scoped errors.

### 2. Claude recovery preserves safe credential boundaries

1. Run AppModel and provider workflow tests.
2. Exercise Claude reconnect, repair, retry, and clear coverage through test doubles.
3. **Expected:** Claude repair/import remains scoped through SessionKeyImportService and Keychain repository behavior; user-facing state identifies Claude and the next action without exposing raw session keys.

### 3. ChatGPT recovery preserves repository boundaries

1. Run AppModel and provider workflow tests.
2. Exercise ChatGPT reconnect, retry, clear, and unsupported repair behavior.
3. **Expected:** ChatGPT durable credential-equivalent material remains behind ChatGPTSessionRepository; unsupported repair does not silently fall back to reconnect; feedback is provider-specific and sanitized.

### 4. Recovery copy and redaction invariants hold

1. Search recovery-related copy and tests with `rg -n "Reconnect|Repair|Clear|Claude|ChatGPT|cookie|session key" Pinemeter PinemeterTests`.
2. Run the security invariant tests.
3. **Expected:** Recovery copy is provider-aware, expected references to credential concepts are instructional only, and tests do not reveal raw credential material.

## Edge Cases

### Unsupported ChatGPT repair

1. Trigger the ChatGPT repair action through the AppModel provider credential action API in tests.
2. **Expected:** The action fails with a sanitized provider/action error and does not attempt direct repository mutation or browser reconnect fallback.

### Clearing provider credentials

1. Trigger clear for each supported provider through the shared AppModel boundary.
2. **Expected:** The selected provider's credential state is cleared through the appropriate repository/service boundary and resulting UI feedback names only the provider and next action.

## Failure Signals

- Focused provider workflow or security invariant tests fail.
- `performProviderCredentialAction` no longer appears in Settings or Setup recovery paths.
- User-facing recovery errors mention raw credential values, cookie values, token strings, or session key contents.
- Unsupported ChatGPT repair succeeds implicitly or routes around AppModel.

## Not Proven By This UAT

- Live browser import with real Claude or ChatGPT credentials.
- Real Keychain access-control behavior under a notarized/release-signed app.
- End-to-end expired-session behavior in a running menu bar app; that is deferred to the later workflow UAT and diagnostics slice.

## Notes for Tester

The absence of live credential material is intentional. Treat test doubles and sanitized fixtures as the authoritative proof for provider action routing and redaction; use S04 for manual/live reset and expired-session walkthroughs.
