---
id: T02
parent: S03
milestone: M006-fd23vy
key_files:
  - Pinemeter/App/AppDelegate.swift
  - Pinemeter/Views/MenuBar/MenuBarManager.swift
  - scripts/vm_validation/pinemeter_vm_validate.sh
  - scripts/vm_validation/README.md
  - .gsd/milestones/M006-fd23vy/evidence/S03/T02-before-import-click.png
  - .gsd/milestones/M006-fd23vy/evidence/S03/T02-debug-policy-window-map.txt
  - .gsd/milestones/M006-fd23vy/evidence/S03/vm-validate-20260703T173436Z.txt
key_decisions:
  - (none)
duration: 
verification_result: passed
completed_at: 2026-07-03T17:37:59.807Z
blocker_discovered: true
---

# T02: Drove the clean-reset onboarding flow to a sanitized credential-gated Keychain prompt outcome.

**Drove the clean-reset onboarding flow to a sanitized credential-gated Keychain prompt outcome.**

## What Happened

Added an approved DEBUG-only automation hook, `--open-popover-after-launch`, because the normal NSStatusItem popover could not be opened reliably through remote AX or coordinate clicks. The hook opens the same `MenuBarPopoverView` setup content in a titled `Pinemeter Automation` window for VM validation builds only. Updated the VM validation harness to pass optional launch args and prevent duplicate Pinemeter processes before install/launch. Rebuilt, installed, reset, and launched Pinemeter with the hook. The setup UI became visible and exposed the expected missing Claude/ChatGPT/Gemini credential state. The browser import attempt was triggered and reached a macOS prompt: Pinemeter wants to use confidential information stored in `Chrome Safe Storage` in the login keychain. This requires the VM login keychain password, so the attempt is classified as `keychain_access_prompt_requires_password` and must stop before any credential entry.

## Verification

Fresh Debug builds after the hook changes passed; evidence includes `.gsd/milestones/M006-fd23vy/evidence/S03-debug-window-policy-build.log` and `.gsd/milestones/M006-fd23vy/evidence/S03-debug-window-build.log`. `PINEMETER_VM_LAUNCH_ARGS=--open-popover-after-launch scripts/vm_validation/pinemeter_vm_validate.sh --all` exited 0 and wrote `.gsd/milestones/M006-fd23vy/evidence/S03/vm-validate-20260703T173436Z.txt`. AX/window evidence `.gsd/milestones/M006-fd23vy/evidence/S03/T02-debug-policy-window-map.txt` confirmed a `Pinemeter Automation` window. Screenshot `.gsd/milestones/M006-fd23vy/evidence/S03/T02-before-import-click.png` shows the setup UI and the `Chrome Safe Storage` Keychain prompt with no credential value entered or exposed. README classification was verified with `rg` for `keychain_access_prompt_requires_password`, `Chrome Safe Storage`, `Pinemeter Automation`, and `--open-popover-after-launch`.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `xcodebuild clean build -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` | 0 | ✅ pass | 1200000ms |
| 2 | `PINEMETER_VM_LAUNCH_ARGS=--open-popover-after-launch scripts/vm_validation/pinemeter_vm_validate.sh --all` | 0 | ✅ pass | 360000ms |
| 3 | `AX/window and screenshot probe for Pinemeter Automation setup UI and Keychain prompt` | 0 | ✅ pass (sanitized credential-gated outcome captured) | 120000ms |
| 4 | `rg -n "Pinemeter Automation|keychain_access_prompt_requires_password|Chrome Safe Storage|--open-popover-after-launch" scripts/vm_validation/README.md .gsd/milestones/M006-fd23vy/evidence/S03 || true` | 0 | ✅ pass | 1000ms |

## Deviations

A DEBUG-only automation window hook was added after the normal status-item popover proved unreachable by remote AX/coordinate automation. This is debug-build-only and does not affect release behavior.

## Known Issues

The import cannot continue until a human unlocks/allows the macOS login Keychain prompt on the VM. The agent must not type, store, or log that password.

## Files Created/Modified

- `Pinemeter/App/AppDelegate.swift`
- `Pinemeter/Views/MenuBar/MenuBarManager.swift`
- `scripts/vm_validation/pinemeter_vm_validate.sh`
- `scripts/vm_validation/README.md`
- `.gsd/milestones/M006-fd23vy/evidence/S03/T02-before-import-click.png`
- `.gsd/milestones/M006-fd23vy/evidence/S03/T02-debug-policy-window-map.txt`
- `.gsd/milestones/M006-fd23vy/evidence/S03/vm-validate-20260703T173436Z.txt`
