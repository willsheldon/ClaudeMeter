# S07 Open Source History Plan

Task: M001/S07/T03  
Date: 2026-06-17  
Status: plan-only, non-destructive

## Executive Summary

This document is a handoff plan for a future maintainer preparing Pinemeter for public open-source publication and a cleaner git history. It is intentionally **not** an execution log for a history rewrite. S07 inspected the repository state and prior M001 readiness evidence, then wrote a safe plan that can only be executed after explicit owner approval.

The repository currently has a Pinemeter-facing application, documentation, workflows, and site, but the final public release decision still depends on ownership confirmation, license attribution confirmation, public repository URL confirmation, remote-name confirmation, and one final secret/public-readiness review. Treat those items as hard-stop gates, not as details a future agent may infer.

## Scope and Non-Destructive Guarantee

### What S07/T03 did

- Inspected the current branch, tracked-file status, remotes, commit count, and recent commit log using read-only git commands.
- Reviewed prior S07 audit evidence and public-facing repository files.
- Wrote this plan for future maintainers.

### What S07/T03 did not do

S07/T03 did **not** run any of the following:

- `git rebase`
- `git reset`
- `git filter-repo`
- `git filter-branch`
- `git push`
- `git remote add`, `git remote remove`, or `git remote set-url`
- repository creation, transfer, or visibility changes
- GitHub release publication
- GitHub Pages deployment
- Homebrew tap updates
- destructive local cleanup commands

The non-destructive git inspection evidence is `gsd_exec:1d3053b9-deee-4b18-bb1f-739d85854ec9`, which ended with `destructive_commands_executed_by_this_script=none`.

## Current State Snapshot

Evidence source: `gsd_exec:1d3053b9-deee-4b18-bb1f-739d85854ec9`.

| Item | Observed state | Publication implication |
|---|---|---|
| Active branch | `milestone/M001` | A future public history operation should start from a fresh protected backup branch or clone, not directly from an active milestone branch. |
| Commit count | `81` | A squash may be desirable for public readability, but the current history also contains useful audit trail while M001 is still closing. |
| Tracked modifications before this task | `.gsd/hook-state.json`, `.gsd/milestones/M001/slices/S07/S07-PLAN.md`, `.gsd/milestones/M001/slices/S07/tasks/T02-PLAN.md` | Future squash planning must first distinguish orchestrator state changes from source/product changes. |
| Remotes | `fork` -> `git@github.com:willsheldon/ClaudeMeter.git`; `origin` -> `https://github.com/eddmann/ClaudeMeter.git` | Remote names are stale relative to a potential public `Pinemeter` repo. Do not infer which remote is authoritative. |
| Recent commits | S07 final audit, S07 verification, S06 status alignment, settings/test updates, security/provider work | Milestone work is integrated but still includes detailed development history and GSD automation commits. |

## Evidence From Prior M001 Slices

The future maintainer should read these artifacts before making publication decisions:

| Artifact | Why it matters |
|---|---|
| `.gsd/milestones/M001/slices/S07/S07-FINAL-AUDIT.md` | Classifies remaining legacy identity references, public-readiness gaps, and redacted secret-shaped scan findings. |
| `.gsd/milestones/M001/slices/S07/tasks/T01-SUMMARY.md` | Provides fresh passing renamed Pinemeter Xcode test and clean build evidence. |
| `.gsd/milestones/M001/slices/S07/tasks/T02-SUMMARY.md` | Records final audit decisions, including intentional compatibility/operational surfaces that were not renamed. |
| `.gsd/milestones/M001/slices/S01/S01-ASSESSMENT.md` through `.gsd/milestones/M001/slices/S06/S06-ASSESSMENT.md` | Preserve the slice-by-slice basis for rename, security, provider, workflow, and release-readiness conclusions. |

## Publication-Risk Surfaces

### Git remotes

Current remotes still reference `ClaudeMeter` names:

- `fork`: `git@github.com:willsheldon/ClaudeMeter.git`
- `origin`: `https://github.com/eddmann/ClaudeMeter.git`

Pending owner decisions:

1. Which remote, if any, is the canonical source of truth after M001?
2. Should a new `Pinemeter` repository be created, or should an existing repository be renamed/transferred?
3. Which account or organization owns the future public repository?
4. Should issue/release history be preserved from the old repository or deliberately reset?

No future agent should push, rename, transfer, or delete a remote until these decisions are confirmed by the owner.

### Release URLs and website URLs

`site/index.html` currently presents public URLs under `https://eddmann.com/Pinemeter/` and GitHub links under `https://github.com/eddmann/Pinemeter`. The release workflow publishes GitHub releases and updates the Homebrew tap at `eddmann/homebrew-tap`.

Pending owner decisions:

1. Is `https://eddmann.com/Pinemeter/` the intended canonical site URL?
2. Is `https://github.com/eddmann/Pinemeter` the intended public repository URL?
3. Should Homebrew continue using `eddmann/tap/pinemeter`?
4. Should the first public release use the changelog version already present, a new version, or a pre-release tag?

### License attribution

`LICENSE` is MIT and currently names `Copyright (c) 2025 Edd Mann`.

Hard-stop caveat: do not alter copyright holders, license text, year ranges, or attribution without explicit owner/legal confirmation. If contributors, prior owners, generated assets, or renamed project history require attribution, add it only after owner approval.

### Secret and credential surfaces

The release workflow references signing, notarization, Homebrew, and GitHub tokens:

- `APPLE_CERTIFICATE_BASE64`
- `APPLE_CERTIFICATE_PASSWORD`
- `APPLE_TEAM_ID`
- `APP_STORE_CONNECT_API_KEY_BASE64`
- `APP_STORE_CONNECT_KEY_ID`
- `APP_STORE_CONNECT_ISSUER_ID`
- `HOMEBREW_TAP_TOKEN`
- `GITHUB_TOKEN`

The final audit also classified secret-shaped scan findings and redacted them. Before any public publication, rerun a secret review from a clean checkout and confirm no plaintext secrets, derived credentials, local environment dumps, SSM paths, or token-bearing logs are present in source, docs, workflows, generated artifacts, or history selected for publication.

## Hard-Stop Forbidden Operations

Do not run these commands or equivalent GUI/API operations until the owner explicitly confirms the exact target repository, target branch, backup plan, and publication timing:

- `git push --force` or `git push --force-with-lease`
- `git push --mirror`
- `git push --all`
- `git push --tags`
- `git rebase -i --root`
- `git reset --hard`
- `git filter-repo`
- `git filter-branch`
- `git remote set-url`, `git remote remove`, or `git remote rename`
- `gh repo create`, `gh repo edit --visibility public`, or repository transfer operations
- `gh release create` or workflow dispatch for release publication
- GitHub Pages publication changes
- Homebrew tap pushes

If any future procedure needs one of these operations, pause and obtain explicit human confirmation in writing.

## Recommended Future Squash Options

### Option A: No rewrite, publish current history after hygiene gates

Use when preserving the full development and GSD audit trail matters more than public history cleanliness.

Process:

1. Finish milestone validation and slice closure.
2. Confirm owner, license, URL, remote, and secret-review gates.
3. Create a fresh public-readiness branch from the validated milestone head.
4. Remove or exclude private automation artifacts only if policy requires it and owner approves.
5. Push normally to the confirmed public repository.

Pros: lowest risk, no history rewrite, easiest rollback.  
Cons: public history includes development automation details and legacy project history.

### Option B: Squash merge into a new public branch

Use when a readable public history is desired but source state should remain traceable to the private milestone branch.

Process:

1. Create a backup tag or branch in the private repository.
2. Create a new branch from the target base selected by the owner.
3. Apply the final tree state as one or a few reviewed commits.
4. Preserve a private mapping note from public commit(s) to original `milestone/M001` commit SHA.
5. Push only to the owner-confirmed public remote after all hard-stop gates pass.

Pros: clean public history, simpler than rewriting in place.  
Cons: loses public per-slice history unless mapped privately.

### Option C: New repository import with selected tree state

Use when public release should start as a clean open-source project without old repo names, remotes, or historical implementation details.

Process:

1. Create an empty private staging repository or local temporary clone.
2. Copy the validated final tree into it, excluding private `.gsd` state if owner policy says not to publish it.
3. Commit with explicit attribution and provenance note approved by the owner.
4. Run all build, test, secret, license, and URL checks in the staging repository.
5. Make the repository public only after owner confirmation.

Pros: cleanest public surface and simplest secret-history risk model.  
Cons: strongest need for attribution/provenance documentation; easiest to accidentally omit useful history.

### Option D: Full history rewrite with filter tooling

Not recommended unless a confirmed secret or private artifact exists in history and publication must preserve otherwise useful history.

Process requirements:

- Fresh clone only.
- Owner-approved rewrite spec.
- Backup remote/tag exists and is verified.
- All collaborators are notified.
- Rewrite is rehearsed locally and diffed against expected final tree.
- Force push uses `--force-with-lease` only after owner approval.

Pros: can remove specific historical material while preserving most history.  
Cons: highest operational risk and easiest to execute incorrectly.

## Public-Hygiene Checklist

Complete this checklist before any repository is made public or any release/site workflow is dispatched.

### Repository identity

- [ ] Confirm final product name is `Pinemeter` everywhere user-facing.
- [ ] Confirm any remaining `ClaudeMeter` references are historical, compatibility, or private planning artifacts.
- [ ] Confirm bundle identifiers, keychain names, cache names, access groups, and SSM paths are intentionally retained or have a migration plan.
- [ ] Confirm GitHub repository owner and repository name.
- [ ] Confirm issue tracker, discussions, security policy, and support contact expectations.

### Documentation

- [ ] `README.md` describes Pinemeter accurately and does not promise unsupported distribution channels.
- [ ] `CHANGELOG.md` top version matches the intended release version.
- [ ] Add or confirm `CONTRIBUTING.md`, `SECURITY.md`, and code of conduct expectations if accepting outside contributions.
- [ ] Confirm screenshots, icons, and generated assets are redistributable.

### License and attribution

- [ ] Confirm MIT license remains correct.
- [ ] Confirm copyright holder and year.
- [ ] Confirm third-party attributions for assets, dependencies, and workflow templates.
- [ ] Confirm old project provenance should be public, summarized, or omitted.

### Site and release URLs

- [ ] Confirm canonical site URL in `site/index.html`.
- [ ] Confirm GitHub links in `site/index.html`.
- [ ] Confirm `downloadUrl` points to the owner-approved release location.
- [ ] Confirm Homebrew command and tap path.
- [ ] Confirm GitHub Pages environment is configured for the target repository.

### CI and release workflows

- [ ] Run `.github/workflows/test.yml` equivalent locally or in CI.
- [ ] Confirm `release.yml` secrets exist only in GitHub secrets and are scoped to the target repository.
- [ ] Confirm release workflow should update `eddmann/homebrew-tap` or a different tap.
- [ ] Confirm release workflow creates drafts or final releases according to owner policy.
- [ ] Confirm notarization credentials are active and least-privilege.

### Secrets and private data

- [ ] Rerun secret scanning on the final tree.
- [ ] Rerun secret scanning on any history that will become public.
- [ ] Review `.gsd` artifacts before deciding whether to publish them.
- [ ] Confirm no SSM parameters, local paths, credentials, cookies, tokens, or private account names are exposed beyond intended documentation.
- [ ] Confirm generated logs do not contain secrets.

## Release and Distribution Prerequisites

Before dispatching `Release Pinemeter` or publishing a public release:

1. Fresh Xcode test evidence exists for the final tree.
2. Clean release build succeeds with signing disabled or with owner-approved signing credentials, depending on the check.
3. Code signing, notarization, stapling, and `spctl` verification are tested in a private dry run.
4. GitHub release notes are reviewed for user-facing accuracy.
5. Homebrew cask update path is confirmed.
6. Site download links and structured metadata point to the intended public release.
7. Rollback plan is ready.

## Rollback Guidance

If a future public-prep operation goes wrong:

1. Stop immediately; do not stack additional rewrite or push attempts.
2. Preserve the failing command, stdout/stderr, branch, remote, and SHA evidence.
3. If no public push occurred, delete the failed local branch or clone and restart from the backup.
4. If a public push occurred, pause for owner decision before force-pushing or deleting public refs.
5. If a release was published, convert it to draft or delete it only with owner confirmation.
6. If a secret was exposed, rotate the secret first, then clean history/public artifacts.
7. Record the incident and final corrective action in the milestone or release notes.

## Explicit Human Confirmation Gates

A future maintainer must obtain explicit human confirmation for each item below:

| Gate | Required decision |
|---|---|
| Repository owner | Account or organization that will own the public Pinemeter repository. |
| Public repository URL | Exact URL to use in README, site, releases, and package metadata. |
| Remote mapping | Which local remote maps to private backup, staging, and public publication. |
| History strategy | No rewrite, squash branch, new repository import, or full filter rewrite. |
| License attribution | Final license text, copyright holder, years, and provenance note. |
| Publication contents | Whether `.gsd` planning/audit artifacts are public, private, summarized, or omitted. |
| Release strategy | Version, draft/final release setting, signing/notarization readiness, Homebrew tap target. |
| Site deployment | Canonical site URL and GitHub Pages target. |
| Secret review | Confirmation that final tree and selected history passed secret review. |

## Failure Modes

| Dependency/surface | Failure path | Handling in this plan |
|---|---|---|
| Filesystem | Expected artifacts such as `README.md`, `LICENSE`, workflows, or S07 audit files are missing or stale. | Treat missing/stale evidence as a hard stop; do not infer publication readiness. Recreate evidence from the final tree first. |
| Git subprocess inspection | `git` commands fail, branch is detached, remotes are missing, or status is dirty in unexpected ways. | Do not rewrite or publish. Capture the failure and ask the owner which checkout/remote is authoritative. |
| Git remotes/network | Remote names or URLs are stale, inaccessible, renamed, or point to the wrong owner. | Do not mutate remotes or push. Confirm repository owner and target URLs explicitly. |
| GitHub release/site APIs | Workflow dispatch, release publication, Pages deployment, or Homebrew tap update fails or publishes to the wrong place. | Keep release/site operations out of S07. Future execution must dry-run where possible and pause before any public mutation. |
| License/attribution ownership | License holder, year, contributor attribution, or provenance is ambiguous. | Leave attribution unchanged until owner/legal confirmation. |
| Secret scanning | Scanner reports malformed output, false positives, or real secret-shaped findings. | Redact findings in artifacts, rotate any real exposed secrets, and do not publish selected history until cleared. |

## Load Profile

This task has no runtime load dimension: it produced a static plan and performed bounded read-only inspection of repository metadata. The only scaling concern is operational, not runtime: if the public-history candidate grows beyond the current 81 commits, future maintainers should avoid manual review alone and use scripted inventory for secret, license, URL, and identity scans before publication.

## Negative Tests

This task is protected by process-level negative checks rather than product tests:

| Negative scenario | Protection/evidence |
|---|---|
| A future maintainer accidentally treats this as permission to rewrite history. | The hard-stop forbidden operations section explicitly blocks rewrite, force-push, release, repo creation, and remote mutation without owner confirmation. |
| Stale `ClaudeMeter` remotes are silently treated as correct. | The current-state table records both stale remote URLs and marks remote authority as a pending owner decision. |
| License attribution is silently rewritten during rename cleanup. | The license caveat blocks attribution changes without owner/legal confirmation. |
| Secret-shaped findings are normalized as safe because they were redacted in audit output. | The secret checklist requires rerunning final-tree and selected-history secret scans before publication. |
| S07 appears to have executed destructive commands. | The non-destructive guarantee cites `gsd_exec:1d3053b9-deee-4b18-bb1f-739d85854ec9`, whose script recorded `destructive_commands_executed_by_this_script=none`. |

## Verification Evidence

| # | Evidence | Exit Code | Verdict | Duration |
|---|---|---:|---|---:|
| 1 | `gsd_exec:1d3053b9-deee-4b18-bb1f-739d85854ec9` — non-destructive branch/status/remotes/count/log inspection | 0 | pass | 97ms |

## Reader-Test Notes

A cold maintainer should be able to answer these questions from this document without reading the whole M001 conversation:

1. What is safe to do now? Read this plan and prior evidence only.
2. What is unsafe without owner confirmation? Any history rewrite, force push, remote mutation, repo publication, release dispatch, site deployment, or license change.
3. What is the current repository state? `milestone/M001`, 81 commits, stale `ClaudeMeter` remotes, and tracked GSD-state modifications observed before this task.
4. Which decisions are still pending? Owner, public URL, remote mapping, history strategy, attribution, publication contents, release strategy, site deployment, and final secret review.
5. Which prior evidence supports the plan? S07 final audit plus S01-S06 assessment artifacts and S07 T01/T02 summaries.
