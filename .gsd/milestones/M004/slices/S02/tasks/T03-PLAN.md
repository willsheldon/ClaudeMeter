---
estimated_steps: 1
estimated_files: 4
skills_used: []
---

# T03: Integrated Gemini API-key backed usage state into AppModel refresh, credential status, and clear/reconnect surfaces with focused AppModel coverage.

Wire Gemini repository/service dependencies into AppModel initialization, refresh orchestration, credential status, and clear/reconnect surfaces while preserving existing providers.

## Inputs

- `Pinemeter/App/AppModel.swift`
- `Pinemeter/App/PinemeterApp.swift`

## Expected Output

- `Pinemeter/App/AppModel.swift`
- `PinemeterTests/AppModelTests.swift`

## Verification

`xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/SecurityInvariantTests`

## Observability Impact

Makes Gemini refresh and credential state visible through AppModel.
