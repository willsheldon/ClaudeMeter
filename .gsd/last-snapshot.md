# GSD context snapshot (2026-06-19T17:28:52.626Z)

## Top project memories
- [MEM001] (gotcha) For Pinemeter release signing, do not use the generic CODE_SIGN_IDENTITY "Developer ID Application" or a mutable APPLE_TEAM_ID secret. The release path must pin and verify `Developer ID Application: AUTIMO SYSTEMS INC (HMR9RDR6M2)` and `TeamIdentifier=HMR9RDR6M2`.
- [MEM008] (gotcha) In this repo, using gsd_requirement_update/save can regenerate .gsd/REQUIREMENTS.md from an incomplete DB row set and drop manually rich requirements R001-R009/R012-R015. Prefer manual surgical edits to REQUIREMENTS.md or reconcile the DB before using requirement tools for requirement changes.
- [MEM002] (architecture) Claude credential repair preserves the legacy `com.claudemeter.sessionkey` Keychain service identifier and repairs access by scoped update-then-add under the selected account, avoiding broad deletes and relying on the current signed app identity for access control.
- [MEM003] (architecture) ChatGPT session repository separates credential-equivalent material by durability: session cookies are stored only in a Keychain-backed repository boundary, transient access tokens stay actor-memory-only, and diagnostics persist only sanitized acquisition state/error categories outside AppSettings.
- [MEM004] (architecture) ChatGPT session acquisition flows now use ChatGPTSessionRepository as the sole durable boundary: AppModel, ChatGPTUsageService, and WebView cookie-store extraction persist session cookies through that repository, while access tokens remain transient and are only re-saved in actor memory after validation.
- [MEM005] (architecture) ChatGPT session cookies are treated as durable credential-equivalent material and stored through ChatGPTSessionRepository's Keychain boundary; ChatGPT access tokens remain transient actor memory only. Persisted ChatGPT acquisition diagnostics are limited to sanitized state and failure categories, not raw cookies, tokens, headers, or AppSettings values.

## Recent gsd_exec runs
- 
…[truncated]
