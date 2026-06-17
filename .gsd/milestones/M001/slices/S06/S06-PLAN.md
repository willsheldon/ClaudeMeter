# S06: Safe cleanup and ownership refactor

**Goal:** Clean safe stale ownership paths and low-risk source/docs assumptions after the Pinemeter rename while preserving provider, credential, diagnostic, test, and compatibility invariants from S04/S05.
**Demo:** After this: obvious dead code, stale names, obsolete assumptions, and low-risk structural issues are removed or cleaned while preserving behavior.

## Must-Haves

- Fresh cache writes use Pinemeter-owned private and public paths while preserving legacy ClaudeMeter compatibility for existing cache/export consumers.
- Credential compatibility identifiers in Keychain code and entitlements are explicitly protected as intentional legacy surfaces deferred to M002; no Keychain service/access-group rename is performed.
- Refresh-interval clamp behavior uses the existing constants and is covered by focused tests.
- Non-historical stale ownership documentation is updated or removed without rewriting historical changelog links or operational SSM identifiers.
- Provider/error audit and focused XCTest verification pass, including new cache and settings tests plus S05 security/provider/session invariants.
- Q3 Threat Surface: no credential storage redesign, no response-body/credential diagnostic logging, and no new secret persistence surfaces are introduced.
- Q4 Requirement Impact: advances R007 and supports R001/R002/R006/R008 by keeping rename cleanup compatible with provider/error safety and final build/test readiness.
- Q5 Failure Modes: legacy cache users, old disk cache migration, Keychain compatibility, stale docs, and diagnostic-redaction regressions are covered by tests or explicit documentation.
- Q6 Load Profile: cache changes remain lightweight file reads/writes on existing repository calls; no polling, telemetry, network, or heavy background work is added.
- Q7 Negative Tests: focused tests assert legacy cache migration/dual-write behavior, intentional legacy credential identifiers, redacted diagnostics, provider-specific copy, and refresh clamp bounds.

## Proof Level

- This slice proves: Executable proof: focused XCTest suites for new CacheRepositoryTests and AppSettingsTests plus existing UsageServiceTests, SecurityInvariantTests, ProviderErrorWorkflowTests, SessionKeyTests, and the S05 provider workflow audit script. S07 remains responsible for final full clean build/test.

## Integration Closure

The slice closes when cache/export path cleanup, credential invariant guards, constants cleanup, and stale docs cleanup are integrated into the renamed Pinemeter project and verified together with the S05 audit/focused tests. No roadmap change is needed; S07 can consume these outputs for final verification and open-source planning.

## Verification

- Preserves local/CI health signals from scripts/provider_workflow_copy_audit.py and focused XCTest failures. Adds no production telemetry; errors and diagnostics must remain explicit and sanitized.

## Tasks

- [x] **T01: CacheRepository now writes Pinemeter-owned cache/export paths while preserving ClaudeMeter legacy compatibility.** `est:1.5h`
  skills_used: [decompose-into-slices, tdd]
  - Files: `Pinemeter/Repositories/CacheRepository.swift`, `PinemeterTests/CacheRepositoryTests.swift`
  - Verify: xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/CacheRepositoryTests -only-testing:PinemeterTests/UsageServiceTests

- [x] **T02: Guarded legacy ClaudeMeter credential identifiers with source comments and executable source-level invariants.** `est:45m`
  skills_used: [decompose-into-slices]
  - Files: `Pinemeter/Repositories/KeychainRepository.swift`, `Pinemeter/Resources/Pinemeter.entitlements`, `PinemeterTests/SecurityInvariantTests.swift`
  - Verify: xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests

- [x] **T03: AppSettings refresh interval clamping now uses shared Constants.Refresh bounds with focused boundary tests.** `est:30m`
  skills_used: [decompose-into-slices, tdd]
  - Files: `Pinemeter/Models/AppSettings.swift`, `PinemeterTests/AppSettingsTests.swift`
  - Verify: xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/AppSettingsTests

- [x] **T04: Aligned the tracked working-status document with current Pinemeter ownership while preserving historical and operational ClaudeMeter exceptions.** `est:45m`
  skills_used: [decompose-into-slices, verify-before-complete]
  - Files: `work-to-date.md`
  - Verify: python3 scripts/provider_workflow_copy_audit.py && xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/CacheRepositoryTests -only-testing:PinemeterTests/AppSettingsTests -only-testing:PinemeterTests/UsageServiceTests -only-testing:PinemeterTests/SecurityInvariantTests -only-testing:PinemeterTests/ProviderErrorWorkflowTests -only-testing:PinemeterTests/SessionKeyTests

## Files Likely Touched

- Pinemeter/Repositories/CacheRepository.swift
- PinemeterTests/CacheRepositoryTests.swift
- Pinemeter/Repositories/KeychainRepository.swift
- Pinemeter/Resources/Pinemeter.entitlements
- PinemeterTests/SecurityInvariantTests.swift
- Pinemeter/Models/AppSettings.swift
- PinemeterTests/AppSettingsTests.swift
- work-to-date.md
