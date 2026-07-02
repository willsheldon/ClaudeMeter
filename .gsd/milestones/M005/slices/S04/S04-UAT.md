# S04: Fresh-reader public UAT — UAT

**Milestone:** M005
**Written:** 2026-07-01T22:26:36.597Z

# S04: Fresh-reader public UAT — UAT

**Milestone:** M005
**Written:** 2026-07-01

## UAT Type

- UAT mode: mixed
- Why this mode is sufficient: The slice is documentation and public-readiness assembly. Automated artifact checks can prove public files, commands, release-safety wording, issue-template safety, and UAT structure are present; H01-H12 remain human-experience checks because only a real fresh reader can validate whether the docs are understandable without maintainer context.

## Preconditions

- Start from the repository root of the M005 worktree.
- Use only public repository files for fresh-reader checks: `README.md`, `CONTRIBUTING.md`, `SECURITY.md`, `RELEASING.md`, `.github/ISSUE_TEMPLATE/*`, `site/index.html`, `Pinemeter.xcodeproj`, and public source/test files.
- Do not use `.gsd/` context, local secrets, unpublished credentials, or maintainer-only release access for the human fresh-reader pass.
- Xcode command-line tools must be available for the automated build/test command.

## Smoke Test

Run the documented CI-style test command:

```sh
xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -skip-testing:PinemeterTests/MenuBarIconSnapshotTests CODE_SIGN_IDENTITY="-" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
```

Expected: command exits 0 without requiring release signing credentials.

## Test Cases

### 1. Public artifacts describe the app and contributor path

1. Open `README.md` from the repository root.
2. Confirm it explains Pinemeter as a macOS menu bar app and names supported provider workflows for Claude, ChatGPT, and Gemini.
3. Confirm it provides CLI build and test commands.
4. Open `CONTRIBUTING.md`, `SECURITY.md`, and GitHub issue templates.
5. **Expected:** A new contributor can find what the app does, how to run checks, where to report issues, and how to avoid sharing secrets or credential material.

### 2. Release-safety documentation preserves signing identity

1. Open `RELEASING.md` and the release-safety section in `README.md`.
2. Confirm the release path pins `Developer ID Application: AUTIMO SYSTEMS INC (HMR9RDR6M2)` and `TeamIdentifier=HMR9RDR6M2`.
3. Confirm generic `Developer ID Application` or mutable team-ID guidance is rejected for release signing.
4. Confirm publishing/remote workflow dispatch is described as maintainer-controlled, not a normal contributor step.
5. **Expected:** A contributor can safely verify local release-facing facts without being instructed to publish, mutate remote state, or use private signing credentials.

### 3. Fresh-reader checklist separates automation from human judgment

1. Open `.gsd/milestones/M005/slices/S04/S04-UAT.md`.
2. Review `Automated Artifact Checks` and `Human Fresh-reader Checks`.
3. Confirm automated checks cite public artifacts and prior evidence IDs.
4. Confirm H01-H12 are explicitly human-only and not marked as automated proof.
5. **Expected:** The checklist can be used by agents for artifact verification while preserving actual outside-reader validation as a human follow-up.

## Edge Cases

### Sensitive report content

1. Draft a hypothetical bug report containing provider cookies, tokens, API keys, raw response bodies, or account identifiers.
2. Review `CONTRIBUTING.md`, `SECURITY.md`, and `.github/ISSUE_TEMPLATE/bug_report.md`.
3. **Expected:** The docs/templates instruct the reporter to redact or avoid posting sensitive material and route vulnerability/privacy concerns privately.

### Stale branding or compatibility wording

1. Search public docs for `ClaudeMeter`.
2. Review each occurrence.
3. **Expected:** Remaining references are limited to explicit compatibility/history context, not stale public product branding.

## Failure Signals

- Public files referenced by the UAT are missing or renamed.
- README lacks a discoverable build/test command, provider setup, privacy/security posture, or purpose statement.
- Issue templates or contribution guidance invite secrets, cookies, tokens, API keys, raw headers, raw responses, or account identifiers.
- Release docs omit the pinned Autimo signing identity or imply generic/mutable signing identity use is acceptable.
- `xcodebuild test` fails with the documented CI-style command.
- Human fresh-reader checks are presented as automated proof.

## Not Proven By This UAT

- H01-H12 have not been performed by a real outside reader in this automated closeout.
- Public release publishing is not exercised; remote workflow dispatch and notarization remain maintainer-controlled.
- Runtime provider login success is not reproven here beyond the public docs describing setup and privacy boundaries.

## Notes for Tester

Use `.gsd/milestones/M005/slices/S04/S04-UAT.md` as the detailed checklist. The automated evidence proves artifact readiness and command viability; a future public launch should still schedule a real fresh-reader pass before announcing the repository broadly.

