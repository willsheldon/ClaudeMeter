# S04: Credential setup and recovery UX — UAT

**Milestone:** M002
**Written:** 2026-06-18T22:14:08.173Z

# UAT: S04 Credential setup and recovery UX

**UAT Type:** Structured manual review plus automated test evidence.

## Preconditions

- Pinemeter is built from the M002/S04 code state.
- Claude credential state can be represented as ready, missing, checking, invalid, stale, or repairable through AppModel.
- ChatGPT credential state can be represented through the session acquisition boundary from S03.

## Steps and Expected Outcomes

1. Open Settings.
   - Expected: A Claude credential row is visible with provider-aware status text and non-secret description.
   - Expected: A ChatGPT credential row is visible when applicable, with ChatGPT-specific status/copy and no Gemini overpromise.
   - Expected: Available actions are provider-aware, such as setup/reconnect, repair when supported, and clear.

2. Review Settings credential rows for secret exposure.
   - Expected: Rows do not display raw session keys, cookies, access tokens, refresh tokens, or credential-equivalent values.
   - Expected: Failure text is sanitized and describes state/recovery, not secret content.

3. Launch setup with a valid durable Claude credential.
   - Expected: Setup recognizes the saved credential and does not repeatedly prompt the user to paste the credential again.
   - Expected: The copy communicates that the saved credential is available without revealing it.

4. Launch setup with a missing Claude credential.
   - Expected: Setup asks the user to provide/setup Claude credentials with Claude-specific labels.
   - Expected: Accessibility labels identify the provider and action.

5. Launch setup with a repairable Claude credential.
   - Expected: Setup offers a repair path rather than requiring unrelated Keychain deletion.
   - Expected: Repair copy stays provider-aware and does not display raw credential values.

6. Clear a provider credential from Settings.
   - Expected: The clear action is scoped to the selected provider credential state.
   - Expected: The UI returns to missing/setup-needed state without exposing cleared material.

## Edge Cases

- Checking or transient state shows neutral progress copy and avoids destructive actions until state is known.
- Invalid/stale credential states show recovery-oriented copy and sanitized failure descriptions.
- ChatGPT unavailable/not connected state remains ChatGPT-specific and does not imply Gemini support.

## Operational Readiness

- Health signal: targeted AppModel, ChatGPTAppModel, and ProviderErrorWorkflow tests pass, proving the provider status models, setup decisions, and sanitized workflow copy are wired for Claude and ChatGPT credential recovery UX.
- Runtime health signal: users should see provider-specific status rows in Settings and provider-specific setup status in the setup wizard without raw credential values.
- Failure signal: failing targeted tests, missing provider status/action markers, or UI copy that includes raw credential-like persistence/logging patterns indicates the slice is broken.
- Recovery procedure: rerun the targeted S04 xcodebuild test command, inspect AppModel provider credential status mapping, then inspect SettingsView and SetupWizardView credential rows/action labels for provider-specific sanitized copy.
- Monitoring gaps: there is no production telemetry or dashboard for credential UX health yet; this menu bar app currently relies on tests, sanitized copy review, and user-visible state transitions.

## Evidence

- Automated test evidence: `gsd_exec` `4e3fd4cd-5b90-4831-a35d-1bca51b67a9f` exited 0 for the combined S04 targeted xcodebuild tests.
- Sanitized copy/source evidence: `gsd_exec` `5911bcef-1363-4ca8-8f37-a8d75be365b7` exited 0 for expected UX markers and no obvious raw credential persistence/logging findings.
