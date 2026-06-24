---
id: T01
parent: S04
milestone: M003
key_files:
  - (none)
key_decisions:
  - (none)
duration: 
verification_result: passed
completed_at: 2026-06-23T22:31:40.103Z
blocker_discovered: false
---

# T01: Wrote the provider workflow UAT checklist for reset, partial-provider, full-provider, expired-session, and clear/reconnect states.

**Wrote the provider workflow UAT checklist for reset, partial-provider, full-provider, expired-session, and clear/reconnect states.**

## What Happened

Created `.gsd/milestones/M003/slices/S04/S04-UAT.md` with a repeatable provider workflow checklist. The artifact documents the exact local reset scope for the Pinemeter UserDefaults domain and scoped keys, plus the Claude and ChatGPT Keychain generic-password service/account pairs. It covers clean first-run reset, Claude-only, ChatGPT-only, both-provider, expired ChatGPT session, and provider clear/reconnect behavior while explicitly prohibiting credential values in evidence.

## Verification

Ran a Python artifact check confirming the checklist includes bundle id `com.eddmann.Pinemeter`, Claude service `com.claudemeter.sessionkey` account `default`, ChatGPT service `com.pinemeter.chatgpt.session` account `chatgpt.com`, required UserDefaults keys, all required UAT scenario headings, and no checked secret-like literals.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `python3 - <<'PY'
from pathlib import Path
p = Path('.gsd/milestones/M003/slices/S04/S04-UAT.md')
text = p.read_text()
required = [
    'com.eddmann.Pinemeter',
    'com.claudemeter.sessionkey',
    'account: `default`',
    'com.pinemeter.chatgpt.session',
    'account: `chatgpt.com`',
    'app_settings',
    'notification_state',
    'ChatGPTSessionRepository.status.chatgpt.com',
    'Clean first-run reset',
    'Claude-only configured',
    'ChatGPT-only configured',
    'Both providers configured',
    'Expired ChatGPT session',
    'Provider clear and reconnect behavior',
]
missing = [s for s in required if s not in text]
secret_like = []
for token in ['sk-', 'sessionKeyValue', '__Secure-next-auth.session-token=', 'Bearer ', 'password:', 'cookie:']:
    if token in text:
        secret_like.append(token)
if missing or secret_like:
    print('FAIL')
    if missing:
        print('missing:', missing)
    if secret_like:
        print('secret-like tokens:', secret_like)
    raise SystemExit(1)
print('PASS: S04-UAT.md includes required reset identifiers, provider workflow checks, and no checked secret-like literals.')
PY` | 0 | ✅ pass | 100ms |

## Deviations

None.

## Known Issues

None.

## Files Created/Modified

None.
