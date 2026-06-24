# S04: Workflow UAT and diagnostics — UAT

**Milestone:** M003
**Written:** 2026-06-23T22:45:55.165Z

# S04: Workflow UAT and diagnostics — UAT

**Milestone:** M003
**Written:** 2026-06-23

## UAT Type

- UAT mode: mixed
- Why this mode is sufficient: Automated XCTest and static audit evidence proves redaction, provider-scoped actions, diagnostic persistence, and reset-scope documentation without touching real credentials; live app checks that require real provider sessions are explicitly marked as human follow-up.

## Preconditions

- Work from this checkout only.
- Do not paste, print, screenshot, or save credential values.
- Use bundle id `com.eddmann.Pinemeter` for local UserDefaults reset scope.
- Claude Keychain scope is generic-password service `com.claudemeter.sessionkey`, account `default`.
- ChatGPT Keychain scope is generic-password service `com.pinemeter.chatgpt.session`, account `chatgpt.com`.
- Full live checks require a macOS user session where Pinemeter can be launched and provider credentials can be entered through the app UI.

## Smoke Test

Run `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` plus `python3 scripts/provider_status_surface_audit.py` and `python3 scripts/provider_workflow_copy_audit.py`. Expected: all commands exit 0; XCTest reports `** TEST SUCCEEDED **`; workflow audit may print advisory copy-review findings but no enforced redaction/copy failure.

## Test Cases

### 1. First-run reset state

1. Apply the documented reset scope for `com.eddmann.Pinemeter`, Claude Keychain service/account, and ChatGPT Keychain service/account.
2. Launch Pinemeter and open setup/settings/menu bar surfaces.
3. **Expected:** Claude and ChatGPT both appear missing or not connected; recovery actions are provider-specific; no credential values appear in UI, logs, or artifacts.

### 2. Claude-only configured

1. Start from reset state.
2. Connect only Claude through the app workflow.
3. Refresh status and open the menu bar popover.
4. **Expected:** Claude is available/configured or shows a Claude-specific sanitized error; ChatGPT remains missing/not connected; ChatGPT retry/clear does not remove Claude's Keychain item.

### 3. ChatGPT-only configured

1. Start from reset state.
2. Connect only ChatGPT through the app workflow.
3. Refresh status and open the menu bar popover.
4. **Expected:** ChatGPT is available/configured or shows a ChatGPT-specific sanitized error; Claude remains missing/not connected; Claude retry/clear does not remove ChatGPT's Keychain item or sanitized diagnostic status.

### 4. Both providers configured

1. Configure Claude and ChatGPT through supported app workflows.
2. Refresh status, open settings/setup surfaces, and open the menu bar popover.
3. **Expected:** Both providers have distinct status, usage, retry, clear, and reconnect states; loading/error/empty states remain provider-specific.

### 5. Expired ChatGPT session

1. Start from a ChatGPT-configured state.
2. Trigger or simulate an expired ChatGPT session through an app-supported path.
3. Refresh ChatGPT usage/status.
4. **Expected:** ChatGPT reports an expired/invalid sanitized state; Claude is unaffected; persisted diagnostic status records only sanitized state/error category; reconnect restores ChatGPT availability.

### 6. Provider clear and reconnect behavior

1. Start with both providers configured.
2. Clear Claude, verify ChatGPT remains configured, then reconnect Claude.
3. Clear ChatGPT, verify Claude remains configured, then reconnect ChatGPT.
4. **Expected:** Each clear action removes only that provider's scoped storage; settings/menu bar states update; reconnect restores only the selected provider; no credential material is exposed.

## Edge Cases

### Storage unavailable or stale session diagnostics

1. Simulate Keychain/storage failure using existing test doubles or safe local test state.
2. **Expected:** The app reports sanitized provider-specific failure states and preserves enough diagnostic context for recovery without persisting raw cookies, tokens, headers, or session keys.

## Failure Signals

- XCTest failure in `SecurityInvariantTests` or `ProviderErrorWorkflowTests`.
- Non-zero exit from `scripts/provider_status_surface_audit.py` or `scripts/provider_workflow_copy_audit.py`.
- UI text that exposes raw credential material or generic provider wording where provider-specific recovery is required.
- Clearing one provider removes or corrupts the other provider's scoped storage.
- `ChatGPTSessionRepository.status.chatgpt.com` contains credential material instead of sanitized status/error category.

## Not Proven By This UAT

- Live destructive reset/import/expired-session/clear-reconnect workflows were not executed by auto-mode in this closeout because they require real app interaction and credential entry.
- Advisory ChatGPT copy-review findings from `provider_workflow_copy_audit.py` remain non-blocking while the script exits 0 in enforce mode.

## Notes for Tester

Use `.gsd/milestones/M003/slices/S04/S04-UAT.md` as the detailed checklist. Record only sanitized states such as missing, available, invalid, expired, or storage unavailable. Never paste credential values into test artifacts, terminal logs, screenshots, or issue comments.
