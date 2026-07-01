---
id: T03
parent: S02
milestone: M005
key_files:
  - .github/ISSUE_TEMPLATE/bug_report.md
  - .github/ISSUE_TEMPLATE/feature_request.md
  - CONTRIBUTING.md
  - README.md
key_decisions:
  - Left the reviewed public template and guidance files unchanged because the verification findings showed existing sensitive-word matches are protective warnings or app documentation rather than leakage or unsafe reporting prompts.
duration: 
verification_result: passed
completed_at: 2026-07-01T21:56:39.722Z
blocker_discovered: false
---

# T03: Verified the public issue templates and contributor guidance remain Pinemeter-focused, sanitized, and non-destructive without requiring source changes.

**Verified the public issue templates and contributor guidance remain Pinemeter-focused, sanitized, and non-destructive without requiring source changes.**

## What Happened

Reviewed `.github/ISSUE_TEMPLATE/bug_report.md`, `.github/ISSUE_TEMPLATE/feature_request.md`, `CONTRIBUTING.md`, and `README.md` for stale product names, GSD/private-process leakage, unsupported public-support promises, destructive-action suggestions, and prompts that could cause users to paste secrets into public issues. The required `rg` search intentionally found Pinemeter branding and sensitive-word warning text, plus README app setup/security documentation; those matches were safe because they either identify the project, document local app credential setup, or explicitly tell users not to disclose secrets publicly. No `GSD`, `push`, or `rewrite` guidance appeared in the captured verification output, and the only ClaudeMeter-era reference is README legacy export compatibility text rather than a public collaboration process leak. A focused follow-up script checked the public reporting surfaces for unsafe paste-secret prompts and destructive git-publication/history rewrite wording and found none. No source edits were needed.

## Verification

Ran the required `rg -n "ClaudeMeter|GSD|secret|token|cookie|push|rewrite|Pinemeter" .github/ISSUE_TEMPLATE CONTRIBUTING.md README.md` through `gsd_exec` and reviewed the captured output. Ran an additional focused `gsd_exec` Python check over the four planned files to confirm there are zero unsafe public-reporting prompts asking users to paste secrets and no destructive git publication/history rewrite guidance.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `rg -n "ClaudeMeter|GSD|secret|token|cookie|push|rewrite|Pinemeter" .github/ISSUE_TEMPLATE CONTRIBUTING.md README.md` | 0 | ✅ pass — reviewed matches; sensitive terms are warnings or app documentation, not public secret-disclosure prompts | 16ms |
| 2 | `python focused check for unsafe public reporting prompts across .github/ISSUE_TEMPLATE/bug_report.md, .github/ISSUE_TEMPLATE/feature_request.md, CONTRIBUTING.md, README.md` | 0 | ✅ pass — unsafe_public_reporting_prompts=0 and no destructive git publication/history rewrite guidance found | 51ms |

## Deviations

None.

## Known Issues

None.

## Files Created/Modified

- `.github/ISSUE_TEMPLATE/bug_report.md`
- `.github/ISSUE_TEMPLATE/feature_request.md`
- `CONTRIBUTING.md`
- `README.md`
