---
id: S01
parent: M003
milestone: M003
provides:
  - Sanitized provider-aware credential status presentation for Claude and ChatGPT across setup and settings.
  - A repeatable provider status surface audit for downstream workflow and menu bar slices.
requires:
  []
affects:
  - S02
  - S03
  - S04
key_files:
  - Pinemeter/App/AppModel.swift
  - Pinemeter/Models/CredentialState.swift
  - Pinemeter/Views/Settings/SettingsView.swift
  - Pinemeter/Views/Setup/SetupWizardView.swift
  - PinemeterTests/AppModelTests.swift
  - PinemeterTests/CredentialStateTests.swift
  - PinemeterTests/ProviderErrorWorkflowTests.swift
  - PinemeterTests/SecurityInvariantTests.swift
  - scripts/provider_status_surface_audit.py
key_decisions:
  - Use surface-neutral `stateText` and `detailText` on `AppProviderCredentialStatus`, preserving existing status/setup aliases as wrappers.
  - Render setup provider-card actions from `AppProviderCredentialStatus.actions` while keeping reconnect as the browser-import CTA to avoid duplicate per-provider reconnect buttons.
  - Audit the final shared setup/settings presentation contract through `stateText`, `detailText`, and shared action handling instead of stale pre-refactor snippets.
patterns_established:
  - Provider credential UI surfaces consume AppModel sanitized provider status models rather than view-local provider-specific credential formatting.
  - Host-owned static audit enforces that setup and settings remain pinned to the sanitized shared provider status contract.
observability_surfaces:
  - scripts/provider_status_surface_audit.py provides a repeatable diagnostic for provider status surface health and credential-material exposure regressions.
drill_down_paths:
  - .gsd/milestones/M003/slices/S01/tasks/T01-SUMMARY.md
  - .gsd/milestones/M003/slices/S01/tasks/T02-SUMMARY.md
  - .gsd/milestones/M003/slices/S01/tasks/T03-SUMMARY.md
  - .gsd/milestones/M003/slices/S01/tasks/T04-SUMMARY.md
  - .gsd/milestones/M003/slices/S01/tasks/T05-SUMMARY.md
duration: ""
verification_result: passed
completed_at: 2026-06-23T21:49:15.495Z
blocker_discovered: false
---

# S01: Provider status surfaces

**Settings and setup now present Claude and ChatGPT credential status through shared sanitized provider status models with provider-specific state text, detail text, and safe next actions.**

## What Happened

The slice centralized provider credential presentation around AppModel-owned sanitized AppProviderCredentialStatus values so both SettingsView and SetupWizardView render provider name, credential label, state text, detail text, and actions without reading raw credential material. Early work mapped existing Claude and ChatGPT credential surfaces, repaired the host-owned audit contract, and identified stale Claude-only copy and duplicated formatting risks. Subsequent tasks added unified state/detail presentation helpers, updated setup and settings to consume the shared model, rendered provider status actions from the same sanitized contract, and extended AppModel, credential-state, provider workflow, and security invariant tests. The final task reconciled scripts/provider_status_surface_audit.py with the finished presentation contract so future agents can verify setup/settings remain pinned to AppModel's sanitized status model instead of view-local secret-adjacent formatting.

## Verification

Fresh slice closeout verification passed via gsd_exec evidence d8f33d8b-e4b5-4cfb-b0df-0765d934e1b7: `python3 scripts/provider_status_surface_audit.py` exited 0; `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` exited 0; and `rg -n "sk-|session-token|__Secure|cookie" Pinemeter/Views PinemeterTests` produced zero Pinemeter/Views matches, with remaining matches confined to tests as synthetic fixtures or negative assertions. Task-level verification also covered targeted AppModel, CredentialState, ProviderErrorWorkflow, and SecurityInvariant test suites.

## Requirements Advanced

None.

## Requirements Validated

None.

## New Requirements Surfaced

None.

## Requirements Invalidated or Re-scoped

None.

## Operational Readiness

None.

## Deviations

T02 intentionally updated both SetupWizardView and SettingsView in addition to the core AppModel/test files so real surfaces consumed the unified presentation fields. T01's verification contract was repaired so auto-mode could discover host-owned checks. No other plan deviations.

## Known Limitations

This slice establishes sanitized status surfaces only. Actual retry, reconnect, repair, clear, and expired-session recovery workflows are intentionally deferred to S02 and later slices.

## Follow-ups

S02 should reuse `AppProviderCredentialStatus.actions` as the source of truth for provider recovery controls, then add behavior-level diagnostics for retry/reconnect/clear outcomes.

## Files Created/Modified

- `Pinemeter/App/AppModel.swift` — Owns the shared sanitized provider credential status presentation contract consumed by setup and settings.
- `Pinemeter/Models/CredentialState.swift` — Supports credential state semantics used by provider status presentation and tests.
- `Pinemeter/Views/Settings/SettingsView.swift` — Renders provider-aware credential status rows from AppModel sanitized status values.
- `Pinemeter/Views/Setup/SetupWizardView.swift` — Renders setup provider status cards and safe next actions from the shared status model.
- `PinemeterTests/AppModelTests.swift` — Covers provider status model helper behavior and sanitized presentation text.
- `PinemeterTests/CredentialStateTests.swift` — Covers credential-state behavior supporting status presentation.
- `PinemeterTests/ProviderErrorWorkflowTests.swift` — Covers provider status and action behavior in setup workflow contexts.
- `PinemeterTests/SecurityInvariantTests.swift` — Guards against credential material exposure in provider status surfaces.
- `scripts/provider_status_surface_audit.py` — Host-owned static audit for shared sanitized setup/settings provider status contract.
