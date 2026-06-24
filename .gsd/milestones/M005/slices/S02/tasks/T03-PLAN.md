---
estimated_steps: 1
estimated_files: 4
skills_used: []
---

# T03: Verify public template consistency

Review templates for stale names, private process leakage, unsupported promises, and destructive-action suggestions. Fix inconsistencies and record verification evidence.

## Inputs

- `.github/ISSUE_TEMPLATE/bug_report.md`
- `.github/ISSUE_TEMPLATE/feature_request.md`
- `CONTRIBUTING.md`
- `README.md`

## Expected Output

- `.github/ISSUE_TEMPLATE/bug_report.md`
- `.github/ISSUE_TEMPLATE/feature_request.md`
- `CONTRIBUTING.md`
- `README.md`

## Verification

`rg -n "ClaudeMeter|GSD|secret|token|cookie|push|rewrite|Pinemeter" .github/ISSUE_TEMPLATE CONTRIBUTING.md README.md` reviewed; no template asks users to paste secrets.

## Observability Impact

Confirms support intake is sanitized and useful.
