# S04: Gemini menu usage integration — UAT

**Milestone:** M004
**Written:** 2026-06-24T21:39:43.711Z

# S04: Gemini menu usage integration — UAT

**Milestone:** M004
**Written:** 2026-06-24

## UAT Type

- UAT mode: artifact-driven
- Why this mode is sufficient: This slice is a SwiftUI/AppModel integration slice with automated state-boundary and renderer tests. The next slice owns end-to-end Gemini workflow UAT; this UAT verifies that the assembled artifacts and test evidence prove Gemini menu display and refresh/error states are wired for that workflow.

## Preconditions

- Worktree is `/Users/will/code/ClaudeMeter/.gsd-worktrees/M004`.
- S01 through S03 are present so Gemini provider identity, credential state, service seams, setup, and settings surfaces exist.
- Xcode can run the Pinemeter Debug test scheme on the local macOS host.

## Smoke Test

Run `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/MenuBarIconRendererTests`. Expected: command exits 0 and reports the targeted AppModel/MenuBarIconRenderer tests passed.

## Test Cases

### 1. Gemini participates in menu state combinations

1. Inspect or run `PinemeterTests/AppModelTests`.
2. Confirm tests cover Gemini-only, Claude plus Gemini, ChatGPT plus Gemini, and all-provider display state.
3. **Expected:** User-visible provider names, dashboard titles, loading copy, and popover-content availability include Gemini without suppressing Claude or ChatGPT.

### 2. Gemini refresh error is visible in popover state

1. Inspect or run the Gemini refresh-error AppModel regression test.
2. Force the modeled Gemini refresh/error state used by the test.
3. **Expected:** AppModel exposes Gemini error display state suitable for the menu popover instead of hiding it behind other providers.

### 3. Menu renderer remains stable with provider state changes

1. Run `PinemeterTests/MenuBarIconRendererTests` with the AppModel tests.
2. Confirm meter rendering tests pass for normal, loading, and stale states.
3. **Expected:** Adding Gemini menu state does not regress the menu-bar icon rendering surface.

## Edge Cases

### Partial provider configuration

1. Model only one or two configured providers, including Gemini.
2. **Expected:** Popover content is still available when Gemini is configured and other providers are absent or unavailable.

### Three-provider coexistence

1. Model Claude, ChatGPT, and Gemini together.
2. **Expected:** All configured providers remain represented; Gemini does not replace or mask existing provider display state.

### Unrelated full-suite blocker

1. Run the isolated known failing test `PinemeterTests/CopyableErrorPresentationTests/test_userFacingErrorSurfacesUseCopyableErrorText`.
2. **Expected:** If it fails, treat it as outside S04 Gemini menu integration; evidence bf6c5624-390c-4d15-98da-8df7e5af7448 shows it reproduces independently.

## Failure Signals

- AppModel provider-combination tests fail or omit Gemini from display names, dashboard titles, loading copy, or popover-content availability.
- MenuBarIconRendererTests regress after Gemini menu-state integration.
- Gemini refresh errors are not inspectable from AppModel/UI state.
- The popover hides all content when only Gemini is configured.

## Not Proven By This UAT

- Live Gemini API refresh against a real account.
- Full user journey for Gemini setup, recovery, clear/reconnect, and coexistence; that is owned by S05.
- Resolution of the unrelated CopyableErrorPresentationTests full-suite blocker.

## Notes for Tester

Focus on AppModel/menu popover state and provider coexistence. Do not use the unrelated CopyableErrorPresentationTests failure as evidence against Gemini menu integration unless the same failure begins touching S04 files or provider-display behavior.
