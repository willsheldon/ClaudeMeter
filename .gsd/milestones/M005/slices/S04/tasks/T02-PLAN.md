---
estimated_steps: 1
estimated_files: 3
skills_used: []
---

# T02: Run public artifact checks

Run non-destructive checks over README, site, GitHub configuration, and any contribution or release docs created by prior slices for stale names, missing paths, unsafe secret prompts, and command drift.

## Inputs

- `README.md`
- `site/index.html`
- `.github`

## Expected Output

- `README.md`
- `site/index.html`
- `.github`

## Verification

`rg -n "ClaudeMeter|Pinemeter|secret|token|cookie|xcodebuild|HMR9RDR6M2|Developer ID Application" README.md site/index.html .github` plus the same check over CONTRIBUTING.md and RELEASING.md if present; review and document findings.

## Observability Impact

Produces artifact-level evidence for public docs quality.
