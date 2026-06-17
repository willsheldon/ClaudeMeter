# S07 Research: Verification and open source history plan

## Summary

S07 is a low-risk closure slice with three deliverables: final Pinemeter verification, a linked final review/exception artifact, and a non-destructive git history/open-source hygiene plan. Active requirements owned by this slice are R002 (behavior remains stable), R008 (renamed Xcode test and clean build pass), and R009 (history squash/open-source hygiene planned without rewriting history or pushing). R001/R004/R005/R006/R007 are mostly consumed as evidence from prior slices.

Skill guidance used: `write-docs` says long-form docs must transfer intent to a cold reader through Context → Refine → Reader-Test. Apply that to the history/hygiene plan: it should not be a session summary; it should let a future maintainer safely execute or reject the plan without rediscovering M001.

No dedicated installed git/Xcode/open-source hygiene skill is present in `<available_skills>`. I did not install any additional skill. Earlier `gsd_resume` and direct broad `bash` attempts were blocked by the research-lane tool policy; use `gsd_exec` for noisy scans and final verification evidence.

## Recommendation

Plan S07 as artifact + verification work, not source refactor work.

1. Run final full verification first and capture evidence IDs:
   - `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug`
   - `xcodebuild clean build -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug`
2. Run small final audit scans for stale identity, public-hygiene gaps, and secret-shaped content. These should classify findings, not automatically rewrite compatibility/history surfaces.
3. Write a durable S07 assessment/history plan artifact under `.gsd/milestones/M001/slices/S07/`, likely `S07-ASSESSMENT.md` plus optionally `S07-OPEN-SOURCE-HISTORY-PLAN.md` if the planner wants separation. The artifact should link prior final review artifacts and evidence IDs, then give an explicit non-destructive squash/open-source checklist.
4. Do **not** run `git rebase`, `git reset`, `git filter-repo`, `git push`, `gh repo create`, `gh release`, or remote mutation commands in M001/S07. R009 only permits planning.

## Implementation Landscape

### Verification surfaces

- Project/scheme are renamed and shared at:
  - `Pinemeter.xcodeproj/project.pbxproj`
  - `Pinemeter.xcodeproj/xcshareddata/xcschemes/Pinemeter.xcscheme`
- Workflow test command already uses Pinemeter names in `.github/workflows/test.yml` and skips snapshot tests only in CI; S07 acceptance asks for local renamed `xcodebuild test` without that skip unless a new exception is documented.
- S01 evidence already passed full renamed test/build, but S07 must run fresh final commands after S06 cleanup.
- S06 focused proof is `gsd_exec 6a6d88c7-202e-4fb7-b4e7-2b11014f9624`: provider audit plus CacheRepository/AppSettings/UsageService/SecurityInvariant/ProviderErrorWorkflow/SessionKey focused tests.
- S05 focused proof is `gsd_exec ac728808-8868-4cc0-98db-f65a792de1ff`: provider workflow audit and focused XCTest bundle.
- S03 focused proof is `gsd_exec 7c2f4b57-6002-470f-abf7-8647bc0828ef`; S03 artifact coverage proof is `0c6424f0-7b52-47a9-8754-2b5a31350f0d`.

### Prior review artifacts to link

- `.gsd/milestones/M001/slices/S01/S01-ASSESSMENT.md` — identity map, remaining references, rename/build evidence.
- `.gsd/milestones/M001/slices/S02/S02-ASSESSMENT.md` — credential/session inventory.
- `.gsd/milestones/M001/slices/S03/S03-ASSESSMENT.md` — ranked security baseline.
- `.gsd/milestones/M001/slices/S04/S04-ARCHITECTURE-REVIEW.md` and `.gsd/milestones/M001/slices/S04/S04-ASSESSMENT.md` — architecture baseline and local-only Opus limitation.
- `.gsd/milestones/M001/slices/S05/S05-ASSESSMENT.md` — provider/error workflow audit.
- `.gsd/milestones/M001/slices/S06/S06-ASSESSMENT.md` — safe cleanup validation.

### Git/open-source state observed

- Branch: `milestone/M001`.
- Remotes still point to old upstream/fork names:
  - `origin https://github.com/eddmann/ClaudeMeter.git`
  - `fork git@github.com:willsheldon/ClaudeMeter.git`
- Commit count observed: 79. Recent commits include many milestone-generated commits, so a future squash plan is reasonable.
- Tracked working tree noise at research time is limited to `.gsd/*` planning state; no app/source tracked modifications were reported by `git status --short --untracked-files=no` outside `.gsd`.
- Public hygiene files present: `README.md`, `LICENSE`, `CHANGELOG.md`, workflows.
- Public hygiene files missing and suitable for future M005/open-source polish: `SECURITY.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `.github/dependabot.yml`, issue templates, PR template.
- `LICENSE` still says `Copyright (c) 2025 Edd Mann`. Do not silently rewrite ownership unless the user confirms legal/attribution intent; include it in the hygiene plan.
- `site/index.html` hardcodes `https://github.com/eddmann/Pinemeter` and release download URL. README intentionally says distribution/Homebrew/final public repo URLs are pending the open-source hygiene plan. S07 should classify the site URLs as pending confirmation rather than assume they are final.

### Remaining old identity references to classify

A source/docs scan excluding `.gsd` found expected compatibility/history/ops references:

- `AGENTS.md` / `CLAUDE.md`: SSM path/profile `ws-claude-claudemeter`; project instructions say secrets use this path, so do not rename in S07.
- `CHANGELOG.md`: historical ClaudeMeter release entries and `eddmann/ClaudeMeter` compare links; likely historical attribution, not active app identity.
- `Pinemeter/Repositories/CacheRepository.swift`: legacy `com.claudemeter` cache directory and `~/.claudemeter/usage.json` export compatibility.
- `Pinemeter/Repositories/KeychainRepository.swift`: intentional legacy Keychain service `com.claudemeter.sessionkey` deferred to M002.
- `Pinemeter/Resources/Pinemeter.entitlements`: intentional legacy access group `$(AppIdentifierPrefix)com.claudemeter` deferred to M002.
- `PinemeterTests/*`: tests intentionally guarding the above compatibility identifiers.
- `work-to-date.md`: documents current Pinemeter status and legacy compatibility exceptions.

S07 should not attempt more rename work unless a scan finds unclassified active UI/project references.

## Natural Seams for Planning

1. **Final verification task**
   - Inputs: renamed project/scheme, prior slice outputs.
   - Actions: run full test and clean build via `gsd_exec`; record evidence IDs and exit codes.
   - Output: task summary with R002/R008 proof.

2. **Final audit/classification task**
   - Inputs: prior assessments, source/docs scans.
   - Actions: run concise stale-name/public-hygiene/secret-shaped scans; classify remaining exceptions as compatibility, history, operational, or pending-confirmation.
   - Output: S07 assessment section/table; no source edits unless there is an obvious safe docs wording fix.

3. **Non-destructive history/open-source plan task**
   - Inputs: `git status`, `git log`, remotes, public hygiene scan, README/site/license findings.
   - Actions: write a plan with explicit safe prerequisites, recommended future squash approach, and hard stop gates requiring human confirmation.
   - Output: plan artifact. Must state no history rewrite or remote push occurred.

4. **Slice closure task**
   - Inputs: evidence IDs and artifacts.
   - Actions: complete S07 with UAT content that checks final verification, artifact links, and destructive-action absence.
   - Output: GSD slice completion with requirements R002/R008/R009 advanced/validated as appropriate.

## First Proof

Run the full renamed test command first:

```bash
xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug
```

Reason: it is the broadest behavior-regression proof for R002/R008 and catches cleanup fallout before spending time polishing the plan. Then run clean build:

```bash
xcodebuild clean build -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug
```

Use `gsd_exec` with compact output/evidence. If either fails due to environment-only code signing or simulator issues, document exact failure and retry only with a justified local-environment flag; do not weaken the acceptance command silently.

## Verification Commands and Checks

Recommended S07 commands/checks:

```bash
# Full final verification
xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug
xcodebuild clean build -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug

# Remaining identity classification scan
rg -n --hidden --glob '!.git/**' --glob '!.gsd/exec/**' --glob '!**/DerivedData/**' 'ClaudeMeter|claudemeter|CLAUDEMETER|Claude Meter' .

# Public hygiene inventory
for f in README.md LICENSE SECURITY.md CONTRIBUTING.md CODE_OF_CONDUCT.md CHANGELOG.md .github/dependabot.yml .github/ISSUE_TEMPLATE/bug_report.md .github/pull_request_template.md; do [ -e "$f" ] && echo "present $f" || echo "missing $f"; done

# Non-destructive git state evidence
git status -sb --untracked-files=no
git remote -v
git rev-list --count HEAD
git log --oneline --max-count=12

# Secret-shaped content scan: keys/locations only, no value dumping
rg -n --hidden --glob '!.git/**' --glob '!.gsd/exec/**' --glob '!**/*.png' --glob '!**/*.jpg' --glob '!**/*.xcuserstate' '(api[_-]?key|secret|token|password|cookie|session|Bearer|sk-[A-Za-z0-9])' README.md site .github scripts Pinemeter PinemeterTests
```

If using `rg` for secret-shaped content, summarize locations/classes; do not paste secrets or session material into artifacts. Existing source/test references to `session`, `cookie`, and `Bearer` are expected security/provider code surfaces.

## Constraints and Watch-outs

- R009 is a plan-only requirement. Destructive or outward-facing operations require fresh explicit user confirmation.
- Do not rename Keychain service/access-group/cache legacy identifiers in S07; S03/S06 explicitly defer those to M002 because they can orphan user data/credentials.
- Do not rewrite SSM secret paths in `AGENTS.md`/`CLAUDE.md`; project instructions say agent-managed secrets live under `/ws-claude/claudemeter` with profile `ws-claude-claudemeter`.
- `site/index.html` contains final-looking GitHub URLs but README says final public repo URLs are pending. The plan should mark repo/hosting/Homebrew decisions as pending confirmation.
- `LICENSE` attribution/ownership is a legal/product decision. S07 can flag it, not autonomously change it.
- `.gsd/exec` will create untracked noise during research/verification. Exclude `.gsd/exec` from hygiene scans and do not treat it as app-source dirt.

## Sources / Evidence from Research

- `gsd_exec 6efac8f8-99d1-460f-8144-b0e2e30980d6` — concise remaining ClaudeMeter/claudemeter refs outside `.gsd`.
- `gsd_exec 88ed7449-2d4f-439f-b19c-4528e87e3a10` — git branch/remotes/commit count and public hygiene file presence.
- `gsd_exec f1c4394d-7ba2-4c77-963f-c0eb9822819f` — R002/R008/R009 requirement details.
- `gsd_exec c7699a8a-0213-4ef7-8a8b-06e0caef8672` — prior M001 artifact inventory.
- Direct reads: `README.md`, `.github/workflows/test.yml`, `.github/workflows/release.yml`, `.github/workflows/deploy-pages.yml`, `.gitignore`, `LICENSE`, `site/index.html`, `.gsd/milestones/M001/slices/S05/S05-SUMMARY.md`.
