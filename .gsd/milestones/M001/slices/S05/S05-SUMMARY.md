---
id: S05
parent: M001
milestone: M001
provides:
  - Provider/error workflow audit findings and safe copy fixes for S06 cleanup boundaries.
  - Executable provider workflow audit harness and focused test coverage for S07 final verification.
  - Deferred provider-aware workflow, credential, and monitoring risks for M002/M003 planning.
requires:
  - slice: S02
    provides: Credential/session inventory identifying Claude and ChatGPT acquisition, storage, reuse, display, logging, clearing, and recovery surfaces.
  - slice: S03
    provides: Security baseline and credential/logging risk categories that guided diagnostic redaction and deferred-risk boundaries.
affects:
  - S06
  - S07
  - M002
  - M003
key_files:
  - scripts/provider_workflow_copy_audit.py
  - Pinemeter/Models/Errors/AppError.swift
  - Pinemeter/Models/Errors/NetworkError.swift
  - Pinemeter/Models/SessionKey.swift
  - Pinemeter/Views/MenuBar/UsagePopoverView.swift
  - Pinemeter/Views/Setup/SetupWizardView.swift
  - Pinemeter/Views/Settings/SettingsView.swift
  - Pinemeter/Services/NetworkService.swift
  - PinemeterTests/ProviderErrorWorkflowTests.swift
  - PinemeterTests/SessionKeyTests.swift
  - PinemeterTests/SecurityInvariantTests.swift
  - README.md
  - site/index.html
  - .gsd/milestones/M001/slices/S05/S05-ASSESSMENT.md
key_decisions:
  - Use a fixed source/docs allowlist for provider workflow copy auditing rather than broad repository traversal.
  - Keep recovery-button detection as a tiny Claude-specific helper rather than introducing a broad typed provider error model in S05.
  - Preserve NetworkError semantics and retry-visible behavior while redacting diagnostic payloads.
  - Keep public copy Claude-first with optional ChatGPT quota visibility instead of claiming generic multi-provider or Gemini support.
patterns_established:
  - Fixed-allowlist source/docs audit script for provider copy and diagnostic drift checks.
  - Focused XCTest invariants for provider/error copy and credential-safe diagnostics.
  - Assessment-first handoff distinguishing safe M001 copy fixes from deferred provider workflow redesign.
observability_surfaces:
  - Local/CI health signal: `python3 scripts/provider_workflow_copy_audit.py` enforce-mode exit status.
  - Local/CI health signal: focused XCTest exit status for SecurityInvariantTests, ProviderErrorWorkflowTests, and SessionKeyTests.
  - Failure signal: non-zero audit/test output identifies stale provider copy or unsafe diagnostics; no production telemetry added.
drill_down_paths:
  - .gsd/milestones/M001/slices/S05/tasks/T01-SUMMARY.md
  - .gsd/milestones/M001/slices/S05/tasks/T02-SUMMARY.md
  - .gsd/milestones/M001/slices/S05/tasks/T03-SUMMARY.md
  - .gsd/milestones/M001/slices/S05/tasks/T04-SUMMARY.md
  - .gsd/milestones/M001/slices/S05/S05-ASSESSMENT.md
duration: ""
verification_result: passed
completed_at: 2026-06-17T15:52:17.103Z
blocker_discovered: false
---

# S05: Provider and error workflow audit

**Audited provider/error workflows, made safe Claude-specific credential copy and diagnostic-redaction fixes, updated public provider positioning, and validated R006 with executable source/docs and focused XCTest evidence.**

## What Happened

S05 consumed the S02 credential/session inventory and S03 security baseline to audit Pinemeter's setup, settings, menu bar status/recovery, model errors, provider services, diagnostics/logging, README, and site copy. The slice deliberately stayed within safe copy and diagnostic changes: Claude-only credential failures now identify the "Claude session key" instead of generic "session key" wording where safe, ChatGPT copy remains ChatGPT-specific, and public copy describes Pinemeter as Claude.ai usage tracking with optional ChatGPT quota visibility rather than claiming generic multi-provider or Gemini support.

The slice also added and enforced a fixed-allowlist source/docs audit script so provider workflow drift can be checked without reading .gsd, planning, git, or other ignored/runtime paths. NetworkService diagnostic logging was tightened to avoid response bodies and credential-shaped fragments while preserving existing error semantics and retry-visible behavior. S05-ASSESSMENT.md records audited surfaces, safe fixes, deferred risks, and handoff guidance for S06, S07, M002, and M003.

## Operational Readiness

Health signal: `python3 scripts/provider_workflow_copy_audit.py` exits 0 in enforce mode and the focused XCTest suite for `SecurityInvariantTests`, `ProviderErrorWorkflowTests`, and `SessionKeyTests` exits 0. These prove public/provider copy stayed within supported claims, Claude credential copy is provider-specific, and NetworkService diagnostics do not normalize response-body or credential-fragment logging.

Failure signal: the audit exits non-zero for stale Claude-only/public provider claims, ambiguous credential copy, or unsafe NetworkService diagnostic patterns; the focused tests fail if provider/error copy regresses or if source-level diagnostic invariants are violated. These failures should block S06/S07 cleanup and final verification until corrected.

Recovery procedure: inspect the audit output category, update only source/docs copy or diagnostic strings within the supported provider scope, rerun the audit plus focused XCTest command, and keep broader provider abstraction, Keychain, ChatGPT token, Gemini, or durable credential workflow redesign deferred unless a future slice explicitly takes that scope. Monitoring gap: this is local/CI-style executable verification only; S05 does not add production telemetry, centralized secret scanning, or runtime alerting.

## Verification

Fresh slice-level verification was run through gsd_exec in this closing turn: `python3 scripts/provider_workflow_copy_audit.py && xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests -only-testing:PinemeterTests/ProviderErrorWorkflowTests -only-testing:PinemeterTests/SessionKeyTests`. Evidence `ac728808-8868-4cc0-98db-f65a792de1ff` exited 0. Requirement R006 was updated to validated with this evidence.

## Requirements Advanced

- R006 — Audited provider/error workflow assumptions across setup, settings, status/recovery, model errors, provider services, diagnostics/logging, README, and site copy; applied safe Claude credential copy, public positioning, and diagnostic-redaction fixes.
- R003 — Used the S02 credential/session inventory as input to identify credential-specific copy and diagnostic risks without expanding credential storage or acquisition scope.

## Requirements Validated

- R006 — S05-ASSESSMENT.md plus gsd_exec ac728808-8868-4cc0-98db-f65a792de1ff: provider workflow audit and focused XCTest command exited 0.

## New Requirements Surfaced

- R011 remains deferred for fully provider-aware setup, status, errors, recovery, and notifications across monitored providers.

## Requirements Invalidated or Re-scoped

None.

## Operational Readiness

None.

## Deviations

None. S05 stayed within safe provider-copy, public-copy, assessment, audit-script, and diagnostic-redaction changes; broader provider workflow redesign remains deferred.

## Known Limitations

S05 does not implement full provider-aware setup/status/recovery flows, durable app-owned credential acquisition, Keychain storage redesign, settings credential rehydration, ChatGPT token handling redesign, Gemini monitoring, production telemetry, centralized secret scanning, git history cleanup, or remote operations.

## Follow-ups

S06 should use the S05 audit findings and fixed-allowlist harness as cleanup boundaries. S07 should include the S05 verification command in final verification. M002/M003 should address durable credentials and fully provider-aware workflows.

## Files Created/Modified

- `scripts/provider_workflow_copy_audit.py` — Added and enforced fixed-allowlist provider workflow source/docs audit.
- `Pinemeter/Models/Errors/AppError.swift` — Qualified relevant Claude credential error copy.
- `Pinemeter/Models/Errors/NetworkError.swift` — Qualified relevant Claude credential/network authentication copy.
- `Pinemeter/Models/SessionKey.swift` — Updated Claude session key validation/copy behavior covered by focused tests.
- `Pinemeter/Views/MenuBar/UsagePopoverView.swift` — Added minimal Claude credential recovery copy detection/helper behavior.
- `Pinemeter/Views/Setup/SetupWizardView.swift` — Updated setup/recovery copy for Claude-specific session key wording.
- `Pinemeter/Views/Settings/SettingsView.swift` — Updated settings credential/recovery copy for provider clarity.
- `Pinemeter/Services/NetworkService.swift` — Redacted HTTP and decode failure diagnostics to avoid response-body and credential-fragment logging.
- `PinemeterTests/ProviderErrorWorkflowTests.swift` — Added focused regression coverage for provider/error workflow copy.
- `PinemeterTests/SessionKeyTests.swift` — Added/updated session key copy validation tests.
- `PinemeterTests/SecurityInvariantTests.swift` — Added source-level invariant coverage for credential-safe NetworkService diagnostics.
- `README.md` — Updated public provider positioning to Claude-first with optional ChatGPT quota visibility.
- `site/index.html` — Updated site provider positioning consistently with README.
- `.gsd/milestones/M001/slices/S05/S05-ASSESSMENT.md` — Recorded S05 audit findings, safe fixes, deferred risks, and downstream handoff.
