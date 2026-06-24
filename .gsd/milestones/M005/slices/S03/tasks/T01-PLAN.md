---
estimated_steps: 1
estimated_files: 4
skills_used: []
---

# T01: Audit release and signing surfaces

Inspect release workflow, signing settings, docs, and scripts for signing identity assumptions, generic Developer ID usage, mutable team id secrets, and any release steps that mutate remote state.

## Inputs

- `.github/workflows/release.yml`
- `Pinemeter.xcodeproj/project.pbxproj`
- `README.md`

## Expected Output

- `.github/workflows/release.yml`
- `Pinemeter.xcodeproj/project.pbxproj`
- `README.md`
- `CHANGELOG.md`

## Verification

Task summary records signing and release findings, including whether official identity is pinned or missing.

## Observability Impact

Maps release failure and signing diagnostic surfaces.
