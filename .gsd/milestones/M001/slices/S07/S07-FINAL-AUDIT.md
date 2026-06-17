# S07 Final Audit: Identity and Public Hygiene Classification

Task: M001/S07/T02  
Date: 2026-06-17

## Scope

This audit classifies remaining old-name identity references and public-readiness gaps after the Pinemeter rename. It intentionally does **not** rename legacy Keychain, cache, access-group, or SSM identifiers; those are compatibility surfaces deferred to future migration work.

## Scan Evidence

| Evidence ID | Purpose | Command summary | Result |
|---|---|---|---|
| `gsd_exec:f7462596-79cb-4c17-827a-6d924d6cde15` | Identity reference scan | Searched for `ClaudeMeter`, `claudemeter`, `CLAUDEMETER`, and `Claude Meter`, excluding `.git`, `.gsd/exec`, and generated/build-like paths. | Completed with 63 matching files, dominated by historical `.gsd` artifacts plus expected compatibility identifiers. |
| `gsd_exec:df44f346-e626-4c99-81bc-391cacb15731` | Public hygiene inventory | Checked README, LICENSE, SECURITY, CONTRIBUTING, CODE_OF_CONDUCT, changelog, Dependabot, issue templates, PR template, workflows, site, provider audit script, and work-to-date notes. | Completed; README, LICENSE, CHANGELOG, site, workflows, script, and work-to-date present; community/security automation files missing. |
| `gsd_exec:c0bdd5f9-08c6-41ca-8d64-313d03b9bbca` | Redacted secret-shaped scan | Searched public/source/test surfaces for secret-shaped classes and reported only paths, line numbers, and categories. | Completed with 10 files containing expected code/test/workflow secret-handling categories; no secret values were emitted. |
| `gsd_exec:c19bcc57-2c69-4a77-952e-40e0dd45e3da` | Sanitized classification context | Printed selected surrounding lines with token/cookie/session/API-key-like values redacted. | Completed; confirmed compatibility comments and expected provider/session/security surfaces. |

## Remaining Reference Classification

| Finding group | Evidence | Classification | Rationale | Action |
|---|---|---|---|---|
| `CHANGELOG.md` old `ClaudeMeter` release notes and upstream comparison/release URLs | `f7462596-79cb-4c17-827a-6d924d6cde15`, `c19bcc57-2c69-4a77-952e-40e0dd45e3da` | Historical attribution | Changelog preserves prior release history, including the original app name and upstream GitHub release links. | Keep until a maintainer intentionally rewrites public release history. |
| `CHANGELOG.md` `~/.claudemeter/usage.json` export mention | Same | Compatibility | Public export path remains intentionally legacy-compatible for external tools. | Keep; migration belongs in future compatibility work. |
| `work-to-date.md` old `ClaudeMeter` mentions | `f7462596-79cb-4c17-827a-6d924d6cde15` | Historical attribution | Project-local progress document records completed rename work and prior name context. | Keep; not a runtime or public identity defect. |
| `AGENTS.md` and `CLAUDE.md` SSM path profile references | `f7462596-79cb-4c17-827a-6d924d6cde15` | Operational secret path | Agent instructions still name `/ws-claude/claudemeter` and `ws-claude-claudemeter`; these are operational secret-management identifiers, not product UI identity. | Keep for now; do not rename secrets in this task. |
| `.gsd/**` requirements, project, roadmap, research, plans, summaries, graph, state manifest | `f7462596-79cb-4c17-827a-6d924d6cde15` | Historical attribution and planning context | GSD artifacts preserve the milestone history of renaming ClaudeMeter to Pinemeter and should remain auditable. | Keep; not source-shipping identity. |
| `Pinemeter/Resources/Pinemeter.entitlements` legacy access group | `f7462596-79cb-4c17-827a-6d924d6cde15`, `c19bcc57-2c69-4a77-952e-40e0dd45e3da` | Compatibility | The entitlement explicitly documents intentional legacy `com.claudemeter` access-group retention for credential continuity. | Keep; defer migration to M002 or explicit credential migration milestone. |
| `Pinemeter/Repositories/KeychainRepository.swift` legacy service name | Same | Compatibility | Source comment documents intentional legacy service identifier retention for Keychain continuity. | Keep; do not rename in this task. |
| `Pinemeter/Repositories/CacheRepository.swift` legacy app support and public cache paths | Same | Compatibility | Repository continues writing legacy cache/export locations for milestone compatibility and external-tool continuity. | Keep; do not rename in this task. |
| `PinemeterTests/CacheRepositoryTests.swift` and `PinemeterTests/SecurityInvariantTests.swift` old-name assertions | Same | Expected security and compatibility test surface | Tests assert that retained legacy identifiers remain documented and deliberate. | Keep; these protect against accidental removal or undocumented credential changes. |
| `site/index.html`, `README.md`, active source UI paths | `f7462596-79cb-4c17-827a-6d924d6cde15`, `c19bcc57-2c69-4a77-952e-40e0dd45e3da` | No active old-name defect found in inspected active public UI surfaces | README heading is Pinemeter; site context scan did not identify old-name product identity. | No source change. |

## Public Hygiene Inventory

| Item | Status | Evidence | Classification | Notes |
|---|---|---|---|---|
| README | Present | `df44f346-e626-4c99-81bc-391cacb15731` | Present public baseline | `README.md` exists and is Pinemeter-branded. |
| LICENSE | Present | Same | Present public baseline | `LICENSE` exists. |
| CHANGELOG | Present | Same | Present public baseline with historical attribution | `CHANGELOG.md` exists and contains old-name historical release entries. |
| SECURITY | Missing | Same | Missing public-hygiene file | Needed before broad open-source publication if security reporting policy is required. |
| CONTRIBUTING | Missing | Same | Missing public-hygiene file | Needed before inviting external contributions. |
| CODE_OF_CONDUCT | Missing | Same | Missing public-hygiene file | Community-policy decision pending. |
| Dependabot | Missing | Same | Missing public-hygiene automation | Dependency update policy/configuration pending. |
| Issue templates | Missing | Same | Missing public-hygiene file | Public support triage template pending. |
| PR template | Missing | Same | Missing public-hygiene file | Contributor review checklist pending. |
| `site/index.html` | Present | Same | Pending public URL/distribution decision | Static site exists, but publication/distribution policy is outside this task. |
| `.github/workflows/test.yml` | Present | Same | Present CI surface | Available for future public readiness review. |
| `.github/workflows/release.yml` | Present | Same | Pending distribution decision | Release workflow exists; token use must stay configured through GitHub secrets. |
| `.github/workflows/deploy-pages.yml` | Present | Same | Pending public URL/distribution decision | Pages deployment exists; publication decision remains explicit human gate. |
| `scripts/provider_workflow_copy_audit.py` | Present | Same | Present audit utility | Supports provider workflow copy checks. |
| `work-to-date.md` | Present | Same | Historical attribution | Useful internal history, not a publication-blocking source file by itself. |

## Secret-Shaped Scan Summary

The scan reported only file paths, line numbers, and secret-shape classes. No token, cookie, password, session, or API-key values were printed.

| Finding group | Evidence | Classification | Rationale | Action |
|---|---|---|---|---|
| `.github/workflows/deploy-pages.yml` `id-token: write` | `c0bdd5f9-08c6-41ca-8d64-313d03b9bbca`, `c19bcc57-2c69-4a77-952e-40e0dd45e3da` | Expected workflow permission | OIDC permission string matched the generic token pattern; it is not a secret value. | Keep. |
| `.github/workflows/release.yml` tap token clone command | Same | Expected workflow secret reference and pending distribution decision | Workflow references a token variable for release publication; value is not in repository output. | Keep configured via GitHub secrets; review before public release. |
| `Pinemeter/Services/ChatGPTUsageService.swift` | Same | Expected provider/session code surface | Code handles API/session terminology and URLSession behavior. The redacted context shows source-level handling, not embedded credentials. | Keep. |
| `Pinemeter/Services/NetworkService.swift` | Same | Expected session code surface | URLSession dependency and session naming triggered generic secret/session patterns. | Keep. |
| `Pinemeter/Services/SessionKeyImportService.swift` | Same | Expected provider/session/security code surface | Cookie/session import behavior necessarily references Safari access-denied and cookie selection logic. | Keep; credential handling unchanged. |
| `Pinemeter/Services/WebViewNetworkService.swift` | Same | Expected cookie code surface | HTTPCookie construction is product functionality, not a stored secret. | Keep. |
| `Pinemeter/Views/Settings/SettingsView.swift` | Same | Expected user-facing configuration field | Settings text field label/name triggered generic secret-shaped pattern; no value emitted. | Keep. |
| `PinemeterTests/ChatGPTUsageServiceTests.swift`, `PinemeterTests/SecurityInvariantTests.swift`, `PinemeterTests/SessionKeyTests.swift` | Same | Expected test/security surface | Tests include synthetic token/session/cookie cases and security invariants; no real values were emitted in audit output. | Keep; these are negative/security test fixtures. |
| `AGENTS.md`, `CLAUDE.md` SSM parameter path references | Identity scan plus project instructions | Operational secret path | SSM paths are project secret-location metadata, not secret values. | Keep; do not move secrets to plaintext. |

## Unexpected Findings

None classified as active defects in this task.

No unclassified active Pinemeter source/UI identity reference to ClaudeMeter was found in the scanned source/public surfaces. No real secret value was identified or emitted. The main release-readiness exceptions are missing public hygiene/community files and explicit future distribution decisions.

## Source Change Notes

No source files were changed by this task. The only created artifact is this audit:

- `.gsd/milestones/M001/slices/S07/S07-FINAL-AUDIT.md`

## Failure Modes

| Dependency | Failure path | Handling in this task |
|---|---|---|
| Repository filesystem traversal | Missing files, unreadable files, binary/generated files, or excessive output. | Scans used bounded Python scripts, skipped `.git`, `.gsd/exec`, generated/build-like paths, and read text with error-tolerant decoding. Missing public hygiene files were classified rather than causing source changes. |
| `gsd_exec` subprocess execution | Non-zero exit, timeout, malformed/truncated output. | Each scan returned exit code 0 with persisted stdout/stderr paths. Evidence IDs are recorded so future agents can inspect full output if needed. |
| Secret-shaped scanning | Accidental dumping of sensitive values. | The scan reported only path, line, and class; the classification-context command redacted quoted values and long token-like strings on secret-sensitive lines. |
| Classification ambiguity | A legacy reference could be mistaken for an active product defect. | Findings are grouped by compatibility, historical attribution, operational secret path, pending public URL/distribution decision, expected provider/session/security code surface, missing public-hygiene file, or active defect. |

## Load Profile

Repository scans are lightweight, local filesystem-bound diagnostics. At 10x expected repository size, first saturation would be filesystem traversal and stdout volume, not runtime app load.

Protections applied:

- Excluded `.git`, `.gsd/exec`, generated/build-like directories, dependency/build paths, and binary suffixes.
- Summarized matches by file, count, line number, and category instead of dumping matching lines wholesale.
- Used persisted `gsd_exec` output files for larger scan results, keeping the task summary concise.

No runtime telemetry or production load behavior was changed.

## Negative Tests

| Negative surface | Evidence | Result |
|---|---|---|
| Old-name active identity references | `f7462596-79cb-4c17-827a-6d924d6cde15` plus `c19bcc57-2c69-4a77-952e-40e0dd45e3da` | Remaining active source references are classified as intentional compatibility/test surfaces; no unclassified active defect was found. |
| Missing public-readiness files | `df44f346-e626-4c99-81bc-391cacb15731` | Missing SECURITY, CONTRIBUTING, CODE_OF_CONDUCT, Dependabot, issue templates, and PR template are explicitly recorded as readiness gaps. |
| Secret-shaped content exposure | `c0bdd5f9-08c6-41ca-8d64-313d03b9bbca` and `c19bcc57-2c69-4a77-952e-40e0dd45e3da` | Scan output and context output avoided secret values and classified expected workflow/provider/session/security surfaces. |
| Unexpected findings | This artifact | Explicitly recorded as none, so absence is auditable. |

## Observability Impact

This task adds release observability by preserving final scan evidence IDs, classification tables, missing-public-hygiene inventory, and explicit unexpected-finding notes. It adds no runtime telemetry.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---|---:|---|---:|
| 1 | `gsd_exec python identity reference scan` | 0 | pass | 140ms |
| 2 | `gsd_exec python public hygiene inventory` | 0 | pass | 45ms |
| 3 | `gsd_exec python redacted secret-shaped content scan` | 0 | pass | 97ms |
| 4 | `gsd_exec python sanitized classification context` | 0 | pass | 66ms |
