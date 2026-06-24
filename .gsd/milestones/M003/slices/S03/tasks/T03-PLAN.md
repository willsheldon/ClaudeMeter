---
estimated_steps: 1
estimated_files: 4
skills_used: []
---

# T03: Added regression coverage for provider-aware menu state, hidden ChatGPT usage, unavailable ChatGPT storage, and ChatGPT refresh demotion when credentials disappear.

Add focused AppModel and menu rendering or snapshot-style tests for provider combinations, including partial setup, unavailable usage, and refresh behavior. Prefer existing test support patterns over adding fragile UI-only assertions.

## Inputs

- `PinemeterTests/AppModelTests.swift`
- `PinemeterTests/ChatGPTAppModelTests.swift`
- `PinemeterTests/MenuBarIconRendererTests.swift`

## Expected Output

- `PinemeterTests/AppModelTests.swift`
- `PinemeterTests/ChatGPTAppModelTests.swift`

## Verification

`xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/ChatGPTAppModelTests -only-testing:PinemeterTests/MenuBarIconRendererTests`

## Observability Impact

Locks provider display behavior into automated evidence.
