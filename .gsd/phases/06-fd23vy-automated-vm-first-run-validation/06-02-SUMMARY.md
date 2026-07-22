---
id: S02
parent: M006-fd23vy
milestone: M006-fd23vy
provides:
  - Fresh Debug app bundle built and selected.
  - Reusable VM install/reset/launch helper for downstream onboarding validation.
  - Confirmed clean first-run state on `macvm2.local`.
requires:
  - slice: S01
    provides: Verified SSH, sudo, AppleScript, screenshot capture, host default, and evidence policy.
affects:
  - S03
key_files:
  - scripts/vm_validation/pinemeter_vm_validate.sh
  - scripts/vm_validation/README.md
  - .gsd/milestones/M006-fd23vy/evidence/S02-xcodebuild-debug.log
  - .gsd/milestones/M006-fd23vy/evidence/S02-app-bundle.txt
  - .gsd/milestones/M006-fd23vy/evidence/S02/vm-validate-20260703T171514Z.txt
  - .gsd/milestones/M006-fd23vy/evidence/S02/vm-validate-20260703T171658Z.txt
  - .gsd/milestones/M006-fd23vy/evidence/S02-post-launch-probe.txt
  - .gsd/milestones/M006-fd23vy/evidence/S02-remote-install-probe.txt
  - .gsd/milestones/M006-fd23vy/evidence/S02-pinemeter-first-run.png
key_decisions: []
patterns_established:
  - Use `pinemeter_vm_validate.sh --all` as the clean install/reset/launch preamble for onboarding validation.
  - Verify clean state with actual preference plist absence plus exact Keychain item absence, not `defaults read` alone.
  - Keep reset commands scoped to exact service/account pairs.
observability_surfaces:
  - Runtime evidence files under `.gsd/milestones/M006-fd23vy/evidence/S02/`.
  - Dry-run output listing exact reset and install targets without values.
drill_down_paths:
  - .gsd/milestones/M006-fd23vy/slices/S02/tasks/T01-SUMMARY.md
  - .gsd/milestones/M006-fd23vy/slices/S02/tasks/T02-SUMMARY.md
  - .gsd/milestones/M006-fd23vy/slices/S02/tasks/T03-SUMMARY.md
duration: ""
verification_result: passed
completed_at: 2026-07-03T17:18:10.267Z
blocker_discovered: false
---

# S02: Clean install and first run reset

**Built, installed, reset, launched, and clean-state probed Pinemeter on `macvm2.local` with a reusable VM validation script.**

## What Happened

S02 created a deterministic clean-install loop for the VM. A fresh Debug build produced a verified `Pinemeter.app` bundle. `scripts/vm_validation/pinemeter_vm_validate.sh` now supports dry-run, install, reset, launch, and full validation modes against `macvm2.local`. The helper installs to `/Applications/Pinemeter.app`, clears quarantine if present, resets `com.eddmann.Pinemeter`, and deletes only the exact known credential items: Claude `com.claudemeter.sessionkey/default` and ChatGPT `com.pinemeter.chatgpt.session/chatgpt.com`. The full loop installed the app, reset local state, launched the menu-bar app, and verified clean first-run state through process presence, preference plist absence, exact Keychain item absence, remote install metadata, and sanitized screenshot evidence. A loose `defaults read` launch check was corrected to direct plist-file probing and reverified with `--launch`.

## Verification

Debug build passed: `.gsd/milestones/M006-fd23vy/evidence/S02-xcodebuild-debug.log` contains `** BUILD SUCCEEDED **`, and `.gsd/milestones/M006-fd23vy/evidence/S02-app-bundle.txt` records the selected app bundle, identifier, TeamIdentifier, and quarantine absence. Script syntax/dry-run/reset checks passed, including exact scoped deletion targets. Full validation passed via `.gsd/milestones/M006-fd23vy/evidence/S02/vm-validate-20260703T171514Z.txt` with install/reset/launch success. Corrected launch verification passed via `.gsd/milestones/M006-fd23vy/evidence/S02/vm-validate-20260703T171658Z.txt` with `launch.running=true` and `preferences.file=missing`. Post-launch probe confirmed `pinemeter.running=true`, `preferences.file=missing`, `claude.keychain=absent`, and `chatgpt.keychain=absent`. Remote install probe confirmed `/Applications/Pinemeter.app` exists, identifier `com.eddmann.Pinemeter`, TeamIdentifier `HMR9RDR6M2`, and quarantine absent. Screenshot evidence was inspected and contains no credential material.

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

The VM host uses the corrected name `macvm2.local`. Pinemeter is a menu bar app and did not present a normal application window during post-launch probing, so clean first-run state was verified with process, install metadata, plist absence, exact Keychain absence, and screenshot safety rather than window content.

## Known Limitations

The screenshot still shows pre-existing non-credential browser windows behind the probe from the VM desktop. S03 should frontmost Pinemeter/setup UI before capturing onboarding evidence.

## Follow-ups

S03 should use `scripts/vm_validation/pinemeter_vm_validate.sh --all` as its reset/install preamble, then drive the menu-bar/setup onboarding UI using the S01 AppleScript/screenshot fallback. If the setup UI is not visible after launch, S03 should first map the menu-bar status item or app activation path.

## Files Created/Modified

- `scripts/vm_validation/pinemeter_vm_validate.sh` — New reusable VM install/reset/launch validation helper.
- `scripts/vm_validation/README.md` — Updated harness documentation for corrected host, evidence policy, and validation commands.
- `.gsd/milestones/M006-fd23vy/evidence/S02/` — Runtime install/reset/launch evidence.
