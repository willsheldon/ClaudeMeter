---
estimated_steps: 1
estimated_files: 3
skills_used: []
---

# T02: Added safe automated reset and redaction checks for provider credential workflows.

Add or update tests/scripts that verify redaction and document safe local reset checks without deleting real user data during automated tests. Use synthetic credentials and existing test doubles.

## Inputs

- `PinemeterTests/SecurityInvariantTests.swift`
- `PinemeterTests/ProviderErrorWorkflowTests.swift`
- `scripts/provider_workflow_copy_audit.py`

## Expected Output

- `PinemeterTests/SecurityInvariantTests.swift`
- `PinemeterTests/ProviderErrorWorkflowTests.swift`

## Verification

`xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests -only-testing:PinemeterTests/ProviderErrorWorkflowTests` and `python3 scripts/provider_workflow_copy_audit.py` if present/applicable.

## Observability Impact

Improves automated proof for redaction and workflow copy.
