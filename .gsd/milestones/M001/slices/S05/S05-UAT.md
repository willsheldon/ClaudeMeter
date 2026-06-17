# S05: Provider and error workflow audit — UAT

**Milestone:** M001
**Written:** 2026-06-17T15:52:17.103Z

# S05 UAT: Provider and Error Workflow Audit

**UAT Type:** Automated artifact and executable verification with reviewer-readable manual acceptance steps.

## Preconditions

- Worktree is the M001 checkout.
- Pinemeter project and scheme exist.
- S05 task work is present, including `scripts/provider_workflow_copy_audit.py`, focused provider/security/session tests, and `S05-ASSESSMENT.md`.

## Steps and Expected Outcomes

1. Run `python3 scripts/provider_workflow_copy_audit.py`.
   - Expected: exits 0 in enforce mode.
   - Expected: audit checks only the fixed source/docs allowlist and does not require reading `.gsd`, `.planning`, `.audits`, `.git`, or ignored runtime paths.

2. Run focused XCTest verification: `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests -only-testing:PinemeterTests/ProviderErrorWorkflowTests -only-testing:PinemeterTests/SessionKeyTests`.
   - Expected: exits 0.
   - Expected: provider/error copy tests confirm Claude credential failures use Claude-specific wording and ChatGPT copy remains ChatGPT-specific.
   - Expected: security invariant tests confirm NetworkService diagnostics avoid response bodies, cookies, session keys, Bearer tokens, and credential-shaped fragments.

3. Review public copy in `README.md` and `site/index.html`.
   - Expected: copy is Claude-first and may mention optional ChatGPT quota visibility.
   - Expected: copy does not claim generic multi-provider, Gemini, or durable credential support.

4. Review `.gsd/milestones/M001/slices/S05/S05-ASSESSMENT.md`.
   - Expected: assessment covers setup, settings, menu bar status/recovery, model errors, provider services, diagnostics/logging, README, and site copy.
   - Expected: assessment maps S05 to R006 and calls out deferred provider-aware workflow redesign for later work.

## Edge Cases

- If the audit fails on public copy, preserve the Claude-first plus optional ChatGPT quota positioning and do not broaden unsupported provider claims.
- If focused tests fail on NetworkService diagnostics, prefer redacted status/endpoint/byte-count style signals over response body logging.
- If a requested fix requires provider abstraction redesign, Keychain migration, ChatGPT token handling changes, Gemini support, or durable credential acquisition, defer it rather than expanding S05 scope.

## Evidence

- gsd_exec `ac728808-8868-4cc0-98db-f65a792de1ff`: combined provider workflow audit and focused XCTest command exited 0.
