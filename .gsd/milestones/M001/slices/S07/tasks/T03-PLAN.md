---
estimated_steps: 12
estimated_files: 9
skills_used: []
---

# T03: Write non destructive history and public hygiene plan

---
skills_used:
  - write-docs
---
Why: R009 is plan-only: future maintainers need a safe, cold-reader-ready path for squashing history and preparing an open-source repo without S07 performing destructive or outward-facing operations.

Do: Using write-docs Context -> Refine -> Reader-Test discipline, inspect non-destructive git state with gsd_exec: branch, status without untracked noise, remotes, commit count, and recent log. Write `.gsd/milestones/M001/slices/S07/S07-OPEN-SOURCE-HISTORY-PLAN.md` with context, current state, hard-stop forbidden commands, recommended future squash options, public-hygiene checklist, license attribution caveat, site/public URL caveat, secret-review checklist, release/distribution prerequisites, rollback guidance, and explicit human confirmation gates. State clearly that S07 did not run rebase, reset, filter-repo, push, repo creation, release publication, or remote mutation.

Done when: The plan can be handed to a maintainer unfamiliar with M001 and they can see what to verify, what not to run, what decisions require the owner, and what evidence from prior slices justifies the plan.

Q3 Threat Surface: The plan must treat git remotes, release URLs, license attribution, and secret scans as publication-risk surfaces.
Q4 Requirement Impact: Directly satisfies R009 and supports launchability without changing source or git history.
Q5 Failure Modes: Ambiguous ownership, unconfirmed license changes, unconfirmed public repo URL, or stale remote names should be explicit pending decisions rather than silently resolved.
Q6 Load Profile: Non-destructive git inspection only; no history rewrite or remote operation.
Q7 Negative Tests: Include a forbidden-operations checklist and verify no destructive command was run during S07.

## Inputs

- `.gsd/milestones/M001/slices/S07/S07-FINAL-AUDIT.md`
- `README.md`
- `LICENSE`
- `CHANGELOG.md`
- `site/index.html`
- `.github/workflows/test.yml`
- `.github/workflows/release.yml`
- `.github/workflows/deploy-pages.yml`
- `.gsd/milestones/M001/slices/S01/S01-ASSESSMENT.md`
- `.gsd/milestones/M001/slices/S02/S02-ASSESSMENT.md`
- `.gsd/milestones/M001/slices/S03/S03-ASSESSMENT.md`
- `.gsd/milestones/M001/slices/S04/S04-ARCHITECTURE-REVIEW.md`
- `.gsd/milestones/M001/slices/S05/S05-ASSESSMENT.md`
- `.gsd/milestones/M001/slices/S06/S06-ASSESSMENT.md`

## Expected Output

- `.gsd/milestones/M001/slices/S07/S07-OPEN-SOURCE-HISTORY-PLAN.md`

## Verification

test -f .gsd/milestones/M001/slices/S07/S07-OPEN-SOURCE-HISTORY-PLAN.md

## Observability Impact

Provides a durable release-planning checklist and destructive-action audit trail for future open-source preparation.
