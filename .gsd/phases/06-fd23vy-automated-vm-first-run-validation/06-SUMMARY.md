---
id: S06
parent: M006-fd23vy
milestone: M006-fd23vy
provides:
  - A future-agent-safe command sequence for VM validation.
  - A final handoff stating current outcome and next rerun precondition.
requires:
  - slice: S04
    provides: Final `missing_browser_auth` runtime outcome and S04 evidence artifacts.
affects:
  []
key_files:
  - scripts/vm_validation/README.md
  - scripts/vm_validation/pinemeter_vm_probe.sh
  - scripts/vm_validation/pinemeter_vm_validate.sh
  - .gsd/milestones/M006-fd23vy/evidence/S04/outcome-classification.txt
  - .gsd/milestones/M006-fd23vy/evidence/S06-xcodebuild-test.log
key_decisions: []
patterns_established:
  - Repeatable VM validation sequence lives in `scripts/vm_validation/README.md`.
  - Use `--open-popover-after-launch` for DEBUG validation UI access.
  - Root-cause browser auth absence as environmental unless contradicted by new evidence.
observability_surfaces:
  - S04 outcome-classification artifact and S06 Xcode test log.
drill_down_paths:
  - .gsd/milestones/M006-fd23vy/slices/S06/tasks/T01-SUMMARY.md
  - .gsd/milestones/M006-fd23vy/slices/S06/tasks/T02-SUMMARY.md
duration: ""
verification_result: passed
completed_at: 2026-07-03T18:27:23.148Z
blocker_discovered: false
---

# S06: Reusable validation command and handoff

**Left a repeatable VM validation sequence, evidence map, and verified final handoff for future agents.**

## What Happened

S06 turned the VM validation work into a reusable handoff. The README now includes a repeatable sequence for probing `macvm2.local`, building the Debug app, installing/resetting/launching it with the DEBUG automation window, handling the Chrome Safe Storage keychain prompt safely, and finding the current S04 evidence. The documented final outcome is `missing_browser_auth`: the harness, install/reset/launch flow, automation window, and Chrome Safe Storage access worked, but Chrome Profile 1 did not provide importable Claude or ChatGPT sessions. Final verification checked script syntax/executable bits, required README/evidence strings, forbidden secret-value patterns, GSD status, and a fresh Xcode test run.

## Verification

`bash -n` passed for both VM validation scripts and both are executable. README required-string checks passed for the repeatable sequence and current final outcome. S04 evidence checks passed for `classification=missing_browser_auth` and absent exact Keychain item metadata. Secret-safety scan found only README policy and secret-safety statements, not raw values or dump commands. `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` passed with `** TEST SUCCEEDED **` in `.gsd/milestones/M006-fd23vy/evidence/S06-xcodebuild-test.log`.

## Requirements Advanced

None.

## Requirements Validated

None.

## New Requirements Surfaced

None.

## Requirements Invalidated or Re-scoped

None.

## Operational Readiness

None.

## Deviations

S05 was skipped because S04 root-caused the remaining failure as browser profile state, not a confirmed app defect.

## Known Limitations

The milestone does not prove successful Claude/ChatGPT import. It proves the reusable validation harness and root-causes the current VM outcome as missing importable browser auth.

## Follow-ups

If provider import success is still required, sign into Claude and ChatGPT in Chrome Profile 1 on `macvm2.local`, then rerun the README sequence and classify the new result.

## Files Created/Modified

- `scripts/vm_validation/README.md` — Added repeatable validation sequence and current final outcome/evidence map.
