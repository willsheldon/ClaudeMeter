---
id: T03
parent: S04
milestone: M002
key_files:
  - Pinemeter/Views/Setup/SetupWizardView.swift
  - Pinemeter/App/AppModel.swift
  - PinemeterTests/AppModelTests.swift
  - PinemeterTests/ProviderErrorWorkflowTests.swift
key_decisions:
  - Use AppProviderCredentialStatus setup-specific properties for wizard branching and accessibility copy rather than duplicating credential-state decision logic inside SetupWizardView.
duration: 
verification_result: passed
completed_at: 2026-06-18T22:12:18.028Z
blocker_discovered: false
---

# T03: Updated the setup wizard to use sanitized durable credential status for ready, missing, and repairable Claude session states.

**Updated the setup wizard to use sanitized durable credential status for ready, missing, and repairable Claude session states.**

## What Happened

SetupWizardView now reads the Claude entry from AppModel.providerCredentialStatuses and renders a sanitized credential status card with accessibility labeling. Ready credentials no longer show repeated manual setup prompts, missing or unknown credentials still show import/manual setup, and repairable unavailable or invalid states show repair and clear recovery actions without exposing credential material. AppProviderCredentialStatus now owns setup-specific prompt copy and accessibility text so setup and tests share one sanitized decision surface.

## Failure Modes
- Browser import can fail due to missing browser cookies, denied Full Disk Access, malformed imported values, network validation failure, or provider rejection. The existing importAndSave path remains the reconnect action and continues to surface SessionKeyImportError, NetworkError, and AppError through sanitized UI copy, including the Full Disk Access button when applicable.
- Repair can fail because the saved credential is missing, Keychain access is unavailable, or the provider rejects the repaired credential during refresh. The new repair action routes through AppModel.repairClaudeSessionKey and shows the sanitized AppProviderCredentialStatus recoverySuggestion/statusDescription instead of raw credential material.
- Clear can fail because Keychain delete fails. The new clear action catches and displays a generic clear failure with localized error text and never displays a session key.

## Load Profile
This task has no meaningful runtime load dimension: it adds setup wizard branching and one-user credential recovery actions around existing Keychain/browser/provider calls. The first saturated resource at 10x would still be the external validation/import provider path, which is only invoked by explicit user action and not by a loop, batch, or background polling flow.

## Negative Tests
- AppModelTests.test_providerCredentialStatusSetupPromptsDistinguishReadyMissingAndRepairableCredentials covers ready credentials skipping setup prompts, missing credentials requesting setup, and repairable unavailable credentials offering repair without raw credential text.
- ProviderErrorWorkflowTests.test_credentialRecoverySetupCopyDoesNotExposeRawCredentialMaterial covers sanitized setup recovery copy and accessibility text for a storage-unavailable credential state.
- Existing ProviderErrorWorkflowTests credential-copy cases continue to protect Claude-specific missing/invalid/recovery wording.

## Verification

Ran the required focused test command for AppModelTests and ProviderErrorWorkflowTests after the final SetupWizardView cleanup. The command completed successfully with all selected tests passing.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/ProviderErrorWorkflowTests` | 0 | ✅ pass | 9530ms |

## Deviations

Added setup-specific computed properties to AppProviderCredentialStatus in AppModel.swift so SetupWizardView and tests can share the same sanitized branching/copy contract; this is within the task's AppModel input surface.

## Known Issues

None.

## Files Created/Modified

- `Pinemeter/Views/Setup/SetupWizardView.swift`
- `Pinemeter/App/AppModel.swift`
- `PinemeterTests/AppModelTests.swift`
- `PinemeterTests/ProviderErrorWorkflowTests.swift`
