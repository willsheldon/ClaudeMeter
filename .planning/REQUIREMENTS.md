# Requirements

This file is the explicit capability and coverage contract for the project.

## Active

### R001 — Product identity is renamed to Pinemeter everywhere feasible, including user-facing surfaces, internal symbols, project/target/scheme names, docs/site, metadata, and tests unless a genuinely risky reference is escalated.

- Class: core-capability
- Status: active
- Description: Product identity is renamed to Pinemeter everywhere feasible, including user-facing surfaces, internal symbols, project/target/scheme names, docs/site, metadata, and tests unless a genuinely risky reference is escalated.
- Why it matters: The app needs to feel owned as Pinemeter rather than a fork of ClaudeMeter, and later work should not inherit stale product identity assumptions.
- Source: user
- Primary owning slice: M001/S01
- Supporting slices: M001/S06, M001/S07
- Validation: mapped
- Notes: If changing a reference is genuinely risky, execution must ask rather than silently leaving it.

### R002 — Existing app behavior remains stable through rename, cleanup, and review-driven restructuring.

- Class: quality-attribute
- Status: active
- Description: Existing app behavior remains stable through rename, cleanup, and review-driven restructuring.
- Why it matters: M001 must improve ownership and maintainability without breaking existing Claude/Opus and GPT monitoring behavior.
- Source: inferred
- Primary owning slice: M001/S07
- Supporting slices: M001/S01, M001/S06
- Validation: mapped
- Notes: Verified by renamed test and clean build commands after changes.

### R003 — Credential and session handling surfaces are inventoried and assessed, including acquisition, storage, reuse, clearing, logging, settings, UI display, and recovery.

- Class: compliance/security
- Status: active
- Description: Credential and session handling surfaces are inventoried and assessed, including acquisition, storage, reuse, clearing, logging, settings, UI display, and recovery.
- Why it matters: Durable app-owned credential acquisition in M002 depends on knowing the current security and workflow surface area.
- Source: user
- Primary owning slice: M001/S02
- Supporting slices: M001/S03, M001/S05
- Validation: mapped
- Notes: Known relevant files include KeychainRepository, SessionKeyImportService, UsageService, ChatGPTUsageService, AppModel, SettingsView, and SetupWizardView.

### R004 — Security review identifies risks in credential storage, session handling, logging, persistence, user-visible recovery, and secret exposure.

- Class: compliance/security
- Status: active
- Description: Security review identifies risks in credential storage, session handling, logging, persistence, user-visible recovery, and secret exposure.
- Why it matters: Pinemeter will handle provider credentials and session material, so unsafe storage or leakage would undermine the product before open-source release.
- Source: user
- Primary owning slice: M001/S03
- Supporting slices: M001/S02, M001/S07
- Validation: mapped
- Notes: Findings may be documented and deferred; M001 does not require fixing every severe issue because Claude/Opus quota is unavailable today unless a safe local fix is obvious.

### R005 — Architecture review produces actionable findings about services, repositories, app state, provider boundaries, settings, and error handling, using an Opus subprocess or advisor if available.

- Class: quality-attribute
- Status: active
- Description: Architecture review produces actionable findings about services, repositories, app state, provider boundaries, settings, and error handling, using an Opus subprocess or advisor if available.
- Why it matters: The codebase should be owned deliberately before durable auth, provider polish, and Gemini monitoring add more pressure to the design.
- Source: user
- Primary owning slice: M001/S04
- Supporting slices: M001/S06, M001/S07
- Validation: mapped
- Notes: If Opus quota is unavailable during execution, capture that limitation and produce a local review baseline.

### R006 — Provider and error workflow assumptions are audited for Claude/Opus and GPT so stale Claude-only messages and recovery paths are identified or safely cleaned.

- Class: failure-visibility
- Status: active
- Description: Provider and error workflow assumptions are audited for Claude/Opus and GPT so stale Claude-only messages and recovery paths are identified or safely cleaned.
- Why it matters: Pinemeter needs provider-aware failures and workflows before broader multi-provider polish and Gemini monitoring.
- Source: user
- Primary owning slice: M001/S05
- Supporting slices: M001/S02, M001/S03
- Validation: mapped
- Notes: M001 fixes obviously stale, misleading, or unsafe copy; larger workflow redesign is deferred to M003.

### R007 — Safe dead-code, stale-name, stale-assumption, and obsolete-path cleanup is performed where it improves ownership without destabilizing behavior.

- Class: quality-attribute
- Status: active
- Description: Safe dead-code, stale-name, stale-assumption, and obsolete-path cleanup is performed where it improves ownership without destabilizing behavior.
- Why it matters: The public-ready codebase should be easier to understand and maintain, not carry misleading fork leftovers.
- Source: user
- Primary owning slice: M001/S06
- Supporting slices: M001/S01, M001/S04
- Validation: mapped
- Notes: Cleanup is allowed to include restructuring when it retires a concrete ownership, provider, security, or architecture risk.

### R008 — Tests and clean build pass after rename, cleanup, and review-driven changes, using Pinemeter project and scheme names if they are renamed.

- Class: launchability
- Status: active
- Description: Tests and clean build pass after rename, cleanup, and review-driven changes, using Pinemeter project and scheme names if they are renamed.
- Why it matters: The ownership baseline is not useful unless the app remains buildable and testable at the end of M001.
- Source: user
- Primary owning slice: M001/S07
- Supporting slices: M001/S01, M001/S06
- Validation: mapped
- Notes: Required commands: xcodebuild test and xcodebuild clean build with renamed Pinemeter project/scheme names, or documented approved exceptions.

### R009 — Git history squashing and open-source repository hygiene are planned without performing destructive history rewriting or remote pushes.

- Class: operability
- Status: active
- Description: Git history squashing and open-source repository hygiene are planned without performing destructive history rewriting or remote pushes.
- Why it matters: The repository should be prepared to become a pretty public repo while avoiding irreversible local/remote history actions without explicit confirmation.
- Source: user
- Primary owning slice: M001/S07
- Supporting slices: M001/S06
- Validation: mapped
- Notes: Actual history rewrite or push requires fresh explicit approval during execution.

## Validated

### R010 — The app obtains and retains credentials or session material without repeatedly asking the user to provide keys again.

- Class: core-capability
- Status: validated
- Description: The app obtains and retains credentials or session material without repeatedly asking the user to provide keys again.
- Why it matters: A smooth product-owned credential flow is central to making Pinemeter usable beyond manual setup.
- Source: user
- Primary owning slice: M002
- Supporting slices: M001/S02, M001/S03, M002/S05
- Validation: Validated by M002/S05 lifecycle verification: credential acquisition, reuse, repair, clearing, invalid credential handling, and redaction coverage passed in the Debug test suite. Evidence is recorded in `.gsd/milestones/M002/slices/S05/S05-ASSESSMENT.md` from `xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` and the combined signing verification command.
- Notes: M002 delivered durable credential acquisition coverage across credential state, Claude Keychain repair, ChatGPT session acquisition, setup and recovery UX, and lifecycle verification. M002 validation still requires UAT evidence for manual/browser/runtime first-run flows before full milestone closure. Remaining provider-specific workflow polish stays scoped to R011/M003; Gemini monitoring remains R012/M004; open-source polish remains R013/M005; destructive history rewrite and remote push protections remain R014.

## Deferred

### R011 — Setup, status, errors, recovery, and notifications are fully provider-aware across monitored LLM providers.

- Class: failure-visibility
- Status: deferred
- Description: Setup, status, errors, recovery, and notifications are fully provider-aware across monitored LLM providers.
- Why it matters: As Pinemeter monitors more than one provider, workflows must identify the affected provider and next action clearly.
- Source: user
- Primary owning slice: M003
- Supporting slices: M001/S05
- Validation: unmapped
- Notes: M001 audits and fixes obvious stale assumptions; full workflow polish is M003. M002 macvm UAT found the welcome screen still foregrounds manual Claude session key entry; M003 should make app-owned/browser import provider setup the primary path and move raw key entry behind an advanced or recovery affordance if retained.

### R012 — Gemini usage monitoring is added in the same product family as existing Opus and GPT monitoring.

- Class: core-capability
- Status: deferred
- Description: Gemini usage monitoring is added in the same product family as existing Opus and GPT monitoring.
- Why it matters: Gemini expands Pinemeter into the intended multi-LLM monitoring scope.
- Source: user
- Primary owning slice: M004
- Supporting slices: M003
- Validation: unmapped
- Notes: Not Google monitoring generically; specifically Gemini usage monitoring.

### R013 — Public open-source polish is completed, including contribution conventions, issue templates, release-facing documentation, and public presentation details.

- Class: launchability
- Status: deferred
- Description: Public open-source polish is completed, including contribution conventions, issue templates, release-facing documentation, and public presentation details.
- Why it matters: The repo should be attractive and understandable when opened to the public, but this should not distract M001 from ownership and safety foundations.
- Source: user
- Primary owning slice: M005
- Supporting slices: M001/S07
- Validation: unmapped
- Notes: Deferred explicitly from M001.

## Out of Scope

### R014 — Do not perform destructive git history rewriting or remote pushes without fresh explicit confirmation.

- Class: anti-feature
- Status: out-of-scope
- Description: Do not perform destructive git history rewriting or remote pushes without fresh explicit confirmation.
- Why it matters: History rewrite and remote publication are irreversible or outward-facing actions and must remain user-approved.
- Source: inferred
- Primary owning slice: none
- Supporting slices: none
- Validation: n/a
- Notes: M001 may prepare a plan/checklist for squashing but cannot execute it automatically.

### R015 — Do not implement the full durable credential acquisition system during M001.

- Class: anti-feature
- Status: out-of-scope
- Description: Do not implement the full durable credential acquisition system during M001.
- Why it matters: M001 must first inventory and review the credential surface so M002 can implement the right secure flow.
- Source: user
- Primary owning slice: M002
- Supporting slices: M001/S02, M001/S03
- Validation: n/a
- Notes: Immediate safety fixes may still be made if discovered and low-risk.

### R016 — Do not implement Gemini monitoring during M001.

- Class: anti-feature
- Status: out-of-scope
- Description: Do not implement Gemini monitoring during M001.
- Why it matters: Gemini monitoring depends on provider-aware workflow polish and should use established provider/auth/error patterns.
- Source: user
- Primary owning slice: M004
- Supporting slices: M003
- Validation: n/a
- Notes: M001 may preserve future seams but should not add Gemini capability.

### R017 — Do not spend M001 on contribution templates, issue templates, and launch-grade public polish.

- Class: anti-feature
- Status: out-of-scope
- Description: Do not spend M001 on contribution templates, issue templates, and launch-grade public polish.
- Why it matters: Those public presentation details belong after ownership, safety, credential, provider, and Gemini foundations are clearer.
- Source: user
- Primary owning slice: M005
- Supporting slices: none
- Validation: n/a
- Notes: M001 may make repo shape cleaner but public polish is M005.

## Traceability

| ID | Class | Status | Primary owner | Supporting | Proof |
|---|---|---|---|---|---|
| R001 | core-capability | active | M001/S01 | M001/S06, M001/S07 | mapped |
| R002 | quality-attribute | active | M001/S07 | M001/S01, M001/S06 | mapped |
| R003 | compliance/security | active | M001/S02 | M001/S03, M001/S05 | mapped |
| R004 | compliance/security | active | M001/S03 | M001/S02, M001/S07 | mapped |
| R005 | quality-attribute | active | M001/S04 | M001/S06, M001/S07 | mapped |
| R006 | failure-visibility | active | M001/S05 | M001/S02, M001/S03 | mapped |
| R007 | quality-attribute | active | M001/S06 | M001/S01, M001/S04 | mapped |
| R008 | launchability | active | M001/S07 | M001/S01, M001/S06 | mapped |
| R009 | operability | active | M001/S07 | M001/S06 | mapped |
| R010 | core-capability | validated | M002 | M001/S02, M001/S03, M002/S05 | M002/S05 lifecycle verification |
| R011 | failure-visibility | deferred | M003 | M001/S05 | unmapped |
| R012 | core-capability | deferred | M004 | M003 | unmapped |
| R013 | launchability | deferred | M005 | M001/S07 | unmapped |
| R014 | anti-feature | out-of-scope | none | none | n/a |
| R015 | anti-feature | out-of-scope | M002 | M001/S02, M001/S03 | n/a |
| R016 | anti-feature | out-of-scope | M004 | M003 | n/a |
| R017 | anti-feature | out-of-scope | M005 | none | n/a |

## Coverage Summary

- Active requirements: 9
- Mapped to slices: 9
- Validated: 1
- Unmapped active requirements: 0
