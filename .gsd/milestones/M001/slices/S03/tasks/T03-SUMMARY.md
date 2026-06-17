---
id: T03
parent: S03
milestone: M001
key_files:
  - PinemeterTests/SecurityInvariantTests.swift
  - .gsd/milestones/M001/slices/S03/S03-ASSESSMENT.md
key_decisions:
  - Treat ChatGPT session cookies and transient access tokens as credential-equivalent and prohibit logging/display of Cookie and Authorization header values.
  - Keep localized user-facing provider/error descriptions generic; richer diagnostics must be added only behind redaction tests.
duration: 
verification_result: passed
completed_at: 2026-06-17T03:01:45.242Z
blocker_discovered: false
---

# T03: Ranked ChatGPT cookie, Bearer-token, and generic error redaction risks and pinned user-facing disclosure invariants with synthetic sentinel tests.

**Ranked ChatGPT cookie, Bearer-token, and generic error redaction risks and pinned user-facing disclosure invariants with synthetic sentinel tests.**

## What Happened

Reviewed the ChatGPT usage service, protocol boundary, Settings ChatGPT credential actions, current ChatGPT tests, and generic error models. Extended `SecurityInvariantTests` to assert that AppError, ChatGPTUsageError, NetworkError, and KeychainError user-facing localized descriptions do not disclose synthetic Claude session-key, ChatGPT cookie, Cookie header, Bearer token, or access-token-shaped sentinels, including when an underlying error contains those values. Updated `S03-ASSESSMENT.md` with ranked ChatGPT credential handling findings, generic error/logging redaction findings, fix/defer recommendations, and populated Failure Modes, Load Profile, Negative Tests, and Observability Impact sections for the pending gates.

## Verification

Ran the focused task verification command via gsd_exec: `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests`. The targeted SecurityInvariantTests suite passed, including the new generic error disclosure tests.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests` | 0 | ✅ pass | 7943ms |

## Deviations

None.

## Known Issues

No new implementation bugs were fixed in this task. The assessment intentionally defers ChatGPT replace-not-display Keychain-backed settings flow, WebView credential cleanup, and centralized request/header redaction to downstream work.

## Files Created/Modified

- `PinemeterTests/SecurityInvariantTests.swift`
- `.gsd/milestones/M001/slices/S03/S03-ASSESSMENT.md`
