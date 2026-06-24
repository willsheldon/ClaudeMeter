---
estimated_steps: 1
estimated_files: 2
skills_used: []
---

# T03: Execute public-readiness verification

Run the build/test command if public docs require it, execute automated UAT checks, mark human-only checks clearly, and prepare milestone validation evidence.

## Inputs

- `README.md`
- `.gsd/milestones/M005/slices/S04/S04-UAT.md`

## Expected Output

- `.gsd/milestones/M005/slices/S04/S04-UAT.md`

## Verification

`xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` plus GSD UAT evidence for automated public-readiness checks.

## Observability Impact

Records final public-readiness evidence.
