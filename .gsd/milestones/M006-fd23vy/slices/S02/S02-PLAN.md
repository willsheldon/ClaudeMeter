# S02: Clean install and first run reset

**Goal:** Create a deterministic clean-install loop for the VM.
**Demo:** After this: Pinemeter can be built, copied to the VM, installed, reset to clean first-run state, and launched reproducibly.

## Must-Haves

- Debug or signed app bundle source is selected and documented.
- App bundle transfers and launches on the VM.
- Preferences for `com.eddmann.Pinemeter` are cleared.
- Exact Claude and ChatGPT Keychain items are removed before launch.
- Pre-launch and post-launch checks prove state transitions without printing credential values.

## Proof Level

- This slice proves: integration

## Integration Closure

The reset and install commands are rerunnable and feed S03 onboarding attempts.

## Verification

- Adds repeatable state probes for clean-first-run validation.

<tasks>
- [ ] **T01**: Build and select app bundle for VM install _(small)_
  Run a fresh local Debug build or select a verified existing app bundle. Record the app path and signing or quarantine status without modifying release signing policy.
  - Verify: `xcodebuild clean build -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` exits 0, and `test -d "$BUILT_PRODUCTS_DIR/Pinemeter.app"` passes for the chosen bundle.
- [ ] **T02**: Create VM reset and install script _(medium)_
  Implement a repo-local helper that copies Pinemeter.app to the VM, installs it under a predictable path, clears quarantine if needed, removes preferences, and deletes only the exact known Claude and ChatGPT Keychain items. It must not print credential values.
  - Files: `scripts/vm_validation/pinemeter_vm_validate.sh`, `scripts/vm_validation/README.md`
  - Verify: Dry-run or explicit reset mode shows the exact commands and live reset exits 0. Keychain delete commands are scoped to the exact service/account pairs.
- [ ] **T03**: Launch app and verify first-run state _(small)_
  Use the harness to install and launch Pinemeter on the VM from clean state. Verify process state, preference state, and absence or creation of expected Keychain items without exposing values.
  - Files: `scripts/vm_validation/pinemeter_vm_validate.sh`
  - Verify: Remote launch exits 0, Pinemeter process is present or menu-bar app state is observable, and first-run state is confirmed through sanitized probes.
</tasks>

## Files Likely Touched

- scripts/vm_validation/pinemeter_vm_validate.sh
- scripts/vm_validation/README.md
