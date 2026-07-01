# S03: Release and signing documentation

**Goal:** Document release practices safely without publishing or mutating remote state.
**Demo:** Release-facing docs and workflow notes pin the official signing identity and describe safe local verification.

## Must-Haves

- Release docs pin `Developer ID Application: AUTIMO SYSTEMS INC (HMR9RDR6M2)` and TeamIdentifier `HMR9RDR6M2`.
- GitHub workflow docs and local checks avoid generic signing identities and mutable team secrets.
- No remote push, release creation, or history rewrite is performed.

## Proof Level

- This slice proves: operational

## Integration Closure

release workflow files, docs, and project signing guidance align with project memory and existing workflows.

## Verification

- Makes release failures easier to diagnose while avoiding secret exposure.

<tasks>
- [x] **T01**: Audited release and signing surfaces for pinned Autimo Developer ID identity, safe local verification guidance, and remote-publishing mutation points. _(small)_
  Inspect release workflow, signing settings, docs, and scripts for signing identity assumptions, generic Developer ID usage, mutable team id secrets, and any release steps that mutate remote state.
  - Files: `.github/workflows/release.yml`, `Pinemeter.xcodeproj/project.pbxproj`, `README.md`, `CHANGELOG.md`
  - Verify: Task summary records signing and release findings, including whether official identity is pinned or missing.
- [x] **T02**: Added safe release documentation that pins the Autimo Developer ID identity and separates local verification from publishing or remote mutation. _(medium)_
  Add or update release documentation that pins the official Autimo signing identity, explains local verification, names non-destructive steps, and states that publishing or remote mutations require explicit confirmation.
  - Files: `RELEASING.md`, `README.md`, `.github/workflows/release.yml`
  - Verify: `rg -n "Developer ID Application: AUTIMO SYSTEMS INC \(HMR9RDR6M2\)|TeamIdentifier=HMR9RDR6M2|Developer ID Application|APPLE_TEAM_ID|push|release" RELEASING.md README.md .github/workflows/release.yml` reviewed for safe guidance.
- [ ] **T03**: Verify release workflow safety _(small)_
  Validate release workflow syntax and documentation consistency locally without pushing, publishing, or rewriting history. Fix stale or unsafe instructions only.
  - Files: `RELEASING.md`, `README.md`, `.github/workflows/release.yml`
  - Verify: Local workflow/doc inspection plus `rg -n "Developer ID Application|HMR9RDR6M2|APPLE_TEAM_ID|git push|gh release|rewrite" RELEASING.md README.md .github/workflows/release.yml`; no external state changes performed.
</tasks>

## Files Likely Touched

- .github/workflows/release.yml
- Pinemeter.xcodeproj/project.pbxproj
- README.md
- CHANGELOG.md
- RELEASING.md
