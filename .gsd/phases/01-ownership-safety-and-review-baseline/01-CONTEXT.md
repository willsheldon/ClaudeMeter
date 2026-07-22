# M001: Ownership, safety, and review baseline

**Gathered:** 2026-06-15
**Status:** Ready for planning

## Project Description

Pinemeter is taking ownership of the existing ClaudeMeter macOS SwiftUI menu bar app. M001 renames and reshapes the codebase so it feels owned, safer, and ready for the next milestones: durable credential acquisition, provider-aware workflows, Gemini monitoring, and public open-source polish.

## Why This Milestone

The current app works enough to have a passing test baseline, but it still carries ClaudeMeter identity, Claude-specific assumptions, credential/session surfaces that need security review, and architecture seams that should be understood before adding durable auth and Gemini support. This milestone establishes a reliable ownership baseline before deeper capability work.

## User-Visible Outcome

### When this milestone is complete, the user can:

- Open and build the app as Pinemeter rather than ClaudeMeter.
- See product-facing app surfaces, docs/site copy, and primary metadata use Pinemeter terminology.
- Rely on existing Claude/Opus and GPT monitoring behavior staying intact after rename and cleanup.
- Inspect review artifacts that explain credential, security, provider/error, architecture, and git-history readiness risks.

### Entry point / environment

- Entry point: macOS menu bar app, Xcode project/scheme, settings/setup views, docs/site.
- Environment: local macOS development and CI-like Xcode build/test environment.
- Live dependencies involved: Claude/Opus provider endpoints, ChatGPT provider endpoints, browser cookies, macOS Keychain, local settings storage. M001 primarily audits these rather than requiring live provider success.

## Completion Class

- Contract complete means: Pinemeter rename coverage, credential inventory, security findings, architecture findings, provider/error audit, cleanup notes, and git-history plan exist with active requirements mapped to slices.
- Integration complete means: renamed project/scheme/app surfaces build and tests pass together, or any explicitly approved risky rename exceptions are documented.
- Operational complete means: clean build and test commands pass in the local Xcode environment; no destructive history rewrite or remote push is performed.

## Final Integrated Acceptance

To call this milestone complete, we must prove:

- The app/test project builds and tests after the Pinemeter rename and cleanup.
- Credential/session surfaces are inventoried with enough precision to plan M002 without rediscovery.
- Security, architecture, and provider/error review findings are captured with fix/defer recommendations.
- No secret values are logged, surfaced, or persisted in plaintext by new M001 work.
- No destructive git history rewrite or remote push has occurred.

## Scope

### In Scope

- Full product rename to Pinemeter across app identity, menu bar labels, settings/setup/about-style surfaces, docs/site copy, bundle-facing strings/assets, internal symbols, project/target/scheme names, and tests where feasible.
- If a remaining ClaudeMeter reference is genuinely risky to change, execution must ask rather than silently leave it.
- Open-source readiness baseline for a pretty repo, including repo hygiene and a non-destructive history squash plan.
- Credential/auth surface inventory covering acquisition, storage, reuse, clearing, logging, settings, UI display, and recovery.
- Security review focused on Keychain/session handling, secret exposure risk, logging, persistence, and user-visible recovery.
- Architecture review around services, repositories, app state, provider boundaries, settings, and error handling, using Opus if available.
- Provider/error workflow audit for stale Claude-only or ambiguous Claude/Opus and GPT assumptions.
- Safe cleanup of unused code, stale names, obsolete assumptions, and dead paths.
- Verification through Xcode tests and clean build.

### Out of Scope / Non-Goals

- M002 owns full durable app-owned credential acquisition and persistence.
- M003 owns full provider-aware setup/status/error/recovery/notification workflow redesign.
- M004 owns Gemini usage monitoring; M001 does not implement Gemini monitoring.
- M005 owns contribution templates, issue templates, release-facing docs, and public launch polish.
- Actual destructive git history rewrite or remote push is out of scope without fresh explicit confirmation.

## Architectural Decisions

### Full-stack Pinemeter rename

**Decision:** Rename product-facing and internal identity from ClaudeMeter to Pinemeter in M001 where feasible, including code symbols, tests, docs/site, project/target/scheme names, and metadata.

**Rationale:** The user wants to take ownership of the codebase, not merely repaint the UI. Leaving internal ClaudeMeter assumptions creates future confusion and makes the repo less presentable.

**Alternatives Considered:**
- Surface-only rename now — rejected because it would preserve misleading internal ownership assumptions.
- Defer project/scheme rename — rejected unless execution finds a genuinely risky migration issue that requires escalation.

### Review-first credential architecture

**Decision:** M001 inventories and reviews credential/session handling but does not implement the full durable credential acquisition system.

**Rationale:** The user wants the app to stop asking for keys repeatedly, but the safe flow depends on understanding existing Claude session key import, ChatGPT session-cookie storage, Keychain service names, settings, errors, and recovery behavior first.

**Alternatives Considered:**
- Implement durable auth immediately — rejected because it risks building on unreviewed credential assumptions.
- Ignore credentials until M002 — rejected because M002 needs a concrete inventory and risk map.

### Pragmatic architecture review

**Decision:** Use an Opus subprocess/advisor for architecture review if available, but produce a local ranked review baseline if quota prevents it.

**Rationale:** The user explicitly wants an Opus architecture review, but also noted current Claude quota is unavailable. M001 should not block indefinitely on quota; it should capture the limitation and still produce useful review findings.

**Alternatives Considered:**
- Require Opus review before proceeding — rejected because quota may block execution.
- Skip architecture review entirely — rejected because later durable auth/provider/Gemini work depends on understanding the current seams.

### Destructive git actions require explicit confirmation

**Decision:** M001 may prepare a git history squash/open-source hygiene plan but must not rewrite history or push remotely without fresh explicit confirmation.

**Rationale:** The user wants a pretty public repo and history squashing, but rewriting history and remote publication are destructive/outward-facing actions.

**Alternatives Considered:**
- Squash automatically during M001 — rejected as unsafe without a fresh explicit action gate.

## Error Handling Strategy

Use sensible defaults during M001. Error copy and diagnostics should become less Claude-only where the app context is broader, while not attempting the full M003 workflow redesign. Credential failures should distinguish missing credential, invalid/expired credential, storage/Keychain failure, provider/network failure, and manual-action-required cases where the code already has enough context. User-visible errors should include a safe next action when known. New diagnostics must preserve operation/provider/phase context without logging secrets or session material. Avoid retry/circuit-breaker machinery unless the review finds a concrete need.

## Risks and Unknowns

- Xcode project/target/scheme rename mechanics — can break build settings, schemes, CI, tests, or asset references if done mechanically.
- Bundle identifiers, Keychain service names, and settings defaults — renaming may have migration implications and could orphan existing user data if not handled deliberately.
- Current Claude/Opus quota — may prevent an Opus subprocess architecture review during execution.
- Stale provider naming — many ClaudeMeter, Claude, claude.ai, and ChatGPT references exist and need classification as product identity vs provider-specific terminology.
- History squashing — desirable for public release but destructive if executed without confirmation.

## Existing Codebase / Prior Art

- `ClaudeMeter/App/AppModel.swift` — Main `@MainActor @Observable` app state; contains Claude and ChatGPT state/error surfaces.
- `ClaudeMeter/Repositories/KeychainRepository.swift` — Actor-isolated Keychain storage using a ClaudeMeter-specific service name.
- `ClaudeMeter/Services/SessionKeyImportService.swift` — Imports Claude session keys from browser cookies via SweetCookieKit.
- `ClaudeMeter/Services/UsageService.swift` — Claude usage API service with retry logic and Claude-specific base URL/logger subsystem.
- `ClaudeMeter/Services/ChatGPTUsageService.swift` — ChatGPT quota usage service and ChatGPT-specific error descriptions.
- `ClaudeMeter/Views/Setup/SetupWizardView.swift` — User setup flow for session key entry/import.
- `ClaudeMeter/Views/Settings/SettingsView.swift` — Settings and ChatGPT session cookie surfaces.
- `ClaudeMeterTests/` — Existing test suite; baseline test command passed before planning.
- `README.md` and `site/index.html` — Public-facing docs/site surfaces currently carrying old identity.

## Relevant Requirements

- R001 — M001/S01 owns the comprehensive Pinemeter rename.
- R002 — M001/S07 verifies behavior remains stable.
- R003 — M001/S02 inventories credential/session handling.
- R004 — M001/S03 captures security review findings.
- R005 — M001/S04 captures architecture review findings.
- R006 — M001/S05 audits provider/error workflow assumptions.
- R007 — M001/S06 performs safe cleanup/refactoring.
- R008 — M001/S07 verifies tests and clean build.
- R009 — M001/S07 prepares a non-destructive git history squash/open-source hygiene plan.

## Technical Constraints

- macOS 14+ SwiftUI menu bar app.
- Keep UI state on `@MainActor @Observable` types and non-UI work in actor services/repositories.
- New user-facing `AppSettings` keys must persist through `SettingsRepository`, appear in `SettingsView` when user-facing, and decode old saved settings safely.
- Agent-managed project secrets must only be stored in AWS SSM Parameter Store. Do not use `.env`, shell profiles, plaintext files, logs, or repo files for secrets.
- App credential/session material should not be logged, displayed, or persisted in plaintext.
- Do not commit planning artifacts; `.gsd/` is managed externally.

## Integration Points

- macOS Keychain — stores app credential/session material.
- Browser cookies via SweetCookieKit — current Claude session key import path.
- Claude/Opus usage API — current Claude usage monitoring path.
- ChatGPT quota endpoint/session-cookie flow — current GPT usage monitoring path.
- Xcode project/scheme/CI workflow — build and test integration that must survive rename.
- README/site/docs — public-facing identity surfaces.
- Git history — plan only; no destructive execution without confirmation.

## Testing Requirements

- Run the renamed equivalent of `xcodebuild test -project ClaudeMeter.xcodeproj -scheme ClaudeMeter -configuration Debug`.
- Run the renamed equivalent of `xcodebuild clean build -project ClaudeMeter.xcodeproj -scheme ClaudeMeter -configuration Debug`.
- If project/scheme names are not renamed because of an approved risk, use the current command and document the exception.
- Add or update tests when rename/refactor changes reachable behavior, settings decoding, credential handling, provider error descriptions, or app state transitions.
- Verify no new M001 work logs or exposes secrets/session values.

## Acceptance Criteria

- S01 proves comprehensive rename coverage or escalates risky exceptions.
- S02 produces credential/session inventory detailed enough for M002.
- S03 produces ranked security findings with fix/defer recommendations.
- S04 produces ranked architecture findings, including Opus attempt status.
- S05 produces provider/error workflow audit and applies obvious safe copy fixes.
- S06 removes safe stale code/names/assumptions and documents any deferred cleanup.
- S07 proves tests and clean build pass and produces a non-destructive git history/open-source hygiene plan.

## Open Questions

- Can Opus be invoked during execution, or will quota require a local-only architecture review baseline?
- Are project/scheme/bundle rename mechanics fully safe, or do any require user escalation?
- Should Keychain service-name migration preserve existing stored credentials immediately, or be deferred to M002 with explicit findings?
