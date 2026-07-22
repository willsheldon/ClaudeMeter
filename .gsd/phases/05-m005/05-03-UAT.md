# S03: Release and signing documentation — UAT

**Milestone:** M005
**Written:** 2026-07-01T22:12:33.586Z

# S03: Release and signing documentation — UAT

**Milestone:** M005
**Written:** 2026-07-01

## UAT Type

- UAT mode: artifact-driven
- Why this mode is sufficient: This slice ships documentation, workflow diagnostics, and signing configuration checks. The meaningful user-facing behavior is visible by inspecting repository artifacts and running local-only parsers/searches; no browser, server, release publication, notarization submission, or remote mutation is required.

## Preconditions

- Work from the repository checkout for M005.
- Do not run `git push`, `gh release`, notarization submission, Homebrew tap update, tag creation, history rewrite, or workflow dispatch as part of this UAT.
- Ruby is available for local YAML parsing through Psych.

## Smoke Test

Run a local artifact check that parses `.github/workflows/release.yml` and searches `.github/workflows/release.yml`, `RELEASING.md`, `README.md`, and `Pinemeter.xcodeproj/project.pbxproj` for the pinned identity, pinned team, forbidden mutable team-secret dependency, and explicit publishing-boundary language. Expected: all checks pass without invoking network or remote mutation commands.

## Test Cases

### 1. Official signing identity is pinned

1. Inspect `.github/workflows/release.yml`, `RELEASING.md`, and `Pinemeter.xcodeproj/project.pbxproj`.
2. Confirm the signing identity is `Developer ID Application: AUTIMO SYSTEMS INC (HMR9RDR6M2)`.
3. Confirm the expected team is `HMR9RDR6M2` and docs include `TeamIdentifier=HMR9RDR6M2`.
4. **Expected:** Release-facing artifacts do not rely on a generic `Developer ID Application` identity and consistently name the Autimo identity/team.

### 2. Mutable team secret dependency is rejected

1. Inspect `.github/workflows/release.yml`.
2. Confirm there is no `secrets.APPLE_TEAM_ID` dependency and no `APPLE_TEAM_ID:` environment assignment.
3. Confirm any `APPLE_TEAM_ID` mention is diagnostic wording that rejects mutable team-secret handling.
4. **Expected:** The workflow uses the pinned `EXPECTED_TEAM_ID: HMR9RDR6M2` constant and treats mutable team secrets as a failure condition.

### 3. Publishing boundaries are explicit

1. Inspect `RELEASING.md` and `README.md` release sections.
2. Confirm `git push` and `gh release` are classified as actions requiring explicit maintainer confirmation.
3. Inspect workflow diagnostics for GitHub release, Homebrew tap, and notarization publishing boundaries.
4. **Expected:** A contributor can distinguish local verification from publishing or remote mutation steps.

### 4. Workflow syntax remains parseable

1. Parse `.github/workflows/release.yml` with Ruby Psych or an equivalent local YAML parser.
2. **Expected:** The workflow parses successfully without requiring GitHub Actions execution.

## Edge Cases

### Generic signing drift

1. Search release-facing files for a generic `CODE_SIGN_IDENTITY = Developer ID Application` assignment.
2. **Expected:** No generic signing assignment exists; the workflow guard would fail if one is introduced.

### Accidental remote-mutation test attempt

1. Review UAT instructions before running checks.
2. **Expected:** The tester stops before any `git push`, `gh release`, notarization submission, Homebrew tap update, tag mutation, history rewrite, or workflow dispatch because those are publishing actions requiring explicit maintainer confirmation.

## Failure Signals

- `.github/workflows/release.yml` does not parse as YAML.
- `Developer ID Application: AUTIMO SYSTEMS INC (HMR9RDR6M2)` is missing from workflow or docs.
- `TeamIdentifier=HMR9RDR6M2` is missing from release docs.
- The workflow uses `secrets.APPLE_TEAM_ID` or an `APPLE_TEAM_ID:` environment value.
- Docs describe `git push` or `gh release` as routine local verification rather than explicit-confirmation publishing actions.
- UAT requires a remote push, release publication, notarization submission, or history rewrite.

## Not Proven By This UAT

- Actual notarization success against Apple services.
- GitHub Actions hosted-runner behavior during a real release dispatch.
- Availability of the Developer ID certificate in a maintainer keychain.
- Homebrew tap publication success.

## Notes for Tester

This UAT is intentionally local-only. The release workflow still contains publishing steps by design, but dispatching it is not a local signing-only check and should not be used for this slice UAT without explicit maintainer approval.
