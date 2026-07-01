# S03: Computer use onboarding import

**Goal:** Validate the real first-run provider import path from authenticated Chrome Profile 1.
**Demo:** After this: visual automation drives Pinemeter onboarding and imports Claude and ChatGPT from Chrome Profile 1, or captures a root-caused sanitized failure.

## Must-Haves

- Computer-use or AppleScript fallback can navigate the setup wizard.
- Browser import targets the Chrome profile/session expected by the VM.
- Claude credential import reaches configured or actionable sanitized error state.
- ChatGPT session import reaches configured or actionable sanitized error state.
- Raw cookies, tokens, and session keys are never printed in logs or summaries.

## Proof Level

- This slice proves: uat

## Integration Closure

Successful or root-caused onboarding state flows into runtime verification in S04.

## Verification

- Produces visual and structured evidence of the hardest user path.

<tasks>
- [ ] **T01**: Map onboarding UI controls for automation _(medium)_
  Inspect the setup wizard with computer-use or Accessibility and identify stable labels, buttons, menu-bar entry points, and prompts needed to start browser import. Prefer semantic selectors or AX labels over coordinates.
  - Files: `scripts/vm_validation/README.md`
  - Verify: Documented UI map includes launch state, import action, browser/Profile 1 assumption, and fallback strategy. Screenshot evidence avoids secrets.
- [ ] **T02**: Drive Chrome Profile 1 import from first run _(medium)_
  From clean reset, use computer-use or AppleScript fallback to drive first-run onboarding and trigger browser import from the authenticated Chrome Profile 1 environment. Do not inspect or print raw cookie values.
  - Files: `scripts/vm_validation/pinemeter_vm_validate.sh`
  - Verify: A full clean-reset onboarding attempt completes to a provider result state. Evidence records UI stages and sanitized result messages only.
- [ ] **T03**: Classify import outcomes without leaking credentials _(medium)_
  Interpret Claude and ChatGPT import results as configured, missing browser auth, API rejection, cookie decoding failure, permission failure, or automation failure. Add sanitized outcome reporting to the harness if needed.
  - Files: `scripts/vm_validation/pinemeter_vm_validate.sh`, `scripts/vm_validation/README.md`
  - Verify: Harness output names outcome categories and never includes raw cookie, token, session key, or header values. Failure categories are actionable.
</tasks>

## Files Likely Touched

- scripts/vm_validation/README.md
- scripts/vm_validation/pinemeter_vm_validate.sh
