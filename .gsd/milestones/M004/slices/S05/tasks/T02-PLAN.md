---
estimated_steps: 1
estimated_files: 3
skills_used: []
---

# T02: Run Gemini final verification

Run full tests and provider redaction/copy audits after Gemini integration, fixing only M004-scope issues.

## Inputs

- `Pinemeter`
- `PinemeterTests`

## Expected Output

- `Pinemeter`
- `PinemeterTests`
- `scripts/provider_workflow_copy_audit.py`

## Verification

`xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` plus provider copy/redaction audit where applicable.

## Observability Impact

Produces final automated Gemini evidence.
