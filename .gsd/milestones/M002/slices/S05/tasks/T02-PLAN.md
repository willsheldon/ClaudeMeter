---
estimated_steps: 1
estimated_files: 1
skills_used: []
---

# T02: Run full credential verification suite

Run the full Debug test suite and inspect signing settings so M002 closes only if credential behavior and official Autimo signing remain intact. Capture any failures as remediation instead of suppressing them.

## Inputs

- `Pinemeter.xcodeproj/project.pbxproj`

## Expected Output

- `.gsd/milestones/M002/slices/S05/S05-ASSESSMENT.md`

## Verification

xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug && xcodebuild -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -showBuildSettings | egrep 'CODE_SIGN_IDENTITY|DEVELOPMENT_TEAM'

## Observability Impact

Produces milestone closure evidence for tests and signing identity.
