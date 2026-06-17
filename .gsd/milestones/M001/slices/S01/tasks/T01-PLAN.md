---
estimated_steps: 1
estimated_files: 12
skills_used: []
---

# T01: Renamed the build-critical Xcode project, scheme, app/test modules, source roots, and app entry point from ClaudeMeter to Pinemeter.

Perform the build-critical rename in one coherent change. Rename `ClaudeMeter.xcodeproj` to `Pinemeter.xcodeproj`, source root `ClaudeMeter/` to `Pinemeter/`, test root `ClaudeMeterTests/` to `PinemeterTests/`, shared scheme `ClaudeMeter.xcscheme` to `Pinemeter.xcscheme`, app target/product references to Pinemeter, test target references to PinemeterTests, app entry file/type `ClaudeMeterApp` to `PinemeterApp`, `TEST_HOST` to the Pinemeter app executable, and all test imports to `@testable import Pinemeter`. Update project and scheme container references so `xcodebuild -list` sees the renamed scheme and targets. Do not touch persistent runtime identifiers in this task except when required for build metadata.

## Inputs

- `.gsd/milestones/M001/slices/S01/S01-RESEARCH.md`
- `ClaudeMeter.xcodeproj/project.pbxproj`
- `ClaudeMeter.xcodeproj/xcshareddata/xcschemes/ClaudeMeter.xcscheme`

## Expected Output

- `Pinemeter.xcodeproj/project.pbxproj`
- `Pinemeter.xcodeproj/xcshareddata/xcschemes/Pinemeter.xcscheme`
- `Pinemeter/App/PinemeterApp.swift`

## Verification

xcodebuild -list -project Pinemeter.xcodeproj
rg -n --glob '!.git/**' --glob '!.gsd/**' '@testable import ClaudeMeter|ClaudeMeter\.xcodeproj|-scheme ClaudeMeter|ClaudeMeterTests|ClaudeMeter\.app|struct ClaudeMeterApp' .

## Observability Impact

Establishes the new module/product names used by build and test diagnostics.
