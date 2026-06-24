---
estimated_steps: 1
estimated_files: 3
skills_used: []
---

# T02: Add safe release documentation

Add or update release documentation that pins the official Autimo signing identity, explains local verification, names non-destructive steps, and states that publishing or remote mutations require explicit confirmation.

## Inputs

- `.github/workflows/release.yml`
- `README.md`

## Expected Output

- `RELEASING.md`
- `README.md`

## Verification

`rg -n "Developer ID Application: AUTIMO SYSTEMS INC \(HMR9RDR6M2\)|TeamIdentifier=HMR9RDR6M2|Developer ID Application|APPLE_TEAM_ID|push|release" RELEASING.md README.md .github/workflows/release.yml` reviewed for safe guidance.

## Observability Impact

Documents release diagnostics and avoids mutable signing ambiguity.
