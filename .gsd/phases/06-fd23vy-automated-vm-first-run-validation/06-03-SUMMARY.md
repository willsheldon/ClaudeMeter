---
id: S03
parent: M006-fd23vy
milestone: M006-fd23vy
provides:
  - Stable setup UI automation entry for Debug VM validation builds.
  - Actionable classification of the current Chrome Safe Storage keychain blocker.
  - Provider import outcome taxonomy for continuation after human keychain approval.
requires:
  - slice: S01
    provides: Remote AX/screenshot evidence conventions.
  - slice: S02
    provides: Clean install/reset/launch harness.
affects:
  - S04
  - S05
  - S06
key_files:
  - Pinemeter/App/AppDelegate.swift
  - Pinemeter/Views/MenuBar/MenuBarManager.swift
  - scripts/vm_validation/pinemeter_vm_validate.sh
  - scripts/vm_validation/README.md
  - .gsd/milestones/M006-fd23vy/evidence/S03/T02-before-import-click.png
  - .gsd/milestones/M006-fd23vy/evidence/S03/T02-debug-policy-window-map.txt
  - .gsd/milestones/M006-fd23vy/evidence/S03/vm-validate-20260703T173436Z.txt
key_decisions: []
patterns_established:
  - Use DEBUG-only automation windows for VM validation when menu-bar popovers are not remotely targetable.
  - Classify credential-gated macOS prompts as `keychain_access_prompt_requires_password` and stop before password entry.
  - Use sanitized outcome categories rather than raw provider/browser credential data.
observability_surfaces:
  - S03 evidence screenshots and AX maps under `.gsd/milestones/M006-fd23vy/evidence/S03/`.
  - README outcome taxonomy for future import attempts.
drill_down_paths:
  - .gsd/milestones/M006-fd23vy/slices/S03/tasks/T01-SUMMARY.md
  - .gsd/milestones/M006-fd23vy/slices/S03/tasks/T02-SUMMARY.md
  - .gsd/milestones/M006-fd23vy/slices/S03/tasks/T03-SUMMARY.md
duration: ""
verification_result: passed
completed_at: 2026-07-03T17:39:54.663Z
blocker_discovered: false
---

# S03: Computer use onboarding import

**Drove first-run onboarding to a sanitized Chrome Safe Storage keychain-password prompt and documented actionable import outcome categories.**

## What Happened

S03 mapped and exercised the first-run onboarding path on `macvm2.local`. Normal NSStatusItem popover entry was not reliable through remote AX, System Events click, or coordinate click, so an approved DEBUG-only launch hook was added: `--open-popover-after-launch`. For VM validation builds only, it opens the same `MenuBarPopoverView` setup content in a titled `Pinemeter Automation` window. The VM validation harness can pass optional launch args and now kills existing Pinemeter processes before install/launch to avoid stale instances. With the hook, the setup UI became visible and exposed missing Claude/ChatGPT/Gemini credential states plus browser import controls. A browser import attempt was triggered and reached a macOS `Chrome Safe Storage` prompt requiring the login keychain password. The agent stopped before credential entry and classified the attempt as `keychain_access_prompt_requires_password`. The README now documents stable UI labels, the DEBUG automation hook, Chrome Profile 1 assumption, fallback strategies, and a sanitized outcome taxonomy for future attempts.

## Verification

Fresh Debug builds passed after the automation hook changes. `PINEMETER_VM_LAUNCH_ARGS=--open-popover-after-launch scripts/vm_validation/pinemeter_vm_validate.sh --all` exited 0 and launched a single Pinemeter process with the hook. AX/window evidence confirmed the `Pinemeter Automation` setup window and expected missing provider labels. Screenshot evidence captured the setup UI and Chrome Safe Storage keychain prompt before any credential entry. README verification found all required outcome categories: configured, missing_browser_auth, keychain_access_prompt_requires_password, full_disk_access_required, api_rejection, cookie_decoding_failure, ui_entry_unavailable, and unexpected_runtime_error. Secret-safety scans found only policy/taxonomy/evidence labels, not credential value reads or dumps.

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

The original plan expected direct computer-use/menu-bar popover control. Remote AX and coordinate attempts did not open the NSStatusItem popover, so an approved DEBUG-only automation window hook was added for VM validation. The import did not proceed beyond Chrome Safe Storage because a human login keychain password is required.

## Known Limitations

A human must unlock/allow the Chrome Safe Storage prompt on the VM before provider-specific import outcomes can be reached. The DEBUG automation hook is for validation builds only and should not be enabled in release builds.

## Follow-ups

After the VM keychain prompt is approved/unlocked, rerun `PINEMETER_VM_LAUNCH_ARGS=--open-popover-after-launch scripts/vm_validation/pinemeter_vm_validate.sh --all`, then trigger `Import from Chrome` again and classify the resulting provider states with the README taxonomy.

## Files Created/Modified

- `Pinemeter/App/AppDelegate.swift` — Adds DEBUG-only automation window hook for `--open-popover-after-launch`.
- `Pinemeter/Views/MenuBar/MenuBarManager.swift` — Adds DEBUG-only wrapper for popover presentation, retained from the first hook attempt.
- `scripts/vm_validation/pinemeter_vm_validate.sh` — Supports optional launch args and kills stale Pinemeter instances before install/launch.
- `scripts/vm_validation/README.md` — Documents S03 UI map, automation hook, current keychain blocker, and outcome taxonomy.
