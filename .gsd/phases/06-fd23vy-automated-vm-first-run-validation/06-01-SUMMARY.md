---
id: S01
parent: M006-fd23vy
milestone: M006-fd23vy
provides:
  - Reachable VM host default `macvm2.local`.
  - Verified SSH/sudo/AppleScript/screenshot channels for downstream install and onboarding slices.
  - Safe evidence policy and PineShot fallback notes.
requires:
  []
affects:
  - S02
  - S03
key_files:
  - scripts/vm_validation/README.md
  - scripts/vm_validation/pinemeter_vm_probe.sh
  - .gsd/milestones/M006-fd23vy/evidence/S01/vm-probe-20260703T170834Z.txt
  - .gsd/milestones/M006-fd23vy/evidence/S01/T02-visual-probe.txt
  - .gsd/milestones/M006-fd23vy/evidence/S01/T02-visual-probe.png
key_decisions: []
patterns_established:
  - Use metadata-only SSH probes for VM readiness.
  - Use SSH-driven AppleScript and sanitized screenshots as the remote visual automation fallback.
  - Keep evidence under `.gsd/milestones/M006-fd23vy/evidence/` and forbid credential-bearing dumps.
observability_surfaces:
  - Categorized VM probe evidence files under `.gsd/milestones/M006-fd23vy/evidence/S01/`.
  - Harness README documenting safe evidence collection and failure categories.
drill_down_paths:
  - .gsd/milestones/M006-fd23vy/slices/S01/tasks/T01-SUMMARY.md
  - .gsd/milestones/M006-fd23vy/slices/S01/tasks/T02-SUMMARY.md
  - .gsd/milestones/M006-fd23vy/slices/S01/tasks/T03-SUMMARY.md
duration: ""
verification_result: passed
completed_at: 2026-07-03T17:11:17.857Z
blocker_discovered: false
---

# S01: VM automation access harness

**Proved the VM automation channel on `macvm2.local` with SSH, sudo, AppleScript, sanitized screenshots, PineShot fallback notes, and safe evidence conventions.**

## What Happened

S01 established the operational harness needed before first-run onboarding validation. The VM host rename was applied to the executable harness (`macvm2.local`). The metadata-only probe verified SSH reachability as `will`, passwordless sudo, macOS version/build, Chrome profile names, required command-line tools, and Chrome/PineShot app presence without reading credential-bearing stores. Visual automation was verified through SSH-driven AppleScript/System Events and `screencapture`; a neutral TextEdit probe screenshot was captured and copied back as evidence. The harness README now documents allowed/prohibited evidence, PineShot IPC fallback paths from the local wiki notes, and the fallback strategy of SSH-driven AppleScript plus screenshot/PineShot IPC when dedicated computer-use tooling is unavailable.

## Verification

S01 verification passed with current evidence: `scripts/vm_validation/pinemeter_vm_probe.sh` exited 0 against `macvm2.local`; `.gsd/milestones/M006-fd23vy/evidence/S01/vm-probe-20260703T170834Z.txt` records reachable host, sudo root, Chrome `Default` and `Profile 1`, required tools, and app presence. Remote visual probe output in `.gsd/milestones/M006-fd23vy/evidence/S01/T02-visual-probe.txt` records AppleScript process count 48, frontmost app TextEdit, and a 369758-byte screenshot. `.gsd/milestones/M006-fd23vy/evidence/S01/T02-visual-probe.png` was visually inspected and contains a neutral probe window with no credential material. Forbidden-pattern scan against `scripts/vm_validation` and S01 evidence only matched README prohibited-data text.

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

The original planned host `Wills-AUTH-vm.local` was renamed to `macvm2.local`; the harness default and README were updated. S01/T03 was completed before T01/T02 during the initial hostname outage, then T01/T02 completed once the renamed host was supplied.

## Known Limitations

Dedicated remote computer-use tooling was not separately identified; the validated fallback is SSH-driven AppleScript plus `screencapture` or PineShot IPC. The visual probe screenshot included existing non-credential browser windows behind the neutral TextEdit probe, so future evidence capture should keep neutral or Pinemeter-specific windows frontmost.

## Follow-ups

S02 should reuse `macvm2.local` for install/reset automation and keep the exact Keychain deletion targets from project memory: Claude service `com.claudemeter.sessionkey` account `default`, ChatGPT service `com.pinemeter.chatgpt.session` account `chatgpt.com`.

## Files Created/Modified

- `scripts/vm_validation/README.md` — Documents target host, safe evidence policy, PineShot fallback, validated visual automation fallback, and current probe status.
- `scripts/vm_validation/pinemeter_vm_probe.sh` — Metadata-only VM readiness probe defaulting to `macvm2.local`.
- `.gsd/milestones/M006-fd23vy/evidence/S01/` — Sanitized probe and screenshot evidence for S01.
