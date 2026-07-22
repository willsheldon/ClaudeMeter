# S05: Gemini workflow UAT — UAT

**Milestone:** M004
**Written:** 2026-06-24T22:01:15.142Z

# S05: Gemini workflow UAT — UAT

**Milestone:** M004
**Written:** 2026-06-24

## UAT Type

- UAT mode: mixed
- Why this mode is sufficient: Gemini spans static artifacts, actor/repository seams, XCTest-covered runtime behavior, and native macOS menu bar UX. Automated and runtime checks prove the non-secret workflow contract with synthetic or mocked credentials; human-follow-up is reserved for real credential entry and live native UX that should not be automated with stored secrets.

## Preconditions

- Work from the M004 worktree and the Debug scheme.
- Use only synthetic, placeholder, or mock Gemini credentials unless a real credential is collected through approved secret handling outside this artifact.
- Do not record real API keys, cookies, bearer tokens, screenshots containing secrets, or provider response payloads in this UAT artifact or logs.
- Run the full test suite and provider audits before accepting the workflow.

## Smoke Test

Run `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug`, `python3 scripts/provider_workflow_copy_audit.py`, `python3 scripts/provider_status_surface_audit.py`, and the S05 artifact integrity check. Expected: all commands exit 0, enforced copy findings are absent, provider status rendering is sanitized, and the UAT artifact contains no secret-like values.

## Test Cases

### 1. Clean state and setup prompt

1. Start from a clean provider state with Claude, ChatGPT, and Gemini credentials absent unless a case explicitly configures them.
2. Open setup/settings surfaces and inspect Gemini presentation.
3. **Expected:** Gemini appears as a first-class provider with missing/not-configured state, setup guidance, and no raw credential material in persisted settings, diagnostics, copy, or logs.

### 2. Gemini-only setup and refresh

1. Configure only Gemini with synthetic or mocked credential material.
2. Trigger refresh through the same app path used by the menu/settings surfaces.
3. **Expected:** Gemini usage state loads or reports a sanitized provider error; Claude and ChatGPT remain absent or unchanged; diagnostics do not expose the credential.

### 3. All-provider coexistence

1. Configure Claude, ChatGPT, and Gemini through their approved credential boundaries using synthetic/mock provider data where needed.
2. Refresh the menu bar usage surface.
3. **Expected:** All three providers render provider-specific status, loading/error/recovery copy remains attributable to the correct provider, and Gemini does not regress Claude or ChatGPT state.

### 4. Invalid Gemini credential

1. Provide an invalid synthetic Gemini API key through the approved Gemini credential path.
2. Refresh Gemini usage.
3. **Expected:** The failure is user-actionable and copyable, recovery copy names Gemini, no secret-shaped value is displayed, and the app remains usable for other providers.

### 5. Clear and reconnect recovery

1. Clear the Gemini credential from settings/setup.
2. Confirm Gemini returns to missing/not-configured state.
3. Reconnect with synthetic/mock credential material and refresh.
4. **Expected:** Credential removal is reflected without stale usage, reconnect restores Gemini refresh behavior, and no provider state leaks across Claude or ChatGPT.

## Edge Cases

### Human-only live credential validation

1. A human tester may provide a real Gemini credential only through approved secret handling.
2. Exercise setup, refresh, invalidation, clear, and reconnect in the native app.
3. **Expected:** Real credential behavior matches the synthetic/mocked contract; any screenshots or notes redact credential material.

### Copy and diagnostic redaction regression

1. Run provider copy and status audits.
2. Inspect copyable error rows for shared ChatGPT/Gemini provider errors.
3. **Expected:** Enforced copy findings are absent and credential-card failure titles remain copyable without exposing secrets.

## Failure Signals

- Full Debug XCTest suite exits non-zero.
- Provider workflow copy audit reports enforced findings.
- Provider status surface audit reports direct raw credential/session access or missing sanitization coverage.
- UAT artifact checks find missing workflow coverage or secret-like values.
- Gemini refresh errors display raw API keys, cookies, bearer tokens, provider payloads, or ambiguous provider copy.

## Not Proven By This UAT

- Live Gemini quota correctness against a real production account without a human-supplied credential.
- Pixel-perfect menu bar visual layout on every macOS display configuration.
- Network-provider availability outside the sanitized recovery and diagnostic contract.

## Notes for Tester

Treat automated evidence as the regression gate and human live-credential checks as optional product acceptance. Advisory ChatGPT copy review items from the workflow audit are known advisory-only output; enforced findings must remain zero.
