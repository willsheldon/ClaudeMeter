# S01: Gemini provider contract — UAT

**Milestone:** M004
**Written:** 2026-06-24T20:18:35.599Z

# S01: Gemini provider contract — UAT

**Milestone:** M004
**Written:** 2026-06-24

## UAT Type

- UAT mode: artifact-driven
- Why this mode is sufficient: S01 is a model and test-contract slice only. It does not add network acquisition, live credential setup, menu bar UI, or browser-executable behavior.

## Preconditions

- Checkout is the M004 worktree.
- Xcode and the Pinemeter Debug test scheme are available.
- No live Gemini credential is required.

## Smoke Test

Run `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -quiet`; the suite should exit 0.

## Test Cases

### 1. Gemini provider identity exists

1. Inspect `Pinemeter/Models/CredentialState.swift`.
2. Confirm `CredentialProvider` includes Gemini with user-facing display text.
3. **Expected:** Gemini can be represented as a first-class provider without removing or renaming Claude or ChatGPT identities.

### 2. Gemini credential contract is sanitized

1. Inspect provider credential kind and state tests.
2. Confirm Gemini status/action tests cover configured, missing, invalid, loading, and unavailable-style states without raw secret fields.
3. **Expected:** Gemini state is represented through sanitized labels, status, and diagnostics only.

### 3. Existing providers remain compatible

1. Run the full Debug test suite.
2. Review existing Claude and ChatGPT provider tests.
3. **Expected:** Existing provider workflow and security tests continue to pass after adding Gemini contract state.

## Edge Cases

### Provider enumeration includes Gemini

1. Inspect `Pinemeter/Services/CredentialStatusService.swift` and its tests.
2. Confirm provider enumeration tests account for Gemini.
3. **Expected:** Adding `.gemini` to all provider cases does not silently omit it from status reporting or break existing providers.

### Gemini actions before implementation

1. Inspect AppModel tests for Gemini action behavior.
2. **Expected:** Gemini actions can be displayed from state but remain unsupported until later slices implement real setup/refresh flows.

## Failure Signals

- Full test suite exits non-zero.
- Gemini is missing from `CredentialProvider` or provider status enumeration.
- Tests expose raw credential values or unsanitized diagnostics.
- Claude or ChatGPT provider tests regress after Gemini is added.

## Not Proven By This UAT

- Live Gemini authentication or API acquisition.
- Gemini usage refresh or normalized usage parsing.
- Settings/setup UI presentation.
- Menu bar rendering or multi-provider live refresh.
- Runtime observability for Gemini network failures.

## Notes for Tester

This slice intentionally stops at the provider/model contract. Unsupported Gemini action errors are expected until S02 and later slices add credential and usage service implementation.
