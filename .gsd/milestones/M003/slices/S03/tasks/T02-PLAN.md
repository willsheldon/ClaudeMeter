---
estimated_steps: 1
estimated_files: 5
skills_used: []
---

# T02: Added provider-aware menu usage state so ChatGPT-only and mixed-provider setups route to the usage popover with provider-specific titles, loading text, refresh behavior, and tests.

Update AppModel menu/setup state and usage popover rendering so configured providers determine the useful menu state. Replace Claude-only headers and empty states with provider-aware copy and refresh behavior.

## Inputs

- `Pinemeter/App/AppModel.swift`
- `Pinemeter/Views/MenuBar/UsagePopoverView.swift`

## Expected Output

- `Pinemeter/App/AppModel.swift`
- `Pinemeter/Views/MenuBar/MenuBarPopoverView.swift`
- `Pinemeter/Views/MenuBar/UsagePopoverView.swift`

## Verification

`xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/ChatGPTAppModelTests`

## Observability Impact

Exposes deterministic provider display and refresh state.
