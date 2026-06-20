# S05: Credential lifecycle verification — UAT

**Milestone:** M002
**Written:** 2026-06-18T22:29:59.470Z

# S05 UAT: Credential lifecycle verification

## UAT Type
Automated artifact and regression-test UAT with operator-readable acceptance steps.

## Preconditions
- Worktree is in the M002/S05 assembled state.
- Xcode command line tools can run the Pinemeter Debug test suite.
- No real provider credentials are required; tests use synthetic credential/session material.

## Steps and Expected Outcomes
1. Run `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug`.
   - Expected: the full Debug test suite passes, including credential lifecycle and redaction tests.
2. Inspect signing settings with `xcodebuild -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -showBuildSettings | egrep 'CODE_SIGN_IDENTITY|DEVELOPMENT_TEAM'`.
   - Expected: official Autimo settings remain visible: Developer ID Application for AUTIMO SYSTEMS INC and team `HMR9RDR6M2`.
3. Review `.gsd/REQUIREMENTS.md` for R010.
   - Expected: R010 is `validated` with M002/S05 lifecycle evidence and notes preserving R011/M003, R012/M004, R013/M005, and R014 boundaries.
4. Review `.gsd/QUEUE.md` for M003.
   - Expected: provider-aware setup, status, error, recovery, and notification polish remains explicitly handed to M003/R011.
5. Review `.gsd/milestones/M002/slices/S05/S05-ASSESSMENT.md`.
   - Expected: the report records passing lifecycle verification, signing evidence, and no remediation required for S05.

## Edge Cases Covered
- First credential/session acquisition.
- Reuse after relaunch/bootstrap boundary.
- Invalid credential/session recovery.
- Claude repair/re-save after signing identity compatibility issues.
- Clear and reacquisition flows.
- Redaction from settings, diagnostics, logs, user-facing errors, and GSD artifacts.

## Evidence
- `gsd_exec` `27fc06dd-77cd-4df8-848c-4bf6e262c5c6`: full Debug suite passed and signing settings preserved.
- `gsd_exec` `785adb78-e0eb-450a-b85e-bd87cdacffa4`: R010, M003 queue handoff, and S05 assessment artifact verified.
