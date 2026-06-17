# S07: Verification and open source history plan — UAT

**Milestone:** M001
**Written:** 2026-06-17T16:38:21.911Z

# UAT: S07 Verification and Open Source History Plan

**UAT Type:** artifact and command-evidence review.

## Preconditions

- Worktree is the M001 worktree.
- S01, S03, S04, and S06 are complete, and S07 tasks T01 through T04 are complete.
- No destructive git history, remote, release, site deployment, or secret-storage mutation is authorized during this UAT.

## Steps and Expected Outcomes

1. Review final executable verification evidence.
   - Expected: `gsd_exec:213e0bef-4923-4e7f-a2de-dd9391c9c1ee` shows required S07 artifacts present and both renamed Pinemeter commands passing: `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` and `xcodebuild clean build -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug`.

2. Review `S07-FINAL-AUDIT.md`.
   - Expected: remaining ClaudeMeter or claudemeter references are classified as compatibility, history, operational secret-path, pending public URL, or public-readiness gaps; no unclassified active UI/project identity defect is left as a silent release risk.

3. Review `S07-OPEN-SOURCE-HISTORY-PLAN.md`.
   - Expected: the plan is cold-reader-safe and non-destructive, includes branch/remotes/commit-count context, public-hygiene gaps, license attribution caveat, site URL caveat, hard-stop destructive commands, and human confirmation gates before any future history rewrite or publication.

4. Review `S07-ASSESSMENT.md`.
   - Expected: final verification, prior review artifacts, audit classifications, and the history plan are linked to M001 success criteria and to R002, R008, and R009; supporting prior-slice requirements are referenced as upstream evidence.

5. Confirm operational readiness for this verification slice.
   - Expected: health and failure signals are based on persisted GSD evidence and artifact presence; recovery directs the next maintainer to inspect `.gsd/exec` logs and reopen/replan rather than making destructive changes.

## Edge Cases

- If Xcode verification fails, S07 must not close; inspect the failing `.gsd/exec` logs and reopen/replan according to failure ownership.
- If an active identity defect is found in user-facing Pinemeter surfaces, classify and fix or escalate it before milestone closure.
- If a future maintainer wants to squash history or publish publicly, this UAT still forbids doing so without explicit human confirmation gates from the plan.

