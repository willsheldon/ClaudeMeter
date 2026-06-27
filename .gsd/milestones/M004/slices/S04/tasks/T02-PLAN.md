---
estimated_steps: 1
estimated_files: 4
skills_used: []
---

# T02: Gemini usage and error states now render in the menu popover alongside configured providers.

Update UsagePopoverView and related provider card components to render Gemini usage, unavailable, loading, and error states alongside other configured providers.

## Inputs

- `Pinemeter/Views/MenuBar/UsagePopoverView.swift`
- `Pinemeter/Views/MenuBar/UsageCardView.swift`

## Expected Output

- `Pinemeter/Views/MenuBar/UsagePopoverView.swift`

## Verification

`xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/MenuBarIconRendererTests -only-testing:PinemeterTests/AppModelTests`

## Observability Impact

Makes Gemini display and error state visible in primary UI.
