---
id: M001
title: "Ownership safety and review baseline"
status: complete
completed_at: 2026-06-17T17:57:01.937Z
key_decisions:
  - Comprehensive Pinemeter identity rename was performed wherever feasible, with compatibility-sensitive identifiers classified rather than blindly renamed.
  - Durable credential acquisition and migration were deferred to M002 after M001 inventory and review.
  - Architecture review proceeded as a ranked artifact-backed baseline with downstream cleanup handoffs.
  - Git history rewrite, remote push, release publication, site deployment, repository creation, and secret-store mutation remain human-gated and were not performed.
  - Milestone sequencing remains M001 ownership baseline, M002 durable credentials, M003 provider-aware workflows, M004 Gemini monitoring, and M005 public polish.
key_files:
  - Pinemeter.xcodeproj/project.pbxproj
  - Pinemeter.xcodeproj/xcshareddata/xcschemes/Pinemeter.xcscheme
  - Pinemeter/App/PinemeterApp.swift
  - Pinemeter/App/AppModel.swift
  - Pinemeter/Repositories/KeychainRepository.swift
  - Pinemeter/Repositories/CacheRepository.swift
  - Pinemeter/Repositories/SettingsRepository.swift
  - Pinemeter/Services/SessionKeyImportService.swift
  - Pinemeter/Services/UsageService.swift
  - Pinemeter/Services/NetworkService.swift
  - Pinemeter/Services/ChatGPTUsageService.swift
  - Pinemeter/Views/Settings/SettingsView.swift
  - Pinemeter/Views/Setup/SetupWizardView.swift
  - PinemeterTests/SecurityInvariantTests.swift
  - README.md
  - site/index.html
  - .github/workflows/test.yml
  - .github/workflows/release.yml
  - .gsd/milestones/M001/M001-VALIDATION.md
  - .gsd/milestones/M001/M001-LEARNINGS.md
lessons_learned:
  - Retained `claudemeter` Keychain/cache/export/access-group identifiers are compatibility surfaces that need migration planning, not automatic rename misses.
  - Credential risk includes transient UI/app state, WebView/session material, Keychain, and diagnostics even when SettingsRepository persistence is credential-free.
  - Narrow provider/error copy improvements can safely land before full provider redesign when source-reviewed and covered by focused tests.
  - Safe cleanup must preserve compatibility and security invariants, not only remove stale names.
  - Milestone closeout should refresh code-change, slice-status, summary, validation, and requirement-transition evidence even when a validation artifact already passes.
---

# M001: Ownership safety and review baseline

**Renamed and reshaped ClaudeMeter into Pinemeter as an owned macOS menu bar app while preserving behavior, inventorying credential/session risk, establishing security and architecture baselines, cleaning safe stale code, and planning non-destructive public history work.**

## What Happened

M001 completed the ownership baseline for Pinemeter. S01 migrated the build-critical and user-facing identity from ClaudeMeter to Pinemeter across the Xcode project, scheme, module, app/test targets, source/test paths, active UI copy, docs/site assets, workflows, and logger subsystem, while classifying compatibility-sensitive Keychain, cache, export, and access-group identifiers instead of changing them blindly. S02 inventoried credential and session handling across Claude and ChatGPT acquisition, storage, reuse, display, logging, clearing, and recovery. S03 converted that inventory into a ranked security baseline with credential/session invariants and fix/defer recommendations. S04 produced an architecture review baseline for provider boundaries, services, repositories, app state, settings, and error handling. S05 audited provider/error workflows, applied safe stale copy and diagnostic-redaction fixes, and verified the focused behavior changes. S06 completed low-risk stale ownership cleanup while preserving cache/export compatibility, credential invariants, settings clamp behavior, provider copy, session keys, and redacted diagnostics. S07 performed final Pinemeter test and clean build verification, classified remaining public-readiness exceptions, and produced a non-destructive git history and open-source hygiene plan without rewriting history, pushing remotes, publishing releases, deploying the site, or mutating secrets. Fresh closeout verification confirmed non-.gsd implementation changes versus main, all seven slices complete with summaries, validation coverage for success criteria and verification classes, and requirement transitions for R001-R009.

## Success Criteria Results

| Criterion | Result | Evidence |
| --- | --- | --- |
| App/project/scheme/tests/docs/site/metadata/internal symbols use Pinemeter wherever feasible with risky exceptions escalated. | PASS | S01 migrated app/project/scheme/module/UI/docs/workflow identity and documented compatibility-sensitive Keychain/cache/export/access-group exceptions; S07 classified remaining public-readiness exceptions. |
| Credential/session handling surfaces inventoried enough for M002. | PASS | S02 produced the complete credential/session inventory; S03 and S05 consumed it for security and workflow review. |
| Security and architecture review artifacts exist with ranked findings and fix/defer recommendations. | PASS | S03 produced ranked security findings and invariants; S04 produced ranked architecture findings and provider-boundary alternatives. |
| Provider/error workflow assumptions audited and obvious safe stale copy fixed. | PASS | S05 audited provider/error workflows, fixed safe stale credential copy and diagnostic-redaction issues, and added focused tests/source/docs evidence. |
| Safe dead code, stale names, obsolete assumptions, and low-risk structural issues cleaned without behavior regressions. | PASS | S06 cleanup retained compatibility/security invariants and verified cache/export compatibility, credential invariants, settings clamp behavior, provider copy, session keys, and redacted diagnostics. |
| Xcode test and clean build verification pass using resulting project/scheme names or exceptions documented. | PASS | S07 recorded fresh final `xcodebuild test` and `xcodebuild clean build` evidence for `Pinemeter.xcodeproj` / `Pinemeter`; S01 also recorded renamed verification after migration. |
| Non-destructive git history squash and open-source hygiene plan exists with no rewrite or remote push. | PASS | S07 produced the plan and explicitly avoided filter-repo, reset, remote pushes, repository creation, release publication, site deployment, and secret mutation. |

Fresh closeout evidence: `gsd_exec` 354bbfba-92cd-4c4c-b613-ca8287ac7969 found 107 non-.gsd files changed versus `main`, all S01-S07 summaries present, all roadmap slice boxes checked, validation verdict `pass`, and no Horizontal Checklist in the roadmap.

## Definition of Done Results

| Item | Result | Evidence |
| --- | --- | --- |
| Code changes exist beyond `.gsd/` artifacts. | PASS | Fresh `gsd_exec` 354bbfba-92cd-4c4c-b613-ca8287ac7969 found 107 non-.gsd files changed versus the merge-base with `main`, including Pinemeter Xcode project, source, tests, workflows, docs, and site assets. |
| All slices complete. | PASS | `gsd_milestone_status` reported milestone M001 active before closeout with seven slices and completed task counts; roadmap lists S01-S07 as `[x]`. |
| Slice summaries exist. | PASS | Fresh artifact check found all S01-S07 `Sxx-SUMMARY.md` files present. |
| Integrations work across slice boundaries. | PASS | M001 validation cross-slice integration table marks S01->S02, S02->S03, S02+S03->S05, S04->S06, S05+S04->S06, and S01+S03+S04+S06->S07 as PASS. |
| Verification classes satisfied. | PASS | M001 validation marks Contract, Integration, Operational, and UAT verification class compliance as PASS. |
| Horizontal Checklist. | PASS | Fresh roadmap scan found no Horizontal Checklist section for M001. |

## Requirement Outcomes

| Requirement | Transition | Evidence |
| --- | --- | --- |
| R001 | active -> validated | S01/S07 prove Pinemeter identity migration with classified compatibility exceptions. |
| R002 | active -> validated | S01/S06/S07 prove rename, cleanup, tests, and clean build preserved behavior. |
| R003 | active -> validated | S02 credential/session inventory covers acquisition, storage, reuse, clearing, logging, settings/UI display, and recovery. |
| R004 | active -> validated | S03 ranked security review covers credential/session/logging/persistence/recovery/secret-exposure risks. |
| R005 | active -> validated | S04 ranked architecture review covers services, repositories, app state, provider boundaries, settings, and errors. |
| R006 | active -> validated | S05 provider/error audit fixed safe stale copy/redaction issues with focused verification. |
| R007 | active -> validated | S06 safe cleanup retained compatibility and security invariants with executable proof. |
| R008 | active -> validated | S07 final Pinemeter `xcodebuild test` and `xcodebuild clean build` evidence passed. |
| R009 | active -> validated | S07 produced a non-destructive history/public hygiene plan and performed no destructive or remote actions. |
| R010-R014 | unchanged deferred | These are planned for later milestones, primarily M002-M004. |
| R015-R017 | unchanged out of scope | M001 respected anti-feature scope by not implementing durable credential acquisition, Gemini monitoring, or launch-grade public polish. |

## Deviations

M001 intentionally retained compatibility-sensitive `claudemeter` Keychain/cache/export/access-group identifiers rather than renaming them automatically. Public release, repository creation, site deployment, Homebrew/release URL confirmation, remote pushes, filter-repo/history rewrite, durable credential acquisition, and Gemini monitoring were deliberately deferred or forbidden by scope.

## Follow-ups

M002 should design durable app-owned credential/session acquisition, migration/fallback reads for retained Keychain/cache identifiers, safer replace-not-display credential flows, and credential diagnostics boundaries. M003 should make setup/status/errors/recovery/provider copy fully provider-aware. M004 should add Gemini monitoring using the reviewed provider boundaries. M005 should handle launch-grade public repository polish, contribution templates, release/hosting/Homebrew decisions, and any destructive git history action only after explicit human approval.
