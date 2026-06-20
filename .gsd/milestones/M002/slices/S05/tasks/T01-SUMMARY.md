---
id: T01
parent: S05
milestone: M002
key_files:
  - PinemeterTests/SecurityInvariantTests.swift
  - PinemeterTests/ProviderErrorWorkflowTests.swift
  - PinemeterTests/AppModelTests.swift
  - PinemeterTests/ChatGPTUsageServiceTests.swift
key_decisions:
  - (none)
duration: 
verification_result: passed
completed_at: 2026-06-18T22:24:52.427Z
blocker_discovered: false
---

# T01: Added credential lifecycle regression tests across Claude and ChatGPT paths.

**Added credential lifecycle regression tests across Claude and ChatGPT paths.**

## What Happened

Added regression coverage for Claude credential setup, invalid recovery, valid reuse, clear, and reacquisition in AppModelTests. Added ChatGPT lifecycle coverage for invalid validation, first acquisition, bootstrap reuse, clear, and reacquisition with file-local test doubles. Extended ChatGPTUsageServiceTests to verify a cleared invalid persisted session can be reacquired and used again. Added provider workflow and security invariant coverage to keep lifecycle recovery copy provider-specific and diagnostic/source surfaces free of synthetic credential material.

## Verification

Ran the task-plan command successfully: `xcodebuild test -quiet -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests -only-testing:PinemeterTests/ProviderErrorWorkflowTests -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/ChatGPTUsageServiceTests` returned status=0.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `xcodebuild test -quiet -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests -only-testing:PinemeterTests/ProviderErrorWorkflowTests -only-testing:PinemeterTests/AppModelTests -only-testing:PinemeterTests/ChatGPTUsageServiceTests` | 0 | ✅ pass | 8000ms |

## Deviations

None.

## Known Issues

None.

## Files Created/Modified

- `PinemeterTests/SecurityInvariantTests.swift`
- `PinemeterTests/ProviderErrorWorkflowTests.swift`
- `PinemeterTests/AppModelTests.swift`
- `PinemeterTests/ChatGPTUsageServiceTests.swift`
