---
estimated_steps: 1
estimated_files: 4
skills_used: []
---

# T02: Add contribution and issue templates

Create local template files that ask for sanitized provider state, macOS version, app version, setup path, expected behavior, actual behavior, and logs or screenshots with secrets removed. Link them from README where appropriate.

## Inputs

- `README.md`
- `.github`

## Expected Output

- `CONTRIBUTING.md`
- `.github/ISSUE_TEMPLATE/bug_report.md`
- `.github/ISSUE_TEMPLATE/feature_request.md`

## Verification

`find .github -maxdepth 3 -type f | sort` and `rg -n "secret|token|cookie|session|provider|xcodebuild|Pinemeter" .github CONTRIBUTING.md README.md` reviewed for safe wording.

## Observability Impact

Improves external bug report observability without collecting secrets.
