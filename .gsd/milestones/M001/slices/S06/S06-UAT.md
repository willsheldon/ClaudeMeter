# S06: Safe cleanup and ownership refactor — UAT

**Milestone:** M001
**Written:** 2026-06-17T16:17:02.558Z

## UAT Type

Artifact and automated runtime verification for a macOS SwiftUI codebase cleanup slice. No manual UI operation is required for S06 because the slice modifies repository behavior, settings constants, source invariants, and documentation rather than adding a new user-facing flow.

## Preconditions

- Work is performed from the M001 worktree.
- The Pinemeter Xcode project and scheme exist.
- S01 through S05 are complete and their provider/security constraints are in force.

## Steps

1. Run `python3 scripts/provider_workflow_copy_audit.py`.
2. Run the focused XCTest bundle for CacheRepositoryTests, AppSettingsTests, UsageServiceTests, SecurityInvariantTests, ProviderErrorWorkflowTests, and SessionKeyTests using the Pinemeter project and scheme.
3. Inspect the results for cache compatibility, refresh interval clamp bounds, intentional legacy Keychain identifiers, provider-specific recovery copy, session key behavior, and diagnostic redaction.
4. Confirm current ownership documentation no longer presents the project as ClaudeMeter, while historical and operational ClaudeMeter exceptions remain intentionally preserved.

## Expected Outcomes

- Provider workflow copy audit passes.
- Focused XCTest bundle passes with exit code 0.
- Fresh cache/export writes use Pinemeter-owned paths while legacy ClaudeMeter cache/export compatibility remains protected by tests.
- Keychain service and access-group identifiers remain unchanged and documented as intentional legacy compatibility surfaces deferred to M002.
- AppSettings refresh interval behavior is unchanged and bounded by shared Constants.Refresh values.
- No new credential persistence, response-body diagnostic logging, polling, telemetry, or background workload is introduced.

## Edge Cases Covered

- Legacy private cache migration when the new private cache is absent.
- Dual public export compatibility for existing legacy consumers.
- Minimum and maximum refresh interval clamp boundaries.
- Exact legacy credential identifier preservation in source and entitlements.
- Provider-specific Claude/GPT copy and redacted diagnostics from S05 remain intact.

## Evidence

- gsd_exec evidence `6a6d88c7-202e-4fb7-b4e7-2b11014f9624` passed the S06 provider audit plus focused XCTest verification bundle.
