---
estimated_steps: 1
estimated_files: 5
skills_used: []
---

# T01: Audited menu bar provider assumptions and documented the current display-state matrix for no-provider, Claude-only, ChatGPT-only, both-provider, loading, and error states.

Inspect MenuBarPopoverView, UsagePopoverView, UsageCardView, ChatGPTUsageCardView, MenuBarIconView, and AppModel setup-complete logic for Claude-only assumptions and partial-provider behavior gaps.

## Inputs

- `Pinemeter/Views/MenuBar/MenuBarPopoverView.swift`
- `Pinemeter/Views/MenuBar/UsagePopoverView.swift`
- `Pinemeter/App/AppModel.swift`

## Expected Output

- `Pinemeter/Views/MenuBar/MenuBarPopoverView.swift`
- `Pinemeter/Views/MenuBar/UsagePopoverView.swift`
- `Pinemeter/Views/MenuBar/UsageCardView.swift`
- `Pinemeter/Views/MenuBar/ChatGPTUsageCardView.swift`
- `Pinemeter/App/AppModel.swift`

## Verification

Task summary records menu provider assumptions and desired display matrix for no provider, Claude-only, ChatGPT-only, both, loading, and error states.

## Observability Impact

Creates a display-state map for menu diagnostics.
