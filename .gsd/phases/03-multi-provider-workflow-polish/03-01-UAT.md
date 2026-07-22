# S01: Provider status surfaces — UAT

**Milestone:** M003
**Written:** 2026-06-23T21:49:15.495Z

# S01: Provider status surfaces — UAT

**Milestone:** M003
**Written:** 2026-06-23

## UAT Type

- UAT mode: runtime-executable
- Why this mode is sufficient: This SwiftUI macOS slice is verified by executable host checks: a static provider-surface audit, the full Xcode test suite, and a credential-material grep. Those checks exercise the model/view presentation contract and security invariants without requiring live provider credentials.

## Preconditions

- Run from the M003 worktree root.
- Xcode and the Pinemeter scheme are available on the host.
- No real Claude or ChatGPT credential material is required; tests use synthetic fixtures only.

## Smoke Test

Run `python3 scripts/provider_status_surface_audit.py`. Expected: the audit reports the centralized AppModel provider status contract, sanitized setup/settings rendering, no direct raw credential UI reads, and required test coverage.

## Test Cases

### 1. Shared provider status contract is present

1. Run `python3 scripts/provider_status_surface_audit.py`.
2. Confirm the audit validates `AppProviderCredentialStatus` fields such as provider name, credential name, `stateText`, `detailText`, and actions.
3. **Expected:** Setup and settings can render provider status without requiring raw token, cookie, key, or session values.

### 2. Settings renders sanitized provider-aware status

1. Run `python3 scripts/provider_status_surface_audit.py`.
2. Confirm the settings checks pass for AppModel provider credential status usage.
3. **Expected:** Settings distinguishes configured, missing, invalid, and action states with provider-specific copy and does not read or display credential material.

### 3. Setup renders the same sanitized model and actions

1. Run `python3 scripts/provider_status_surface_audit.py`.
2. Confirm the setup checks pass for shared provider status text and actions.
3. **Expected:** Setup shows provider-specific next actions for Claude and ChatGPT without duplicating secret-adjacent formatting logic in the view.

### 4. Automated regression suite passes

1. Run `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug`.
2. **Expected:** The full Pinemeter test suite passes, including AppModel, CredentialState, provider workflow, and security invariant coverage.

### 5. Credential material is absent from view surfaces

1. Run `rg -n "sk-|session-token|__Secure|cookie" Pinemeter/Views PinemeterTests`.
2. Review matches.
3. **Expected:** There are no matches in `Pinemeter/Views`; any remaining matches are confined to tests as synthetic fixtures, cookie terminology assertions, or negative security checks.

## Edge Cases

- Claude configured while ChatGPT is missing: provider rows should show distinct Claude configured status and ChatGPT setup or reconnect guidance.
- ChatGPT invalid or expired while Claude remains configured: ChatGPT row should show an invalid or reconnect action without implying Claude is broken.
- Both providers missing: setup and settings should show missing states and safe next actions for each provider.
- Credential-like strings in tests: grep findings are acceptable only when limited to synthetic fixtures or negative assertions; no view match is acceptable.

## Operational Readiness

- **Health signal**: `python3 scripts/provider_status_surface_audit.py` plus the full `xcodebuild test` suite passing proves the provider status presentation contract is intact.
- **Failure signal**: Audit failures, failing provider workflow/security invariant tests, or any credential-material grep match under `Pinemeter/Views` indicate the slice contract is broken.
- **Recovery**: Revert view-local provider status formatting to consume `AppProviderCredentialStatus`, then rerun the audit, full test suite, and credential-material grep.
- **Monitoring gaps**: This is a local UI/model contract with no live runtime telemetry; future slices should add recovery-flow diagnostics where retry/reconnect actions mutate provider state.

## Gates to Close

- Q8 Operational Readiness is addressed by the health signal, failure signal, recovery, and monitoring gaps above.

