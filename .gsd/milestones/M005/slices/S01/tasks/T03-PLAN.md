---
estimated_steps: 1
estimated_files: 3
skills_used: []
---

# T03: Verify docs paths and commands

Check documented paths and commands against the repository. Run non-destructive local validation for build/test commands if docs were changed in ways that affect them.

## Inputs

- `README.md`
- `site/index.html`

## Expected Output

- `README.md`
- `site/index.html`
- `CHANGELOG.md`

## Verification

`test -f Pinemeter.xcodeproj/project.pbxproj && test -f Pinemeter.xcodeproj/xcshareddata/xcschemes/Pinemeter.xcscheme` plus `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` if build/test documentation changed.

## Observability Impact

Confirms public commands remain reproducible.
