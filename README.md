# Pinemeter

![Pinemeter](docs/heading.png)

Pinemeter is a macOS menu bar app for keeping Claude.ai plan usage visible at a glance, with optional quota/status visibility for ChatGPT and Gemini when those providers are configured.

## Features

- **Claude.ai usage monitoring** - Track your 5-hour session, 7-day weekly, and Sonnet-specific usage limits
- **Optional provider visibility** - Show ChatGPT quota status from a browser session and Gemini status from an API key
- **Menu bar integration** - Clean, colour-coded usage indicator that lives in your macOS menu bar
- **Multiple icon styles** - Choose from 6 icon styles: Battery, Circular, Minimal, Segments, Dual Bar, or Gauge
- **Pacing indicator** - Flame icon warns when you're using Claude faster than sustainable pace
- **Smart notifications** - Configurable alerts at warning and critical thresholds (defaults: 75% and 90%)
- **Auto-refresh** - Automatic usage updates every 1 minute, 5 minutes, or 10 minutes
- **Local JSON export** - Write usage percentages for scripts, shell prompts, and dashboards

## Screenshots

### Menu Bar

The menu bar icon changes colour based on your usage levels:

<p align="center">
  <img src="docs/menubar-safe.png" width="260" alt="Menu bar - Safe usage">
  <img src="docs/menubar-warning.png" width="260" alt="Menu bar - Warning threshold">
  <img src="docs/menubar-critical.png" width="260" alt="Menu bar - Critical threshold">
</p>

When using Sonnet models, an additional indicator shows your Sonnet-specific usage:

<p align="center">
  <img src="docs/menubar-sonnet.png" width="300" alt="Menu bar - Sonnet usage">
</p>

### Notifications

Pinemeter sends native macOS notifications when you reach warning or critical thresholds:

<p align="center">
  <img src="docs/notifications.png" width="450" alt="Usage notifications">
</p>

### Settings

Configure your Claude session, optional ChatGPT and Gemini providers, refresh interval, icon style, and notification thresholds:

<p align="center">
  <img src="docs/settings-general.png" width="380" alt="Settings - General">
  <img src="docs/settings-notifications.png" width="380" alt="Settings - Notifications">
</p>

### Setup Wizard

<p align="center">
  <img src="docs/setup-wizard.png" width="600" alt="First-time setup wizard">
</p>

## Installation

### Homebrew

```bash
brew install eddmann/tap/pinemeter
```

### Manual Download

1. Download the latest Pinemeter release from [GitHub Releases](https://github.com/eddmann/Pinemeter/releases/latest).
2. Unzip and move `Pinemeter.app` to Applications.
3. Double-click to open.

Releases are signed and notarized. If you validate release artifacts manually, the expected Developer ID is `Developer ID Application: AUTIMO SYSTEMS INC (HMR9RDR6M2)` and the expected Team Identifier is `HMR9RDR6M2`.

## Usage

### First Launch

1. Pinemeter appears in your menu bar as a gauge icon.
2. The setup wizard guides you through provider configuration.
3. Import supported browser sessions or paste credentials manually.
4. The app validates configured providers and begins monitoring available usage/quota status.

### Provider Setup

#### Claude.ai

Pinemeter can import your existing Claude session from local browser cookies. Sign in to [claude.ai](https://claude.ai) in a supported browser, then choose **Import from Browser** in the setup wizard or Settings.

Chrome, Arc, Brave, Edge, and other Chromium browsers may ask for browser Safe Storage Keychain access so Pinemeter can decrypt cookies. Safari cookies are protected by macOS and may require Full Disk Access.

If browser import is unavailable, paste your Claude session manually. Pinemeter accepts either a raw `sk-ant-...` Claude session key or a Cookie header containing `sessionKey=...`.

#### ChatGPT

ChatGPT quota visibility is optional. Sign in to ChatGPT in a supported browser, then use the ChatGPT browser import action in setup or Settings. Pinemeter stores ChatGPT session cookies through its Keychain-backed session repository and keeps access-token material transient.

If ChatGPT is unavailable, rate limited, rejected, or not configured, the provider status is shown without blocking Claude monitoring.

#### Gemini

Gemini visibility is optional and uses an API key entered in Settings. Pinemeter stores Gemini API keys in Keychain and shows status/diagnostic state without exposing the raw key in the UI or diagnostics.

### Manual Claude Session Setup

Your Claude session key is stored in your browser cookies.

**Chrome/Edge:**

1. Open [claude.ai](https://claude.ai)
2. Press `F12` to open DevTools
3. Go to Application > Cookies > `https://claude.ai`
4. Find the `sessionKey` cookie (starts with `sk-ant-`)
5. Copy the value

**Safari:**

1. Open [claude.ai](https://claude.ai)
2. Go to Develop > Show Web Inspector (enable Develop menu in Safari preferences if needed)
3. Go to Storage > Cookies > `https://claude.ai`
4. Find the `sessionKey` cookie (starts with `sk-ant-`)
5. Copy the value

**Firefox:**

1. Open [claude.ai](https://claude.ai)
2. Press `F12` to open Developer Tools
3. Go to Storage > Cookies > `https://claude.ai`
4. Find the `sessionKey` cookie (starts with `sk-ant-`)
5. Copy the value

### Daily Use

- Monitor Claude.ai usage at a glance with the colour-coded menu bar icon
- Click the icon to access detailed statistics, provider status, and Settings
- Receive automatic notifications when reaching warning or critical thresholds
- Use Settings to repair, reconnect, or clear provider credentials when a provider reports an error

### Troubleshooting and Reset Paths

- **Browser Safe Storage prompts:** Chromium-based imports may request Keychain access to decrypt browser cookies. Allow access for the signed Pinemeter app if you initiated the import.
- **Safari import cannot see cookies:** Grant Full Disk Access to Pinemeter in macOS System Settings, then retry the import.
- **Provider unavailable, rejected, or rate limited:** Open Settings and use the provider-specific repair, reconnect, or clear actions. The UI shows sanitized status and copyable error text without raw credentials.
- **Reset local state:** Clear the affected provider in Settings, sign in again in your browser if needed, then import or paste the credential again.
- **Inspect exported usage:** Check `~/.pinemeter/usage.json` for the latest exported Claude usage percentages. A legacy compatibility copy may also be written to `~/.claudemeter/usage.json` for older scripts.

### Integration with External Tools

Pinemeter exports Claude usage data to `~/.pinemeter/usage.json` for use with external tools like Claude Code statusline scripts, shell prompts, or custom dashboards. For compatibility with earlier ClaudeMeter-era scripts, Pinemeter may also write a legacy `~/.claudemeter/usage.json` copy.

**JSON format:**

```json
{
  "last_updated": "2025-12-24T07:30:00Z",
  "session_usage": {
    "reset_at": "2025-12-24T12:00:00Z",
    "utilization": 29
  },
  "sonnet_usage": {
    "reset_at": "2025-12-30T00:00:00Z",
    "utilization": 15
  },
  "weekly_usage": {
    "reset_at": "2025-12-30T00:00:00Z",
    "utilization": 45
  }
}
```

**Example: Claude Code statusline**

Create `~/.claude/statusline.sh`:

```bash
#!/bin/bash
usage=$(jq -r '.session_usage.utilization' ~/.pinemeter/usage.json 2>/dev/null)

if [ -z "$usage" ] || [ "$usage" = "null" ]; then
  echo "Usage: ~"
elif [ "$usage" -lt 50 ]; then
  echo -e "\033[32mUsage: ${usage}%\033[0m"
elif [ "$usage" -lt 80 ]; then
  echo -e "\033[33mUsage: ${usage}%\033[0m"
else
  echo -e "\033[31mUsage: ${usage}%\033[0m"
fi
```

Then configure Claude Code's `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash ~/.claude/statusline.sh"
  }
}
```

## Requirements

- macOS 14.0 (Sonoma) or later
- Active Claude.ai account with a browser session or Claude session key
- Optional: ChatGPT browser session if enabling ChatGPT quota visibility
- Optional: Gemini API key if enabling Gemini status visibility
- For browser import, a supported browser signed in to the provider you want to import

## Building from Source

Requires Xcode 16.0 or later.

```bash
# Clone the repository
git clone https://github.com/eddmann/Pinemeter.git
cd Pinemeter

# Open in Xcode
open Pinemeter.xcodeproj

# CLI debug build
xcodebuild clean build -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug

# CLI tests (matches CI signing behavior; snapshot tests are skipped in CI)
xcodebuild test \
  -project Pinemeter.xcodeproj \
  -scheme Pinemeter \
  -configuration Debug \
  -skip-testing:PinemeterTests/MenuBarIconSnapshotTests \
  CODE_SIGN_IDENTITY="-" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO
```

## Disclaimer

**This is an unofficial tool** and is not affiliated with, endorsed by, or supported by Anthropic PBC, OpenAI, or Google.

This application accesses provider web/API surfaces using browser-based authentication or user-provided credentials. **This may violate provider Terms of Service.** By using Pinemeter, you acknowledge that:

- Providers may block, restrict, rate limit, or terminate access at any time
- Your provider accounts could be affected by using unofficial clients
- Release builds are signed and notarized by Apple
- **Use at your own risk** - the developer assumes no liability for any consequences

**Data storage:**

- Claude session keys are stored securely in macOS Keychain (encrypted, device-local only)
- ChatGPT session cookies are stored through a Keychain-backed repository boundary; access-token material remains transient where applicable
- Gemini API keys are stored securely in macOS Keychain
- Browser import reads local browser cookies only to extract the selected provider credential/session material
- Diagnostic and acquisition state is sanitized; raw cookies, tokens, headers, and API keys are not written to diagnostics
- Usage data is cached locally (unencrypted, contains usage percentages/status only)
- No data is sent to third-party servers or collected by the developer

This software is provided "as is" under the MIT License, without warranty of any kind. **By downloading and using Pinemeter, you accept these terms.**

## License

MIT License - see [LICENSE](LICENSE) file for details.
