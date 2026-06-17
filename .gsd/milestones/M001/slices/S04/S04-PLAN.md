# S04: Architecture review baseline

**Goal:** Produce a concise architecture review baseline for Pinemeter that ranks current architecture risks, compares provider-boundary options, and gives downstream S05/S06 concrete recommendations without changing app code.
**Demo:** After this: a ranked architecture review, using Opus if available, identifies provider, service, repository, app-state, settings, and error-handling risks.

## Must-Haves

- Architecture review artifact captures current boundaries around AppModel, services/repositories, settings persistence, credentials, provider workflows, and error/observability surfaces.
- Provider-boundary alternatives are compared with a recommendation and explicit tradeoffs.
- Ranked findings identify what to fix now, defer, or hand to later milestones.
- No production source changes are required for this slice unless the review uncovers a plan-invalidating issue.

## Proof Level

- This slice proves: Artifact review plus repository evidence references; no app build required unless source code is changed.

## Integration Closure

Downstream S05 consumes provider/error workflow findings; S06 consumes cleanup/refactor seams. S04 itself closes with durable review artifacts and decisions only.

## Verification

- Adds architecture findings that call out diagnostic/error-state gaps; no runtime observability code is changed in this slice.

## Tasks

- [x] **T01: Mapped current Pinemeter architecture boundaries for AppModel, provider services, settings persistence, credentials, and setup/settings views.** `est:30m`
  Read existing S04 research plus targeted code surfaces to summarize current AppModel, service, repository, settings, credential, and provider workflow boundaries. Produce a concise architecture map for the review artifact.
  - Files: `.gsd/milestones/M001/slices/S04/S04-RESEARCH.md`, `ClaudeMeter/App/AppModel.swift`, `ClaudeMeter/Services`, `ClaudeMeter/Repositories`, `ClaudeMeter/Models/AppSettings.swift`
  - Verify: Review artifact section exists and cites the inspected source surfaces; no source files modified.

- [x] **T02: Compared three provider-boundary alternatives and recommended avoiding a universal provider protocol for now.** `est:30m`
  Use design-it-twice style comparison for at least three approaches: keep provider-specific services with AppModel orchestration, introduce a common provider abstraction, or add a provider coordinator while keeping service APIs separate. Recommend the smallest safe next step.
  - Files: `.gsd/milestones/M001/slices/S04/S04-ARCHITECTURE-REVIEW.md`
  - Verify: Review artifact contains alternatives, tradeoffs, recommendation, and rejected options.

- [x] **T03: Ranked architecture findings and created downstream handoffs for S05, S06, M002, and later provider milestones.** `est:30m`
  Create a ranked finding list with severity, affected files, recommended disposition, and downstream owner slice or milestone. Include credential compatibility and redaction invariants from prior S03 memory.
  - Files: `.gsd/milestones/M001/slices/S04/S04-ARCHITECTURE-REVIEW.md`
  - Verify: Review artifact has ranked findings and downstream handoff table for S05/S06/M002.

## Files Likely Touched

- .gsd/milestones/M001/slices/S04/S04-RESEARCH.md
- ClaudeMeter/App/AppModel.swift
- ClaudeMeter/Services
- ClaudeMeter/Repositories
- ClaudeMeter/Models/AppSettings.swift
- .gsd/milestones/M001/slices/S04/S04-ARCHITECTURE-REVIEW.md
