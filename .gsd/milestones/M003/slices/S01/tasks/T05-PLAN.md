---
estimated_steps: 1
estimated_files: 3
skills_used: []
---

# T05: Reconciled the provider status surface audit with the final shared sanitized setup/settings presentation contract.

Update the host-owned provider status surface audit so it checks the final shared AppProviderCredentialStatus presentation contract used by SettingsView and SetupWizardView instead of stale pre-refactor snippets. Do not relax secret-leakage checks; the audit should still prove setup/settings consume sanitized provider status models and do not expose credential material. Rerun the audit, full tests, and credential leakage grep after the audit contract is repaired.

## Inputs

- `.gsd/milestones/M003/slices/S01/tasks/T01-SUMMARY.md`
- `.gsd/milestones/M003/slices/S01/tasks/T02-SUMMARY.md`
- `.gsd/milestones/M003/slices/S01/tasks/T03-SUMMARY.md`
- `.gsd/milestones/M003/slices/S01/tasks/T04-SUMMARY.md`

## Expected Output

- `scripts/provider_status_surface_audit.py`
- `.gsd/milestones/M003/slices/S01/tasks/T05-SUMMARY.md`

## Verification

python3 scripts/provider_status_surface_audit.py
xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug
rg -n "sk-|session-token|__Secure|cookie" Pinemeter/Views PinemeterTests
