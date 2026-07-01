---
id: T02
parent: S01
milestone: M005
key_files:
  - README.md
  - site/index.html
  - CHANGELOG.md
key_decisions:
  - Treat CHANGELOG.md repository URL correction as part of public docs accuracy because stale release links are user-visible documentation.
duration: 
verification_result: passed
completed_at: 2026-07-01T17:51:46.457Z
blocker_discovered: false
---

# T02: Updated the README, landing page, and public changelog links so fresh readers see current Pinemeter provider support, privacy posture, setup, reset, build, and troubleshooting guidance.

**Updated the README, landing page, and public changelog links so fresh readers see current Pinemeter provider support, privacy posture, setup, reset, build, and troubleshooting guidance.**

## What Happened

Rewrote README.md as the main fresh-reader guide for the current product state: Homebrew and release installation, release signing identity, Claude/ChatGPT/Gemini provider setup, browser import caveats, reset and repair paths, local JSON export paths, CLI build/test commands, and privacy/security boundaries for Keychain-backed credential storage and sanitized diagnostics.

Updated site/index.html public landing copy to include optional Gemini visibility alongside ChatGPT, align JSON-LD softwareVersion with the current changelog version, expand secure-storage language, add provider setup cards, add a privacy/troubleshooting section, and update the footer disclaimer to name Anthropic, OpenAI, and Google.

Updated CHANGELOG.md reference links from the stale ClaudeMeter repository URLs to Pinemeter repository URLs so public release history resolves to the current public project.

## Failure Modes
This task's external dependencies were local filesystem reads/writes and diagnostic subprocess execution. Missing files would have caused the edits or verification assertions to fail; no such missing-file blocker occurred for the edited public docs. The final verification subprocess completed successfully and persisted stdout/stderr under .gsd/exec. No network, provider API, browser automation, or runtime credential access was used.

## Load Profile
No runtime load dimension applies. This was bounded static documentation work over README.md, site/index.html, and CHANGELOG.md, not a shipped runtime path.

## Negative Tests
No product negative tests apply because this task only changed public documentation. Negative/static coverage was provided by assertions that fail if key public-copy regressions remain: missing Gemini docs, missing ChatGPT/Gemini Keychain privacy copy, missing reset/troubleshooting copy, stale site version, missing build/test commands, stale ClaudeMeter changelog links, and missing Pinemeter export compatibility copy.

## Observability Impact
Improves external troubleshooting by documenting provider repair/reconnect/clear actions, browser Safe Storage and Safari Full Disk Access paths, sanitized provider error copy, Keychain credential boundaries, release signing verification details, and JSON export inspection paths.

## Verification

Ran the task-required public-copy review command through gsd_exec: `rg -n "ClaudeMeter|Pinemeter|xcodebuild|provider|privacy|credential|Gemini|ChatGPT|Claude" README.md site/index.html CHANGELOG.md`. In the same verification run, static assertions confirmed README.md documents Gemini, ChatGPT session storage, Homebrew install, CLI xcodebuild build/test commands, reset/troubleshooting, privacy/sanitized diagnostics, release signing identity, and primary plus legacy export paths; site/index.html documents Gemini, current 1.4.0 structured version, privacy/troubleshooting reset, and the expanded provider disclaimer; CHANGELOG.md no longer contains github.com/eddmann/ClaudeMeter links and does contain github.com/eddmann/Pinemeter links.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `gsd_exec bash: rg -n "ClaudeMeter|Pinemeter|xcodebuild|provider|privacy|credential|Gemini|ChatGPT|Claude" README.md site/index.html CHANGELOG.md plus static public-copy assertions` | 0 | ✅ pass | 423ms |

## Deviations

The task expected output listed README.md and site/index.html, but CHANGELOG.md was also updated because it was an explicit task input, part of the required verification scan, and T01 identified stale public changelog links as a public documentation accuracy issue.

## Known Issues

None.

## Files Created/Modified

- `README.md`
- `site/index.html`
- `CHANGELOG.md`
