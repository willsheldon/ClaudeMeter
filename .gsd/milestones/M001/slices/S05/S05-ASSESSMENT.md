# S05 Assessment: Provider and Error Workflow Audit

## Summary

S05 audited Pinemeter's provider-specific setup, status, error, diagnostic, recovery, and public-copy workflows against the S02 credential inventory and S03 security baseline. The safe changes made in this slice keep current behavior intact while making Claude-specific credential failures explicit, redacting risky network diagnostics, and updating public copy to describe the product accurately: primarily Claude.ai usage tracking with optional ChatGPT quota visibility when configured.

S05 did **not** redesign provider interfaces, Keychain storage, settings credential rehydration, ChatGPT token handling, Gemini support, generic provider support, or git history. Those remain deferred to later milestones/slices called out below.

## Audited Surfaces

- `Pinemeter/Models/Errors/AppError.swift` — user-facing credential and recovery error copy.
- `Pinemeter/Models/Errors/NetworkError.swift` — network error descriptions and recovery guidance.
- `Pinemeter/Models/SessionKey.swift` — Claude session key validation and diagnostics copy.
- `Pinemeter/Views/MenuBar/UsagePopoverView.swift` — popover status, recovery actions, Claude usage display, and optional ChatGPT quota display.
- `Pinemeter/Views/Setup/SetupWizardView.swift` — first-run setup and manual Claude session entry copy.
- `Pinemeter/Views/Settings/SettingsView.swift` — settings credential and ChatGPT quota visibility copy.
- `Pinemeter/Services/NetworkService.swift` — HTTP/decode diagnostic payloads and logging surfaces.
- `README.md` and `site/index.html` — public positioning and credential-handling copy.
- `scripts/provider_workflow_copy_audit.py` — fixed-allowlist executable drift check for source, public docs, and unsafe diagnostics.
- Focused tests in `PinemeterTests/SecurityInvariantTests.swift`, `PinemeterTests/ProviderErrorWorkflowTests.swift`, and `PinemeterTests/SessionKeyTests.swift`.

## Changed Files

- `README.md` — public copy now presents Pinemeter as Claude.ai usage tracking with optional ChatGPT quota visibility, and Claude credential language is explicitly scoped to Claude session keys.
- `site/index.html` — metadata, hero, feature, and security copy now use the same Claude-first plus optional ChatGPT quota positioning.
- `Pinemeter/Models/Errors/AppError.swift` — earlier S05 task qualified Claude credential error copy.
- `Pinemeter/Models/Errors/NetworkError.swift` — earlier S05 task qualified Claude credential error copy.
- `Pinemeter/Models/SessionKey.swift` — earlier S05 task qualified validation failures; T04 also clarified source comments as Claude session key comments.
- `Pinemeter/Views/Setup/SetupWizardView.swift` — earlier S05 task qualified setup copy; T04 also clarified accessibility/status copy for Claude session key validation.
- `Pinemeter/Services/NetworkService.swift` — earlier S05 task replaced response-body diagnostics with status/endpoint/byte-count style diagnostics.
- `PinemeterTests/SecurityInvariantTests.swift` — earlier S05 task added source-level invariants for redacted NetworkService diagnostics.
- `scripts/provider_workflow_copy_audit.py` — earlier S05 task added the fixed-allowlist copy/security audit used as the final drift check.

## Safe Fixes Applied

- Claude credential failures now say `Claude session key` instead of ambiguous `session key` where the surface is specifically about Claude authentication.
- Setup/recovery copy remains provider-specific rather than pretending all credential workflows behave the same.
- Public docs now avoid stale Claude-only product positioning by mentioning optional ChatGPT quota visibility, while avoiding unsupported claims about Gemini or generic provider support.
- Network diagnostics preserve failure visibility without logging response bodies, authorization/cookie fragments, or credential-shaped values.
- The audit script passes in default enforce mode and keeps ChatGPT copy inventory advisory/report-only so current optional ChatGPT surfaces can be reviewed without blocking the safe S05 fixes.

## Security and Redaction Notes

- S05 intentionally did not add instructions asking users to paste secrets into logs, issues, crash reports, or diagnostics.
- README and site copy describe local/Keychain handling at a high level and avoid exposing example secret values beyond the existing non-secret `sk-ant-...` format hint.
- `NetworkService` diagnostics are limited to redacted endpoint/status/byte-count style signals; response bodies and credential fragments are covered by `SecurityInvariantTests` and the provider workflow audit.
- The assessment contains no credential values, tokens, cookies, bearer fragments, or user-specific secret material.

## Remaining Deferred Work

- Provider interface redesign remains deferred. S05 did not introduce a generic provider abstraction or normalize all provider status/error surfaces.
- Keychain storage redesign remains deferred to M002; S05 only clarified current Claude credential copy and audited the existing surfaces.
- Settings credential rehydration remains deferred. S05 did not change how settings restore, reuse, or clear credentials beyond safe copy/error updates.
- ChatGPT token handling remains deferred. S05 did not persist ChatGPT bearer tokens, redesign NextAuth session use, or broaden ChatGPT behavior.
- Gemini monitoring remains out of scope for M001 and was not claimed in app, README, or site copy.
- Git history cleanup/open-source history rewriting remains out of scope; S05 did not perform destructive git operations or alter repository history.
- Full provider-aware setup, status, errors, recovery, and notifications remain deferred to R011/M003.

## Requirement Impact

### R006 — Provider and error workflow assumptions

Validated for S05 scope. The slice audited Claude/Opus and GPT assumptions, applied safe copy fixes, added an executable provider workflow copy/security audit, and documented the remaining provider-aware workflow redesign as deferred rather than silently broadening claims.

### R003 — Credential and session handling inventory

Preserved and extended. S05 consumed the S02 credential inventory by checking acquisition, storage wording, reuse/recovery copy, UI display, and logging/diagnostic surfaces. It did not redesign credential acquisition or storage, keeping R003's inventory role intact for M002.

### R004 — Security review and secret exposure

Preserved and partially advanced. S05 kept the S03 security baseline intact by replacing risky network diagnostics with redacted signals and adding regression coverage against response-body or credential-fragment logging. Broader security findings remain documentable/deferred where they require workflow redesign.

## Downstream Handoff

- **S06 cleanup:** use `scripts/provider_workflow_copy_audit.py` before and after cleanup that touches provider, credential, setup, status, or error copy. Do not turn advisory ChatGPT findings into generic provider claims without a real workflow change.
- **S07 final verification:** include the audit script and focused Xcode tests in final validation evidence. Public docs should continue to say Claude.ai usage tracking plus optional ChatGPT quota visibility, not Gemini or generic provider support.
- **M002 durable credentials:** use this assessment plus S02/S03 artifacts to redesign app-owned credential/session acquisition and retention. Current Keychain and settings rehydration behavior was not changed by S05.
- **M003 provider-aware workflows:** use the audited surfaces list as the starting map for typed provider-aware setup, status, error, notification, and recovery flows.
- **M004 Gemini monitoring:** do not infer Gemini readiness from S05. Gemini remains a future provider integration after provider-aware workflows exist.

## Failure Modes

- **Filesystem reads for the audit script:** `scripts/provider_workflow_copy_audit.py` scans a fixed allowlist. Missing files or unreadable paths fail the script and bubble as a non-zero verification result rather than silently passing.
- **Public copy drift:** stale Claude-only public positioning, unsupported generic provider claims, or unsafe credential/logging copy fail the audit in default mode.
- **Xcode test subprocess:** build/test failures bubble through the verification command and block completion. S05 made only static copy and diagnostic changes, so runtime provider API failures are not introduced by T04.
- **Ambiguous provider decisions:** ambiguous or risky provider-copy choices are documented as deferred instead of broadened into generic provider support.

## Load Profile

S05 has no new runtime load path. The only 10x load dimension is verification-time static scanning of a fixed allowlist plus focused Xcode tests. The first resource to saturate would be local subprocess time, bounded by scanning 11 explicit files and running only the focused security/provider/session test targets rather than the full app test suite.

## Negative Tests

- `scripts/provider_workflow_copy_audit.py` fails on public-doc regressions to Claude-only positioning, unsupported generic provider claims, ambiguous Claude credential copy, and unsafe diagnostics that reintroduce response-body or credential logging.
- `PinemeterTests/SecurityInvariantTests.swift` protects against response-body and credential-fragment logging in `NetworkService` diagnostics.
- `PinemeterTests/ProviderErrorWorkflowTests.swift` protects provider/error workflow copy and recovery regressions from earlier S05 fixes.
- `PinemeterTests/SessionKeyTests.swift` protects Claude session key parsing/validation error behavior.

## Observability Impact

S05 adds an agent-runnable drift signal rather than production telemetry. Future agents can inspect provider/error workflow drift by running:

```sh
python3 scripts/provider_workflow_copy_audit.py
```

A passing result means enforced source/docs copy and redaction invariants are still satisfied; advisory ChatGPT inventory remains available for provider-aware workflow design without blocking current safe fixes.
