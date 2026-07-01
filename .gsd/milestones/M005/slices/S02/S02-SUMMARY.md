---
id: S02
parent: M005
milestone: M005
provides:
  - Clear public contribution, issue reporting, and support boundaries for sanitized outside collaboration.
requires:
  - slice: S01
    provides: Accurate public docs and README context for linking contribution, support, and issue-reporting guidance.
affects:
  - S04
key_files:
  - CONTRIBUTING.md
  - SECURITY.md
  - README.md
  - .github/ISSUE_TEMPLATE/config.yml
  - .github/ISSUE_TEMPLATE/bug_report.yml
  - .github/ISSUE_TEMPLATE/feature_request.yml
  - .github/ISSUE_TEMPLATE/bug_report.md
  - .github/ISSUE_TEMPLATE/feature_request.md
key_decisions:
  - Use public issue forms only for sanitized bug and feature intake; route credential, privacy, and vulnerability concerns through SECURITY.md and private vulnerability reporting.
  - Preserve YAML GitHub issue forms as the primary GitHub issue UI and add Markdown templates as portable checklists.
patterns_established:
  - Public templates should ask for sanitized provider state and diagnostic categories, never raw credentials, cookies, tokens, sessions, request headers, or provider responses.
  - Support guidance should keep remote-side actions and destructive git operations out of contributor templates.
observability_surfaces:
  - None; this is an artifact-only documentation/template slice with no runtime health surface.
drill_down_paths:
  - .gsd/milestones/M005/slices/S02/tasks/T01-SUMMARY.md
  - .gsd/milestones/M005/slices/S02/tasks/T02-SUMMARY.md
  - .gsd/milestones/M005/slices/S02/tasks/T03-SUMMARY.md
duration: ""
verification_result: passed
completed_at: 2026-07-01T18:20:36.096Z
blocker_discovered: false
---

# S02: Contributor templates and support paths

**Public contributor guidance, issue templates, and private security reporting paths now steer outside collaboration toward sanitized, non-destructive reports.**

## What Happened

This slice added and verified the public collaboration surface for Pinemeter. T01 established the support shape: CONTRIBUTING.md for contributor workflow, SECURITY.md for private security and privacy reporting, GitHub issue form configuration, and YAML bug and feature forms. T02 preserved those GitHub issue forms as the primary GitHub UI while adding portable Markdown bug and feature checklists, then linked the guidance from README and CONTRIBUTING.md. T03 audited the assembled templates and support docs for stale ClaudeMeter/GSD process leakage, unsafe secret prompts, destructive git suggestions, and unsupported public promises. The resulting flow directs ordinary bugs and feature requests through structured public templates while routing credential, privacy, and vulnerability concerns away from public issues.

## Verification

Slice-level verification was run with gsd_exec evidence `1bb03b57-b323-4051-92aa-d3bd5ec9d68b`. The audit confirmed expected collaboration files exist, README links to CONTRIBUTING.md and SECURITY.md, CONTRIBUTING.md documents the local xcodebuild build and test commands plus secret-handling guidance, bug templates collect provider, macOS, app version, setup path, expected behavior, actual behavior, and sanitized diagnostics, feature templates ask for privacy and credential impact, SECURITY.md routes sensitive reports to private vulnerability reporting with warnings not to send real secrets publicly, public templates do not request secrets or private process data, and support docs do not leak stale ClaudeMeter or GSD process wording. The audit exited 0 with `audit-verdict: PASS`.

## Requirements Advanced

None.

## Requirements Validated

None.

## New Requirements Surfaced

None.

## Requirements Invalidated or Re-scoped

None.

## Operational Readiness

None.

## Deviations

T01 added SECURITY.md and a GitHub private reporting contact path instead of a public security/privacy issue template, because credential-equivalent provider material should not be reported through public issues. T02 preserved the YAML issue forms from T01 and added Markdown templates as portable checklists rather than replacing the primary GitHub issue UI.

## Known Limitations

The private vulnerability reporting URL depends on repository settings in the eventual public GitHub repository; SECURITY.md includes fallback guidance if private vulnerability reporting is unavailable. This slice does not prove GitHub-hosted form rendering or fresh-reader end-to-end usability.

## Follow-ups

S04 should include a fresh-reader check that a contributor can follow README, CONTRIBUTING.md, SECURITY.md, and the issue templates without prior project context. S03 should separately verify release and signing guidance remains non-destructive and pins the official signing identity.

## Files Created/Modified

- `CONTRIBUTING.md` — Documents public contribution workflow, issue-reporting expectations, local xcodebuild build/test commands, coding conventions, and secret-handling boundaries.
- `SECURITY.md` — Routes credential, privacy, and vulnerability reports to private reporting paths and warns against public secret disclosure.
- `README.md` — Links public contribution and security/support guidance from the main project entry point.
- `.github/ISSUE_TEMPLATE/config.yml` — Configures issue template chooser links and disables blank public issues.
- `.github/ISSUE_TEMPLATE/bug_report.yml` — Primary GitHub bug form collecting sanitized provider, setup, environment, expected/actual behavior, and diagnostic details.
- `.github/ISSUE_TEMPLATE/feature_request.yml` — Primary GitHub feature form collecting user problem, proposed behavior, alternatives, and privacy/credential impact.
- `.github/ISSUE_TEMPLATE/bug_report.md` — Portable Markdown bug checklist mirroring the sanitized diagnostic prompts.
- `.github/ISSUE_TEMPLATE/feature_request.md` — Portable Markdown feature checklist mirroring the privacy and credential impact prompts.
