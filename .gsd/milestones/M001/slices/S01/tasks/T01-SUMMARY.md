---
id: T01
parent: S01
milestone: M001
key_files:
  - Pinemeter.xcodeproj/project.pbxproj
  - Pinemeter.xcodeproj/xcshareddata/xcschemes/Pinemeter.xcscheme
  - Pinemeter/App/PinemeterApp.swift
  - PinemeterTests/AppModelTests.swift
  - AGENTS.md
  - scripts/demo.sh
key_decisions:
  - (none)
duration: 
verification_result: passed
completed_at: 2026-06-17T01:03:40.246Z
blocker_discovered: false
---

# T01: Renamed the build-critical Xcode project, scheme, app/test modules, source roots, and app entry point from ClaudeMeter to Pinemeter.

**Renamed the build-critical Xcode project, scheme, app/test modules, source roots, and app entry point from ClaudeMeter to Pinemeter.**

## What Happened

Renamed `ClaudeMeter.xcodeproj` to `Pinemeter.xcodeproj`, `ClaudeMeter/` to `Pinemeter/`, `ClaudeMeterTests/` to `PinemeterTests/`, the shared scheme to `Pinemeter`, and the app entry type/file to `PinemeterApp`. Updated project and scheme metadata, test host paths, test imports, demo script build paths, and agent build instructions so Xcode recognizes the renamed project shape.

## Verification

Verified with `xcodebuild -list -project Pinemeter.xcodeproj`, then with final renamed test and clean build commands recorded in T05 evidence.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `xcodebuild -list -project Pinemeter.xcodeproj` | 0 | ✅ pass | 11800ms |

## Deviations

Also updated `AGENTS.md` and `scripts/demo.sh` command surfaces during T01 because stale build-command references appeared in the T01 scan.

## Known Issues

Persistent runtime identifiers and docs/history references were intentionally handled in later S01 tasks.

## Files Created/Modified

- `Pinemeter.xcodeproj/project.pbxproj`
- `Pinemeter.xcodeproj/xcshareddata/xcschemes/Pinemeter.xcscheme`
- `Pinemeter/App/PinemeterApp.swift`
- `PinemeterTests/AppModelTests.swift`
- `AGENTS.md`
- `scripts/demo.sh`
