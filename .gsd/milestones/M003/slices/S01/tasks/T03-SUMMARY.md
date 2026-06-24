---
id: T03
parent: S01
milestone: M003
key_files:
  - Pinemeter/Views/Setup/SetupWizardView.swift
  - PinemeterTests/ProviderErrorWorkflowTests.swift
key_decisions:
  - Render setup provider-card actions from `AppProviderCredentialStatus.actions` while keeping reconnect as the browser-import CTA to avoid duplicate per-provider reconnect buttons.
  - Use SwiftUI accessibility containment on setup status cards so nested repair/clear buttons remain independently reachable.
duration: 
verification_result: passed
completed_at: 2026-06-23T17:31:58.917Z
blocker_discovered: false
---

# T03: Rendered shared provider credential status actions in setup and pinned setup/settings status surfaces to the sanitized shared model.

**Rendered shared provider credential status actions in setup and pinned setup/settings status surfaces to the sanitized shared model.**

## What Happened

Settings already rendered Claude and ChatGPT credential rows from `appModel.providerCredentialStatuses`; this task extended the setup wizard status cards to render sanitized shared provider actions from each `AppProviderCredentialStatus` as well. Setup now surfaces repair and clear actions directly on provider status cards while continuing to route reconnect/import through the existing combined browser import controls, avoiding manual credential entry and keeping raw session keys/cookies out of SwiftUI state.

The setup card accessibility behavior was adjusted from combined children to contained children so the new nested action buttons remain reachable to assistive technologies. Tests were added to `ProviderErrorWorkflowTests` to pin that Settings and Setup both consume shared status fields (`stateText`, `detailText`, `lastFailureTitle`) and that Setup exposes shared repair/clear actions without text fields, secure fields, or manual validation entry points.

## Failure Modes
- Browser import dependency: reconnect/repair for non-Claude paths still uses `importProviderSessions(from:)`, which already reports per-provider import failures and Full Disk Access recovery hints through sanitized `ProviderBrowserImportOutcome` messages.
- Keychain/session repository dependency: clear actions call `clearSessionKey()` or `clearChatGPTSessionCookie()` through `clearSavedCredential(for:)`; thrown errors bubble to a sanitized user-facing `Failed to clear saved credential: ...` message without including credential material.
- Claude repair dependency: repair calls `repairClaudeSessionKey()` and surfaces either a success message or the shared sanitized recovery/detail text from `providerCredentialStatuses`.

## Load Profile

## Negative Tests
- `ProviderErrorWorkflowTests.test_settingsAndSetupRenderSharedProviderCredentialStatusModel` asserts both Setup and Settings consume `providerCredentialStatuses`, render shared sanitized status text fields, and do not contain manual/credential-shaped UI fragments.
- `ProviderErrorWorkflowTests.test_setupProviderStatusCardsExposeSharedRepairAndClearActionsWithoutManualCredentials` asserts Setup exposes shared repair/clear action handling, keeps reconnect out of per-card buttons, preserves accessible containment for nested buttons, and does not call manual credential validation entry points.
- Existing `SecurityInvariantTests.test_settingsViewDoesNotOfferManualCredentialEntry` and `SecurityInvariantTests.test_setupWizardUsesCombinedBrowserImportButtons` continue to protect against stale manual credential UI and provider-specific duplicated import buttons.

## Verification

Ran the focused task verification command via `gsd_exec`: `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/ProviderErrorWorkflowTests -only-testing:PinemeterTests/SecurityInvariantTests`. The command exited 0 and the digest showed the targeted provider workflow and security invariant tests passing.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/ProviderErrorWorkflowTests -only-testing:PinemeterTests/SecurityInvariantTests` | 0 | ✅ pass | 22725ms |

## Deviations

None.

## Known Issues

None.

## Files Created/Modified

- `Pinemeter/Views/Setup/SetupWizardView.swift`
- `PinemeterTests/ProviderErrorWorkflowTests.swift`
