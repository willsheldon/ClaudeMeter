---
id: T03
parent: S02
milestone: M003
key_files:
  - Pinemeter/Views/Settings/SettingsView.swift
  - Pinemeter/Views/Setup/SetupWizardView.swift
  - PinemeterTests/ProviderErrorWorkflowTests.swift
key_decisions:
  - Provider action buttons now route through `AppModel.performProviderCredentialAction` from both Settings and Setup, while combined browser import remains the bulk reconnect/import surface.
duration: 
verification_result: passed
completed_at: 2026-06-23T22:02:02.875Z
blocker_discovered: false
---

# T03: Wired provider recovery buttons in Settings and Setup through the shared AppModel provider credential action boundary with provider-scoped sanitized feedback.

**Wired provider recovery buttons in Settings and Setup through the shared AppModel provider credential action boundary with provider-scoped sanitized feedback.**

## What Happened

Updated `SettingsView` provider credential rows so action buttons call a single `performProviderCredentialAction(_:for:)` helper that delegates to `appModel.performProviderCredentialAction(kind, for: status.provider)`, tracks the active provider/action for progress button text, disables concurrent credential mutations, and reports provider-specific progress/success/failure copy without credential values. Updated `SetupWizardView` so repair/clear provider card actions use the same AppModel recovery API and provider-scoped progress state instead of surface-specific action branches. Added regression coverage in `ProviderErrorWorkflowTests` to assert both Settings and Setup route provider actions through the AppModel boundary, keep manual credential entry out of these surfaces, and avoid bypassing recovery actions through provider-specific helpers.

## Failure Modes
External dependencies are the browser-session import path, Keychain-backed credential storage/repair/clear operations, and provider validation/usage refresh invoked by `AppModel.performProviderCredentialAction`. The UI now bubbles sanitized `LocalizedError` descriptions from the AppModel boundary as `Provider: Failed to <action> <credential name>: <sanitized error>` and uses refreshed provider status recovery suggestions when an action returns a non-usable state. Concurrent mutation failure/race risk is handled by disabling provider action buttons while any credential import/action is active or the credential state is validating. Full Disk Access/browser import failures remain surfaced through the existing combined browser import path and are not expanded with raw secret material.

## Load Profile
No meaningful 10x runtime load dimension was introduced: these are user-initiated button actions over at most two providers. The saturating resource would be external credential import/Keychain/provider validation latency, and the protection is UI-level serialization via `activeCredentialActionProvider`, `isCredentialImportBusy`, and validating-state disabled buttons so repeated clicks do not fan out concurrent credential operations.

## Negative Tests
`PinemeterTests/ProviderErrorWorkflowTests.swift::test_providerStatusActionsUseSharedAppModelRecoveryBoundaryWithoutManualCredentials` checks that Setup and Settings use `appModel.performProviderCredentialAction`, do not expose manual `TextField`/validation entry points, and do not bypass the shared boundary for provider action buttons. `PinemeterTests/SecurityInvariantTests.swift` focused cases verify user-facing/settings/setup credential recovery surfaces do not contain credential-shaped fragments, manual credential entry, or persisted credential state.

## Verification

Ran the required focused test command through `gsd_exec`: `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests -only-testing:PinemeterTests/ProviderErrorWorkflowTests`. The command exited 0 and the digest showed the updated provider workflow tests passing.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests -only-testing:PinemeterTests/ProviderErrorWorkflowTests` | 0 | ✅ pass | 14469ms |

## Deviations

Added a focused regression test update in `PinemeterTests/ProviderErrorWorkflowTests.swift` to protect the provider UI wiring contract; the task plan expected two UI files but allowed test updates.

## Known Issues

None.

## Files Created/Modified

- `Pinemeter/Views/Settings/SettingsView.swift`
- `Pinemeter/Views/Setup/SetupWizardView.swift`
- `PinemeterTests/ProviderErrorWorkflowTests.swift`
