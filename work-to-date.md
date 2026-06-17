# Work to Date

## Current state

This repository is now the **Pinemeter** macOS 14+ Swift 6 / SwiftUI menu bar app. It tracks AI service usage limits from the menu bar, keeps UI state on `@MainActor` observable types, isolates non-UI work in services/repositories, and builds/tests through the Pinemeter Xcode project and scheme.

Current local build command:

```bash
xcodebuild clean build \
  -project Pinemeter.xcodeproj \
  -scheme Pinemeter \
  -configuration Debug
```

Current local test command:

```bash
xcodebuild test \
  -project Pinemeter.xcodeproj \
  -scheme Pinemeter \
  -configuration Debug
```

## Ownership and naming status

The active product, project, scheme, app metadata, and primary user-facing docs should use **Pinemeter**. Remaining `ClaudeMeter` references are not automatically stale; some are intentional compatibility, historical, or operational identifiers and should only be changed in slices that explicitly own those migrations.

Intentional exceptions currently include:

- Historical release names and URLs in `CHANGELOG.md`.
- Agent/secret-management SSM paths in `AGENTS.md` and `CLAUDE.md`.
- Legacy credential, cache, export, or compatibility identifiers guarded by source comments and tests.

## Recently completed cleanup

S06 cleanup has moved low-risk ownership assumptions toward Pinemeter while preserving compatibility invariants:

- `CacheRepository` now writes Pinemeter-owned cache/export paths while preserving legacy ClaudeMeter cache/export compatibility where required.
- Legacy ClaudeMeter keychain and entitlement identifiers remain in place with explanatory compatibility comments and source-level invariant tests.
- `AppSettings` refresh interval clamping now uses shared `Constants.Refresh` bounds instead of duplicated numeric assumptions.
- This working document has been reduced to current Pinemeter status so it no longer contradicts the renamed project.

## Verification focus

For this cleanup slice, use the provider workflow copy audit plus focused Pinemeter XCTest checks that protect cache migration, settings bounds, usage behavior, security invariants, provider error workflows, and session-key handling:

```bash
python3 scripts/provider_workflow_copy_audit.py && \
xcodebuild test \
  -project Pinemeter.xcodeproj \
  -scheme Pinemeter \
  -configuration Debug \
  -only-testing:PinemeterTests/CacheRepositoryTests \
  -only-testing:PinemeterTests/AppSettingsTests \
  -only-testing:PinemeterTests/UsageServiceTests \
  -only-testing:PinemeterTests/SecurityInvariantTests \
  -only-testing:PinemeterTests/ProviderErrorWorkflowTests \
  -only-testing:PinemeterTests/SessionKeyTests
```
