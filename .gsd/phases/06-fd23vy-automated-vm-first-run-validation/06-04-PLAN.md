# S04: Runtime state and diagnostic verification

**Goal:** Verify the VM runtime state after the onboarding import attempt using sanitized UI, preference, Keychain metadata, and diagnostic evidence.
**Demo:** After this: menu-bar state, app logs, Keychain presence, preferences, and screenshots prove what the VM onboarding achieved.

## Must-Haves

- The post-import setup/menu state is captured with sanitized screenshot and AX text.
- Exact Pinemeter Keychain item presence/absence is checked without reading secret values.
- Preferences and process/runtime status are recorded without credential material.
- The observed outcome is classified using the S03 taxonomy.

## Proof Level

- This slice proves: Runtime evidence from macvm2.local plus local artifact references.

## Integration Closure

Consumes S01/S02 harnesses and S03 outcome taxonomy; produces diagnostic evidence for deciding whether S05 fix/rerun work is needed.

## Verification

- Adds S04 evidence files that show what the app achieved and why provider onboarding did or did not configure credentials.

<tasks>
- [x] **T01**: Captured the post-import UI outcome after the VM keychain prompt was allowed. _(small)_
  Use the existing VM SSH/screenshot/AX channel to capture the Pinemeter automation window after the Keychain prompt was allowed. Record visible provider statuses and sanitized error text only.
  - Verify: Evidence files under the S04 evidence directory exist and contain sanitized missing/configured status text without credential values.
- [x] **T02**: Captured sanitized runtime metadata showing no saved provider credentials after the import attempt. _(small)_
  Check exact expected Pinemeter Keychain item presence only, preferences existence/keys only, process args, app bundle metadata, and sanitized logs if available. Do not read Keychain values, cookies, tokens, authorization headers, or browser storage contents.
  - Files: `scripts/vm_validation/pinemeter_vm_validate.sh`
  - Verify: Metadata evidence under the S04 evidence directory exists and forbidden-value scans do not show credential-dumping commands or values.
- [x] **T03**: Classified the post-unlock runtime outcome as `missing_browser_auth`. _(small)_
  Summarize the observed runtime state using the S03 taxonomy and decide whether S05 needs code fixes or a rerun after browser auth is restored.
  - Files: `scripts/vm_validation/README.md`
  - Verify: Outcome classification evidence is present and references objective S04 evidence.
</tasks>

## Files Likely Touched

- scripts/vm_validation/pinemeter_vm_validate.sh
- scripts/vm_validation/README.md
