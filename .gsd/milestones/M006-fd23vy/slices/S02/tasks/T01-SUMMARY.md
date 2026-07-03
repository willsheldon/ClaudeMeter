---
id: T01
parent: S02
milestone: M006-fd23vy
key_files:
  - .gsd/milestones/M006-fd23vy/evidence/S02-xcodebuild-debug.log
  - .gsd/milestones/M006-fd23vy/evidence/S02-app-bundle.txt
key_decisions:
  - (none)
duration: 
verification_result: passed
completed_at: 2026-07-03T17:14:30.266Z
blocker_discovered: false
---

# T01: Built and selected a verified Debug `Pinemeter.app` bundle for VM installation.

**Built and selected a verified Debug `Pinemeter.app` bundle for VM installation.**

## What Happened

Ran a fresh Debug build with `xcodebuild clean build -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug`. The build completed successfully and produced `/Users/will/Library/Developer/Xcode/DerivedData/Pinemeter-blaeajqgnbyrdefgkbvjsbzzwwfq/Build/Products/Debug/Pinemeter.app`. Verified the app bundle directory exists, has bundle identifier `com.eddmann.Pinemeter`, reports TeamIdentifier `HMR9RDR6M2`, and has no local quarantine xattr. This is a Debug build selection for VM validation only and does not modify the release signing policy.

## Verification

Fresh `xcodebuild clean build -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` completed successfully; `.gsd/milestones/M006-fd23vy/evidence/S02-xcodebuild-debug.log` contains `** BUILD SUCCEEDED **` at line 811. `test -d "$BUILT_PRODUCTS_DIR/Pinemeter.app"` passed, and `.gsd/milestones/M006-fd23vy/evidence/S02-app-bundle.txt` records app path, identifier, TeamIdentifier, and quarantine absence.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `xcodebuild clean build -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` | 0 | ✅ pass | 120000ms |
| 2 | `test -d "$BUILT_PRODUCTS_DIR/Pinemeter.app" plus codesign/quarantine probe` | 0 | ✅ pass | 120000ms |

## Deviations

None.

## Known Issues

None.

## Files Created/Modified

- `.gsd/milestones/M006-fd23vy/evidence/S02-xcodebuild-debug.log`
- `.gsd/milestones/M006-fd23vy/evidence/S02-app-bundle.txt`
