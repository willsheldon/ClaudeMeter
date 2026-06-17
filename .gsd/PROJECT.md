# Project

## What This Is

Pinemeter is a macOS 14+ SwiftUI menu bar app for monitoring LLM usage across providers. It began as the ClaudeMeter codebase and M001 completed the ownership baseline: primary app identity, project/scheme names, source/test/module surfaces, docs/site copy, and active user-facing references now use Pinemeter, while compatibility-sensitive credential/cache identifiers are explicitly classified for later migration.

## Core Value

The one thing that must survive every tradeoff is: Pinemeter should reliably show the user their current LLM usage state from the menu bar without repeatedly forcing them through fragile manual credential workflows.

## Project Shape

- **Complexity:** complex
- **Why:** The work crosses macOS app identity, Xcode project naming, secure credential/session handling, provider-specific network services, Keychain persistence, error workflows, architecture review, and future multi-provider expansion.

## Current State

M001 is complete. The app builds and tests as Pinemeter using `Pinemeter.xcodeproj` and the `Pinemeter` scheme. Credential and session surfaces have been inventoried; security and architecture review baselines exist; provider/error workflow assumptions have been audited; safe stale ownership cleanup has been applied; and a non-destructive git-history/open-source hygiene plan exists. Existing Keychain service/access-group, cache, and export identifiers that could orphan user data remain compatibility surfaces for M002 rather than silent rename omissions.

## Architecture / Key Patterns

The project uses Swift and SwiftUI. Project convention is to keep UI state on `@MainActor @Observable` types and non-UI work in actor services/repositories. Current important seams include `AppModel`, `UsageService`, `ChatGPTUsageService`, `SessionKeyImportService`, `KeychainRepository`, `SettingsRepository`, setup/settings views, and error models. Security-sensitive app credential material should stay in Keychain-style secure storage; settings persistence should remain credential-free unless a later milestone deliberately changes the credential model with migration and verification.

## Capability Contract

See `.gsd/REQUIREMENTS.md` for the explicit capability contract, requirement status, and coverage mapping. M001 requirements R001-R009 are validated; R010-R014 remain deferred for later milestones; R015-R017 remain M001 anti-feature/out-of-scope constraints.

## Milestone Sequence

- [x] M001: Ownership, safety, and review baseline — Renamed ClaudeMeter to Pinemeter, inventoried credentials, captured security and architecture findings, cleaned safe stale code, and verified the app still builds/tests.
- [ ] M002: Durable credential acquisition — Implement app-owned credential/session acquisition and persistence so users are not repeatedly asked for keys.
- [ ] M003: Multi-provider workflow polish — Make setup, status, errors, recovery, and notifications provider-aware across monitored LLM providers.
- [ ] M004: Gemini monitoring extension — Add Gemini usage monitoring using the established provider/auth/error patterns.
- [ ] M005: Public open-source polish — Finish contribution conventions, issue templates, release-facing docs, and launch-grade public repo presentation.
