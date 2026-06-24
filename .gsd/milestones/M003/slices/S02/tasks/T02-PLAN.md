---
estimated_steps: 1
estimated_files: 6
skills_used: []
---

# T02: Centralized provider credential recovery actions in AppModel and routed setup repair/clear flows through that sanitized orchestration boundary.

Add or refine AppModel methods that execute provider recovery actions from ProviderCredentialActionKind for Claude and ChatGPT. Preserve scoped Keychain update/add behavior, ChatGPT repository boundaries, and sanitized user-visible result state.

## Inputs

- `Pinemeter/App/AppModel.swift`
- `Pinemeter/Models/CredentialState.swift`

## Expected Output

- `Pinemeter/App/AppModel.swift`
- `PinemeterTests/AppModelTests.swift`
- `PinemeterTests/ProviderErrorWorkflowTests.swift`

## Verification

`xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/ProviderErrorWorkflowTests`

## Observability Impact

Centralizes recovery result and failure categories.
