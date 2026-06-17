---
estimated_steps: 1
estimated_files: 2
skills_used: []
---

# T02: Update settings credential recovery controls

Update SettingsView with provider credential rows for status, reconnect, repair, and clear actions. Keep copy Claude first with optional ChatGPT quota visibility and do not imply Gemini support yet.

## Inputs

- `Pinemeter/Views/Settings/SettingsView.swift`
- `Pinemeter/App/AppModel.swift`

## Expected Output

- `Pinemeter/Views/Settings/SettingsView.swift`
- `PinemeterTests/AppModelTests.swift`

## Verification

xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppModelTests

## Observability Impact

Makes recovery actions visible without exposing credential values.
