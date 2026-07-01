---
id: T03
parent: S02
milestone: M005
key_files:
  - .github/ISSUE_TEMPLATE/bug_report.md
  - .github/ISSUE_TEMPLATE/feature_request.md
  - CONTRIBUTING.md
  - README.md
key_decisions:
  - Treat README credential setup and legacy compatibility mentions as expected product documentation while keeping issue templates and support guidance sanitized.
duration: 
verification_result: passed
completed_at: 2026-07-01T18:16:18.379Z
blocker_discovered: false
---

# T03: Verified public issue templates and contributor support guidance for sanitized, non-destructive public collaboration.

**Verified public issue templates and contributor support guidance for sanitized, non-destructive public collaboration.**

## What Happened

Reviewed the portable bug and feature Markdown templates, CONTRIBUTING guidance, and README support section for stale names, private GSD/process leakage, unsupported promises, destructive-action suggestions, and requests to paste secrets. The audit found no missing source files, no semantic problems, and all expected public-support anchors present: bug and feature templates route credential/privacy/vulnerability concerns to SECURITY.md, CONTRIBUTING links both portable templates, and README links both portable templates plus private security reporting. The grep matches for secret/token/cookie terms were expected: they appear in explicit redaction guidance or in README user setup documentation, not in template instructions asking public reporters to paste credential material.

## Failure Modes
External dependencies for this documentation-only verification were the local filesystem and the `rg` subprocess. Missing files were explicitly checked and reported as `missing-files: none`; the audit script would fail non-zero if any source file was absent. The `rg` command exit code was recorded (`rg-exit: 0`) and semantic checks would fail non-zero if forbidden public-reporting patterns or missing cross-links were found. There are no network/API dependencies.

## Load Profile

## Negative Tests
The verification included negative pattern checks for public template hazards: instructions to paste/include secret material, destructive git actions such as force-push/history rewrite, and private GSD/process leakage. The persisted evidence shows `semantic-problems: []`, confirming none of those negative cases were present in the checked files.

## Observability Impact
This task leaves a persisted GSD execution artifact at `.gsd/exec/6ed5b59c-f947-4e2e-9fbf-9aaff1d7f032.stdout` containing the exact grep output, semantic warnings, cross-link anchor checks, and final PASS verdict for later inspection.

## Verification

Ran a `gsd_exec` audit that executed `rg -n "ClaudeMeter|GSD|secret|token|cookie|push|rewrite|Pinemeter" .github/ISSUE_TEMPLATE CONTRIBUTING.md README.md`, reviewed the matches, and performed semantic checks for forbidden public-reporting prompts, destructive git suggestions, private GSD/process leakage, and required template/support links. The command exited 0 with `audit-verdict: PASS`, `semantic-problems: []`, and all anchor checks true.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `python audit: superpowers-agent version; rg -n "ClaudeMeter|GSD|secret|token|cookie|push|rewrite|Pinemeter" .github/ISSUE_TEMPLATE CONTRIBUTING.md README.md; semantic forbidden-pattern and anchor checks` | 0 | ✅ pass | 562ms |

## Deviations

No source edits were required because the existing public templates and support guidance already met the task contract.

## Known Issues

The README intentionally contains credential setup documentation and legacy ClaudeMeter compatibility references; the audit recorded them as warnings, not public-template consistency problems.

## Files Created/Modified

- `.github/ISSUE_TEMPLATE/bug_report.md`
- `.github/ISSUE_TEMPLATE/feature_request.md`
- `CONTRIBUTING.md`
- `README.md`
