---
estimated_steps: 1
estimated_files: 4
skills_used: []
---

# T04: Verified the menu bar multi-provider behavior with full-suite tests and deterministic copy scans, with no scope-relevant code changes required.

Run full tests and inspect user-facing menu copy for stale Claude-only language where the scope is multi-provider. Fix only scope-relevant regressions.

## Inputs

- `Pinemeter/Views/MenuBar`
- `Pinemeter/App/AppModel.swift`

## Expected Output

- `Pinemeter/Views/MenuBar/UsagePopoverView.swift`
- `Pinemeter/Views/MenuBar/MenuBarPopoverView.swift`
- `PinemeterTests/AppModelTests.swift`
- `PinemeterTests/ChatGPTAppModelTests.swift`

## Verification

`xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` and `rg -n "Claude Usage|Setup|ChatGPT|provider" Pinemeter/Views/MenuBar Pinemeter/App` reviewed for expected copy.

## Observability Impact

Confirms menu polish is covered by full-suite verification.
