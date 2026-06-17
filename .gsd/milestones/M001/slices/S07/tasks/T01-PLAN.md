---
estimated_steps: 12
estimated_files: 4
skills_used: []
---

# T01: Captured fresh passing renamed Pinemeter Xcode test and clean build evidence for final milestone verification.

---
skills_used:
  - verify-before-complete
---
Why: R002 and R008 require fresh proof that behavior remains stable and the renamed Pinemeter project and scheme pass after all prior cleanup.

Do: Run the full local test command `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` with gsd_exec and capture its evidence ID and exit code. Then run `xcodebuild clean build -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` with gsd_exec and capture its evidence ID and exit code. If either fails for environment-only reasons such as simulator or signing, record the exact failure and do not silently weaken the command; only use a justified retry flag if the failure is proven local-environment-only.

Done when: Both commands pass with exit code 0, or a precise blocker is documented with evidence so the slice cannot be falsely closed.

Q3 Threat Surface: The task does not touch credentials or app code, but the logs may include build environment paths; do not paste excessive logs into artifacts.
Q4 Requirement Impact: Directly validates R002 and R008 and supports final R001 closure.
Q5 Failure Modes: Failing tests, build errors, simulator unavailability, or signing differences must block closure until classified.
Q6 Load Profile: Full Xcode test/build can be long-running and should be run through gsd_exec with an adequate timeout.
Q7 Negative Tests: Treat non-zero exit from either exact renamed command as negative proof, not as a pass with caveats.

## Inputs

- `Pinemeter.xcodeproj/project.pbxproj`
- `Pinemeter.xcodeproj/xcshareddata/xcschemes/Pinemeter.xcscheme`
- `Pinemeter`
- `PinemeterTests`
- `.gsd/milestones/M001/slices/S06/S06-ASSESSMENT.md`

## Expected Output

- `Pinemeter.xcodeproj/project.pbxproj`
- `Pinemeter.xcodeproj/xcshareddata/xcschemes/Pinemeter.xcscheme`
- `Pinemeter`
- `PinemeterTests`

## Verification

xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug && xcodebuild clean build -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug

## Observability Impact

Produces final Xcode verification evidence IDs and logs for S07 assessment and milestone validation.
