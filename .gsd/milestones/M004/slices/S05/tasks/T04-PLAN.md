---
estimated_steps: 1
estimated_files: 4
skills_used: []
---

# T04: Fixed the copyable provider-error regression by making setup credential-card failure titles copyable and updating the regression test for the shared ChatGPT/Gemini provider error row.

Diagnose why CopyableErrorPresentationTests.test_userFacingErrorSurfacesUseCopyableErrorText fails after Gemini workflow integration. Fix only M004-scope user-facing provider error copy or test expectations as appropriate, preserving sanitized credential boundaries. Rerun the targeted failing test, the full xcodebuild test suite, provider_workflow_copy_audit.py, provider_status_surface_audit.py, and the S05 UAT artifact checks before returning to slice closeout.

## Inputs

- `.gsd/exec/f4d9f53d-d6f8-4775-b605-55edd30eba7e.stdout`
- `.gsd/exec/f03cbe58-91a3-47ac-a249-697dec10b79a.stdout`
- `.gsd/exec/603d7c64-320e-4e71-a1ab-5b3c41f0b829.stdout`
- `.gsd/exec/3e10273b-bab7-48ae-984d-99b3bc3150cb.stdout`
- `.gsd/exec/f632192d-3349-46c7-8463-aa511c8b60c2.stdout`

## Expected Output

- `Pinemeter`
- `PinemeterTests`
- `.gsd/milestones/M004/slices/S05/tasks/T04-SUMMARY.md`

## Verification

xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/CopyableErrorPresentationTests/test_userFacingErrorSurfacesUseCopyableErrorText
xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug
python3 scripts/provider_workflow_copy_audit.py
python3 scripts/provider_status_surface_audit.py
S05 UAT artifact check confirms required workflows and no secret-like values.
