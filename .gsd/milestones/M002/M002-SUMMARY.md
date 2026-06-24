---
id: M002
title: "Durable credential acquisition"
status: complete
completed_at: 2026-06-20T04:18:08.279Z
key_decisions:
  - Credential lifecycle proof uses synthetic secret material and redaction assertions instead of real provider credentials.
  - S05 UAT is recorded as mixed runtime/artifact UAT because the UAT spec explicitly does not require real provider credentials.
key_files:
  - Pinemeter/Models/CredentialState.swift
  - Pinemeter/Repositories/ChatGPTSessionRepository.swift
  - Pinemeter/Services/SessionKeyImportService.swift
  - Pinemeter/Services/ChatGPTUsageService.swift
  - Pinemeter/App/AppModel.swift
  - Pinemeter/Views/Settings/SettingsView.swift
  - PinemeterTests/SecurityInvariantTests.swift
  - PinemeterTests/ProviderErrorWorkflowTests.swift
  - .gsd/milestones/M002/M002-VALIDATION.md
  - .gsd/milestones/M002/slices/S05/S05-ASSESSMENT.md
lessons_learned:
  - M002 closure requires structured UAT evidence, not only slice summaries and automated assessment prose.
  - For this repo, preserve the official Autimo signing identity when running release/signing-related checks.
---

# M002: Durable credential acquisition

**M002 delivered durable, provider-aware credential acquisition, repair, reuse, clearing, and lifecycle verification for Claude and ChatGPT without persisting secret material outside Keychain boundaries.**

## What Happened

M002 established a shared sanitized credential state contract, repaired Claude Keychain credential handling under the signed app identity, added a ChatGPT session acquisition boundary with durable Keychain-backed session storage and transient access-token handling, exposed provider-aware setup/reconnect/repair/clear UX, and closed the milestone with lifecycle, redaction, signing, and requirement validation evidence. A prior validation pass marked the milestone needs-attention because UAT evidence was not concrete enough; this resume session added structured S05 UAT evidence via gsd_uat_exec and revalidated the milestone as pass.

## Success Criteria Results

- PASS: R010 is validated by `.gsd/REQUIREMENTS.md` and S05 UAT evidence `b11eefc8-6690-4476-93ba-4daed817eac3`.
- PASS: Claude and ChatGPT credential material can be acquired/repaired/reused/cleared through app-owned provider-aware flows, covered by S01-S05 implementation and Debug test evidence `f96bc370-dded-41a6-9170-9bc31e1e3e8b`.
- PASS: Secret material is excluded from settings, logs, errors, artifacts, and user-facing diagnostics by S01/S03/S05 redaction and lifecycle coverage.
- PASS: Legacy Claude Keychain compatibility is preserved by S02 repair behavior.
- PASS: Provider-aware setup, status, repair/reconnect, and clear flows are delivered by S04 and validated by S05.

## Definition of Done Results

- PASS: All M002 slices S01-S05 are complete.
- PASS: Fresh Debug test verification completed successfully in this resume session.
- PASS: Signing settings were inspected and remain pinned to `Developer ID Application: AUTIMO SYSTEMS INC (HMR9RDR6M2)` with `DEVELOPMENT_TEAM = HMR9RDR6M2`.
- PASS: Structured UAT result for M002/S05 is saved as PASS.
- PASS: Milestone validation was rerun and written as verdict `pass`.

## Requirement Outcomes

- R010: validated by M002/S05 durable credential lifecycle evidence.
- R011: remains deferred to M003 for broader multi-provider workflow polish.
- R012: remains deferred to M004 for Gemini monitoring extension.
- R013: remains deferred to M005 for public open-source polish.
- R014: remains a cross-cutting safety boundary around destructive history rewrite and remote push protections.

## Deviations

The original validation was needs-attention due to missing concrete UAT action evidence; this was resolved by adding structured S05 runtime/artifact UAT evidence before milestone completion.

## Follow-ups

Proceed to M003 multi-provider workflow polish. The known downstream TODO is popup menu vertical meter behavior under M003.
