# S04 Architecture Review Baseline

## Scope

This review covers the Pinemeter architecture after S01-S03: `AppModel`, provider usage services, settings persistence, credential/session surfaces, settings/setup views, and downstream seams for S05/S06. It is an artifact-only slice; no production source changes are required here.

## Current Boundary Map

| Area | Current owner | Evidence | Assessment |
|---|---|---|---|
| UI state and orchestration | `@MainActor @Observable final class AppModel` | `ClaudeMeter/App/AppModel.swift` | Correct main-actor boundary, but too many provider and credential workflows are coordinated in one type. |
| Claude usage | `UsageService` behind `UsageServiceProtocol` | `ClaudeMeter/Services/UsageService.swift` | Good service seam; AppModel still owns refresh state and error string. |
| ChatGPT usage | `ChatGPTUsageService` plus WebView/network helpers | `ClaudeMeter/Services/ChatGPTUsageService.swift`, `WebViewNetworkService.swift` | Provider-specific flow is intentionally separate, but AppModel coordinates credential existence, refresh, and settings visibility. |
| Settings persistence | `SettingsRepository` actor storing `AppSettings` under `app_settings` | `ClaudeMeter/Repositories/SettingsRepository.swift`, `ClaudeMeter/Models/AppSettings.swift` | Good actor isolation and credential-free preference model. Keep credentials out of `AppSettings`. |
| Credentials/session material | Keychain accounts plus transient UI state | `AppModel` credential methods, setup/settings views | Must preserve redaction and keep `com.claudemeter.sessionkey` compatibility unless a migration is explicitly implemented. |
| User-facing configuration UI | `SettingsView`, `SetupWizardView` | `ClaudeMeter/Views/Settings/SettingsView.swift`, `ClaudeMeter/Views/Setup/SetupWizardView.swift` | Views are large and contain provider-specific entry/validation flows; refactor only after S05 clarifies workflow behavior. |

## Provider Boundary Alternatives

### A. Keep provider-specific services and AppModel orchestration

- **Shape:** Continue with `UsageService` and `ChatGPTUsageService`; AppModel owns refresh state, credential checks, and visibility settings.
- **Pros:** Smallest change, matches current tests, no premature abstraction over unlike providers.
- **Cons:** AppModel continues to grow; provider-specific error/status handling remains scattered.
- **Use when:** S05 finds provider workflows are too different for a common abstraction.

### B. Introduce a common `UsageProvider` abstraction

- **Shape:** Define a provider protocol exposing refresh, credential status, display state, and errors.
- **Pros:** Could simplify UI iteration across Claude, ChatGPT, Gemini.
- **Cons:** Risky now: Claude session keys, ChatGPT cookies/tokens, and future Gemini auth likely have different lifecycles. A common abstraction may hide important credential/security differences.
- **Use when:** M003/M004 prove the provider flows have converged.

### C. Add a provider coordinator while keeping service APIs separate

- **Shape:** Keep provider-specific services, but move AppModel provider orchestration into a coordinator/state object that reports provider status, refresh phases, and sanitized errors.
- **Pros:** Reduces AppModel without pretending providers are identical; creates one place for diagnostics/redaction; prepares Gemini without forcing a universal provider protocol.
- **Cons:** Adds one new boundary and needs careful tests around state transitions.
- **Recommendation:** Prefer this for S06/M003 if S05 confirms current provider workflows stay separate.

## Ranked Findings

| Rank | Finding | Severity | Files | Recommendation | Owner |
|---:|---|---|---|---|---|
| 1 | Credential compatibility and redaction are architecture invariants, not cleanup details. | High | `KeychainRepository`, `AppModel`, credential UI/services | Do not rename `com.claudemeter.sessionkey` or expose Cookie/Bearer/session material without an explicit migration and redaction tests. | M002 |
| 2 | AppModel coordinates too many provider-specific workflows. | Medium | `ClaudeMeter/App/AppModel.swift` | Defer code extraction until S05 maps provider/error flows; then consider coordinator option C. | S05/S06 |
| 3 | Provider errors are string-based and split by provider. | Medium | `AppModel`, services, settings/setup views | Introduce sanitized provider error/status model before adding more providers. | S05/M003 |
| 4 | Settings persistence is correctly credential-free but has side effects from broad `settings` mutation. | Medium | `AppSettings`, `SettingsRepository`, `AppModel.scheduleSettingsSave` | Keep as-is for M001; when adding settings, test decode compatibility and save behavior. | S06+ |
| 5 | Settings and setup views are large provider workflow surfaces. | Low | `SettingsView`, `SetupWizardView` | Refactor only after workflow audit; extract credential entry components with tests if touched. | S06 |

## Downstream Handoff

| Downstream | Needs from S04 |
|---|---|
| S05 Provider and error workflow audit | Validate whether provider workflows remain distinct and define sanitized provider error/status shapes. |
| S06 Safe cleanup and ownership refactor | Prefer small extractions around views or AppModel coordinator seams; avoid credential storage changes. |
| M002 Durable credential acquisition | Treat session/cookie/token flows as credential-equivalent and preserve Keychain service compatibility. |
| M003/M004 Provider expansion | Do not introduce a universal provider abstraction until Claude, ChatGPT, and Gemini lifecycles are compared. |

## Decision

For the next implementation slice, do **not** introduce a universal `UsageProvider` protocol yet. Keep provider-specific services and, if cleanup is needed, extract orchestration into a provider coordinator that preserves provider-specific auth and error semantics.

## Verification

- Reviewed S04 research and current source surfaces listed above.
- No production source files modified.
- Artifact provides boundary map, three alternatives, recommendation, ranked findings, and downstream handoff.
