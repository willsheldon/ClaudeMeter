---
id: M006-fd23vy
title: "Automated VM first run validation"
status: complete
completed_at: 2026-07-03T18:28:46.590Z
key_decisions:
  - Use `macvm2.local` as the VM host after the original hostname was renamed.
  - Add a DEBUG-only `--open-popover-after-launch` automation window because menu-bar popover automation was unreliable remotely.
  - Classify final provider-import outcome as `missing_browser_auth`, not an app defect.
  - Skip S05 fix loop because S04 root-caused the failure to browser profile state.
key_files:
  - scripts/vm_validation/README.md
  - scripts/vm_validation/pinemeter_vm_probe.sh
  - scripts/vm_validation/pinemeter_vm_validate.sh
  - Pinemeter/App/AppDelegate.swift
  - Pinemeter/Views/MenuBar/MenuBarManager.swift
  - .gsd/milestones/M006-fd23vy/evidence/S04/outcome-classification.txt
  - .gsd/milestones/M006-fd23vy/evidence/S06-xcodebuild-test.log
lessons_learned:
  - Remote menu-bar popover clicks can be brittle even when AX sees the status item; a DEBUG-only normal window provides much better validation access.
  - Chrome Safe Storage may require a human login keychain approval step; agents must stop before credential entry.
  - A missing provider session after keychain approval is distinct from keychain access failure and should be classified separately.
---

# M006-fd23vy: Automated VM first run validation

**Built a reusable macVM Pinemeter first-run validation harness and root-caused the current provider-import failure as missing browser auth.**

## What Happened

M006 established an agent-runnable validation path for Pinemeter first-run onboarding on `macvm2.local`. The work added a metadata-only VM probe, a clean install/reset/launch script, and README documentation covering evidence policy, prohibited credential data, VM commands, and provider-import outcome categories. The harness proved SSH, sudo, AppleScript, screenshots, app installation, reset semantics, signing/quarantine state, and runtime metadata collection. Because remote AX/coordinate automation could not reliably open the menu-bar NSStatusItem popover, the app gained a DEBUG-only `--open-popover-after-launch` automation hook that opens the same setup view in a normal titled `Pinemeter Automation` window. The validation drove the browser import path through Chrome Safe Storage, stopped safely for the login keychain prompt until human approval, then continued and classified the final provider outcome as `missing_browser_auth`: Chrome Profile 1 did not provide importable Claude or ChatGPT sessions, and exact Pinemeter credential Keychain items remained absent. S05 was skipped because no Pinemeter code defect was confirmed. S06 documented the repeatable sequence and fresh `xcodebuild test` passed.

## Success Criteria Results

- ✅ Build/install/launch on VM: satisfied by S02/S06.
- ✅ Clean first-run reset: preferences and exact Claude/ChatGPT Keychain items cleared/absent.
- ✅ Visual automation: satisfied by SSH/AppleScript/screenshot harness and DEBUG automation window.
- ✅ Import success or categorized failure: final outcome `missing_browser_auth` with sanitized evidence.
- ✅ Post-onboarding verification without secrets: exact Keychain presence checks only; no values printed.
- ✅ Rerunnable validation command/script: documented in `scripts/vm_validation/README.md`.

## Definition of Done Results

- ✅ All planned executable slices complete; S05 skipped with reason after no defect was found.
- ✅ Milestone validation verdict: pass.
- ✅ Fresh `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` passed.
- ✅ Secret-safety scans found only policy/secret-safety text, not credential values or dump commands.
- ✅ Evidence stored under `.gsd/milestones/M006-fd23vy/evidence/` with final classification in S04.

## Requirement Outcomes

No requirement tools were used per project gotcha. Milestone-specific criteria were validated directly. The open product/environment precondition is that Chrome Profile 1 must contain importable signed-in Claude/ChatGPT sessions for a configured-provider outcome.

## Deviations

The milestone vision originally referenced `Wills-AUTH-vm.local`; the VM is now `macvm2.local`. S05 was skipped because the fix loop was not applicable after the final root cause was environmental browser auth. Provider import success was not proven; the allowed categorized-failure path was used.

## Follow-ups

If successful provider import must be proven, sign into Claude and ChatGPT in Chrome Profile 1 on `macvm2.local`, rerun the README validation sequence, and reclassify the outcome. Do not make app fixes unless new evidence shows valid sessions were present but Pinemeter failed to import them.
