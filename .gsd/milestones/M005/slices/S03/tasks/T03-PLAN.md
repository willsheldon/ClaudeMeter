---
estimated_steps: 1
estimated_files: 3
skills_used: []
---

# T03: Verify release workflow safety

Validate release workflow syntax and documentation consistency locally without pushing, publishing, or rewriting history. Fix stale or unsafe instructions only.

## Inputs

- `RELEASING.md`
- `README.md`
- `.github/workflows/release.yml`

## Expected Output

- `RELEASING.md`
- `README.md`
- `.github/workflows/release.yml`

## Verification

Local workflow/doc inspection plus `rg -n "Developer ID Application|HMR9RDR6M2|APPLE_TEAM_ID|git push|gh release|rewrite" RELEASING.md README.md .github/workflows/release.yml`; no external state changes performed.

## Observability Impact

Confirms public release guidance is safe and diagnosable.
