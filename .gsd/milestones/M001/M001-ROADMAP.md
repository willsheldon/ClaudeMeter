# M001: Ownership safety and review baseline

**Vision:** Rename and reshape ClaudeMeter into Pinemeter as an owned macOS menu bar app, while preserving current behavior, inventorying credential surfaces, capturing security and architecture findings, auditing provider/error assumptions, cleaning safe stale code, and preparing a non-destructive public repo history plan.

## Success Criteria

- The app, project, scheme, tests, docs/site, metadata, and primary internal symbols use Pinemeter instead of ClaudeMeter wherever feasible, with any risky exceptions explicitly escalated.
- Credential and session handling surfaces are inventoried with enough detail to plan M002 without rediscovery.
- Security and architecture review artifacts exist with ranked findings and fix/defer recommendations.
- Provider/error workflow assumptions are audited and obvious safe stale copy is fixed.
- Safe dead code, stale names, obsolete assumptions, and low-risk structural issues are cleaned without behavior regressions.
- Xcode test and clean build verification pass using the resulting project and scheme names, or approved exceptions are documented.
- A non-destructive git history squash and open-source hygiene plan exists, with no history rewrite or remote push performed.

## Slices

- [x] **S01: Pinemeter identity migration** `risk:high` `depends:[]`
  > After this: After this: the app, tests, docs/site, metadata, project/scheme surfaces, and primary code symbols use Pinemeter instead of ClaudeMeter, with any risky exceptions explicitly surfaced.

- [x] **S02: Credential surface inventory** `risk:high` `depends:[S01]`
  > After this: After this: a concrete inventory shows where Claude and GPT credentials or session material are obtained, stored, reused, displayed, logged, cleared, and recovered.

- [x] **S03: Security review baseline** `risk:high` `depends:[S02]`
  > After this: After this: a ranked security findings report identifies credential, Keychain, logging, persistence, and recovery risks with fix or defer recommendations.

- [x] **S04: Architecture review baseline** `risk:medium` `depends:[S01]`
  > After this: After this: a ranked architecture review, using Opus if available, identifies provider, service, repository, app-state, settings, and error-handling risks.

- [x] **S05: Provider and error workflow audit** `risk:medium` `depends:[S02,S03]`
  > After this: After this: stale Claude-only or provider-ambiguous setup, status, error, and recovery messages are identified, and obvious safe copy fixes are applied.

- [x] **S06: Safe cleanup and ownership refactor** `risk:medium` `depends:[S04,S05]`
  > After this: After this: obvious dead code, stale names, obsolete assumptions, and low-risk structural issues are removed or cleaned while preserving behavior.

- [x] **S07: Verification and open source history plan** `risk:low` `depends:[S01,S03,S04,S06]`
  > After this: After this: renamed test and clean build commands pass, final review artifacts are linked, and a non-destructive git history squash and open-source hygiene plan exists.

## Boundary Map

### S01 to S02
Produces:
- Renamed project identity map and any risky rename exceptions.
- Updated source/test/docs paths or names needed for inventory references.
Consumes:
- Existing ClaudeMeter codebase and baseline test evidence.

### S02 to S03
Produces:
- Credential/session inventory with acquisition, storage, reuse, display, logging, clearing, and recovery surfaces.
Consumes:
- Pinemeter identity map from S01.

### S02 and S03 to S05
Produces:
- Credential risk categories and security recommendations.
- Known provider-specific error and recovery surfaces.
Consumes:
- Credential/session inventory and security findings.

### S04 to S06
Produces:
- Architecture findings and candidate cleanup/refactor priorities.
Consumes:
- Renamed codebase from S01.

### S05 and S04 to S06
Produces:
- Provider/error audit findings and safe copy fixes.
- Architecture-backed cleanup boundaries.
Consumes:
- Review artifacts and provider/error audit results.

### S01 S03 S04 S06 to S07
Produces:
- Renamed codebase, review artifacts, cleanup changes, and known deferred risks.
Consumes:
- All prior slice outputs to run final verification and produce the non-destructive history plan.
