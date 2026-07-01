# S01: Public docs accuracy pass

**Goal:** Make public documentation match the implemented product state.
**Demo:** README, site, changelog, and public docs accurately explain Pinemeter and current provider workflows.

## Must-Haves

- README and site use Pinemeter identity consistently and describe supported providers accurately.
- Setup, privacy, storage, reset, and troubleshooting docs reflect current credential boundaries.
- Commands and file paths in docs match the repository.

## Proof Level

- This slice proves: contract

## Integration Closure

README, site/index.html, CHANGELOG, and relevant docs agree with code and tests.

## Verification

- Improves external troubleshooting by documenting current diagnostics and reset paths.

<tasks>
- [x] **T01**: Audited public docs against the current Pinemeter app state and identified stale or missing public-facing claims. _(small)_
  Compare README, site, changelog, workflows, and project files against implemented providers, setup flows, privacy boundaries, build/test commands, and Pinemeter identity. Record stale or missing public-facing claims.
  - Files: `README.md`, `site/index.html`, `CHANGELOG.md`, `.github/workflows`, `Pinemeter.xcodeproj`
  - Verify: Task summary lists doc mismatches with file references and proposed updates.
- [x] **T02**: Verified README, landing page, and changelog public copy now reflects current Pinemeter provider support, privacy posture, setup, reset, build, and troubleshooting guidance. _(medium)_
  Update README and site copy so a fresh reader understands what Pinemeter is, supported providers, privacy/security posture, setup, reset, build/test commands, and troubleshooting.
  - Files: `README.md`, `site/index.html`, `CHANGELOG.md`
  - Verify: `rg -n "ClaudeMeter|Pinemeter|xcodebuild|provider|privacy|credential|Gemini|ChatGPT|Claude" README.md site/index.html CHANGELOG.md` reviewed for accurate public copy.
- [x] **T03**: Verified public documentation paths, local assets, project scheme files, and documented Pinemeter Xcode test commands against the active M005 checkout. _(small)_
  Check documented paths and commands against the repository. Run non-destructive local validation for build/test commands if docs were changed in ways that affect them.
  - Files: `README.md`, `site/index.html`, `CHANGELOG.md`
  - Verify: `test -f Pinemeter.xcodeproj/project.pbxproj && test -f Pinemeter.xcodeproj/xcshareddata/xcschemes/Pinemeter.xcscheme` plus `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` if build/test documentation changed.
</tasks>

## Files Likely Touched

- README.md
- site/index.html
- CHANGELOG.md
- .github/workflows
- Pinemeter.xcodeproj
