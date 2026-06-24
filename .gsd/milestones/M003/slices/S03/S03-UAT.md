# S03: Menu bar multi-provider usage — UAT

**Milestone:** M003
**Written:** 2026-06-23T22:26:49.825Z

# S03: Menu bar multi-provider usage — UAT

**Milestone:** M003
**Written:** 2026-06-23

## UAT Type

- UAT mode: runtime-executable
- Why this mode is sufficient: This is a native macOS SwiftUI menu bar slice whose critical behavior is AppModel-driven routing, provider-aware copy, refresh fan-out, and regression-protected menu/icon state. The automated XCTest suite and deterministic source assertions exercise those state transitions without requiring a live credential loop or manual menu bar interaction.

## Preconditions

- macOS 14+ build environment with Xcode available.
- Run from the repository worktree root.
- No live Claude or ChatGPT credentials are required; tests use existing test doubles and repositories.

## Smoke Test

Run `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug`. Expected: the full test suite exits 0.

## Test Cases

### 1. Claude-only usage remains usable

1. Run AppModel tests that cover configured Claude usage.
2. Inspect the menu state exposed by AppModel.
3. **Expected:** a Claude-configured user routes to the usage surface, sees Claude-scoped usage copy, and can refresh Claude usage without requiring ChatGPT.

### 2. ChatGPT-only usage routes to usage instead of setup

1. Use test coverage for an existing ChatGPT session with ChatGPT usage enabled and no Claude setup.
2. Inspect `hasConfiguredUsageProvider` and dashboard title behavior.
3. **Expected:** the menu routes to the usage popover, title/copy identify ChatGPT usage, and the setup prompt is not shown solely because Claude is absent.

### 3. Both providers show a unified dashboard

1. Use AppModel regression coverage with both Claude and ChatGPT configured.
2. Trigger the configured-provider refresh path.
3. **Expected:** the dashboard represents both providers, refresh fans out to visible configured providers, and provider-specific cards remain separate.

### 4. Hidden or unavailable ChatGPT state is safe

1. Run ChatGPTAppModel tests for hidden ChatGPT usage and unavailable ChatGPT storage.
2. **Expected:** hidden ChatGPT usage does not incorrectly count as configured menu usage, unavailable storage publishes sanitized state, and no credential material appears in status or errors.

## Edge Cases

### ChatGPT credential disappears during refresh

1. Run the regression covering missing ChatGPT session during `refreshConfiguredUsageProviders`.
2. **Expected:** ChatGPT is removed/demoted from configured menu state and the menu remains useful for any remaining configured provider.

### No provider configured

1. Inspect AppModel no-provider configured state.
2. **Expected:** no configured usage provider is reported and the menu presents setup/reconnect guidance rather than an empty usage dashboard.

## Failure Signals

- Full XCTest suite fails.
- `hasConfiguredUsageProvider`, `usageDashboardTitle`, or `refreshConfiguredUsageProviders` disappear from the source without equivalent replacement coverage.
- ChatGPT-only setup routes to setup-incomplete UI.
- Mixed-provider refresh only refreshes Claude or refreshes hidden/unconfigured ChatGPT.
- User-facing menu copy regresses to a Claude-only dashboard for mixed-provider state.

## Not Proven By This UAT

- Live menu bar visual polish on a physical macOS status item.
- Live Claude or ChatGPT network usage APIs with real credentials.
- Expired-session end-to-end human recovery flow, which belongs to S04 workflow UAT and diagnostics.

## Notes for Tester

The expected manual experience is that the popover feels provider-aware: Claude-only, ChatGPT-only, and both-provider states should all be understandable without exposing session keys, cookies, headers, or tokens.
