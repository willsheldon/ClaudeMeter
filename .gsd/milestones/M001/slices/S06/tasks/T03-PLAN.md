---
estimated_steps: 4
estimated_files: 2
skills_used: []
---

# T03: AppSettings refresh interval clamping now uses shared Constants.Refresh bounds with focused boundary tests.

skills_used: [decompose-into-slices, tdd]

Why: AppSettings.setRefreshInterval still uses literal 60 and 600 values while Constants.Refresh.minimum and Constants.Refresh.maximum exist. This is a low-risk stale assumption cleanup that improves ownership/readability without changing UI state or service boundaries.

Do: Update AppSettings.setRefreshInterval to clamp using Constants.Refresh.minimum and Constants.Refresh.maximum. Adjust the adjacent refresh interval documentation to refer to the constants' intended bounds. Add focused AppSettings tests for below-minimum, above-maximum, and in-range refresh interval behavior. Keep AppSettings Codable backward compatibility unchanged and do not add any user-facing settings keys.

Done when: AppSettingsTests pass and prove the behavior did not change while removing the duplicated magic numbers.

## Inputs

- `Pinemeter/Models/AppSettings.swift`
- `Pinemeter/Models/Constants.swift`

## Expected Output

- `Pinemeter/Models/AppSettings.swift`
- `PinemeterTests/AppSettingsTests.swift`

## Verification

xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppSettingsTests

## Observability Impact

Adds focused test coverage for settings boundary behavior; no app telemetry or logging changes.
