# S01: VM automation access harness

**Goal:** Prove and document the remote automation channels before touching app onboarding.
**Demo:** After this: the agent has a proven command surface for SSH, sudo, AppleScript, computer-use, screenshot capture, PineShot fallback, and sanitized artifact collection on Wills-AUTH-vm.local.

## Must-Haves

- SSH as `will` works and passwordless sudo is verified.
- Accessibility and screenshot capture are verified.
- Computer-use feasibility is checked or a fallback capture plan is documented.
- PineShot wiki notes are incorporated into the evidence strategy.
- No secrets are collected or printed.

## Proof Level

- This slice proves: operational

## Integration Closure

Harness commands work against the real VM and produce a small sanitized probe artifact set.

## Verification

- Establishes the diagnostic channel used by all later slices.

<tasks>
- [x] **T01**: Verified VM SSH access and metadata-only environment assumptions against renamed host `macvm2.local`. _(small)_
  Verify SSH access to Wills-AUTH-vm.local as `will`, passwordless sudo, macOS version, Chrome profile layout, and installed screenshot tools. Check the local wiki for VM or PineShot operating notes before relying on behavior. Capture only sanitized probe output.
  - Verify: Run SSH probes for `sw_vers`, `id`, `sudo -n whoami`, Chrome profile directories, and tool availability. Evidence must not include cookies or secrets.
- [x] **T02**: Verified remote visual automation through AppleScript and sanitized screenshot capture on `macvm2.local`. _(small)_
  Validate System Events, AppleScript, `screencapture`, and standard computer-use availability for the VM. Launch PineShot if needed and verify its menu-bar-only behavior matches wiki notes. Capture a sanitized screenshot artifact that shows no secrets.
  - Verify: Run a remote AppleScript process count, a screenshot probe, and a computer-use feasibility check or documented fallback. Screenshot artifact exists and contains no credential material.
- [x] **T03**: Defined sanitized VM validation evidence conventions and a rerunnable VM probe helper. _(small)_
  Choose local and remote evidence paths, redaction rules, SSH option wrapper, and naming conventions for screenshots, logs, and state probes. Do not create broad logging that could capture cookies or tokens.
  - Files: `scripts/vm_validation/README.md`
  - Verify: Documentation names evidence paths, prohibited data, and safe commands. Review with `rg` for forbidden raw-cookie or token-dump commands before completion.
</tasks>

## Files Likely Touched

- scripts/vm_validation/README.md
