# Pinemeter VM Validation Harness

This directory contains agent-runnable helpers for validating Pinemeter first-run onboarding on the macOS VM without exposing credentials.

## Target VM

Defaults:

- Host: `macvm2.local`
- User: `will`
- Evidence root: `.gsd/milestones/M006-fd23vy/evidence/`

Override with environment variables when the VM is reachable under a different name:

```sh
PINEMETER_VM_HOST=<host-or-ip> PINEMETER_VM_USER=will scripts/vm_validation/pinemeter_vm_probe.sh
```

## Evidence policy

Allowed evidence:

- Host reachability and sanitized SSH outcome category.
- macOS version/build, current username, and passwordless-sudo result.
- Chrome profile directory names only, such as `Default` or `Profile 1`.
- Presence/absence of tools and applications.
- Screenshots that do not show cookies, tokens, Keychain values, authorization headers, or private account pages.
- Sanitized app logs with credential material redacted at source.

Prohibited evidence:

- Raw Chrome cookie databases or browser storage contents.
- Cookie values, session keys, bearer tokens, CSRF tokens, authorization headers, or API keys.
- Keychain item values or broad Keychain dumps.
- Full HTTP request/response bodies from authenticated provider APIs.
- Screenshots of credential material or provider account details unrelated to onboarding state.

## PineShot fallback

Local PineShot notes were found at:

- `/Users/will/wiki/pineshot-screenshots.md`
- `/Users/will/code/claude/debug-screenshots-with-pineshot.md`

The useful operating assumptions from those notes are:

- PineShot may already have Screen Recording permission even when shell `screencapture` does not.
- PineShot exposes a file-based debug IPC in its sandbox container:
  - Trigger: `~/Library/Containers/com.pineit.pineshot/Data/Documents/debug-trigger`
  - Done signal: `~/Library/Containers/com.pineit.pineshot/Data/Documents/debug-done`
  - Results: `~/Library/Containers/com.pineit.pineshot/Data/Documents/debug-info.txt`
  - Images: `~/Library/Containers/com.pineit.pineshot/Data/Documents/debug-*.png`
- PineShot must be running (`pgrep -x PineShot`) before the debug IPC can be used.

Use PineShot as a screenshot fallback only for sanitized onboarding screens. Do not capture provider account pages or browser developer tools showing credential-bearing data.

## Visual automation fallback

Validated remote visual controls on `macvm2.local`:

- AppleScript via `osascript` can inspect `System Events` process state.
- `screencapture -x` can capture the active desktop.
- A safe neutral TextEdit probe window was captured and copied back as `.gsd/milestones/M006-fd23vy/evidence/S01/T02-visual-probe.png`.

If dedicated computer-use tooling is not available for the remote VM, use SSH-driven AppleScript for semantic UI actions and SSH-driven `screencapture` or PineShot IPC for sanitized visual evidence.

## S03 onboarding UI map

Source-of-truth labels from the app code:

- Status item accessibility label: `Pinemeter` (`MenuBarManager.setupStatusItem`).
- First-run title: `Welcome to Pinemeter` (`SetupWizardView`).
- Import section title: `Import signed-in browser sessions`.
- Browser import action labels include `Import from Default Browser`, `Import from Chrome`, `Import from Safari`, `Import from Brave`, `Import from Edge`, `Import from Arc`, and `Import from Firefox`.
- Import buttons carry accessibility labels equal to their visible titles and an accessibility hint explaining that Claude and ChatGPT sessions are imported without showing credential values.
- Full Disk Access remediation button label: `Open Full Disk Access`.

Observed VM state from `macvm2.local`:

- Pinemeter launches as a menu bar process with no normal windows after a clean reset.
- Accessibility sees the status item as `menu bar item 1 of menu bar 2` on process `Pinemeter`, with description `Pinemeter` and geometry near `position=1644,3 size=31,24` on the current VM display.
- `AXPress` on that status item and `cliclick` at the observed center did not open a detectable AX window in the current desktop state. Treat coordinates as a last-resort fallback, not a stable selector.
- Chrome `Profile 1` exists on the VM and is the expected authenticated browser profile for S03 import attempts.

Preferred S03 automation strategy:

1. Run `scripts/vm_validation/pinemeter_vm_validate.sh --all` to build from the selected bundle, install, reset, and launch cleanly.
2. Prefer AX/semantic entry through the status item label `Pinemeter`; if unavailable, use screenshot-guided computer-use against the menu bar icon.
3. Once the popover appears, target buttons by accessibility label, especially `Import from Chrome`.
4. Capture only sanitized stage evidence: visible labels, provider result categories, and screenshots without cookies, tokens, browser storage, Keychain values, or provider account details.
5. If the popover cannot be opened, classify the result as `ui_entry_unavailable` and include AX map plus screenshot evidence.
6. If macOS prompts for the login keychain password while reading Chrome Safe Storage, classify the result as `keychain_access_prompt_requires_password`. Do not type, store, screenshot after entry, or log the password. A human must approve/unlock the prompt on the VM before the agent can continue the import.

## S03 outcome categories

Use these sanitized categories when recording import attempts:

- `configured`: Provider credential/session imported and the provider card reports configured/connected state.
- `missing_browser_auth`: Browser profile is readable but the provider session is absent or expired.
- `keychain_access_prompt_requires_password`: macOS requires a login keychain password to read Chrome Safe Storage. Stop before credential entry.
- `full_disk_access_required`: macOS blocks browser storage access and the UI offers Full Disk Access remediation.
- `api_rejection`: Session material was saved or read, but provider usage refresh rejected it; record only status/error category and sanitized UI text.
- `cookie_decoding_failure`: Browser cookie material could not be decoded/reassembled; never print cookie values or encrypted blobs.
- `ui_entry_unavailable`: The setup UI could not be opened or targeted; include AX map and screenshot evidence.
- `unexpected_runtime_error`: Any other sanitized app/runtime error; include stage, provider, and redacted message only.

## Current S03 import attempt status

- A DEBUG-only `--open-popover-after-launch` automation hook was added for VM validation builds. It opens the setup view in a normal titled window (`Pinemeter Automation`) so AX and screenshots can inspect the same onboarding content without relying on brittle menu-bar popover clicks.
- The first S03 import attempt reached the setup UI and triggered browser import; macOS displayed a `Chrome Safe Storage` Keychain prompt requiring the login keychain password.
- After human approval of that prompt, the import continued and Pinemeter reported sanitized missing-session errors for Claude and ChatGPT.
- Current sanitized outcome category: `missing_browser_auth`.
- Current evidence: `.gsd/milestones/M006-fd23vy/evidence/S04/outcome-classification.txt`.

## Repeatable validation sequence

Run these commands from the repository/worktree root. They collect metadata only and must not print or store credential values.

1. Probe VM access and local automation prerequisites:

   ```sh
   PINEMETER_VM_HOST=macvm2.local scripts/vm_validation/pinemeter_vm_probe.sh
   ```

2. Build a Debug app locally:

   ```sh
   xcodebuild clean build \
     -project Pinemeter.xcodeproj \
     -scheme Pinemeter \
     -configuration Debug
   ```

3. Install, reset, and launch the app on the VM. The DEBUG launch arg opens the setup view in a titled automation window for AX/screenshot validation:

   ```sh
   PINEMETER_VM_HOST=macvm2.local \
   PINEMETER_VM_LAUNCH_ARGS=--open-popover-after-launch \
   scripts/vm_validation/pinemeter_vm_validate.sh --all
   ```

4. If the Chrome Safe Storage login Keychain prompt appears, stop automation until a human unlocks/allows it on the VM. Do not enter, store, or log that password through agent tools.

5. After the prompt is allowed, capture sanitized UI/runtime evidence and classify the outcome with the S03 categories. Current final evidence is under:

   - `.gsd/milestones/M006-fd23vy/evidence/S04/post-import-ui-map.txt`
   - `.gsd/milestones/M006-fd23vy/evidence/S04/post-import-ui.png`
   - `.gsd/milestones/M006-fd23vy/evidence/S04/runtime-metadata.txt`
   - `.gsd/milestones/M006-fd23vy/evidence/S04/outcome-classification.txt`

Current final outcome: `missing_browser_auth`. The harness, install/reset/launch flow, DEBUG automation window, and Chrome Safe Storage access all worked; Chrome Profile 1 did not provide importable Claude or ChatGPT sessions.

## Current probe status

At the time this harness was added, the original planned host `Wills-AUTH-vm.local` did not resolve from the agent host and historical known-host IPs timed out. The VM was later identified as `macvm2.local`; the probe script now defaults to that name. It exits with category `ssh_or_dns_unavailable` when the configured host is unreachable and writes a small evidence file under the evidence root.
