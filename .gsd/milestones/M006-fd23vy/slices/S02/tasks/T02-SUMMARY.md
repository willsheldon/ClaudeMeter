---
id: T02
parent: S02
milestone: M006-fd23vy
key_files:
  - scripts/vm_validation/pinemeter_vm_validate.sh
  - scripts/vm_validation/README.md
  - .gsd/milestones/M006-fd23vy/evidence/S02-dry-run-latest.txt
  - .gsd/milestones/M006-fd23vy/evidence/S02-reset-latest.txt
  - .gsd/milestones/M006-fd23vy/evidence/S02/vm-validate-20260703T171435Z.txt
key_decisions:
  - (none)
duration: 
verification_result: passed
completed_at: 2026-07-03T17:15:02.162Z
blocker_discovered: false
---

# T02: Added and verified the VM reset/install harness with exact scoped preference and Keychain deletion targets.

**Added and verified the VM reset/install harness with exact scoped preference and Keychain deletion targets.**

## What Happened

Implemented `scripts/vm_validation/pinemeter_vm_validate.sh`, a repo-local helper that can dry-run, install, reset, launch, or run the full VM validation loop against `macvm2.local`. The helper auto-detects the Debug `Pinemeter.app` bundle unless `PINEMETER_APP_PATH` is supplied, installs to `/Applications/Pinemeter.app`, clears quarantine if needed, deletes only the Pinemeter preferences domain `com.eddmann.Pinemeter`, and deletes only the exact known Keychain items: Claude service `com.claudemeter.sessionkey` account `default`, and ChatGPT service `com.pinemeter.chatgpt.session` account `chatgpt.com`. It writes categorized evidence files and does not read or print credential values.

## Verification

Ran `bash -n scripts/vm_validation/pinemeter_vm_validate.sh` successfully. Ran `scripts/vm_validation/pinemeter_vm_validate.sh --dry-run`, which recorded the selected app path, install target, exact preference domain, and exact Keychain service/account pairs. Ran `scripts/vm_validation/pinemeter_vm_validate.sh --reset`, which exited 0 and wrote `.gsd/milestones/M006-fd23vy/evidence/S02/vm-validate-20260703T171435Z.txt` with `reset.complete=true`. Ran a forbidden-pattern scan; hits were limited to scoped deletion labels and `swift-custom-dump` dependency/build-log text, not secret-reading or value-printing commands.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `bash -n scripts/vm_validation/pinemeter_vm_validate.sh` | 0 | ✅ pass | 1000ms |
| 2 | `scripts/vm_validation/pinemeter_vm_validate.sh --dry-run` | 0 | ✅ pass | 180000ms |
| 3 | `scripts/vm_validation/pinemeter_vm_validate.sh --reset` | 0 | ✅ pass | 120000ms |
| 4 | `rg forbidden secret-dumping patterns across scripts/vm_validation and S02 evidence` | 0 | ✅ pass (only scoped deletion labels and dependency/build-log false positives) | 1000ms |

## Deviations

The script defaults to the renamed VM host `macvm2.local` rather than the original plan hostname.

## Known Issues

Install and launch are implemented but verified in S02/T03 rather than this reset-focused task.

## Files Created/Modified

- `scripts/vm_validation/pinemeter_vm_validate.sh`
- `scripts/vm_validation/README.md`
- `.gsd/milestones/M006-fd23vy/evidence/S02-dry-run-latest.txt`
- `.gsd/milestones/M006-fd23vy/evidence/S02-reset-latest.txt`
- `.gsd/milestones/M006-fd23vy/evidence/S02/vm-validate-20260703T171435Z.txt`
