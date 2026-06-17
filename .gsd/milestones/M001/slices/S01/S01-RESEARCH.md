# S01 Research: Pinemeter identity migration

## Summary

S01 is a high-risk rename slice because product identity is embedded in Xcode project/scheme/target names, module imports, bundle identifiers, generated Info.plist keys, GitHub workflows, docs/site copy, app UI, logging/cache/keychain identifiers, and filesystem paths. The current app still builds as `ClaudeMeter` with targets `ClaudeMeter` and `ClaudeMeterTests` and one shared scheme `ClaudeMeter` (`xcodebuild -list -project ClaudeMeter.xcodeproj`, evidence `gsd_exec d36bf4cf-07e7-464a-b4ab-d0909001d4ef`).

Primary requirement owned: R001 comprehensive Pinemeter rename. Supporting requirements: R002/R008 behavior and build/test stability. Durable memory confirms the project decision: perform comprehensive product and internal rename wherever feasible, including project, scheme, target, source symbols, tests, docs/site, metadata, and user-facing copy.

No project-specific SwiftUI skill is installed. `npx skills find "SwiftUI macOS Xcode"` surfaced possible future skills such as `dimillian/skills@macos-spm-app-packaging` and `vabole/apple-skills@guide-macos-spm-packaging`; do not install during this slice unless explicitly asked.

## Recommendation

Plan S01 as an ordered rename with an early Xcode proof:

1. Rename Xcode project, scheme, app/test targets, module, product, and source/test root directories to `Pinemeter`/`PinemeterTests`; update `.xcodeproj/project.pbxproj`, `.xcscheme`, test imports, `TEST_HOST`, workflow commands, and filesystem paths together.
2. Rename the Swift app entry symbol `ClaudeMeterApp` to `PinemeterApp` and update file headers/comments where they carry product identity.
3. Update generated Info.plist build settings and user-facing UI/docs/site strings from ClaudeMeter to Pinemeter.
4. Treat persistent identifiers separately: bundle IDs, keychain access group/service names, cache directories, exported `~/.claudemeter` path, logger subsystem, and old GitHub URLs need an explicit compatibility decision. Renaming them blindly can orphan existing data or change signing/keychain behavior.
5. Run `xcodebuild -list` immediately after project/scheme rename, then the renamed test command, then clean build. Fix module/import failures before touching lower-risk docs.

Suggested final commands after successful rename:

```bash
xcodebuild -list -project Pinemeter.xcodeproj
xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug
xcodebuild clean build -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug
```

If CI signing remains fragile, workflows already use code-signing overrides in test; local milestone acceptance still wants the clean build command unless an approved exception is documented.

## Implementation Landscape

### Xcode/project/scheme surfaces

Critical files:

- `ClaudeMeter.xcodeproj/project.pbxproj`
  - File references: `ClaudeMeter.app`, `ClaudeMeterTests.xctest`, root groups `ClaudeMeter`, `ClaudeMeterTests`.
  - Targets: `ClaudeMeter`, `ClaudeMeterTests`; target dependency `remoteInfo = ClaudeMeter`.
  - Build settings from compact scan (`gsd_exec debfd3bd-f00e-43ed-99f6-05e32bc11d6d`, `1829b0f7-82cc-42e5-bd7f-6326957676b5`):
    - `PRODUCT_BUNDLE_IDENTIFIER = com.eddmann.ClaudeMeter` and `com.eddmann.ClaudeMeterTests`.
    - `INFOPLIST_KEY_CFBundleDisplayName = ClaudeMeter` in app Debug/Release.
    - `PRODUCT_NAME = "$(TARGET_NAME)"`, so target rename controls app/test product names.
    - Test target `TEST_HOST = "$(BUILT_PRODUCTS_DIR)/ClaudeMeter.app/Contents/MacOS/ClaudeMeter"` must become Pinemeter.
    - `GENERATE_INFOPLIST_FILE = YES`; checked-in `ClaudeMeter/Resources/Info.plist` exists but appears not referenced by `INFOPLIST_FILE`.
- `ClaudeMeter.xcodeproj/xcshareddata/xcschemes/ClaudeMeter.xcscheme`
  - `BuildableName = "ClaudeMeter.app"`, `BlueprintName = "ClaudeMeter"`, `ReferencedContainer = "container:ClaudeMeter.xcodeproj"`.
  - Rename scheme file to `Pinemeter.xcscheme` and update references.
- `.github/workflows/test.yml`
  - Uses `-project ClaudeMeter.xcodeproj`, `-scheme ClaudeMeter`, `-skip-testing:ClaudeMeterTests/MenuBarIconSnapshotTests`.
- `.github/workflows/release.yml`
  - Workflow name is `Release ClaudeMeter`; updates `ClaudeMeter.xcodeproj/project.pbxproj`; builds `ClaudeMeter`; likely names artifacts/releases with old identity further down. Search/update all `ClaudeMeter` occurrences.
- `.github/workflows/deploy-pages.yml`
  - No obvious project build coupling from initial scan, but include in final identity scan.

Natural seam: Xcode/project/scheme/target/module rename should be a single task because partial changes break imports, `TEST_HOST`, scheme buildables, and workflow commands together.

### Source and test filesystem/module surfaces

Current source/test roots:

- `ClaudeMeter/` should likely become `Pinemeter/`.
- `ClaudeMeterTests/` should likely become `PinemeterTests/`.
- `ClaudeMeter/App/ClaudeMeterApp.swift` contains `@main struct ClaudeMeterApp: App`; rename file and type to `PinemeterApp`.
- Tests use `@testable import ClaudeMeter` throughout. Update all to `@testable import Pinemeter` after target/module rename. Evidence: `gsd_exec 2d7baf0e-f8f3-4358-b7b7-569f8a0d990f`.

Most `ClaudeMeter` source references are file-header comments and safe mechanical replacements once paths and module are handled. Provider-specific `Claude`, `Claude.ai`, `Claude API`, `Claude session`, and `Sonnet` strings are not product identity and should not be blanket-renamed.

### User-facing app/UI surfaces

Important files:

- `ClaudeMeter/Views/Setup/SetupWizardView.swift`
  - `Text("Welcome to ClaudeMeter")`.
  - `Text("Setup complete! Launching ClaudeMeter...")`.
  - `Text("Monitor your Claude.ai plan usage in real-time")` and `Text("Claude Session")` are provider-specific and probably remain until S05/M003 unless copy polishing is obviously safe.
- `ClaudeMeter/App/SessionKeyImportPromptCoordinator.swift`
  - Comment and prompt: `ClaudeMeter will ask macOS Keychain...`; rename product owner but keep Claude browser session wording.
- `ClaudeMeter/Views/Settings/SettingsView.swift`
  - About tab: `Text("ClaudeMeter")`, `Text("Monitor your Claude.ai usage limits")`, GitHub link `https://github.com/eddmann/ClaudeMeter`.
  - Login item copy around line 92: `Automatically launch ClaudeMeter when you log in`.
- `ClaudeMeter/Models/IconStyle.swift`
  - Description: `Compact quota meters for Claude and ChatGPT` is provider-specific, not product identity.

Natural seam: UI/product copy can follow Xcode rename. Avoid broad `Claude -> Pine` replacements; only replace `ClaudeMeter` and `claudemeter` identity unless a human confirms provider copy changes.

### Persistent identifiers and risky rename exceptions

These are high-risk because they can affect existing users, app sandbox/keychain access, cache location, or external integrations:

- `ClaudeMeter/Repositories/KeychainRepository.swift`
  - `private let serviceName = "com.claudemeter.sessionkey"`.
  - Blind rename to `com.pinemeter.sessionkey` would not find existing credentials. Safer options for planner: either keep as a documented S01 exception until S02/M002, or implement fallback/migration from old service to new service with tests.
- `ClaudeMeter/Resources/ClaudeMeter.entitlements`
  - `$(AppIdentifierPrefix)com.claudemeter` keychain access group.
  - It appears not referenced by project build settings (`CODE_SIGN_ENTITLEMENTS` not found in compact build-setting scan), but if wired later, renaming access group changes keychain access semantics and signing requirements.
- `ClaudeMeter/Repositories/CacheRepository.swift`
  - Application Support cache dir: `com.claudemeter`.
  - Public export path: `~/.claudemeter/usage.json` (also mentioned in `CHANGELOG.md`). Changing it may break external tools or lose cache continuity.
- `ClaudeMeter/Services/NetworkService.swift` and likely other services
  - Logger subsystem `com.claudemeter` appears in code (`gsd_exec 312ec07b-d62d-436c-8e96-08937f2d2f60`). Safe from behavior perspective, but useful for log continuity. Rename is likely okay if accepted as ownership identity; document if retained.
- `PRODUCT_BUNDLE_IDENTIFIER = com.eddmann.ClaudeMeter`
  - Full ownership rename likely wants a new bundle ID such as `com.pinemeter.Pinemeter` or `com.pineit.Pinemeter`, but changing it changes app identity, preferences container, sandbox container, login item identity, and update/signing behavior. This should be an explicit decision/escalation item if no owner domain is known.

Recommendation for planner: split persistent identifiers into a task that produces an identity map with one status per identifier: rename now, migrate with fallback, or defer as risky exception. Do not silently leave old names.

### Docs/site/assets surfaces

Files:

- `README.md`: title, image alt text, installation, GitHub release URL, setup text, notification text all say ClaudeMeter.
- `site/index.html`: title/meta/keywords and page copy say ClaudeMeter; image assets `site/logo.png`, `site/preview.png` may visually contain old branding.
- `CHANGELOG.md`: old repo compare links and historical entries. Keep historical changelog content unless ownership policy says to rewrite old release history; update current project links if present. `~/.claudemeter/usage.json` reference is a compatibility/export decision.
- `work-to-date.md`: intentionally historical planning note mentioning Pinemeter rebrand; likely leave or archive, but exclude from product identity acceptance if it is internal historical context.
- `docs/heading.png`, `docs/setup-wizard.png`, `site/logo.png`, `site/preview.png`, and screenshots may visually include ClaudeMeter strings. Images were identified by path/dimensions, not OCR. Planner should include a visual asset audit or explicitly document deferred image refresh if no source art exists.
- `AGENTS.md` and `CLAUDE.md`: project/agent instruction files mention ClaudeMeter. Since AGENTS is preloaded project context, updating it may matter for future agents, but be careful not to remove provider-specific Claude references.

Natural seam: docs/site text is independent after build-critical rename. Image asset replacement may be separate and may require user/design input.

## First Proof / Highest-Risk Unblocker

The first proof should be the Xcode rename, not docs copy. Successful minimum proof:

1. Filesystem paths and project metadata renamed enough that `xcodebuild -list -project Pinemeter.xcodeproj` reports targets `Pinemeter`, `PinemeterTests` and scheme `Pinemeter`.
2. `@testable import Pinemeter` compiles.
3. `TEST_HOST` points to `Pinemeter.app/Contents/MacOS/Pinemeter`.

This retires the biggest unknown: whether file-system-synchronized Xcode groups and shared scheme references survive the project/target/module rename.

## Verification Plan

Fast scans after each task:

```bash
rg -n --glob '!.git/**' --glob '!.gsd/**' 'ClaudeMeter|claudemeter|CLAUDEMETER' .
rg -n --glob '!.git/**' --glob '!.gsd/**' '@testable import ClaudeMeter|ClaudeMeter\.xcodeproj|-scheme ClaudeMeter|ClaudeMeterTests|ClaudeMeter\.app' .
xcodebuild -list -project Pinemeter.xcodeproj
```

Full verification at slice end:

```bash
xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug
xcodebuild clean build -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug
```

If workflows are updated, also check textual consistency:

```bash
rg -n 'ClaudeMeter|claudemeter|CLAUDEMETER' README.md site .github Pinemeter PinemeterTests Pinemeter.xcodeproj
```

Acceptance scan should classify any remaining hits as one of:

- provider-specific Claude references that should remain (`Claude.ai`, `Claude API`, `Claude session`, `Sonnet`),
- historical docs/changelog references intentionally retained,
- compatibility identifiers intentionally retained pending migration,
- risky exceptions escalated/documented.

## Risks / Watch-outs

- File-system-synchronized Xcode root groups mean folder path rename and pbxproj group path rename must match exactly.
- Generated Info.plist build settings are the active bundle display source; `ClaudeMeter/Resources/Info.plist` may be stale or unreferenced. Do not assume editing it changes the built app.
- The checked-in entitlements file appears unreferenced by `CODE_SIGN_ENTITLEMENTS`; decide whether to rename/move it or leave/delete later in S06 after confirming build settings.
- Bundle ID and keychain/cache identifiers are not just names. Renaming without migration can lose preferences/cache/session access. S01 can document exceptions, but should not silently leave them.
- GitHub URLs currently point to `eddmann/ClaudeMeter`; public repo destination is not specified. Use placeholder/new URL only if product owner is known, otherwise leave a documented TODO/exception for S07 public-history/open-source plan.
- Provider-specific Claude terminology should remain where it describes Claude provider behavior; broad replacement of `Claude` would corrupt setup and API semantics.
- Existing screenshots/logo/preview images likely need visual review; text scans do not catch rendered old names.
- Do not commit or modify `.gsd/`; all implementation should stay in the worktree source/docs/project files.

## Suggested Task Boundaries for Planner

1. **Xcode/module/path rename task**: rename `ClaudeMeter.xcodeproj`, source/test roots, scheme file, app/test targets, product references, `TEST_HOST`, test imports, and app entry type. Verify with `xcodebuild -list` and a compile/test attempt.
2. **Product UI copy task**: update Setup Wizard, Settings/About, Keychain prompt owner text, login item text, and display name build settings. Keep provider-specific Claude copy intact unless clearly product-owned.
3. **Persistent identity map task**: enumerate bundle ID, keychain service/access group, cache/export paths, logger subsystem, UserDefaults/sandbox implications; implement safe renames only where compatibility is not harmed, otherwise record explicit S01 exceptions for S02/M002/S07.
4. **Docs/site/workflow task**: update README, site metadata/copy, GitHub Actions project/scheme/test-target names, and release workflow naming/artifact references. Identify image assets that need regeneration.
5. **Final coverage/verification task**: run remaining-reference scans, classify exceptions, run renamed test and clean build commands, and produce S01 output for downstream slices.

## Sources / Evidence

- `memory_query "Pinemeter identity migration ClaudeMeter rename"`: MEM001 comprehensive rename decision; MEM005 milestone sequencing.
- `gsd_exec b6196268-2e17-487e-a123-423089334e7a`: top-level inventory, reference counts, Xcode/project surfaces.
- `gsd_exec 5f636aeb-0898-4ef6-aa2b-adf703212d1d`: detailed ClaudeMeter reference map.
- `gsd_exec b37163d2-f17d-463c-892b-b291e27f153a`: source/docs/site inventory.
- `gsd_exec d36bf4cf-07e7-464a-b4ab-d0909001d4ef`: current Xcode project list showing targets/scheme.
- `gsd_exec debfd3bd-f00e-43ed-99f6-05e32bc11d6d` and `1829b0f7-82cc-42e5-bd7f-6326957676b5`: build-setting summaries.
- `gsd_exec 2d7baf0e-f8f3-4358-b7b7-569f8a0d990f`: test import/module references.
- `gsd_exec 18e82d7a-7fae-4582-b39e-9f65e2de46c5`, `bf1b56e0-a0f1-49bf-8050-4ca481e7a75b`, `312ec07b-d62d-436c-8e96-08937f2d2f60`: UI, cache/keychain/logger, and product string scans.
