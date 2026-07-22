<!-- SUPERPOWERS_SKILLS_START -->
## 🎯 SKILLS

[superpowers-agent Docs](.agents/docs/SUPERPOWERS.md)

- Skills encode proven techniques that prevent mistakes.
   - Not using them means repeating solved problems and missing edge cases.
   - If a skill exists for your task, you MUST use it.
- **Before starting any task**, check for relevant skills, use your native skill tool to do so.
- Review skill descriptions/frontmatter to identify relevant ones.
- When a skill references a tool you don't have, substitute your equivalent.

---

## Version Check

Once per day, check for updates:
1. **CURRENT_VERSION:** run `superpowers-agent version` and read the printed version.
2. **NPM_LATEST_VERSION:** run `npm view @complexthings/superpowers-agent version`.
3. Compare by semver, not string order (`9.10.0` > `9.9.0`). If newer, tell the user, but don't run these yourself:
   > Your superpowers-agent has updates (`CURRENT_VERSION` → `NPM_LATEST_VERSION`). Run:
   > ```sh
   > npm install -g @complexthings/superpowers-agent
   > superpowers-agent bootstrap && superpowers-agent setup-skills
   > ```
   Match, or a lookup fails → stay silent.

---

<!-- SUPERPOWERS_SKILLS_END -->

Pinemeter is a macOS 14+ SwiftUI menu bar app; keep UI state on `@MainActor @Observable` types and non-UI work in actor services/repositories.

Build with `xcodebuild clean build -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug`; test with `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug`.

New `AppSettings` keys must persist through `SettingsRepository`, appear in `SettingsView` when user-facing, and decode old saved settings safely.

## Secrets

This project uses AWS SSM Parameter Store for agent-managed project secrets. Secrets must only be stored in SSM Parameter Store — never in `.env` files, shell profiles, local plaintext files, logs, repo files, or any other store.

Use `mysecrets` to manage secrets for this project.

ssm_path: /ws-claude/claudemeter
aws_profile: sso-ws-claude

Writes work; do not request IAM grants. `sso-ws-claude` is the read-only role by design, and a raw `aws ssm put-parameter` under it will always get AccessDenied. That is not a blocker: `mysecrets set` routes writes through `aws-project-write.sh` (assumes `WsClaudeProjectWrite` with a session policy scoped to this project's path). If a write fails with a permission error, the cause is registry resolution, not IAM; most likely you are not running from the registered canonical path.

Registry matching is exact-path against `/Users/will/code/pinemeter`. From inside a git worktree (`.worktrees/<name>`) or any other path, either `cd /Users/will/code/pinemeter` for `mysecrets set`/`delete`, or use:

```bash
aws-project-write.sh \
  --project-path /Users/will/code/pinemeter \
  --profile sso-ws-claude \
  exec -- aws ssm put-parameter \
  --region ca-central-1 \
  --name /ws-claude/claudemeter/<KEY> \
  --type SecureString \
  --key-id alias/ws-claude-ssm \
  --value "<val>" \
  --overwrite
```

Canonical notes: `/Users/will/wiki/ws-claude-sso-scoped-secrets.md`.

## Host cmux Payload Rule

On cmux hosts, do not use `cmux send` for literal long command text: it is a keystroke API and interprets `\n`, `\r`, and `\t` as Enter, Return, and Tab. For literal payloads, use `cmux set-buffer --name <unique> -- <payload>`, then `cmux paste-buffer --name <unique> --surface <surface>`, then send Enter separately with `cmux send --surface <surface> '\r'`. Canonical notes: `/Users/will/wiki/gsd-cmux.md`.

## GSD Runtime

As of 2026-07-13 this project runs on **GSD Core** (`@opengsd/gsd-core`, "GSD-v1") inside Claude Code via the `gsd-*` skills. The gsd-pi (GSD-2) CLI runtime is retired for this project. `.gsd/` is retained as a read-only GSD-2 archive (migrated via `gsd-tools from-gsd2` / `gsd1-lightport`); new phase work lives in `.planning/`. gsd-pi remains installed fleet-wide for other projects.
