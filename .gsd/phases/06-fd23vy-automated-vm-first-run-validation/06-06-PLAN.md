# S06: Reusable validation command and handoff

**Goal:** Leave future agents with a clear reusable VM validation command sequence, evidence map, and current handoff status.
**Demo:** After this: future agents can rerun the VM validation end to end using documented commands and know where evidence is stored.

## Must-Haves

- README includes end-to-end commands for probe, build/install/reset/launch, and post-import diagnostics.
- README states current VM host, current outcome, and exact evidence paths.
- Final validation checks confirm commands/docs are discoverable and no secret-value patterns were introduced.

## Proof Level

- This slice proves: Artifact inspection plus command/path verification.

## Integration Closure

Closes the milestone by turning the S01-S04 harness and evidence into a reusable continuation workflow.

## Verification

- Improves future-agent diagnosability by documenting where evidence is written and how outcomes are classified.

<tasks>
- [x] **T01**: Documented the repeatable VM validation command sequence and evidence map. _(small)_
  Update the VM validation README with a concise end-to-end command sequence for future agents, including default host, build path selection, install/reset/launch, automation launch args, and evidence locations.
  - Files: `scripts/vm_validation/README.md`
  - Verify: README contains probe, xcodebuild, validate --all, launch args, S04 evidence, and current `missing_browser_auth` outcome.
- [x] **T02**: Verified final harness documentation, artifact safety, GSD status, and the Swift test suite. _(small)_
  Run final checks over README/scripts/evidence for required strings and forbidden credential-value patterns; inspect GSD status.
  - Files: `scripts/vm_validation/README.md`, `scripts/vm_validation/pinemeter_vm_probe.sh`, `scripts/vm_validation/pinemeter_vm_validate.sh`
  - Verify: Required strings are present, forbidden scan has only policy/secret-safety hits, and GSD status shows S06 ready for closure.
</tasks>

## Files Likely Touched

- scripts/vm_validation/README.md
- scripts/vm_validation/pinemeter_vm_probe.sh
- scripts/vm_validation/pinemeter_vm_validate.sh
