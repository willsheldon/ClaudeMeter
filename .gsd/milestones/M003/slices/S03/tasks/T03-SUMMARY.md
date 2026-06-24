---
id: T03
parent: S03
milestone: M003
key_files:
  - PinemeterTests/AppModelTests.swift
  - PinemeterTests/ChatGPTAppModelTests.swift
key_decisions:
  - Use existing AppModel and ChatGPTAppModel test surfaces for deterministic menu-state regressions instead of adding fragile UI-only assertions.
duration: 
verification_result: passed
completed_at: 2026-06-23T22:22:20.045Z
blocker_discovered: false
---

# T03: Added regression coverage for provider-aware menu state, hidden ChatGPT usage, unavailable ChatGPT storage, and ChatGPT refresh demotion when credentials disappear.

**Added regression coverage for provider-aware menu state, hidden ChatGPT usage, unavailable ChatGPT storage, and ChatGPT refresh demotion when credentials disappear.**

## What Happened

Updated the existing AppModel-focused regression tests rather than introducing fragile UI snapshot assertions. `PinemeterTests/AppModelTests.swift` now covers ChatGPT credentials that are present but hidden from usage, and verifies that a missing ChatGPT session during refresh removes ChatGPT from the configured menu-provider state. `PinemeterTests/ChatGPTAppModelTests.swift` now asserts that unavailable ChatGPT storage and a saved-but-hidden ChatGPT session leave the menu routing in setup/default state instead of advertising ChatGPT usage.

## Failure Modes

External dependencies for this task are test-only substitutes for Keychain-backed ChatGPT session storage, Claude usage fetching, and ChatGPT quota fetching. Storage unavailable is covered in `test_bootstrap_withChatGPTStorageUnavailablePublishesSanitizedStatus`, which verifies sanitized unavailable status and no configured usage provider. A missing ChatGPT session during refresh is covered in `test_refreshConfiguredUsageProviders_missingChatGPTSessionRemovesProviderFromMenuState`, which verifies credential demotion, nil usage data, and default menu copy. Hidden ChatGPT usage despite a saved cookie is covered in both AppModel and ChatGPT bootstrap tests so the menu does not route to usage when the user disables the provider.

## Load Profile


## Negative Tests

Negative coverage added or extended: ChatGPT usage hidden with a saved cookie keeps the menu in setup/default state; ChatGPT credential storage unavailable does not advertise ChatGPT as configured; ChatGPT refresh receiving `missingSessionCookie` clears provider state and resets menu loading copy. These are asserted in `PinemeterTests/AppModelTests.swift` and `PinemeterTests/ChatGPTAppModelTests.swift`.

## Verification

Ran the authoritative narrowed regression command through `gsd_exec`: `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/ChatGPTAppModelTests -only-testing:PinemeterTests/MenuBarIconRendererTests`. The command exited 0 and the targeted AppModel, ChatGPTAppModel, and MenuBarIconRenderer tests passed.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/ChatGPTAppModelTests -only-testing:PinemeterTests/MenuBarIconRendererTests` | 0 | ✅ pass | 9003ms |

## Deviations

None.

## Known Issues

None.

## Files Created/Modified

- `PinemeterTests/AppModelTests.swift`
- `PinemeterTests/ChatGPTAppModelTests.swift`
