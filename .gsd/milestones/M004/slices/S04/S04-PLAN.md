# S04: Gemini menu usage integration

**Goal:** Integrate Gemini usage into the menu bar display, refresh orchestration, and partial-provider states.
**Demo:** The menu bar popover refreshes and displays Gemini usage alongside other configured providers.

## Must-Haves

- Menu bar surfaces render Gemini usage, loading, unavailable, and error states.
- Refresh orchestration handles Gemini independently from Claude and ChatGPT.
- Tests cover one, two, and three-provider combinations.

## Proof Level

- This slice proves: integration

## Integration Closure

MenuBarPopoverView, UsagePopoverView, provider cards, AppModel refresh methods, and services agree on Gemini display state.

## Verification

- Makes Gemini refresh/error state inspectable through AppModel and UI state.

## Tasks

- [x] **T01: Added AppModel popover-content state that accounts for Gemini usage and Gemini errors.** `est:medium`
  Add Gemini usage state and refresh state to AppModel/menu state in a way that composes with Claude and ChatGPT rather than branching every provider combination manually.
  - Files: `Pinemeter/App/AppModel.swift`, `Pinemeter/Models/UsageData.swift`, `Pinemeter/Models/UsageStatus.swift`, `PinemeterTests/AppModelTests.swift`
  - Verify: `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests`

- [x] **T02: Gemini usage and error states now render in the menu popover alongside configured providers.** `est:medium`
  Update UsagePopoverView and related provider card components to render Gemini usage, unavailable, loading, and error states alongside other configured providers.
  - Files: `Pinemeter/Views/MenuBar/UsagePopoverView.swift`, `Pinemeter/Views/MenuBar/UsageCardView.swift`, `Pinemeter/Views/MenuBar/ChatGPTUsageCardView.swift`, `Pinemeter/Views/MenuBar/MenuBarPopoverView.swift`
  - Verify: `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/MenuBarIconRendererTests -only-testing:PinemeterTests/AppModelTests`

- [x] **T03: Added AppModel regression tests for Gemini-only, mixed Gemini provider combinations, all-provider display state, and Gemini refresh error display state.** `est:medium`
  Add tests for Gemini-only, Claude plus Gemini, ChatGPT plus Gemini, all providers, and Gemini error states, then run full verification.
  - Files: `PinemeterTests/AppModelTests.swift`, `PinemeterTests/ChatGPTAppModelTests.swift`, `PinemeterTests/MenuBarIconRendererTests.swift`, `PinemeterTests/GeminiUsageServiceTests.swift`
  - Verify: `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug`

## Files Likely Touched

- Pinemeter/App/AppModel.swift
- Pinemeter/Models/UsageData.swift
- Pinemeter/Models/UsageStatus.swift
- PinemeterTests/AppModelTests.swift
- Pinemeter/Views/MenuBar/UsagePopoverView.swift
- Pinemeter/Views/MenuBar/UsageCardView.swift
- Pinemeter/Views/MenuBar/ChatGPTUsageCardView.swift
- Pinemeter/Views/MenuBar/MenuBarPopoverView.swift
- PinemeterTests/ChatGPTAppModelTests.swift
- PinemeterTests/MenuBarIconRendererTests.swift
- PinemeterTests/GeminiUsageServiceTests.swift
