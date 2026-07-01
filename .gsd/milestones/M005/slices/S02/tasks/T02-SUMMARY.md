---
id: T02
parent: S02
milestone: M005
key_files:
  - .github/ISSUE_TEMPLATE/bug_report.md
  - .github/ISSUE_TEMPLATE/feature_request.md
  - CONTRIBUTING.md
  - README.md
key_decisions:
  - Preserve existing GitHub YAML issue forms as the primary issue UI and add Markdown templates as portable contributor checklists.
duration: 
verification_result: passed
completed_at: 2026-07-01T18:13:35.039Z
blocker_discovered: false
---

# T02: Added portable Markdown bug and feature templates and linked them from contributor and README guidance with explicit sanitized-provider reporting prompts.

**Added portable Markdown bug and feature templates and linked them from contributor and README guidance with explicit sanitized-provider reporting prompts.**

## What Happened

Created `.github/ISSUE_TEMPLATE/bug_report.md` and `.github/ISSUE_TEMPLATE/feature_request.md` as portable Markdown checklists alongside the existing GitHub YAML issue forms. The bug checklist asks for Pinemeter version, macOS version and architecture, affected provider or area, setup path, expected behavior, actual behavior, reproduction steps, sanitized provider state, and logs/screenshots with secrets removed. The feature checklist asks for user problem, area, proposed behavior, expected benefit, alternatives, sanitized provider/setup context, and privacy or credential impact.

Updated `CONTRIBUTING.md` so external contributors are directed to either the issue form or the Markdown checklist and reminded not to include session keys, cookies, tokens, API keys, request headers, account identifiers, or private workspace names. Updated `README.md` support bullets to link the new Markdown templates and summarize the sanitized diagnostic fields.

## Failure Modes

This task is documentation/template-only. The external dependency surface is limited to filesystem paths under `.github`, `CONTRIBUTING.md`, and `README.md`; missing expected files would surface as verification failures from `test -f` and `rg`. GitHub issue-form rendering remains handled by the existing `.yml` templates, while the new `.md` files serve as fallback/portable checklists.

## Load Profile

No runtime load dimension applies. These are static repository templates and README/contributor links; there is no API, subprocess, network path, queue, cache, or request volume to saturate.

## Negative Tests

The verification command performed a negative wording review by searching for secret-sensitive terms (`secret`, `token`, `cookie`, `session`, `provider`) across `.github`, `CONTRIBUTING.md`, and `README.md`, then confirming those terms appear in explicit exclusion/sanitization guidance rather than requests for raw credential material. Required Markdown template sections were also asserted with `test -f` and targeted `rg` checks.

## Verification

Ran the planned GSD verification command: `find .github -maxdepth 3 -type f | sort` plus `rg -n "secret|token|cookie|session|provider|xcodebuild|Pinemeter" .github CONTRIBUTING.md README.md`, with additional assertions that the required Markdown template files exist and contain sanitized provider-state, expected/actual behavior, xcodebuild/source-build, and privacy/credential impact prompts. The command exited 0 and recorded evidence at `.gsd/exec/d6d8416e-00e6-4584-a4a2-1b7e3f5a826c.stdout`.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `find .github -maxdepth 3 -type f | sort && rg -n "secret|token|cookie|session|provider|xcodebuild|Pinemeter" .github CONTRIBUTING.md README.md plus required template assertions` | 0 | ✅ pass | 331ms |

## Deviations

The task expected Markdown templates, while T01 had already added YAML GitHub issue forms. I preserved the YAML forms and added the Markdown templates as portable checklists instead of replacing the existing forms.

## Known Issues

None.

## Files Created/Modified

- `.github/ISSUE_TEMPLATE/bug_report.md`
- `.github/ISSUE_TEMPLATE/feature_request.md`
- `CONTRIBUTING.md`
- `README.md`
