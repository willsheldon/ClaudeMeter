# S01: Public docs accuracy pass — UAT

**Milestone:** M005
**Written:** 2026-07-01T18:00:24.950Z

# S01: Public docs accuracy pass — UAT

**Milestone:** M005
**Written:** 2026-07-01

## UAT Type

- UAT mode: runtime-executable
- Why this mode is sufficient: This slice changes public documentation and documented local commands, so repository-local artifact checks plus the documented Xcode test command prove the docs are actionable without needing a live app server or browser session.

## Preconditions

- Work from the repository root for this checkout.
- Xcode and the macOS SDK needed by the Pinemeter scheme are installed.
- No network access or external credentials are required.

## Smoke Test

Run `rg -n "Pinemeter|ClaudeMeter|xcodebuild|Gemini|ChatGPT|Claude|credential|reset|troubleshoot" README.md site/index.html CHANGELOG.md` and confirm public copy uses Pinemeter identity, with any ClaudeMeter mentions limited to legacy or historical context.

## Test Cases

### 1. Fresh reader sees current product and provider scope

1. Open `README.md` and `site/index.html`.
2. Review the app identity, supported-provider descriptions, setup flow, and troubleshooting/reset guidance.
3. **Expected:** The docs describe Pinemeter as a macOS menu bar app, mention Claude monitoring plus optional ChatGPT and Gemini support, and explain setup/reset/troubleshooting without stale ClaudeMeter product branding.

### 2. Public privacy and credential posture is documented

1. Search `README.md` and `site/index.html` for credential, Keychain, local, private, and sanitized diagnostic wording.
2. Compare the wording against the implemented credential boundary summarized by the task artifacts.
3. **Expected:** Docs state that Claude session keys, ChatGPT session cookies, and Gemini API keys are kept behind local Keychain-backed boundaries, and that diagnostics avoid raw cookies, tokens, headers, and API keys.

### 3. Documented local verification command works

1. Confirm `Pinemeter.xcodeproj/project.pbxproj` exists.
2. Confirm `Pinemeter.xcodeproj/xcshareddata/xcschemes/Pinemeter.xcscheme` exists.
3. Run `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug`.
4. **Expected:** The command exits 0.

## Edge Cases

### Legacy references remain intentionally scoped

1. Search public docs for `ClaudeMeter`.
2. **Expected:** Any remaining references are clearly historical, migration, repository-link, bundle-identifier, or legacy export-path references rather than current product identity.

## Failure Signals

- README, site, or changelog presents ClaudeMeter as the current product name.
- README omits one of the current public provider workflows: Claude, ChatGPT, or Gemini.
- Credential or diagnostic wording implies raw credentials are logged, exported, or stored outside the intended local Keychain-backed boundaries.
- Documented build/test commands or Xcode project paths do not exist or fail locally.

## Not Proven By This UAT

- This UAT does not prove S02 contributor templates or support paths.
- This UAT does not prove S03 release/signing documentation beyond public-copy references already checked here.
- This UAT does not perform a full manual fresh-reader comprehension study; S04 owns that broader public UAT.

## Notes for Tester

The README test command is displayed across multiple lines for readability; execute it as `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug`. Treat external GitHub and Homebrew URLs as public documentation strings in this slice; no destructive git or remote-side checks are required.
