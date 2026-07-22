# S03: ChatGPT session acquisition boundary — UAT

**Milestone:** M002
**Written:** 2026-06-18T21:56:44.562Z

# UAT: ChatGPT session acquisition boundary

**UAT Type:** Automated developer verification with synthetic credential sentinels.

## Preconditions

- Pinemeter builds with the `Pinemeter` scheme.
- Tests run in Debug configuration.
- Synthetic ChatGPT cookie and Bearer-token sentinels are used; no real credential material is required or inspected.

## Steps

1. Run the ChatGPT session repository tests.
2. Run the ChatGPT usage-service tests.
3. Run the security invariant, provider error workflow, and settings repository tests covering ChatGPT credential material.
4. Inspect failures, if any, for leaked cookie, token, or header sentinel values.

## Expected Outcomes

- ChatGPT session cookies save, load, validate, and clear only through the secure repository boundary.
- ChatGPT Bearer access tokens remain transient and are not durably persisted.
- WebView-acquired session material has a validated persistence path and invalid sessions are cleared.
- `AppSettings` and UserDefaults settings contain no ChatGPT cookie, Bearer token, or header values.
- User-facing errors and acquisition diagnostics contain only sanitized state or category information.

## Edge Cases

- Missing ChatGPT session material reports sanitized missing/invalid state rather than a raw credential value.
- Invalid persisted ChatGPT sessions are cleared by the usage path.
- Synthetic cookie and Bearer-token fragments do not appear in diagnostics, settings payloads, or localized error text.

## Evidence

- `gsd_exec` evidence `e91f4d6d-c75d-4dbd-9533-c92d053e6990`: targeted S03 xcodebuild test command exited 0.
