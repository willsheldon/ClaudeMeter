# S02: Claude Keychain repair flow — UAT

**Milestone:** M002
**Written:** 2026-06-18T21:34:20.645Z

# UAT: Claude Keychain repair flow

**UAT Type:** Automated repository/service/model regression with manual recovery workflow specification.

## Preconditions

- Pinemeter is built from the current checkout with the `Pinemeter` scheme.
- Synthetic Claude session keys are used for tests; no real credential material is required or recorded.
- Existing unrelated Keychain items are out of scope and must not be deleted by the repair path.

## Steps and Expected Outcomes

1. Save a synthetic Claude session key for a selected account through the Keychain repository.
   - Expected: the key is stored using the legacy `com.claudemeter.sessionkey` service identifier and can be loaded for that account.
2. Repair or re-save the selected account credential.
   - Expected: repair returns a typed created or updated outcome and only touches the selected account credential.
3. Invoke Claude credential repair through the session import service and AppModel.
   - Expected: AppModel receives a sanitized Claude credential state; raw Keychain errors and credential values are not exposed.
4. Trigger representative Claude credential recovery copy paths.
   - Expected: user-facing labels and recovery messages are Claude-specific and do not disclose session-key material.
5. Run signing and security invariant tests.
   - Expected: official Autimo signing assumptions and legacy Keychain service preservation remain encoded as regression tests.

## Edge Cases

- Missing credential: repair creates the selected account credential without deleting unrelated Keychain rows.
- Existing credential: repair updates the selected account credential and reports an update outcome.
- Keychain failure: failure is mapped to a sanitized credential state/failure category with recovery guidance.
- Signing drift: security invariant tests fail if the repair path no longer matches the intended signed app identity assumptions.

## Evidence

- `gsd_exec` evidence `f6e340e0-7944-4f17-ae26-ac083a8c2b62` passed the targeted S02 test set with exit code 0.
