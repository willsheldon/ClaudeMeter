---
estimated_steps: 1
estimated_files: 1
skills_used: []
---

# T01: Wrote the provider workflow UAT checklist for reset, partial-provider, full-provider, expired-session, and clear/reconnect states.

Create a UAT checklist for M003 that covers clean first-run reset, Claude-only, ChatGPT-only, both providers, expired ChatGPT session, and provider clear/reconnect behavior. Include the exact local reset scope for UserDefaults and Keychain items from project memory.

## Inputs

- `.gsd/KNOWLEDGE.md`
- `.gsd/milestones/M003/M003-ROADMAP.md`

## Expected Output

- `.gsd/milestones/M003/slices/S04/S04-UAT.md`

## Verification

Checklist includes bundle id `com.eddmann.Pinemeter`, Claude service `com.claudemeter.sessionkey` account `default`, and ChatGPT service `com.pinemeter.chatgpt.session` account `chatgpt.com`, with no secret values.

## Observability Impact

Creates a repeatable diagnostic workflow for first-run and recovery states.
