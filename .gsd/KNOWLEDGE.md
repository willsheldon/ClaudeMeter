# Project Knowledge

Append-only register of project-specific rules, patterns, and lessons learned.
Agents read this before every unit. Add entries when you discover something worth remembering.
## Rules

| # | Scope | Rule | Why | Added |
|---|-------|------|-----|-------|
| 1 | build-signing | Always use the official Autimo signing key when building signed ClaudeMeter/Pinemeter artifacts. | Prevents accidental ad-hoc/local signing and keeps release artifacts tied to the expected trusted identity. | 2026-06-17 |

## Patterns

| # | Pattern | Where | Notes |
|---|---------|-------|-------|

## Lessons Learned

| # | What Happened | Root Cause | Fix | Scope |
|---|--------------|------------|-----|-------|
| 1 | Claude credentials saved by ad-hoc builds can prompt or fail after moving to the official Autimo signed Pinemeter app. | Keychain access is tied to the signed app identity while the project intentionally retains the legacy ClaudeMeter service and access-group identifiers for credential compatibility. | Repair by re-saving through `repairClaudeSessionKey` under the official Autimo identity, preserving `com.claudemeter.sessionkey` and avoiding broad Keychain deletes or access-group rewrites. | M002/S02 Claude Keychain repair |
