# Work to Date

Project folder: `/Users/will/code/ClaudeMeter`

## Current state

This project is a macOS 14+ Swift 6 / SwiftUI menu bar app originally named **ClaudeMeter**. It tracks AI service usage limits from the menu bar, using an `@MainActor` observable `AppModel`, actor-isolated services, and Xcode-based build/test workflows.

Current checked-out branch at the time this summary was written: `fix/cloudflare-bypass-webview`.

## Significant work completed

### ChatGPT quota support

Recent work added ChatGPT quota tracking alongside the original Claude usage surfaces.

Implemented pieces include:

- `ChatGPTUsageData` model for quota rows, worst-bucket percentage calculation, menu bar roles, display labels, reset timestamps, and status derivation.
- `ChatGPTUsageService` for calling ChatGPT's internal usage endpoint and turning responses into app-level quota data.
- ChatGPT-specific error handling for missing cookies, invalid cookies, HTTP failures, invalid responses, and network unavailability.
- `AppModel` state for ChatGPT usage data, refresh state, error messages, and whether a ChatGPT session cookie is present.
- Settings UI support for entering ChatGPT session cookie material, including token-part fields and full cookie header handling.
- Tests covering ChatGPT usage model behavior and cookie-header normalization.

### Weekly quota window handling

Recent commits refined ChatGPT weekly quota behavior, including reading and representing the weekly quota window rather than treating all ChatGPT quota data as a simple flat current-percent value.

### Quota display refinement

The display layer has been refined so quota data can be shown more clearly in the app UI and menu bar. Current direction appears to be toward a cleaner, focused presentation of the most important quota signals rather than exposing many visual variants.

### Cloudflare bypass via WKWebView

A branch-level fix was added for the Cloudflare bot-protection problem by using `WKWebView` where needed. This is intended to let the app obtain or validate ChatGPT session state in a browser context that behaves more like a real user session.

### Menu bar UI cleanup

The most recent commit removed legacy menu bar icon styles and simplified the menu bar icon system.

Removed or reduced surfaces include:

- Battery icon style
- Circular gauge icon style
- Gauge icon style
- Minimal icon style
- Segmented bar icon style
- Icon style picker UI

The remaining direction is a simpler menu bar representation, with less settings complexity and fewer unused UI branches.

### CI and release groundwork already present

The project already has GitHub Actions workflows for testing, release automation, and Pages deployment. The changelog indicates prior work on automated version extraction from `CHANGELOG.md`, Xcode test workflow setup, and release workflow behavior.

## Current known product direction

The next intended milestone discussed is to make the app its own project and rebrand it as **Pinemeter**.

Planned direction:

- Rename user-facing app identity from ClaudeMeter to Pinemeter.
- Use Pineit / Pineshot-inspired green and white branding.
- Create a new logo and app visual identity.
- Purge remaining user-facing mentions of ClaudeMeter where they no longer apply.
- Clean up unused UI and make the app presentable as an owned Pineit project.
- Move/link the project to a private repository under the `pineit-ca` GitHub account.
- Update the app's About/repository link to point at the new private repo instead of the current upstream/origin reference.

No outward-facing GitHub changes were made during the discussion that produced this summary.

## Important cautions for next work

- The current app and local instructions still refer heavily to ClaudeMeter and the upstream repository. Rebranding should cover code identifiers, bundle/product names, README/docs, screenshots, About links, workflows, changelog references, and app assets.
- GitHub repository creation or remote changes are outward-facing actions and should only happen after explicit confirmation.
- The working tree was clean before this summary file was created.
- Build verification should use the existing Xcode command from `AGENTS.md`:

```bash
xcodebuild clean build \
  -project ClaudeMeter.xcodeproj \
  -scheme ClaudeMeter \
  -configuration Debug
```

## Suggested next milestone

Create a GSD milestone in this project root for the Pinemeter rebrand with slices roughly ordered as:

1. Product identity audit: enumerate all ClaudeMeter/upstream references and all user-facing rename targets.
2. Branding assets: create Pinemeter logo/icon set using Pineit/Pineshot green and white palette.
3. App rename: update product name, bundle metadata, About links, docs, and visible UI copy.
4. UI cleanup: remove remaining unused settings/UI branches and polish menu bar/popover presentation.
5. Verification and repository move: build/test locally, then create/link the private `pineit-ca` repository only after explicit confirmation.
