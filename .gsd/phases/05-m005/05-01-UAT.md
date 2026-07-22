# S01: Public docs accuracy pass — UAT

**Milestone:** M005
**Written:** 2026-07-01T21:50:17.699Z

# S01: Public docs accuracy pass — UAT

**Milestone:** M005
**Written:** 2026-07-01

## UAT Type

- UAT mode: mixed
- Why this mode is sufficient: This slice verifies documentation artifacts, repository-local command/path references, and public landing-page copy. Static artifact checks prove README/changelog/path accuracy, while the landing-page portion can be reviewed by opening `site/index.html` locally or inspecting its HTML copy without requiring a live backend or provider credentials.

## Preconditions

- Work from the M005 checkout root.
- Xcode command-line tools are installed and able to run the Pinemeter scheme.
- Optional landing-page visual review may open `site/index.html` from disk; no localhost server, network access, signing credentials, or provider accounts are required.

## Smoke Test

Run a public-copy scan across README.md, site/index.html, and CHANGELOG.md for `ClaudeMeter|Pinemeter|xcodebuild|provider|privacy|credential|Gemini|ChatGPT|Claude`; expected result is that all matches are Pinemeter-current or intentionally compatibility-scoped.

## Test Cases

### 1. Public identity and provider copy

1. Open or inspect `README.md`, `site/index.html`, and `CHANGELOG.md`.
2. Confirm Pinemeter is the primary product identity.
3. Confirm Claude, ChatGPT, and Gemini provider support is described where provider support is discussed.
4. **Expected:** No stale ClaudeMeter product identity appears; any ClaudeMeter mention is explicitly historical or compatibility-scoped.

### 2. Privacy, credential, reset, and troubleshooting claims

1. Read the README setup, privacy/security, reset, export, and troubleshooting sections.
2. Confirm credential-equivalent storage is described as Keychain-backed and diagnostics/reset paths are public-reader understandable.
3. **Expected:** A fresh contributor can understand what data is stored, where credentials live, how to reset provider state, and where to start troubleshooting.

### 3. Repository paths and documented local verification command

1. Confirm `Pinemeter.xcodeproj/project.pbxproj` exists.
2. Confirm `Pinemeter.xcodeproj/xcshareddata/xcschemes/Pinemeter.xcscheme` exists.
3. Run `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug`.
4. **Expected:** The project and scheme files exist and the documented test command exits 0 with TEST SUCCEEDED.

## Edge Cases

### Compatibility references

1. Search for `ClaudeMeter` in public docs.
2. **Expected:** Matches are limited to compatibility or migration context, not current product branding.

### Multiline command formatting

1. Normalize README line continuations around the documented Xcode command.
2. **Expected:** The documented command resolves to `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug`.

## Failure Signals

- README, site, or changelog uses ClaudeMeter as the current product name.
- Public docs omit one of the supported providers when describing provider support.
- Privacy or credential guidance contradicts Keychain-backed credential boundaries.
- Documented project/scheme paths are missing.
- The documented Xcode test command fails in the checkout.

## Not Proven By This UAT

- It does not prove release signing, notarization, or App Store distribution readiness.
- It does not prove contributor templates or issue/support paths, which are deferred to S02.
- It does not prove fresh-reader end-to-end onboarding, which is deferred to S04.

## Notes for Tester

The README may mention ClaudeMeter only for backward-compatible export or migration context. Treat that as acceptable when clearly scoped, and treat unqualified ClaudeMeter branding as a failure.
