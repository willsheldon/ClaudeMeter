---
id: T01
parent: S01
milestone: M005
key_files:
  - README.md
  - site/index.html
  - CHANGELOG.md
  - .github/workflows/release.yml
  - .github/workflows/test.yml
  - .github/workflows/deploy-pages.yml
  - Pinemeter.xcodeproj/project.pbxproj
  - Pinemeter/Models/CredentialState.swift
  - Pinemeter/Repositories/CacheRepository.swift
  - Pinemeter/Views/Settings/SettingsView.swift
  - Pinemeter/Views/Setup/SetupWizardView.swift
key_decisions:
  - Treat T01 as an audit-only task and record proposed documentation changes rather than editing README/site/changelog in this unit.
duration: 
verification_result: passed
completed_at: 2026-07-01T17:45:00.448Z
blocker_discovered: false
---

# T01: Audited public docs against current Pinemeter implementation and identified stale provider, release, version, privacy, export, and changelog claims.

**Audited public docs against current Pinemeter implementation and identified stale provider, release, version, privacy, export, and changelog claims.**

## What Happened

Compared README.md, site/index.html, CHANGELOG.md, .github/workflows, and Pinemeter.xcodeproj/project.pbxproj against implementation surfaces for providers, setup flows, privacy boundaries, build/test/release commands, export paths, diagnostics, and signing identity.

Key mismatches and proposed updates:

1. Provider coverage is incomplete in public docs. README.md:5,44,115,175-176 and site/index.html:10-11,319,354,422 describe Claude plus optional ChatGPT, but implementation includes a first-class Gemini credential/usage surface: Pinemeter/Models/CredentialState.swift:5-16 defines Claude, ChatGPT, and Gemini; Pinemeter/Repositories/GeminiAPIKeyRepository.swift is present; Pinemeter/Services/GeminiUsageService.swift is present; Settings UI copy says Gemini API keys are added in Settings at Pinemeter/Views/Settings/SettingsView.swift:114-117 and setup copy references Gemini key status at Pinemeter/Views/Setup/SetupWizardView.swift:179-182. Proposed update: document Gemini API-key setup, quota visibility/status behavior, and privacy storage alongside Claude and ChatGPT.

2. README install status conflicts with release workflow and site. README.md:61 tells users to download releases but README.md:65 says release distribution and Homebrew packaging are pending; site/index.html:434-455 advertises Homebrew install; .github/workflows/release.yml:179-205 creates GitHub releases and updates eddmann/homebrew-tap. Proposed update: remove the pending-distribution caveat from README or replace it with current release/Homebrew instructions.

3. Site structured version is stale. site/index.html:53 hardcodes softwareVersion 1.0.0, while CHANGELOG.md latest is 1.4.0 and release workflow injects version into site via .github/workflows/deploy-pages.yml:32-55. Pinemeter.xcodeproj/project.pbxproj currently has MARKETING_VERSION=1.0 as the source baseline and release.yml updates it from CHANGELOG at .github/workflows/release.yml:52-57. Proposed update: align static site fallback/current version with CHANGELOG or make deploy injection visibly authoritative.

4. CHANGELOG links still point to ClaudeMeter. CHANGELOG.md:153-169 use github.com/eddmann/ClaudeMeter compare/release URLs even though public docs/site/release workflow now use Pinemeter and bundle/project identity is com.eddmann.Pinemeter. Proposed update: migrate changelog reference links to github.com/eddmann/Pinemeter and decide whether historical 1.0.0 wording should remain ClaudeMeter or be annotated as pre-rename history.

5. Privacy/data-storage docs lag credential boundaries. README.md:207-208 only says Claude session keys are stored in Keychain and browser import stores only the Claude session key. Implementation has separate Keychain-backed ChatGPTSessionRepository and GeminiAPIKeyRepository, sanitized credential diagnostics in CredentialState.swift:119-226, and no raw credential values in diagnostics. site/index.html:422 mentions ChatGPT local session data but not Gemini API keys or sanitized diagnostics. Proposed update: document that Claude session keys, ChatGPT session cookies, and Gemini API keys are credential-equivalent material stored through Keychain boundaries; access tokens remain transient where applicable; diagnostic/acquisition state is sanitized.

6. Browser/setup docs are Claude-centric while setup imports multiple providers. README.md:73-82 says import from a browser signed in to claude.ai and manual setup focuses on Claude sessionKey; SetupWizardView.swift:177-205 says import buttons check Claude and ChatGPT and Gemini API key status appears without credential values. Proposed update: split provider setup into Claude browser import/manual sessionKey, ChatGPT browser import/session cookie, and Gemini API key entry/status.

7. Export documentation is partly current but omits legacy compatibility. README.md:120-148 documents ~/.pinemeter/usage.json. CacheRepository.swift:47-54 and 123-124 write both ~/.pinemeter/usage.json and legacy ~/.claudemeter/usage.json. CHANGELOG.md:89 only records the old ~/.claudemeter/usage.json export. Proposed update: mention primary ~/.pinemeter path plus legacy ~/.claudemeter compatibility if intentionally supported.

8. Troubleshooting/diagnostics docs are missing current reset/repair paths. Implementation exposes repair/reconnect/clear credential actions and copyable error text in SettingsView.swift:759-909, sanitized failure categories in CredentialState.swift:119-226, and Full Disk Access helper copy in SetupWizardView.swift:58 plus SystemSettingsOpener.swift. Public README/site do not explain repair/reset diagnostics beyond browser permissions. Proposed update: add troubleshooting section for browser Safe Storage prompts, Safari Full Disk Access, credential repair/reconnect/clear, provider unavailable/rate-limited/rejected states, and where to inspect local JSON/log surfaces.

9. Build/test docs are under-specified. README.md:179-192 only describes opening Xcode and running ⌘R. Project instructions and .github/workflows/test.yml:30-37 use `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -skip-testing:PinemeterTests/MenuBarIconSnapshotTests CODE_SIGN_IDENTITY="-" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO`; project instructions also specify `xcodebuild clean build -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug`. Proposed update: add CLI build/test commands and note snapshot tests are skipped in CI.

10. Signing identity is implemented but public docs do not mention release trust details. .github/workflows/release.yml:13-14 pins `Developer ID Application: AUTIMO SYSTEMS INC (HMR9RDR6M2)` and Team ID HMR9RDR6M2, verifies signature at lines 107-124, notarizes/staples at lines 126-170. README disclaimer only says app is signed and notarized by Apple. Proposed update: document expected Developer ID/team for users validating release artifacts.

## Failure Modes
External dependencies for this audit were local filesystem reads and diagnostic subprocess execution. Missing optional slice research produced ENOENT for `.gsd/milestones/M005/slices/S01/S01-RESEARCH.md`; this was non-blocking because the inlined plan and source files were sufficient. Diagnostic subprocesses completed successfully with persisted stdout/stderr under `.gsd/exec/`. No network or provider API calls were made.

## Load Profile
No runtime load dimension applies. This task is a bounded static documentation audit over 68 project files and public docs, not a shipped runtime path.

## Negative Tests
No product negative tests apply because this task did not modify implementation or tests. The audit did verify absence/presence boundaries through targeted scans: missing Gemini/public privacy references versus implemented Gemini/credential diagnostics, stale ClaudeMeter changelog links versus Pinemeter workflow/project identity, and README release caveat versus release/Homebrew workflow evidence.

## Observability Impact
Identified gaps in public diagnostic and setup documentation: credential repair/reconnect/clear actions, sanitized provider failure categories, browser Safe Storage and Full Disk Access paths, Keychain privacy boundaries, release signing verification, and JSON export compatibility.

## Verification

Ran two gsd_exec diagnostics. The first scanned 68 implementation/workflow files for provider, identity, export, command, and diagnostics surfaces and confirmed Pinemeter identity, pinned release signing, provider services, and workflow metadata. The second produced focused line-reference evidence across README.md, site/index.html, CHANGELOG.md, Settings/Setup UI, credential diagnostics, export repository, signing workflow, and test workflow. Verification passed because the task summary lists concrete doc mismatches with file references and proposed updates as required by the task plan.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `gsd_exec python: scan Pinemeter, Pinemeter.xcodeproj, and .github/workflows for providers, identity, export paths, commands, diagnostics, project version, and workflow metadata` | 0 | ✅ pass | 991ms |
| 2 | `gsd_exec python: focused doc mismatch audit with line references for README, site, changelog, settings/setup UI, credential diagnostics, export implementation, signing workflow, and test workflow` | 0 | ✅ pass | 218ms |

## Deviations

No public docs were edited; this task's verification contract asks for an audit summary listing mismatches and proposed updates, leaving actual documentation changes for downstream tasks.

## Known Issues

The optional slice research file `.gsd/milestones/M005/slices/S01/S01-RESEARCH.md` was not present in this worktree. This did not block execution because the task plan and audited source files provided enough context.

## Files Created/Modified

- `README.md`
- `site/index.html`
- `CHANGELOG.md`
- `.github/workflows/release.yml`
- `.github/workflows/test.yml`
- `.github/workflows/deploy-pages.yml`
- `Pinemeter.xcodeproj/project.pbxproj`
- `Pinemeter/Models/CredentialState.swift`
- `Pinemeter/Repositories/CacheRepository.swift`
- `Pinemeter/Views/Settings/SettingsView.swift`
- `Pinemeter/Views/Setup/SetupWizardView.swift`
