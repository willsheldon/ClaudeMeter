---
id: S02
parent: M005
milestone: M005
provides:
  - Contributor-facing templates and support guidance that collect useful sanitized Pinemeter reports without private process leakage.
requires:
  - slice: S01
    provides: Accurate public docs and README context consumed by the contributor guidance and support links.
affects:
  - S03
  - S04
key_files:
  - CONTRIBUTING.md
  - README.md
  - .github/ISSUE_TEMPLATE/bug_report.md
  - .github/ISSUE_TEMPLATE/feature_request.md
  - .github/ISSUE_TEMPLATE/bug_report.yml
  - .github/ISSUE_TEMPLATE/feature_request.yml
  - .github/ISSUE_TEMPLATE/config.yml
  - SECURITY.md
key_decisions:
  - Preserved the dual GitHub issue-form and portable Markdown checklist setup because it supports GitHub-native reports and README/CONTRIBUTING links without duplicating support paths.
  - Preserved SECURITY.md plus issue-template contact links as the private path for credential, privacy, and vulnerability reports rather than adding a public security issue template.
patterns_established:
  - Public report templates should request sanitized provider/setup state and explicitly forbid raw credential-equivalent material.
  - Sensitive security, privacy, and credential concerns should route through private reporting paths instead of public issue templates.
observability_surfaces:
  - Artifact diagnostics via issue templates: bug reports collect Pinemeter version, macOS version, provider/setup state, reproduction steps, sanitized provider state, and redacted logs or screenshots.
drill_down_paths:
  - .gsd/milestones/M005/slices/S02/tasks/T01-SUMMARY.md
  - .gsd/milestones/M005/slices/S02/tasks/T02-SUMMARY.md
  - .gsd/milestones/M005/slices/S02/tasks/T03-SUMMARY.md
duration: ""
verification_result: passed
completed_at: 2026-07-01T21:59:30.745Z
blocker_discovered: false
---

# S02: Contributor templates and support paths

**Public contributor guidance, issue templates, and private support paths now give outside contributors sanitized ways to report Pinemeter bugs, feature ideas, and sensitive security or privacy concerns.**

## What Happened

Reviewed the assembled S02 task work and verified that the repository exposes a coherent public collaboration surface: CONTRIBUTING.md explains how to build and test Pinemeter, documents SwiftUI and actor-service conventions, and warns contributors not to paste credential material; README.md links contributors toward contribution guidance and issue paths; GitHub bug and feature templates collect app version, macOS version, provider/setup state, expected and actual behavior, and sanitized diagnostics; and SECURITY.md plus issue-template configuration provide the private channel for credential, privacy, and vulnerability reports. The slice preserved the existing dual GitHub issue-form plus portable Markdown checklist pattern because it supports both GitHub-native reporting and README/CONTRIBUTING links without adding unsafe public security prompts.

## Verification

Fresh slice-level verification was run through gsd_exec evidence `5ab61017-255f-4ab9-b664-67914c5b1fbc`. It confirmed the eight expected public support files are present, passed fourteen contract checks for build/test guidance, coding conventions, secret handling, README links, bug/feature template diagnostics, and private SECURITY.md routing, and found zero unsafe public wording matches for secret-pasting prompts, destructive git guidance, private GSD process leakage, or stale ClaudeMeter naming outside explicit legacy compatibility context.

## Requirements Advanced

- R013 — Delivered the contribution conventions and issue-template portion of public open-source polish with verified README, CONTRIBUTING, bug, feature, and private security/support paths.

## Requirements Validated

None.

## New Requirements Surfaced

None.

## Requirements Invalidated or Re-scoped

None.

## Operational Readiness

None.

## Deviations

No file edits were needed during closeout because task-level verification showed the expected contributor templates and support guidance already satisfied the slice contract in the active worktree.

## Known Limitations

This slice verifies repository artifacts only. It does not execute the Xcode build/test suite, validate GitHub's rendered issue-form UI, or cover release/signing documentation reserved for S03.

## Follow-ups

S03 should keep release-facing guidance aligned with these contributor safety boundaries, especially around non-destructive local verification and avoiding public exposure of signing or credential material.

## Files Created/Modified

- `CONTRIBUTING.md` — Contributor guidance for build/test commands, coding conventions, issue reporting, and secret-handling boundaries.
- `README.md` — Public entry point that links contributors to contribution and reporting paths.
- `.github/ISSUE_TEMPLATE/bug_report.md` — Portable Markdown bug checklist for sanitized Pinemeter diagnostics.
- `.github/ISSUE_TEMPLATE/feature_request.md` — Portable Markdown feature checklist with provider and privacy/credential impact prompts.
- `.github/ISSUE_TEMPLATE/bug_report.yml` — GitHub issue-form counterpart for structured bug reports.
- `.github/ISSUE_TEMPLATE/feature_request.yml` — GitHub issue-form counterpart for structured feature requests.
- `.github/ISSUE_TEMPLATE/config.yml` — GitHub issue-template configuration that routes sensitive reports toward private security guidance.
- `SECURITY.md` — Private reporting guidance for credential, privacy, and vulnerability concerns.
