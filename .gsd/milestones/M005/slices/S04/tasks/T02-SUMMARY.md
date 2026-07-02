---
id: T02
parent: S04
milestone: M005
key_files:
  - README.md
  - site/index.html
  - .github
  - CONTRIBUTING.md
  - RELEASING.md
  - .gsd/exec/7b402759-9053-461b-bd78-8323fb926d04.stdout
  - .gsd/exec/8224ec99-bcf7-4f43-8fb0-cbed264c5594.stdout
key_decisions:
  - Classified `~/.claudemeter/usage.json` as intentional legacy compatibility wording rather than stale public branding.
  - Treated site-local `logo.png` references as document-relative assets and verified them with corrected path resolution.
duration: 
verification_result: passed
completed_at: 2026-07-01T22:19:13.639Z
blocker_discovered: false
---

# T02: Ran non-destructive public artifact checks across README, site, GitHub templates/workflows, CONTRIBUTING.md, and RELEASING.md and documented the review findings.

**Ran non-destructive public artifact checks across README, site, GitHub templates/workflows, CONTRIBUTING.md, and RELEASING.md and documented the review findings.**

## What Happened

Reviewed the required public surfaces for stale naming, missing paths, unsafe secret prompts, and command drift. The primary scan covered `README.md`, `site/index.html`, `.github`, and optional docs `CONTRIBUTING.md` and `RELEASING.md` because both optional files are present.

Findings:
- Stale naming: no unsafe product-name drift was found in public docs. `Pinemeter` is the active product name; the only `ClaudeMeter` hit in the reviewed public files is README legacy export compatibility for `~/.claudemeter/usage.json`, which is intentional compatibility context rather than stale branding.
- Missing paths: an initial broad check reported `site/index.html` `logo.png` references as missing because it resolved site-relative assets from the repository root. A corrected document-relative check found no missing or unsafe relative file/image/link targets in public docs/templates.
- Unsafe secret prompts: README, CONTRIBUTING, issue templates, and release docs consistently warn users not to share session keys, cookies, API keys, tokens, headers, or account-identifying screenshots. The site still publicly describes manual Claude setup as pasting a `sessionKey`/Cookie header into the app; this is a product setup path, not an instruction to share credentials in issues or logs.
- Command drift: build/test commands in README, CONTRIBUTING, and GitHub workflow align around `xcodebuild ... -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug`, with CI-style unsigned test flags. Release docs/workflow pin `Developer ID Application: AUTIMO SYSTEMS INC (HMR9RDR6M2)` and `EXPECTED_TEAM_ID=HMR9RDR6M2` and explicitly guard against generic `Developer ID Application` and mutable `APPLE_TEAM_ID` release signing.

## Failure Modes
External dependencies for this task were local filesystem reads, `rg`, and Python path parsing. Missing files would surface in the file list or command stderr; no required public artifact was missing. Pattern matching could produce false positives because the task intentionally searches for sensitive words, so each hit was manually classified. Relative-link parsing could misclassify site-local assets if resolved from the repository root; this was caught and corrected with a document-relative path check.

## Load Profile

## Negative Tests
The corrected path checker covered missing and repository-escaping relative link/image targets across README, site, optional docs, and `.github` files. The unsafe prompt scan intentionally searched for copy/paste/provide language near secret/token/cookie/API-key/session material and release mutation terms (`git push`, `gh release`, workflow dispatch, notarization), confirming public docs either warn against sharing credentials or gate destructive release actions behind maintainer confirmation.

## Observability Impact
Diagnostic evidence was persisted under `.gsd/exec/` for later milestone validation: the full public artifact scan at `.gsd/exec/7b402759-9053-461b-bd78-8323fb926d04.stdout` and the corrected relative path check at `.gsd/exec/8224ec99-bcf7-4f43-8fb0-cbed264c5594.stdout`.

## Verification

Ran the required `rg` pattern over `README.md`, `site/index.html`, `.github`, and optional `CONTRIBUTING.md`/`RELEASING.md`, then reviewed the full persisted output for stale names, unsafe secret prompts, and command drift. Ran a corrected document-relative path checker after identifying the initial root-relative `site/index.html` asset false positive; the corrected check reported no missing or unsafe relative targets.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `rg -n "ClaudeMeter|Pinemeter|secret|token|cookie|xcodebuild|HMR9RDR6M2|Developer ID Application" README.md site/index.html .github CONTRIBUTING.md RELEASING.md plus scripted missing-path, unsafe-secret-prompt, and command-drift scans` | 0 | ✅ pass — scan completed and findings reviewed; only intentional compatibility, credential-safety, and pinned release-signing references found | 89ms |
| 2 | `python3 document-relative public docs/templates link check` | 0 | ✅ pass — no missing or unsafe relative file/image/link targets detected | 57ms |

## Deviations

None. The task was non-destructive, so no public artifact files were edited.

## Known Issues

The site documents manual pasting of a Claude sessionKey/Cookie header into the app; this is an intentional setup path, but remains a sensitive workflow that should stay paired with clear no-sharing guidance in README and issue templates.

## Files Created/Modified

- `README.md`
- `site/index.html`
- `.github`
- `CONTRIBUTING.md`
- `RELEASING.md`
- `.gsd/exec/7b402759-9053-461b-bd78-8323fb926d04.stdout`
- `.gsd/exec/8224ec99-bcf7-4f43-8fb0-cbed264c5594.stdout`
