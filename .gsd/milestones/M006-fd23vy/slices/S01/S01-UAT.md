# S01: VM automation access harness — UAT

**Milestone:** M006-fd23vy
**Written:** 2026-07-03T17:11:17.860Z

# UAT: S01 VM automation access harness

## UAT Type

- UAT mode: mixed

## UAT-01: Metadata-only VM probe

- Command: `scripts/vm_validation/pinemeter_vm_probe.sh`
- Result: PASS
- Evidence: `.gsd/milestones/M006-fd23vy/evidence/S01/vm-probe-20260703T170834Z.txt`
- Notes: Verified SSH, sudo, macOS version/build, Chrome profile names, required tools, and Chrome/PineShot app presence against `macvm2.local` without reading cookies, tokens, Keychain values, authorization headers, or browser storage contents.

## UAT-02: Visual automation channel

- Command: SSH-driven AppleScript plus `screencapture -x`, followed by `scp` of the screenshot artifact.
- Result: PASS
- Evidence: `.gsd/milestones/M006-fd23vy/evidence/S01/T02-visual-probe.txt` and `.gsd/milestones/M006-fd23vy/evidence/S01/T02-visual-probe.png`
- Notes: AppleScript counted System Events processes and identified TextEdit as frontmost. Screenshot artifact was visually inspected and shows a neutral probe window with no credential material.

## UAT-03: Evidence safety scan

- Command: `rg -n -i "(select .*cookies|cookies.sqlite|Cookie:|authorization:|bearer |session-token|session_key|sessionkey|token=|security find-generic-password -w|dump)" scripts/vm_validation .gsd/milestones/M006-fd23vy/evidence/S01 || true`
- Result: PASS
- Notes: Only README prohibited-data policy text matched; no executable secret-dumping commands or evidence leaks were found.

