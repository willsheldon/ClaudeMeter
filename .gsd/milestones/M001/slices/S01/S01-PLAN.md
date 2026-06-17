# S01: Pinemeter identity migration

**Goal:** Rename ClaudeMeter to Pinemeter across project identity, app/test module surfaces, user-facing copy, docs/site, and workflows wherever safe, while explicitly documenting risky persistent-identifier exceptions that could affect existing users or credentials.
**Demo:** After this: the app, tests, docs/site, metadata, project/scheme surfaces, and primary code symbols use Pinemeter instead of ClaudeMeter, with any risky exceptions explicitly surfaced.

## Must-Haves

- `xcodebuild -list -project Pinemeter.xcodeproj` reports Pinemeter targets and scheme.
- App and test module build surfaces use Pinemeter naming, including source/test root paths, app entry point, scheme, target/product names, and `@testable import Pinemeter`.
- User-facing product copy in setup/settings/about/keychain prompt/docs/site uses Pinemeter, while provider-specific Claude/ChatGPT terminology remains intact.
- Persistent identifiers such as bundle ID, keychain service/access group, cache/export paths, logger subsystem, and historical URLs are either safely renamed with compatibility preserved or listed as explicit S01 exceptions for downstream slices.
- Remaining `ClaudeMeter`/`claudemeter` references are classified as provider-specific, historical, compatibility-preserved, or risky exceptions.
- Renamed test and clean build commands pass, or any failure is a concrete blocker with evidence.

## Proof Level

- This slice proves: High: project/scheme/module rename must be proven with Xcode list, test, clean build, and remaining-reference scans.

## Integration Closure

S01 provides the renamed project shape and identity exception map consumed by S02 credential inventory, S04 architecture review, and S07 final verification.

## Verification

- Rename should preserve or deliberately update log subsystem names; any logger/cache/keychain identifier choices must be visible in the identity map so future agents can diagnose continuity issues.

## Tasks

- [x] **T01: Renamed the build-critical Xcode project, scheme, app/test modules, source roots, and app entry point from ClaudeMeter to Pinemeter.** `est:large`
  Perform the build-critical rename in one coherent change. Rename `ClaudeMeter.xcodeproj` to `Pinemeter.xcodeproj`, source root `ClaudeMeter/` to `Pinemeter/`, test root `ClaudeMeterTests/` to `PinemeterTests/`, shared scheme `ClaudeMeter.xcscheme` to `Pinemeter.xcscheme`, app target/product references to Pinemeter, test target references to PinemeterTests, app entry file/type `ClaudeMeterApp` to `PinemeterApp`, `TEST_HOST` to the Pinemeter app executable, and all test imports to `@testable import Pinemeter`. Update project and scheme container references so `xcodebuild -list` sees the renamed scheme and targets. Do not touch persistent runtime identifiers in this task except when required for build metadata.
  - Files: `ClaudeMeter.xcodeproj/project.pbxproj`, `ClaudeMeter.xcodeproj/xcshareddata/xcschemes/ClaudeMeter.xcscheme`, `ClaudeMeter/App/ClaudeMeterApp.swift`, `ClaudeMeterTests/AppModelTests.swift`, `ClaudeMeterTests/ChatGPTAppModelTests.swift`, `ClaudeMeterTests/ChatGPTUsageServiceTests.swift`, `ClaudeMeterTests/MenuBarIconRendererTests.swift`, `ClaudeMeterTests/NotificationServiceTests.swift`, `ClaudeMeterTests/SessionKeyTests.swift`, `ClaudeMeterTests/SettingsRepositoryTests.swift`, `ClaudeMeterTests/UsageLimitRiskTests.swift`, `ClaudeMeterTests/UsageServiceTests.swift`
  - Verify: xcodebuild -list -project Pinemeter.xcodeproj
rg -n --glob '!.git/**' --glob '!.gsd/**' '@testable import ClaudeMeter|ClaudeMeter\.xcodeproj|-scheme ClaudeMeter|ClaudeMeterTests|ClaudeMeter\.app|struct ClaudeMeterApp' .

- [x] **T02: Updated active product UI copy and metadata from ClaudeMeter to Pinemeter while preserving provider-specific Claude terminology.** `est:medium`
  Update product-owned user-facing strings from ClaudeMeter to Pinemeter in setup, settings/about, login item text, keychain prompt owner text, generated Info.plist build display name, file headers, and comments. Preserve provider-specific Claude/Claude.ai/Claude API/Claude session/Sonnet wording where it describes the monitored provider rather than the product. If `Pinemeter/Resources/Info.plist` remains unreferenced, update path/name only for consistency but note that generated build settings drive runtime display name.
  - Files: `ClaudeMeter/App/SessionKeyImportPromptCoordinator.swift`, `ClaudeMeter/Views/Setup/SetupWizardView.swift`, `ClaudeMeter/Views/Settings/SettingsView.swift`, `ClaudeMeter.xcodeproj/project.pbxproj`, `ClaudeMeter/Resources/ClaudeMeter.entitlements`, `ClaudeMeter/Resources/Info.plist`, `ClaudeMeter/App/ClaudeMeterApp.swift`, `ClaudeMeter/Models/Constants.swift`
  - Verify: rg -n --glob '!.git/**' --glob '!.gsd/**' 'ClaudeMeter|claudemeter|CLAUDEMETER' Pinemeter PinemeterTests Pinemeter.xcodeproj | head -200

- [x] **T03: Created the Pinemeter identity exception map for persistent runtime identifiers and compatibility-sensitive names.** `est:medium`
  Inventory and decide each risky runtime identifier discovered in research: bundle ID, keychain service name, keychain access group/entitlements, Application Support cache directory, public export path, logger subsystem, UserDefaults/sandbox implications, and GitHub repository URLs. Apply only low-risk renames or compatibility-preserving migrations; otherwise leave the old identifier and document it as an explicit S01 exception for S02/M002/S07. Add tests only if runtime migration behavior is changed. Save the identity map as a slice assessment artifact so downstream credential and verification slices do not rediscover it.
  - Files: `ClaudeMeter/Repositories/KeychainRepository.swift`, `ClaudeMeter/Repositories/CacheRepository.swift`, `ClaudeMeter/Services/NetworkService.swift`, `ClaudeMeter/Resources/ClaudeMeter.entitlements`, `ClaudeMeter.xcodeproj/project.pbxproj`
  - Verify: rg -n --glob '!.git/**' --glob '!.gsd/**' 'com\.claudemeter|\.claudemeter|eddmann/ClaudeMeter|ClaudeMeter' Pinemeter PinemeterTests Pinemeter.xcodeproj README.md site .github CHANGELOG.md work-to-date.md
If runtime migration code changes: xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug

- [x] **T04: Updated docs, site, workflows, demo script, and primary visual assets to Pinemeter identity.** `est:medium`
  Update README, site metadata/copy, GitHub Actions project/scheme/test-target names, release workflow naming/artifact references, and agent/project instruction files where they describe the product identity. Preserve historical changelog entries unless they are current install/repo links, and classify remaining historical references. Audit image assets (`docs/heading.png`, setup/settings screenshots, `site/logo.png`, `site/preview.png`) for visible old branding; update only if source assets are available and low risk, otherwise document deferred image refresh as a S01 exception.
  - Files: `README.md`, `site/index.html`, `.github/workflows/test.yml`, `.github/workflows/release.yml`, `.github/workflows/deploy-pages.yml`, `AGENTS.md`, `CLAUDE.md`, `CHANGELOG.md`, `work-to-date.md`
  - Verify: rg -n --glob '!.git/**' --glob '!.gsd/**' 'ClaudeMeter|claudemeter|CLAUDEMETER' README.md site .github AGENTS.md CLAUDE.md CHANGELOG.md work-to-date.md docs || true

- [x] **T05: Ran final rename coverage scans and Xcode verification for the renamed Pinemeter project.** `est:medium`
  Run full remaining-reference scans, classify every remaining ClaudeMeter/claudemeter hit, verify provider-specific Claude terms were not corrupted, and run renamed test and clean build commands. Save a concise S01 completion assessment/UAT note listing renamed surfaces, risky exceptions, verification evidence, and downstream handoff notes for S02/S04/S07. If tests or clean build fail, debug and retry unless the failure is a true environment or signing blocker.
  - Files: `ClaudeMeter.xcodeproj/project.pbxproj`, `ClaudeMeterTests/AppModelTests.swift`, `ClaudeMeterTests/ChatGPTAppModelTests.swift`, `ClaudeMeterTests/ChatGPTUsageServiceTests.swift`, `ClaudeMeterTests/MenuBarIconRendererTests.swift`, `ClaudeMeterTests/NotificationServiceTests.swift`, `ClaudeMeterTests/SessionKeyTests.swift`, `ClaudeMeterTests/SettingsRepositoryTests.swift`, `ClaudeMeterTests/UsageLimitRiskTests.swift`, `ClaudeMeterTests/UsageServiceTests.swift`
  - Verify: rg -n --glob '!.git/**' --glob '!.gsd/**' 'ClaudeMeter|claudemeter|CLAUDEMETER' .
xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug
xcodebuild clean build -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug

## Files Likely Touched

- ClaudeMeter.xcodeproj/project.pbxproj
- ClaudeMeter.xcodeproj/xcshareddata/xcschemes/ClaudeMeter.xcscheme
- ClaudeMeter/App/ClaudeMeterApp.swift
- ClaudeMeterTests/AppModelTests.swift
- ClaudeMeterTests/ChatGPTAppModelTests.swift
- ClaudeMeterTests/ChatGPTUsageServiceTests.swift
- ClaudeMeterTests/MenuBarIconRendererTests.swift
- ClaudeMeterTests/NotificationServiceTests.swift
- ClaudeMeterTests/SessionKeyTests.swift
- ClaudeMeterTests/SettingsRepositoryTests.swift
- ClaudeMeterTests/UsageLimitRiskTests.swift
- ClaudeMeterTests/UsageServiceTests.swift
- ClaudeMeter/App/SessionKeyImportPromptCoordinator.swift
- ClaudeMeter/Views/Setup/SetupWizardView.swift
- ClaudeMeter/Views/Settings/SettingsView.swift
- ClaudeMeter/Resources/ClaudeMeter.entitlements
- ClaudeMeter/Resources/Info.plist
- ClaudeMeter/Models/Constants.swift
- ClaudeMeter/Repositories/KeychainRepository.swift
- ClaudeMeter/Repositories/CacheRepository.swift
- ClaudeMeter/Services/NetworkService.swift
- README.md
- site/index.html
- .github/workflows/test.yml
- .github/workflows/release.yml
- .github/workflows/deploy-pages.yml
- AGENTS.md
- CLAUDE.md
- CHANGELOG.md
- work-to-date.md
