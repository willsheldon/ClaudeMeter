---
id: T04
parent: S03
milestone: M003
key_files:
  - Pinemeter/App/AppModel.swift
  - Pinemeter/Views/MenuBar/MenuBarPopoverView.swift
  - Pinemeter/Views/MenuBar/UsagePopoverView.swift
  - PinemeterTests/AppModelTests.swift
  - PinemeterTests/ChatGPTAppModelTests.swift
key_decisions:
  - No source changes were made because the provider-aware menu behavior and regression coverage were already present and verified.
duration: 
verification_result: passed
completed_at: 2026-06-23T22:24:03.456Z
blocker_discovered: false
---

# T04: Verified the menu bar multi-provider behavior with full-suite tests and deterministic copy scans, with no scope-relevant code changes required.

**Verified the menu bar multi-provider behavior with full-suite tests and deterministic copy scans, with no scope-relevant code changes required.**

## What Happened

Reviewed the active-unit source context for `AppModel`, `MenuBarPopoverView`, `UsagePopoverView`, and the ChatGPT-focused AppModel regression tests. The menu bar routing now uses `hasConfiguredUsageProvider`, title/loading copy is provider-aware for Claude-only, ChatGPT-only, mixed-provider, and no-provider states, refresh fans out through `refreshConfiguredUsageProviders`, and Claude credential recovery copy is scoped to Claude errors.

No files were modified because the requested behavior was already present and the verification checks passed.

## Failure Modes
- External dependencies for this verification task were the Xcode test subprocess and local source-file scans. The Xcode subprocess could fail via build/test failure, simulator/runtime issue, or timeout; the task bubbles that through nonzero `gsd_exec` evidence. The source scan could fail on missing files or stale copy assertions; the deterministic Python assertion exits nonzero if any required provider-aware copy surface is absent.
- Runtime provider failure paths are covered by existing tests and source behavior: ChatGPT storage unavailable publishes sanitized unavailable state and leaves the menu in setup state; invalid ChatGPT cookies publish provider-rejected status without saving secrets; ChatGPT usage fetch failures stay isolated from Claude usage/error state; missing ChatGPT cookies demote ChatGPT state and clear ChatGPT usage data.

## Load Profile

## Negative Tests
- `PinemeterTests/ChatGPTAppModelTests.swift` covers ChatGPT storage unavailable, hidden ChatGPT usage, invalid ChatGPT cookie rejection, invalid cookie not saved, ChatGPT fetch failure isolation from Claude state, and clearing only the ChatGPT account.
- Prior S03 coverage in `PinemeterTests/AppModelTests.swift` covers provider-aware menu state regressions for Claude-only, ChatGPT-only, both-provider, loading, refresh disabled state, and Claude recovery copy scoping.
- The deterministic scan asserted that no-provider copy is multi-provider, ChatGPT-only and mixed-provider titles exist, refresh fan-out exists, and Claude recovery remains scoped to Claude errors.

## Verification

Ran the required copy review command through `gsd_exec` and reviewed the captured matches for menu/App provider language. Ran the full required Xcode test suite through `gsd_exec`; it exited 0. Added a deterministic source assertion through `gsd_exec` for the specific multi-provider menu surfaces: provider-aware route, ChatGPT-only title, mixed-provider title, no-provider prompt, refresh fan-out, and Claude-scoped recovery.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `rg -n "Claude Usage|Setup|ChatGPT|provider" Pinemeter/Views/MenuBar Pinemeter/App` | 0 | ✅ pass | 27ms |
| 2 | `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` | 0 | ✅ pass | 7042ms |
| 3 | `python3` deterministic stale Claude-only menu copy assertion | 0 | ✅ pass | 93ms |

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `rg -n "Claude Usage|Setup|ChatGPT|provider" Pinemeter/Views/MenuBar Pinemeter/App` | 0 | ✅ pass | 27ms |
| 2 | `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` | 0 | ✅ pass | 7042ms |
| 3 | `python3 deterministic stale Claude-only menu copy assertion` | 0 | ✅ pass | 93ms |

## Deviations

None.

## Known Issues

None.

## Files Created/Modified

- `Pinemeter/App/AppModel.swift`
- `Pinemeter/Views/MenuBar/MenuBarPopoverView.swift`
- `Pinemeter/Views/MenuBar/UsagePopoverView.swift`
- `PinemeterTests/AppModelTests.swift`
- `PinemeterTests/ChatGPTAppModelTests.swift`
