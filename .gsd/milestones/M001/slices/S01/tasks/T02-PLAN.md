---
estimated_steps: 1
estimated_files: 8
skills_used: []
---

# T02: Updated active product UI copy and metadata from ClaudeMeter to Pinemeter while preserving provider-specific Claude terminology.

Update product-owned user-facing strings from ClaudeMeter to Pinemeter in setup, settings/about, login item text, keychain prompt owner text, generated Info.plist build display name, file headers, and comments. Preserve provider-specific Claude/Claude.ai/Claude API/Claude session/Sonnet wording where it describes the monitored provider rather than the product. If `Pinemeter/Resources/Info.plist` remains unreferenced, update path/name only for consistency but note that generated build settings drive runtime display name.

## Inputs

- `.gsd/milestones/M001/slices/S01/S01-RESEARCH.md`

## Expected Output

- `Pinemeter/App/SessionKeyImportPromptCoordinator.swift`
- `Pinemeter/Views/Setup/SetupWizardView.swift`
- `Pinemeter/Views/Settings/SettingsView.swift`

## Verification

rg -n --glob '!.git/**' --glob '!.gsd/**' 'ClaudeMeter|claudemeter|CLAUDEMETER' Pinemeter PinemeterTests Pinemeter.xcodeproj | head -200

## Observability Impact

Keeps product-facing diagnostics and prompts aligned with the new owner identity without changing provider semantics.
