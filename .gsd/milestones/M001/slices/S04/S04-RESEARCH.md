# S04 Research: Architecture review baseline

## Summary

Pinemeter is already shaped around the milestone's intended architecture: `AppModel` is `@MainActor @Observable` UI state, and most non-UI work sits behind actor services/repositories. The main architecture risk is not a missing layer; it is that provider-specific workflows, settings persistence side effects, error state, and credential storage conventions are still coordinated directly in `AppModel` and large settings/setup views.

This research is a local architecture baseline. I did not invoke an Opus advisor because local `claude` exists but the available shell lacks a safe timeout wrapper, and auto-mode should not risk blocking on an interactive/quota flow. The baseline below is sufficient for task decomposition and can be supplemented later by Opus if quota/tooling is available.

Memory context found:
- MEM003: attempt Opus if available, but do not block; produce local ranked baseline if quota prevents it.
- MEM002: M001 inventories credential/session handling; M002 owns durable app-owned credential acquisition and persistence.

## Recommendation

Plan S04 follow-up work as a review-and-boundary artifact, not as a broad refactor. The highest-value next tasks are:

1. Document the provider boundary alternatives before changing code: current provider-specific services, a common `UsageProvider` abstraction, or a provider coordinator that keeps service APIs separate but centralizes AppModel orchestration. The `design-an-interface` skill applies here because provider boundaries have multiple plausible shapes.
2. Record a ranked finding list that S05/S06 can consume: credential compatibility identifiers, provider orchestration in `AppModel`, error observability gaps, settings-save side effects, and large view cleanup seams.
3. Use tests as first proof. Existing tests already cover `AppModel`, `ChatGPTUsageService`, and `SettingsRepository`; add review-specific tests only when a later slice changes behavior.
4. Apply the `observability` skill guidance when implementing fixes: prefer durable, non-secret status/failure surfaces over one-off debug logs.

## Requirements and Constraints

- R005 requires ranked architecture review findings.
- R007 requires S06 cleanup/refactoring to use architecture-backed boundaries.
- S01 completed the Pinemeter rename; old identity references are not automatically stale. Keychain/cache/export/access-group identifiers may be compatibility-sensitive until M002.
- App architecture rule: UI state stays on `@MainActor @Observable`; non-UI work stays in actor services/repositories.
- New `AppSettings` keys must persist via `SettingsRepository`, appear in `SettingsView` if user-facing, and decode older saved settings safely.
- Do not perform destructive git actions.

Skill discovery:
- Installed relevant skills: `design-an-interface`, `observability`, `leveraging-cli-tools`.
- Gap: no installed SwiftUI/macOS architecture-specific skill was obvious.
- `npx skills find "SwiftUI macOS architecture"` found promising external skills, notably `rshankras/claude-code-apple-skills@macos-development`; do not install during this slice unless explicitly requested.

## Implementation Landscape

### App orchestration

- `Pinemeter/App/AppModel.swift` (lines 6-8) declares `@MainActor @Observable final class AppModel`.
- `AppModel` owns visible state for both Claude and ChatGPT usage: `usageData`, `chatGPTUsageData`, loading/refresh flags, `errorMessage`, `chatGPTErrorMessage`, setup completion, and ChatGPT cookie presence (lines 18-27).
- `AppModel` injects repositories/services through protocols for settings, keychain, notification, session import, and ChatGPT service, but currently references concrete `UsageService` in the initializer/dependencies scan.
- `AppModel.bootstrap()` loads settings, detects default and ChatGPT keychain accounts, refreshes usage, and starts the refresh loop.
- `AppModel.refreshUsage(forceRefresh:)` and `refreshChatGPTUsage()` are separate provider flows with separate state flags and string error surfaces.
- `AppModel.scheduleSettingsSave(previous:)` debounces settings saves with a `Task`, then restarts refresh behavior when interval/settings changes.

### Provider services

- `Pinemeter/Services/UsageService.swift` (lines 10-18) is an actor with injected `NetworkServiceProtocol`, cache, keychain, and settings repositories. It owns the Claude API base URL (`https://claude.ai/api`) and retry/cache behavior.
- `Pinemeter/Services/Protocols/UsageServiceProtocol.swift` defines a clean actor protocol for Claude operations: fetch usage, fetch organizations, validate session key.
- `Pinemeter/Services/ChatGPTUsageService.swift` defines `ChatGPTUsageError` and an actor service for ChatGPT quota fetching/validation. It uses a cookie-header helper and parses usage buckets into `ChatGPTUsageData`.
- Provider behavior is not unified. This is acceptable for now, but S05/S06 should avoid copying provider conditionals into views or `AppModel`.

### Persistence and credential surfaces

- `Pinemeter/Repositories/KeychainRepository.swift` is an actor and still uses service name `com.claudemeter.sessionkey`. This is likely compatibility-sensitive and should be classified before any rename.
- Accounts are provider-specific: Claude uses `default`; ChatGPT uses `chatgpt`.
- `Pinemeter/Repositories/SettingsRepository.swift` stores JSON `AppSettings` under `app_settings` in UserDefaults and notification state under `notification_state`.
- `Pinemeter/Models/AppSettings.swift` has custom `Codable` decode defaults for old saved settings, including ChatGPT display fields and icon style. This is the required path for adding settings safely.
- `Pinemeter/Repositories/CacheRepository.swift` uses Application Support path component `com.claudemeter` plus disk cache/public JSON export paths. These are compatibility and public-output surfaces, not safe blind cleanup.

### Views and UI seams

- `Pinemeter/Views/Settings/SettingsView.swift` is the largest source file in the app (~889 lines). It likely mixes multiple settings panels, credential controls, ChatGPT fields, import actions, and validation UI. This is the top safe-cleanup candidate after review.
- `Pinemeter/Views/Setup/SetupWizardView.swift` (~226 lines) handles setup/session import/paste behavior. It should remain thin over `AppModel` or a future setup coordinator; avoid embedding provider validation logic there.

### Tests

- `PinemeterTests/AppModelTests.swift` covers bootstrap/setup state, refresh behavior, validation, and injected doubles.
- `PinemeterTests/ChatGPTAppModelTests.swift` covers ChatGPT session detection and save/refresh behavior without requiring Claude setup.
- `PinemeterTests/ChatGPTUsageServiceTests.swift` covers quota status derivation and cookie header normalization.
- `PinemeterTests/SettingsRepositoryTests.swift` covers settings persistence and backward-compatible decode behavior.
- Test doubles exist under `PinemeterTests/TestDoubles/` for cache, keychain, network, notifications, session import, settings, and usage service.

## Ranked Architecture Findings

### 1. High: Provider orchestration is concentrated in `AppModel`

`AppModel` owns both Claude and ChatGPT refresh/setup/session state, including provider-specific flags and error strings. This keeps UI state on the main actor, which is correct, but it makes each new provider or credential workflow expand the central app state object.

Recommendation: Defer code changes until a small provider-boundary design is chosen. Prefer either:
- a `UsageProvider` protocol with provider state/result types, or
- a `ProviderCoordinator` actor/service that keeps provider services distinct but returns main-actor-ready state updates.

Fix/defer: Fix in S06 only if it enables safe cleanup; otherwise defer to M002 provider/session ownership work.

### 2. High: Credential identifier compatibility is under-documented

`KeychainRepository` still uses `com.claudemeter.sessionkey`; `CacheRepository` uses `com.claudemeter`; docs mention `~/.claudemeter/usage.json`. S01 intentionally retained compatibility-sensitive identifiers, but the code does not encode which old names are compatibility contracts versus stale names.

Recommendation: Create a credential/cache identity inventory with classifications: must-preserve, migrate-in-M002, safe-rename, safe-delete. Do not rename keychain/cache/export identifiers in S06 without migration proof.

Fix/defer: Document now; defer migration to M002.

### 3. Medium-high: Error surfaces are user strings, not structured provider status

`AppModel` exposes `errorMessage` and `chatGPTErrorMessage` as strings. Services define typed errors, but by the time errors reach UI state, structured cause/retry/auth-expired information is mostly collapsed into `localizedDescription`.

Recommendation: Introduce a small typed UI failure state when changing this area, e.g. provider, category (`authExpired`, `network`, `quotaParse`, `unknown`), display message, timestamp, retryable flag. Do not log secrets. This aligns with the observability skill's guidance for durable failure state.

Fix/defer: Capture as S05/S06 finding; implement only if task scope includes error workflow audit.

### 4. Medium: Settings save side effects are implicit and centralized

`settings` has a `didSet` that schedules persistence after settings load. `scheduleSettingsSave(previous:)` also influences refresh-loop lifecycle. This is convenient, but future `AppSettings` additions can accidentally create network or lifecycle side effects from view binding changes.

Recommendation: Keep the existing pattern but document it as a convention: new settings must classify whether they are pure persistence, refresh-affecting, or credential-affecting. Add tests around any refresh-affecting setting changes.

Fix/defer: Document now; test in future implementation slices.

### 5. Medium: SettingsView is a large mixed-responsibility view

`SettingsView.swift` is ~889 lines and likely combines layout, provider settings, credential operations, validation status, and import actions. It is a safe cleanup target if split along existing UI sections without changing behavior.

Recommendation: S06 can split the view into section subviews if tests/build pass and no behavior changes are introduced. Avoid moving service logic into subviews; keep actions as closures or `AppModel` calls.

Fix/defer: Fix in S06 only as mechanical extraction.

### 6. Medium-low: Service abstraction is asymmetric

`UsageServiceProtocol` exists for Claude, while `ChatGPTUsageService` has its own protocol file and API shape. That asymmetry is not necessarily wrong because providers differ, but it makes cross-provider status/UI harder.

Recommendation: Use `design-an-interface` before unifying. Avoid forcing a shallow common interface if provider semantics differ.

Fix/defer: Defer unless S05 finds duplicated provider error workflow assumptions.

### 7. Low: Observability is partially present but inconsistent

`UsageService` and `NetworkService` use `Logger(subsystem: "com.pinemeter", ...)`, but app-visible last failure state is limited. Actor/service logs should avoid secrets and include provider/category/status, not raw cookies/session keys.

Recommendation: When touching provider services, add structured, non-secret log contexts and preserve last failure classification in app state or a lightweight diagnostics model.

Fix/defer: Opportunistic in S05/S06.

## Natural Seams for Tasks

1. **Architecture inventory task**: produce a table of provider/service/repository/AppModel/settings/error boundaries with file:line refs and classify old identifiers. Inputs: `AppModel`, repositories, services, models, tests. Output: ranked findings doc.
2. **Provider boundary design task**: apply design-an-interface to compare three designs: keep separate provider flows, introduce `UsageProvider`, introduce `ProviderCoordinator`. Output: recommendation for S05/S06.
3. **Error and observability audit task**: trace typed service errors to `AppModel` string surfaces and UI display. Output: fix/defer list for structured error state.
4. **Settings persistence convention task**: document `AppSettings` addition path and refresh-affecting side effects. Output: checklist consumed by S06.
5. **Safe cleanup candidate task**: identify mechanical extractions from `SettingsView` and old-name references that are safe versus compatibility-sensitive. Output: S06 boundaries.

## First Proof

The first proof for any implementation consuming this review should be non-destructive and test-backed:

1. Run the existing targeted tests:
   - `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests`
   - `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/ChatGPTAppModelTests`
   - `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/ChatGPTUsageServiceTests`
   - `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SettingsRepositoryTests`
2. If only documentation/research changes are made, proof is artifact existence and source coverage, plus no source modification required.
3. If S06 extracts views, proof is full `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` and app build.

## Verification Plan

For S04 research completion:
- Verify `.gsd/milestones/M001/slices/S04/S04-RESEARCH.md` exists via `gsd_summary_save`.
- Verify research covers provider, service, repository, app-state, settings, and error-handling risks.
- Verify Opus attempt status is explicit and non-blocking.

For downstream implementation tasks:
- Refactors: run full test command from project instructions.
- Settings changes: add/adjust decode compatibility tests in `SettingsRepositoryTests` and ensure user-facing settings appear in `SettingsView`.
- Credential/cache identity changes: require migration/compatibility proof before renaming any `com.claudemeter` or `~/.claudemeter` surface.
- Error workflow changes: test both happy path and at least one typed failure path without logging secrets.

## Opus Attempt Status

Status: local-only baseline.

Evidence:
- `claude` command is present at `/Applications/cmux.app/Contents/Resources/bin/claude`.
- The shell does not have a safe `timeout` command, and invoking a model subprocess can block on auth/quota/interactive prompts.
- No repository-local Opus wrapper/config was found by scanning for `claude`, `opus`, and `model` references.

Decision: Do not block S04 on Opus. If an advisor is later available, ask it to review this artifact and the cited source ranges rather than re-scouting the whole repo.

## Sources

Files read/scanned:
- `Pinemeter/App/AppModel.swift` (lines 1-342): main `@MainActor @Observable` app state, provider refresh/setup orchestration, settings save debounce, error strings.
- `Pinemeter/Services/UsageService.swift` (lines 1-174): Claude usage actor, network/cache/keychain/settings dependencies, base URL/retry/cache behavior.
- `Pinemeter/Services/ChatGPTUsageService.swift` (lines 1-196): ChatGPT usage actor, typed errors, cookie header and quota parsing/validation.
- `Pinemeter/Services/NetworkService.swift` (lines 1-82): actor URLSession wrapper, HTTPS validation, request headers, generic decode/error path.
- `Pinemeter/Services/SessionKeyImportService.swift` (lines 1-98): browser session-key import service and imported key validation boundary.
- `Pinemeter/Services/Protocols/UsageServiceProtocol.swift` (lines 1-20): Claude usage protocol boundary.
- `Pinemeter/Repositories/KeychainRepository.swift` (lines 1-112): keychain actor and compatibility-sensitive service name.
- `Pinemeter/Repositories/SettingsRepository.swift` (lines 1-67): UserDefaults JSON persistence and notification state persistence.
- `Pinemeter/Repositories/CacheRepository.swift` (lines 1-119): memory/disk cache and compatibility-sensitive Application Support/export paths.
- `Pinemeter/Models/AppSettings.swift` (lines 1-120): settings model and backward-compatible decode defaults.
- `Pinemeter/Views/Settings/SettingsView.swift` (lines 1-889): large settings UI and safe extraction candidate.
- `Pinemeter/Views/Setup/SetupWizardView.swift` (lines 1-226): setup/session import UI.
- `PinemeterTests/AppModelTests.swift` (lines 1-220): AppModel bootstrap/refresh/session tests.
- `PinemeterTests/ChatGPTAppModelTests.swift` (lines 1-220): ChatGPT AppModel session behavior tests.
- `PinemeterTests/ChatGPTUsageServiceTests.swift` (lines 1-220): ChatGPT data and cookie behavior tests.
- `PinemeterTests/SettingsRepositoryTests.swift` (lines 1-180): settings persistence and decode compatibility tests.

Persisted scan artifacts:
- `.gsd/exec/8d816112-6870-4f35-9755-32a7814dc7f9.stdout`: broad architecture scan.
- `.gsd/exec/5c02399d-c1eb-49e8-bc2f-0bf56abe0c5a.stdout`: compact line excerpts for key architecture files.
- `.gsd/exec/7b13ba89-73dc-495d-bbcc-3aff98e05018.stdout`: test/view/protocol surface scan.
- `.gsd/exec/a1e54360c949c.stdout` equivalent run ID: stale identity and error scan is stored under `.gsd/exec/cbb20581-799c-4d87-a39e-1e54360c949c.stdout`.
