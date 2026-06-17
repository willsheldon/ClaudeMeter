---
estimated_steps: 1
estimated_files: 8
skills_used: []
---

# T03: Inventoried ChatGPT cookie acquisition, validation, token derivation, reuse, display, clearing, and recovery paths.

Map split NextAuth cookie parts, full Cookie header paste, raw token handling, validation, Keychain account `chatgpt`, auth-session request, access-token derivation, quota request, UI display/status, and clear/recovery behavior for ChatGPT quota monitoring.

## Inputs

- `.gsd/milestones/M001/slices/S02/S02-RESEARCH.md`

## Expected Output

- `Pinemeter/Views/Settings/SettingsView.swift`
- `Pinemeter/App/AppModel.swift`
- `Pinemeter/Services/ChatGPTUsageService.swift`
- `Pinemeter/Services/Protocols/ChatGPTUsageServiceProtocol.swift`
- `Pinemeter/Models/ChatGPTUsageData.swift`
- `Pinemeter/Models/API/ChatGPTAPIResponses.swift`
- `PinemeterTests/ChatGPTUsageServiceTests.swift`
- `PinemeterTests/ChatGPTAppModelTests.swift`

## Verification

rg -n 'chatGPTSessionCookie|ChatGPT|__Secure-next-auth|cookieHeader|accessToken|auth/session|codex/settings/usage|clearChatGPTSessionCookie|validateSessionCookie' Pinemeter PinemeterTests

## Observability Impact

Identifies ChatGPT cookie/token transformation and places where token material may be held in memory.
