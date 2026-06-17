---
id: T01
parent: S05
milestone: M001
key_files:
  - scripts/provider_workflow_copy_audit.py
key_decisions:
  - Use a fixed allowlist rather than repository traversal to avoid reading ignored/planning/runtime-secret paths.
  - Separate advisory report-only ChatGPT copy inventory from enforced final invariants so later fixes can make default mode meaningful.
duration: 
verification_result: passed
completed_at: 2026-06-17T15:36:48.718Z
blocker_discovered: false
---

# T01: Added a fixed-allowlist provider workflow copy audit harness for source and public-doc drift checks.

**Added a fixed-allowlist provider workflow copy audit harness for source and public-doc drift checks.**

## What Happened

Created `scripts/provider_workflow_copy_audit.py`, a repo-local Python audit harness that reads only the explicit S05 allowlist under `Pinemeter/`, `PinemeterTests/`-eligible scope by design (none currently listed), `README.md`, and `site/index.html`. The script does not traverse the repo and rejects disallowed path parts such as `.gsd`, `.git`, `.planning`, `.audits`, derived/build/cache directories, and absolute/out-of-repo paths.

The harness categorizes current findings for Claude credential copy, ChatGPT copy review, public-doc claims, and NetworkService response-body diagnostics. `--report-only` prints the current inventory and exits 0 so later S05 tasks can use it before fixes land. Default mode exits nonzero when enforced invariants are violated: Claude credential copy should say `Claude session key`, public docs should mention optional ChatGPT quota visibility without generic-provider claims, and NetworkService should not log full response bodies. ChatGPT source/doc mentions are also inventoried as advisory report-only review evidence, while generic-provider ChatGPT claims remain enforceable.

## Failure Modes
- Filesystem missing-file dependency: every allowlisted file is checked with `is_file()` before reading. Missing files fail with `provider-workflow-copy-audit: missing required file: <relative path>` and exit 2.
- Filesystem path-safety dependency: absolute paths, out-of-repository resolutions, and forbidden path components are rejected before any read. This protects against accidentally scanning `.gsd`, `.git`, `.planning`, `.audits`, derived data, caches, or unrelated checkouts.
- Text decoding dependency: allowlisted files are read as UTF-8; `OSError` bubbles as a clear `unable to read allowlisted files` diagnostic.
- No network, subprocess, runtime credential store, or API dependency is used by the harness.

## Load Profile
- Expected load is 11 small fixed files. At 10x, the first saturating resource would be local file-read/regex CPU time, but the fixed allowlist prevents unbounded traversal and keeps runtime proportional only to the explicit list.
- No runtime service, pool, rate limit, pagination, or cache is needed because this is a small static scan with no network or background process.

## Negative Tests
- Verified default mode returns nonzero while current enforced stale findings exist, proving the harness can fail on stale provider copy/public-doc/response-body logging invariants.
- Verified report-only mode returns 0 with the same findings, proving current drift can be inventoried before later fixes land.
- Verified Python syntax compilation with `python3 -m py_compile scripts/provider_workflow_copy_audit.py`.
- The script contains explicit missing-file and forbidden-path error paths; no destructive fixture mutation was needed for this task because the task verification scope is report-only over the current repository state.

## Verification

Ran the provider workflow copy audit in report-only mode, compiled the script, and exercised default enforcement mode expecting it to fail while known stale findings remain. Report-only exited 0 and listed current S05 categories; compile exited 0; default mode exited 1 as the negative enforcement check.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `python3 scripts/provider_workflow_copy_audit.py --report-only; python3 -m py_compile scripts/provider_workflow_copy_audit.py; python3 scripts/provider_workflow_copy_audit.py (expected nonzero while stale findings remain)` | 0 | ✅ pass | 291ms |

## Deviations

None.

## Known Issues

Default mode intentionally fails until later S05 tasks fix Claude credential wording, optional ChatGPT quota public-doc copy, and NetworkService response-body diagnostics.

## Files Created/Modified

- `scripts/provider_workflow_copy_audit.py`
