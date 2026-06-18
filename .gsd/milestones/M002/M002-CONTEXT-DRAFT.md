# M002: Durable credential acquisition

**Gathered:** 2026-06-18
**Status:** Draft awaiting depth verification

## Project Description

Pinemeter is a macOS 14+ SwiftUI menu bar app for monitoring LLM usage across providers. M002 focuses on making credential acquisition durable and app-owned so users do not repeatedly rely on fragile manual credential workflows.

## Why This Milestone

The project’s core value is reliable menu bar visibility into LLM usage state without repeatedly forcing the user through manual credential import. M001 identified durable credential acquisition as the next milestone after the rename and credential inventory work. M002 should retire the fragile acquisition path for Claude and ChatGPT by letting Pinemeter acquire the needed credential/session material itself and persist it securely.

## User-Visible Outcome

### When this milestone is complete, the user can:

- Open Pinemeter, connect Claude through an app-owned login window, quit and relaunch the app, and continue seeing usage refresh without re-entering credentials.
- Open Pinemeter, connect ChatGPT through an app-owned login window, quit and relaunch the app, and continue seeing usage refresh without re-entering credentials.
- See a clear provider-specific reconnect prompt when Claude or ChatGPT credentials are missing, invalid, expired, or revoked.

### Entry point / environment

- Entry point: Pinemeter macOS menu bar app, likely via Settings or provider status/reconnect UI.
- Environment: local macOS 14+ SwiftUI app using app-owned login UI.
- Live dependencies involved: Claude web session/login, ChatGPT web session/login, macOS Keychain, existing provider usage fetchers.

## Completion Class

- Contract complete means: credential acquisition, validation, persistence, replacement, and failure-state interfaces are covered by unit tests and fixtures where provider web flows can be simulated.
- Integration complete means: acquired Claude and ChatGPT credential/session material is stored through the real credential persistence path and consumed by the real usage refresh paths after app restart.
- Operational complete means: credentials survive app quit/relaunch, invalid credentials do not trigger noisy background loops, and users can intentionally reacquire credentials when prompted.

## Final Integrated Acceptance

To call this milestone complete, we must prove:

- With no usable Claude credential, a user can log in through Pinemeter’s WKWebView-based acquisition window, Pinemeter stores the required session material securely, the app is quit and relaunched, and Claude usage refresh succeeds without re-entering credentials.
- With no usable ChatGPT credential, a user can log in through Pinemeter’s WKWebView-based acquisition window, Pinemeter stores the required session material securely, the app is quit and relaunched, and ChatGPT usage refresh succeeds without re-entering credentials.
- A missing, invalid, expired, or revoked provider credential produces a clear provider-specific reconnect prompt rather than a silent failure, repeated background prompt, or cryptic error.
- The real provider login/session behavior and real macOS Keychain persistence cannot be fully simulated if this milestone is to be considered truly done.

## Architectural Decisions

### App-owned credential acquisition

**Decision:** M002 should implement app-owned in-app credential acquisition rather than only improving manual import.

**Rationale:** The milestone exists to make credential acquisition durable and reduce fragile manual workflows. An in-app login window is the strongest user-visible outcome and aligns with the project’s core value.

**Alternatives Considered:**
- Guided import flow — lower risk, but keeps the user responsible for fragile external credential work.
- Hybrid fallback flow — more resilient, but adds fallback state and broader scope; can be revisited after the main path works.

### Claude and ChatGPT provider scope

**Decision:** M002 should define success across both Claude and ChatGPT, not Claude alone or only a provider-neutral core.

**Rationale:** Proving two different credential/session shapes forces the durable acquisition abstraction to be real while still staying focused on providers already present in the app.

**Alternatives Considered:**
- Claude first — narrower and easier, but may leave the credential model too provider-specific.
- Provider-neutral core — architecturally clean, but weaker as a user-visible milestone unless paired with real provider proof.

### WKWebView session capture

**Decision:** M002 should use a WKWebView-based app-owned login surface for session capture.

**Rationale:** Pinemeter needs enough control to observe the provider cookies/session material required by current usage fetchers. WKWebView offers that control while keeping acquisition inside the app.

**Alternatives Considered:**
- System web auth — stronger OS-native trust posture, but may not expose the session material needed by current unofficial provider APIs.
- External browser handoff — lower embedded-web risk, but too close to the fragile manual workflow this milestone is meant to replace.

### Existing credential handling

**Decision:** M002 should force reacquisition rather than silently preserving old manually-imported credentials as the normal path.

**Rationale:** The user chose a cleaner state model where durable app-owned acquisition becomes the new source of truth, even though it is more disruptive for users with currently-working imported credentials.

**Alternatives Considered:**
- Preserve and upgrade — less disruptive, but leaves old manual credential provenance as an ongoing compatibility concern.
- Parallel credentials — maximum rollback safety, but introduces confusing precedence and extra test states.

## Error Handling Strategy

Provider credential failures should become clear provider-specific reauthentication states. Pinemeter should avoid noisy background loops and cryptic errors: instead of repeatedly prompting, it should mark the affected provider as needing reconnect, preserve safe last-known display state where appropriate, and offer an explicit reconnect action from the menu bar or Settings. Error details should be sufficient for debugging without exposing credential values in logs, UI, files, or diagnostics.

## Risks and Unknowns

- Provider web login/session volatility — Claude and ChatGPT may change cookie names, login flows, bot defenses, or session semantics, which could break acquisition.
- Secret minimization boundary — WKWebView session inspection risks over-collecting sensitive data unless the implementation captures only what the usage fetchers need.
- Forced reacquisition UX — forcing all users onto the new acquisition path is cleaner but disruptive if acquisition fails for one provider.
- App Store or platform policy posture — embedded web login and session capture may affect distribution options or review expectations.
- Testability of real provider flows — unit tests can cover contracts, but final proof needs real macOS and live provider login behavior.

## Existing Codebase / Prior Art

- Existing Claude credential/session handling — M001 identified Claude session key import and Keychain storage as current prior art to replace or supersede.
- Existing ChatGPT credential/session handling — M001 identified ChatGPT session cookie settings and provider-specific error flows as current prior art to replace or supersede.
- SettingsRepository and AppSettings — new user-facing settings or persisted keys must decode old saved settings safely and persist through SettingsRepository.
- SwiftUI menu bar app architecture — UI state should remain on @MainActor @Observable types, with non-UI work in actor services/repositories.

## Relevant Requirements

- Durable credential acquisition — advances the project’s core value of reliable menu bar usage monitoring without fragile repeated manual credential workflows.
- Secure credential storage — acquired credential/session material must be stored securely, expected to use Keychain rather than plaintext settings or files.
- Failure visibility — invalid or missing credentials must surface clear reconnect states.

## Scope

### In Scope

- WKWebView-based in-app login/acquisition flow for Claude.
- WKWebView-based in-app login/acquisition flow for ChatGPT.
- Secure persistence of acquired credential/session material.
- Forced reacquisition behavior for existing manually-imported credentials as the new source of truth.
- Provider-specific reconnect prompts for missing, invalid, expired, or revoked credentials.
- Integration with existing usage refresh paths after app quit/relaunch.
- Tests around acquisition contracts, persistence, invalid/missing credential states, and restart behavior where automatable.

### Out of Scope / Non-Goals

- Gemini credential acquisition or monitoring.
- General provider marketplace or arbitrary provider plugin system.
- External browser handoff as the primary path.
- Silent background reauthentication.
- Broad public open-source polish or git history rewriting.

## Technical Constraints

- macOS 14+ SwiftUI menu bar app.
- UI state on @MainActor @Observable types; non-UI acquisition, validation, and persistence work in actor services/repositories.
- New AppSettings keys must persist through SettingsRepository, appear in SettingsView when user-facing, and decode old saved settings safely.
- Secrets must not be logged, written to plaintext files, checked into the repo, or exposed in diagnostics.
- Existing project verification commands are `xcodebuild clean build -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` and `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug`.

## Integration Points

- Claude web login/session — acquired through app-owned WKWebView and consumed by Claude usage refresh.
- ChatGPT web login/session — acquired through app-owned WKWebView and consumed by ChatGPT usage refresh.
- macOS Keychain — durable storage for acquired credential/session material.
- SettingsView / menu bar status UI — entry points for connect, reconnect, and provider credential status.
- SettingsRepository / AppSettings — any user-facing or persisted acquisition state must pass through existing settings infrastructure.
- Existing provider fetchers/repositories — must consume acquired credentials after restart.

## Testing Requirements

Unit tests should cover provider acquisition state machines, credential validation result mapping, persistence/replacement/removal behavior, old settings decode safety, and failure-state presentation. Integration tests should cover Keychain-backed persistence and provider fetcher consumption where the project can safely use test doubles for provider responses. Manual or UAT verification must cover real macOS app lifecycle with live Claude and ChatGPT login: no credential, acquire through Pinemeter, refresh succeeds, quit/relaunch, refresh still succeeds, then invalid/missing credential produces a reconnect prompt.

## Acceptance Criteria

- Claude can be connected through an in-app WKWebView acquisition flow and continues working after app relaunch.
- ChatGPT can be connected through an in-app WKWebView acquisition flow and continues working after app relaunch.
- Existing manually-imported credentials are not treated as the normal durable source of truth; users are guided to reacquire through the new flow.
- Missing, invalid, expired, or revoked provider credentials produce a clear provider-specific reconnect prompt.
- Credential/session values are not logged or stored outside secure persistence.
- Build and test commands pass after implementation.

## Open Questions

- Should forced reacquisition happen immediately on first launch after upgrade, or only when the user opens provider settings / when refresh first fails?
- What exact credential/session fields are minimally required for Claude and ChatGPT usage refreshers?
- Should the app retain last-known usage while a provider is disconnected, and if so how stale should it appear?
- Are there distribution constraints, such as App Store compatibility, that should influence WKWebView session capture design?
