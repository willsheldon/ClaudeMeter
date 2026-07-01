---
id: T01
parent: S02
milestone: M005
key_files:
  - CONTRIBUTING.md
  - SECURITY.md
  - .github/ISSUE_TEMPLATE/config.yml
  - .github/ISSUE_TEMPLATE/bug_report.yml
  - .github/ISSUE_TEMPLATE/feature_request.yml
  - README.md
key_decisions:
  - Use public issue forms only for sanitized bug and feature intake; route security/privacy concerns through SECURITY.md and GitHub private vulnerability reporting instead of a public issue template.
duration: 
verification_result: passed
completed_at: 2026-07-01T18:06:54.724Z
blocker_discovered: false
---

# T01: Added local contributor guidance, public bug and feature issue forms, and private security/privacy reporting guidance for sanitized external collaboration.

**Added local contributor guidance, public bug and feature issue forms, and private security/privacy reporting guidance for sanitized external collaboration.**

## What Happened

Created the smallest useful local collaboration surface after inspecting the existing `.github` directory, `README.md`, and `AGENTS.md`: a contribution guide, a private security/privacy reporting guide, public bug and feature issue forms, issue template configuration, and README links to the new support paths.

The selected set intentionally does not include a public security/privacy issue form. Pinemeter handles credential-equivalent provider material, so sensitive reports are routed through `SECURITY.md` and the GitHub private advisory contact link instead of public issues. Public bug reports now request version, macOS/architecture, affected area, setup path, reproduction steps, expected/actual behavior, sanitized diagnostics, and a safety checklist. Feature requests now include the user problem, affected area, proposed behavior, alternatives, and privacy/credential impact.

## Failure Modes

- Local filesystem/artifact dependency: template files must exist under the repository and be parseable as plain GitHub issue-template YAML/Markdown. Failure path is missing files or missing required public-diagnostic fields; verification explicitly checked every selected artifact path and required text markers.
- GitHub contact-link dependency: `.github/ISSUE_TEMPLATE/config.yml` points users to GitHub private vulnerability reporting. If the repository has not enabled private advisories, `SECURITY.md` provides a fallback maintainer-contact instruction without asking users to post secrets publicly.
- User-provided diagnostic dependency: contributors may accidentally include secrets. The bug form, feature form, contribution guide, security guide, and README all repeat secret-redaction boundaries and route credential/privacy concerns away from public issues.

## Load Profile

## Negative Tests

- Verified that blank public issues are disabled so reports must use structured templates or contact links.
- Verified that no `.github/ISSUE_TEMPLATE/privacy_security_report.md` public template exists, preserving the private-reporting boundary for sensitive material.
- Verified the bug report form warns against public credential/privacy reports and requires a safety checklist that confirms secret removal.
- Verified the feature request form includes a required privacy and credential impact field.

## Observability Impact

Plans structured public diagnostic intake: external bug reports now collect sanitized status/error text, provider/setup path, reproduction steps, environment details, and secret-redaction confirmation.

## Verification

Ran artifact-level verification through `gsd_exec` because this task changes repository collaboration templates, not app runtime behavior. The check confirmed all selected files exist, README links to the contribution and security guides, blank public issues are disabled, bug reports request the required diagnostic context, feature requests include privacy/credential impact, SECURITY.md warns against sending real secrets, CONTRIBUTING.md includes local build/test commands, and no public security/privacy issue template was created.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `gsd_exec python artifact verification for M005 S02 T01 contributor templates` | 0 | ✅ pass | 417ms |

## Deviations

Implemented `SECURITY.md` plus a GitHub contact link instead of a public security/privacy issue template because the task allowed security or privacy reporting "if appropriate" and this project handles credential-equivalent provider material.

## Known Issues

The GitHub private advisory URL depends on repository settings; `SECURITY.md` documents a fallback contact path if private vulnerability reporting is unavailable.

## Files Created/Modified

- `CONTRIBUTING.md`
- `SECURITY.md`
- `.github/ISSUE_TEMPLATE/config.yml`
- `.github/ISSUE_TEMPLATE/bug_report.yml`
- `.github/ISSUE_TEMPLATE/feature_request.yml`
- `README.md`
