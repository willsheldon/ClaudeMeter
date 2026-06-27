# S03: Gemini setup and settings UI — UAT

**Milestone:** M004
**Written:** 2026-06-24T21:23:51.063Z

# S03: Gemini setup and settings UI — UAT

**Milestone:** M004
**Written:** 2026-06-24

## UAT Type

- UAT mode: artifact-driven
- Why this mode is sufficient: This slice changes SwiftUI setup/settings presentation and AppModel provider status behavior. The slice is sufficiently covered by the full XCTest suite plus static copy inspection because no live Gemini service call or browser/runtime workflow is introduced until downstream menu integration and workflow UAT slices.

## Preconditions

- Worktree is `/Users/will/code/ClaudeMeter/.gsd-worktrees/M004`.
- Xcode project and tests are available locally.
- No live Gemini, Claude, or ChatGPT credentials are required; tests use model/repository seams and sanitized UI state.

## Smoke Test

Run `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug`. Expected: command exits 0 and reports `** TEST SUCCEEDED **`.

## Test Cases

### 1. Gemini appears in provider setup and settings status

1. Inspect provider status rendering in Settings and Setup views via the provider-copy scan.
2. Confirm Gemini appears alongside Claude and ChatGPT in provider-aware copy and status rows.
3. **Expected:** Gemini setup/status text is present, and no stale two-provider empty-state phrase remains.

### 2. Gemini recovery actions are represented in model and UI workflows

1. Run `PinemeterTests/ProviderErrorWorkflowTests` and `PinemeterTests/AppModelTests` as part of the full suite.
2. Exercise missing, configured, invalid, retry, reconnect, clear, and mixed-provider cases through tests.
3. **Expected:** Gemini state transitions and recovery actions pass without exposing credential material.

### 3. Gemini coexists with Claude and ChatGPT provider states

1. Run the full Debug test suite.
2. Confirm ChatGPT bootstrap and provider matrix expectations match the three-provider state.
3. **Expected:** Existing Claude and ChatGPT behavior remains compatible with Gemini-aware status collections.

## Edge Cases

### Stale provider copy or secret disclosure in setup/settings

1. Run `rg -n "Claude|ChatGPT|Gemini|provider|cookie|key" Pinemeter/Views/Settings Pinemeter/Views/Setup` and review matches.
2. Run stale phrase checks for `both providers`, `two providers`, `Claude and ChatGPT only`, `Claude/ChatGPT`, and `Claude or ChatGPT`.
3. **Expected:** Provider copy is intentionally three-provider aware, stale two-provider phrases are absent, and setup/settings text does not disclose credential material.

## Failure Signals

- Full XCTest suite fails.
- Gemini is absent from provider status/setup copy.
- Setup/settings copy contains stale two-provider assumptions.
- UI copy exposes API keys, cookies, tokens, or secrets.
- Mixed-provider tests regress Claude or ChatGPT behavior while adding Gemini.

## Not Proven By This UAT

- Live Gemini API connectivity or usage refresh.
- Menu bar popover display of Gemini usage.
- End-to-end human setup with real credentials.
- Production signing/notarization behavior.

## Notes for Tester

This UAT is intentionally artifact-driven because S03 is a setup/settings presentation and model-status slice. Downstream slices S04 and S05 are responsible for runtime menu integration and repeatable workflow UAT with refresh/recovery/coexistence behavior.
