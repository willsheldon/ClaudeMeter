# S03: Security review baseline — UAT

**Milestone:** M001
**Written:** 2026-06-17T03:08:28.926Z

# S03 UAT: Security review baseline

**UAT Type:** Artifact and automated focused XCTest verification.

## Preconditions

- Worktree is the M001 GSD worktree.
- S01 and S02 are complete.
- S03 tasks T01 through T04 are complete.

## Steps

1. Open `.gsd/milestones/M001/slices/S03/S03-ASSESSMENT.md`.
2. Confirm the report ranks credential/session findings with location, threat category, exploit scenario, severity, evidence, and fix/defer recommendation.
3. Confirm the report explicitly reconciles the S02 settings-persistence discrepancy by stating that `AppSettings`/`SettingsRepository` persistence is credential-free while credential risk remains elsewhere.
4. Confirm coverage includes Keychain attributes and retained compatibility identifier, SwiftUI raw credential state/reveal flows, ChatGPT cookie/access-token handling, user-visible/logged error propagation, and WKWebView session-key retention cleanup risk.
5. Run the focused verification command from the slice plan.

## Expected Outcomes

- The S03 assessment exists and is downstream-ready for S05, S07, and M002.
- The report separates M001 review-baseline findings from M002 durable credential implementation work.
- Focused XCTest suites pass for security invariants, settings persistence, and ChatGPT usage behavior.
- Tests use synthetic sentinel strings only and do not expose real secrets.

## Edge Cases

- If `SettingsRepository` begins persisting credential-shaped fields, the credential-free persistence invariant should fail.
- If future localized error descriptions include request headers, cookies, Bearer tokens, or session keys, disclosure invariants should fail.
- If ChatGPT cookie normalization is downgraded from credential-bearing treatment, the security invariant should fail.
- If the Keychain service identifier is renamed without migration planning, the assessment flags that as a compatibility risk rather than a safe M001 cleanup.

## Evidence

- `gsd_exec` evidence `7c2f4b57-6002-470f-abf7-8647bc0828ef`: focused XCTest command exited 0.
- `gsd_exec` evidence `0c6424f0-7b52-47a9-8754-2b5a31350f0d`: assessment coverage check passed.
