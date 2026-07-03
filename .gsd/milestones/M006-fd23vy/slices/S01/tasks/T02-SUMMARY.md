---
id: T02
parent: S01
milestone: M006-fd23vy
key_files:
  - scripts/vm_validation/README.md
  - .gsd/milestones/M006-fd23vy/evidence/S01/T02-visual-probe.txt
  - .gsd/milestones/M006-fd23vy/evidence/S01/T02-visual-probe.png
key_decisions:
  - (none)
duration: 
verification_result: passed
completed_at: 2026-07-03T17:10:13.696Z
blocker_discovered: false
---

# T02: Verified remote visual automation through AppleScript and sanitized screenshot capture on `macvm2.local`.

**Verified remote visual automation through AppleScript and sanitized screenshot capture on `macvm2.local`.**

## What Happened

Ran a remote SSH-driven visual probe that created a neutral TextEdit probe document, used AppleScript/System Events to count processes and identify the frontmost app, captured the desktop with `screencapture -x`, and copied the screenshot back into the S01 evidence directory. The screenshot was visually inspected and contains the neutral TextEdit probe text rather than credential material. Documented the validated fallback path in `scripts/vm_validation/README.md`: use SSH-driven AppleScript for semantic UI actions and SSH-driven `screencapture` or PineShot IPC for sanitized visual evidence if dedicated computer-use tooling is not available for the VM.

## Verification

Ran remote visual probe via SSH to `macvm2.local`; output in `.gsd/milestones/M006-fd23vy/evidence/S01/T02-visual-probe.txt` shows AppleScript process count 48, frontmost app TextEdit, and screenshot file size 369758 bytes. Copied `.gsd/milestones/M006-fd23vy/evidence/S01/T02-visual-probe.png` back locally and inspected it; it shows a neutral TextEdit probe window and no credential material. Ran the forbidden-pattern scan against `scripts/vm_validation` and S01 evidence; only README prohibited-data text matched.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `ssh will@macvm2.local '<visual probe using osascript and screencapture>'; scp visual-probe.png back to S01 evidence` | 0 | ✅ pass | 90000ms |
| 2 | `read .gsd/milestones/M006-fd23vy/evidence/S01/T02-visual-probe.png` | 0 | ✅ pass (visual inspection: neutral probe, no credential material) | 1000ms |
| 3 | `rg -n -i "(select .*cookies|cookies.sqlite|Cookie:|authorization:|bearer |session-token|session_key|sessionkey|token=|security find-generic-password -w|dump)" scripts/vm_validation .gsd/milestones/M006-fd23vy/evidence/S01 || true` | 0 | ✅ pass (only README prohibited-data text matched) | 1000ms |

## Deviations

No dedicated remote computer-use tool was identified in this harness step; SSH-driven AppleScript plus screenshot/PineShot IPC is documented as the fallback automation path.

## Known Issues

The captured desktop included existing non-credential browser windows behind the neutral probe. Future onboarding evidence should keep neutral or app-specific windows frontmost and avoid provider account pages or developer tools.

## Files Created/Modified

- `scripts/vm_validation/README.md`
- `.gsd/milestones/M006-fd23vy/evidence/S01/T02-visual-probe.txt`
- `.gsd/milestones/M006-fd23vy/evidence/S01/T02-visual-probe.png`
