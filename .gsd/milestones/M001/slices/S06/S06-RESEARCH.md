# S06 Research: Safe cleanup and ownership refactor

## Summary

S06 should be a targeted cleanup slice, not a broad provider redesign. The highest-value safe cleanup is to align non-secret cache/export ownership naming with Pinemeter while preserving compatibility, remove or neutralize stale ownership-only comments/docs, and tighten small internal constants/tests. S04 and S05 both constrain this slice: do not rename credential/keychain identifiers without a migration plan, do not broaden provider copy into generic multi-provider language, and keep S05 diagnostic redaction intact.

Research evidence:
- `gsd_exec 4800bf8a-a46a-405f-9623-20cdb52bcafa` found non-GSD stale refs; source-critical hits are `CacheRepository`, `KeychainRepository`, and `Pinemeter.entitlements`.
- `gsd_exec 35af459f-7ba2-44c2-8545-f5889d58e1b2` classified tracked stale refs.
- `gsd_exec 31c6dc8c-4046-425d-84c6-5cb15cb022be` ran `python3 scripts/provider_workflow_copy_audit.py` successfully before S06 planning.

## Requirements and Constraints

Active/advanced requirements relevant to this slice:
- **R007**: S06 owns safe cleanup/refactoring of unused code, stale names, obsolete assumptions, and dead paths without behavior regressions.
- **R001/R002/R008 support**: cleanup must not break the Pinemeter rename, tests, or final clean build.
- **R006 support**: S05 provider/error audit must remain enforced; keep Claude-specific credential copy, ChatGPT-specific quota copy, and redacted diagnostics.

Hard constraints from prior slices:
- S04 ranked finding #1: `com.claudemeter.sessionkey` is a credential compatibility invariant. Do **not** rename `Pinemeter/Repositories/KeychainRepository.swift` service name or `Pinemeter/Resources/Pinemeter.entitlements` access group in S06 unless a migration/redaction plan is explicitly added. Prefer documenting as deferred to M002.
- S05: do not introduce generic provider claims, Gemini claims, ChatGPT credential redesign, Keychain redesign, or response-body/credential diagnostic logging.
- Project rule: UI state stays on `@MainActor @Observable`; non-UI work stays in actor services/repositories.

## Skill Discovery

Relevant installed skill considered: `observability`. Its useful rule for S06 is that unattended/background paths should leave agent-readable signals without exposing secrets. Applied as a constraint, not a request for new telemetry: if touching cache/export or diagnostics, keep errors explicit and sanitized, and preserve the S05 local/CI health signal (`scripts/provider_workflow_copy_audit.py`). No additional skill is necessary for a Swift cleanup/refactor slice; external `npx skills find` was not needed because the local SwiftUI/XCTest patterns are already established in this repo.

## Recommendation

Plan S06 as 3 to 4 small tasks:

1. **Cache/export ownership cleanup with compatibility tests**
   - Target: `Pinemeter/Repositories/CacheRepository.swift`, new `PinemeterTests/CacheRepositoryTests.swift` if feasible.
   - Current mismatch: README says public export is `~/.pinemeter/usage.json`, but code still writes `~/.claudemeter/usage.json`; private app-support cache dir is still `com.claudemeter`.
   - Safe approach: refactor `CacheRepository` init to allow injectable app-support/home URLs for tests, write the primary public export to `.pinemeter/usage.json`, and preserve legacy `.claudemeter/usage.json` as a compatibility dual-write or migration path. For private cache, migrate/copy from `com.claudemeter/usage_cache.json` to `com.pinemeter/usage_cache.json` when new cache is absent.
   - Do not touch Keychain service/access group in this task.

2. **Explicitly document/defer credential compatibility identifiers**
   - Target: `Pinemeter/Repositories/KeychainRepository.swift`, `Pinemeter/Resources/Pinemeter.entitlements`, maybe tests/source invariant.
   - Add comments or source-level invariant tests explaining legacy `com.claudemeter.sessionkey` / keychain access group are intentional compatibility surfaces deferred to M002. This prevents future agents from mechanically renaming them as cleanup.
   - If adding tests, prefer source-level invariant tests in `PinemeterTests/SecurityInvariantTests.swift` rather than real Keychain mutation.

3. **Low-risk constant and stale header cleanup**
   - Target: `Pinemeter/Models/AppSettings.swift`, `Pinemeter/Models/Constants.swift`, optional header comments across Swift files.
   - `AppSettings.setRefreshInterval` still clamps with literals `60`/`600` even though `Constants.Refresh.minimum` and `.maximum` exist and are otherwise unused. Replace literals with constants and adjust docs if needed.
   - `Created by Edd` appears in 54 Swift files. Removing or replacing file header author lines is behavior-free but high-churn; planner should decide whether this belongs in S06 or S07/open-source hygiene. If done, use a scriptable exact removal and run full tests.

4. **Public/docs stale ownership cleanup only where non-historical**
   - Target: `work-to-date.md`, maybe `CHANGELOG.md`, `CLAUDE.md`/`AGENTS.md`.
   - `work-to-date.md` is tracked and still describes old project path/commands; either update to Pinemeter or remove if obsolete.
   - `CHANGELOG.md` contains historical `ClaudeMeter` release links and old `~/.claudemeter` notes. Treat as historical unless the public repo strategy says otherwise; do not silently rewrite release history.
   - `AGENTS.md`/`CLAUDE.md` contain AWS SSM paths with `claudemeter`; these are project-secret operational identifiers, not product copy. Do not change without secret-store migration.

## Implementation Landscape

### CacheRepository seam

Files:
- `Pinemeter/Repositories/CacheRepository.swift`
- `Pinemeter/Repositories/Protocols/CacheRepositoryProtocol.swift`
- `Pinemeter/Services/UsageService.swift`
- `PinemeterTests/TestDoubles/CacheRepositoryFake.swift`

Observed behavior:
- `CacheRepository` owns memory cache, disk cache, and public JSON export.
- It currently creates app-support dir `com.claudemeter`, writes `usage_cache.json`, and writes public export to `~/.claudemeter/usage.json`.
- README already documents `~/.pinemeter/usage.json`, so source and docs disagree.
- There is no direct `CacheRepositoryTests.swift`; `UsageServiceTests` use `CacheRepositoryFake`.

Planner note: because `FileManager.homeDirectoryForCurrentUser` is not injectable today, tests will be easier if `CacheRepository` accepts optional base URLs in an internal/testable initializer while preserving the public default initializer.

### Credential/keychain seam

Files:
- `Pinemeter/Repositories/KeychainRepository.swift`
- `Pinemeter/Resources/Pinemeter.entitlements`
- `PinemeterTests/SecurityInvariantTests.swift`

Observed behavior:
- `KeychainRepository` service name remains `com.claudemeter.sessionkey`.
- Entitlements keychain access group remains `$(AppIdentifierPrefix)com.claudemeter` while bundle id is already `com.eddmann.Pinemeter`.
- S04 explicitly says this is an M002 migration issue, not a cleanup detail. S06 should only annotate/protect it.

### AppModel/provider seam

Files:
- `Pinemeter/App/AppModel.swift`
- `Pinemeter/App/SessionKeyImportPromptCoordinator.swift`
- provider services/tests

Observed behavior:
- `AppModel.swift` is 342 lines and coordinates Claude refresh, ChatGPT refresh, credential load/save/clear/import, notifications, settings debounce, and refresh scheduling.
- S04 flags AppModel orchestration as a medium architecture issue, but S05 deliberately kept provider-specific flows. S06 should not introduce a universal provider abstraction.
- If a small refactor is desired, extract only duplicated credential save/load helpers or leave AppModel alone until M003; cache/export cleanup is the safer first proof.

### Provider audit seam

Files:
- `scripts/provider_workflow_copy_audit.py`
- `PinemeterTests/ProviderErrorWorkflowTests.swift`
- `PinemeterTests/SessionKeyTests.swift`
- `PinemeterTests/SecurityInvariantTests.swift`

Observed behavior:
- The audit scans a fixed allowlist and exits 0 with advisories. It does not scan `CacheRepository`, keychain entitlements, or historical docs.
- Keep this as the main quick safety check after source/docs cleanup.

## Natural Seams / Suggested Task Breakdown

- **T01 First proof: CacheRepository Pinemeter paths with compatibility**
  - Implement testable URL injection and migration/dual-write behavior.
  - Add tests for new `.pinemeter` export path and old `.claudemeter` compatibility.
  - This proves S06 can safely clean a real stale ownership path without credential risk.

- **T02 Guard intentional legacy credential identifiers**
  - Add comments and/or source invariant tests documenting why keychain service/access group remain legacy.
  - No runtime Keychain migration.

- **T03 Minor source cleanup**
  - Replace refresh interval clamp literals with `Constants.Refresh.minimum/maximum`.
  - Optional: remove stale `Created by Edd` headers if accepted as ownership cleanup; otherwise record as deferred open-source hygiene.

- **T04 Stale docs cleanup and audit**
  - Update/remove `work-to-date.md` if it is still intended to be tracked.
  - Leave historical changelog and secret SSM identifiers alone unless explicitly scoped.
  - Run provider audit and focused tests.

## First Proof

Start with `CacheRepository` because it is the clearest stale ownership issue that is not credential-sensitive. It also has a user-visible/docs mismatch: README says `~/.pinemeter/usage.json`, implementation writes `~/.claudemeter/usage.json`. The proof should be tests showing:

- fresh cache writes create `com.pinemeter/usage_cache.json` and `~/.pinemeter/usage.json`;
- old `com.claudemeter/usage_cache.json` is read/migrated when new cache is absent;
- legacy public export is either still written or explicitly documented as deprecated but preserved for one milestone;
- no session key or cookie material is involved.

## Verification Plan

Fast checks after each task:

```sh
python3 scripts/provider_workflow_copy_audit.py
xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug \
  -only-testing:PinemeterTests/SecurityInvariantTests \
  -only-testing:PinemeterTests/ProviderErrorWorkflowTests \
  -only-testing:PinemeterTests/SessionKeyTests
```

Add focused cache tests if T01 changes `CacheRepository`, then run:

```sh
xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug \
  -only-testing:PinemeterTests/CacheRepositoryTests \
  -only-testing:PinemeterTests/UsageServiceTests
```

Slice close verification should include the S05 command plus any new cache tests. S07 still owns final full test and clean build.

## Risks and Deferred Work

- **Do not rename Keychain identifiers in S06.** That can orphan stored credentials or break access groups; defer to M002 with migration tests.
- **Do not delete legacy public export abruptly.** External statusline scripts may still read `~/.claudemeter/usage.json`; dual-write is safer than a hard cutover.
- **Do not introduce provider abstraction.** AppModel/provider cleanup is tempting but belongs to M003 unless it is a very small behavior-preserving extraction.
- **Do not rewrite historical changelog release links as if past releases were Pinemeter.** Public-history presentation belongs to S07/M005.
- **Do not touch SSM path names in `AGENTS.md`/`CLAUDE.md` as product cleanup.** Those are operational secret-store identifiers.
