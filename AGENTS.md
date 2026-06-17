Pinemeter is a macOS 14+ SwiftUI menu bar app; keep UI state on `@MainActor @Observable` types and non-UI work in actor services/repositories.

Build with `xcodebuild clean build -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug`; test with `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug`.

New `AppSettings` keys must persist through `SettingsRepository`, appear in `SettingsView` when user-facing, and decode old saved settings safely.

## Secrets

This project uses AWS SSM Parameter Store for agent-managed project secrets. Secrets must only be stored in SSM Parameter Store — never in `.env` files, shell profiles, local plaintext files, logs, repo files, or any other store.

Use `mysecrets` to manage secrets for this project.

ssm_path: /ws-claude/claudemeter
aws_profile: ws-claude-claudemeter
