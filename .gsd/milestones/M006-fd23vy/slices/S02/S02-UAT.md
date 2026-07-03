# S02: Clean install and first run reset — UAT

**Milestone:** M006-fd23vy
**Written:** 2026-07-03T17:18:10.269Z

# UAT: S02 Clean install and first run reset

## UAT Type

- UAT mode: runtime-executable

## UAT-01: Fresh Debug build and bundle selection

- Command: `xcodebuild clean build -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug`
- Result: PASS
- Evidence: `.gsd/milestones/M006-fd23vy/evidence/S02-xcodebuild-debug.log`, `.gsd/milestones/M006-fd23vy/evidence/S02-app-bundle.txt`
- Notes: Build succeeded and selected app bundle exists with identifier `com.eddmann.Pinemeter`, TeamIdentifier `HMR9RDR6M2`, and no quarantine xattr.

## UAT-02: Scoped reset and install harness

- Commands: `bash -n scripts/vm_validation/pinemeter_vm_validate.sh`, `scripts/vm_validation/pinemeter_vm_validate.sh --dry-run`, `scripts/vm_validation/pinemeter_vm_validate.sh --reset`
- Result: PASS
- Evidence: `.gsd/milestones/M006-fd23vy/evidence/S02-dry-run-latest.txt`, `.gsd/milestones/M006-fd23vy/evidence/S02/vm-validate-20260703T171435Z.txt`
- Notes: Dry-run and live reset name only exact preference and Keychain deletion targets; no credential values are read or printed.

## UAT-03: Full install, reset, launch, and clean-state probe

- Command: `scripts/vm_validation/pinemeter_vm_validate.sh --all`
- Result: PASS
- Evidence: `.gsd/milestones/M006-fd23vy/evidence/S02/vm-validate-20260703T171514Z.txt`, `.gsd/milestones/M006-fd23vy/evidence/S02-post-launch-probe.txt`, `.gsd/milestones/M006-fd23vy/evidence/S02-remote-install-probe.txt`, `.gsd/milestones/M006-fd23vy/evidence/S02/vm-validate-20260703T171658Z.txt`
- Notes: Installed app exists remotely, app launches, Pinemeter process runs, preference plist is missing after reset/launch, and exact Claude/ChatGPT Keychain items are absent.

## UAT-04: Screenshot safety

- Artifact: `.gsd/milestones/M006-fd23vy/evidence/S02-pinemeter-first-run.png`
- Result: PASS
- Notes: Screenshot was visually inspected and contains no credential material.

