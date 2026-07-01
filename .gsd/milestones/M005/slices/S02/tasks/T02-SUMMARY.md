---
id: T02
parent: S02
milestone: M005
key_files:
  - CONTRIBUTING.md
  - .github/ISSUE_TEMPLATE/bug_report.md
  - .github/ISSUE_TEMPLATE/feature_request.md
  - README.md
key_decisions:
  - Preserved the existing dual GitHub issue-form and portable Markdown checklist setup because it satisfies both GitHub-native reporting and README/CONTRIBUTING links without duplicating new paths.
  - Preserved SECURITY.md as the private channel for credential handling, privacy, and vulnerability concerns instead of adding a public security issue template.
duration: 
verification_result: passed
completed_at: 2026-07-01T21:54:51.536Z
blocker_discovered: false
---

# T02: Added and verified public contributor guidance plus portable Markdown bug and feature templates for sanitized Pinemeter reporting.

**Added and verified public contributor guidance plus portable Markdown bug and feature templates for sanitized Pinemeter reporting.**

## What Happened

Confirmed the planned local artifacts are present under the active worktree: CONTRIBUTING.md, .github/ISSUE_TEMPLATE/bug_report.md, .github/ISSUE_TEMPLATE/feature_request.md, and README.md support/contributing links. The bug checklist asks for Pinemeter version, macOS version and architecture, affected provider or area, setup path, expected and actual behavior, reproduction steps, sanitized provider state, and logs or screenshots only after removing private material. The feature checklist asks for user problem, area, proposed behavior, expected benefit, alternatives, sanitized provider/setup context, and privacy or credential impact. CONTRIBUTING.md and README.md link these templates and route credential, privacy, and vulnerability concerns to SECURITY.md instead of public issues. No further edits were needed because the expected output already matched the task contract.

## Verification

Ran the planned inventory command and confirmed the GitHub issue template files exist alongside existing workflow files. Ran the planned wording scan across .github, CONTRIBUTING.md, and README.md; reviewed matches for secret/token/cookie/session/provider/xcodebuild/Pinemeter wording. The contributor-facing template and documentation matches are redaction/sanitization instructions, while workflow token matches are GitHub Actions secret references in release automation, not prompts for public reporters to paste secrets.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `find .github -maxdepth 3 -type f | sort` | 0 | ✅ pass | 12ms |
| 2 | `rg -n "secret|token|cookie|session|provider|xcodebuild|Pinemeter" .github CONTRIBUTING.md README.md` | 0 | ✅ pass | 18ms |

## Deviations

No source edits were needed because the expected files and README/CONTRIBUTING links already satisfied the T02 contract in the active worktree.

## Known Issues

The broad scan also matches release workflow GitHub Actions secret references such as HOMEBREW_TAP_TOKEN; these are not public issue-template wording and do not ask users to paste secrets.

## Files Created/Modified

- `CONTRIBUTING.md`
- `.github/ISSUE_TEMPLATE/bug_report.md`
- `.github/ISSUE_TEMPLATE/feature_request.md`
- `README.md`
