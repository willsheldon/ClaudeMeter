---
estimated_steps: 1
estimated_files: 5
skills_used: []
---

# T01: Mapped current Claude and ChatGPT recovery action entry points, target provider action API gaps, and safety risks for S02 follow-up implementation.

Trace Claude and ChatGPT reconnect, import, clear, repair, and refresh paths through AppModel, repositories, services, settings, and setup. Identify missing provider-aware actions and unsafe direct view-service coupling.

## Inputs

- `Pinemeter/App/AppModel.swift`
- `Pinemeter/Services/SessionKeyImportService.swift`
- `Pinemeter/Repositories/ChatGPTSessionRepository.swift`

## Expected Output

- `Pinemeter/App/AppModel.swift`
- `Pinemeter/Services/SessionKeyImportService.swift`
- `Pinemeter/Services/ChatGPTUsageService.swift`
- `Pinemeter/Repositories/ChatGPTSessionRepository.swift`
- `Pinemeter/Repositories/KeychainRepository.swift`

## Verification

Task summary lists current action entry points, target provider action API, and safety gaps with file references.

## Observability Impact

Maps recovery phases and diagnostic state.
