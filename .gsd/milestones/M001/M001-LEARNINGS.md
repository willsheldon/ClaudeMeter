---
phase: M001
phase_name: Ownership safety and review baseline
project: Pinemeter
generated: 2026-06-17T17:55:19Z
counts:
  decisions: 5
  lessons: 5
  patterns: 4
  surprises: 3
missing_artifacts: []
---

# M001 Learnings: Ownership safety and review baseline

### Decisions

- Comprehensive identity ownership was the right M001 boundary: Pinemeter now owns the app/project/scheme/module/source/test/docs/site identity wherever feasible, while compatibility-sensitive identifiers were classified instead of blindly renamed.
  Source: S01-SUMMARY.md/What Happened

- Durable credential acquisition was intentionally deferred: M001 produced inventory, security review, and invariants, while M002 remains responsible for safer app-owned acquisition, fallback migration, and replace-not-display flows.
  Source: S02-SUMMARY.md/Follow-ups

- Architecture review could proceed as an artifact-backed local baseline when external advisor capacity was unavailable, as long as findings were ranked and handed to cleanup/provider-boundary work.
  Source: M001-VALIDATION.md/Success Criteria Checklist

- Destructive git history and publication actions require fresh human approval: M001 produced a plan and explicitly avoided filter-repo, reset, remote pushes, releases, site deployment, repository creation, and secret-store mutation.
  Source: M001-VALIDATION.md/Success Criteria Checklist

- Public ownership readiness should be sequenced after safety and verification: M001 validated ownership/review baseline, leaving durable credentials, provider-aware workflows, Gemini monitoring, and launch-grade public polish for later milestones.
  Source: PROJECT.md/Milestone Sequence

### Lessons

- Retained `claudemeter` Keychain/cache/export/access-group identifiers are compatibility surfaces, not failed rename work; changing them without migration could orphan existing user credentials or usage state.
  Source: S01-SUMMARY.md/Known limitations

- Credential risk is not limited to durable settings persistence: M001 established that SettingsRepository remains preference-only, while risk remains in transient UI/app state, Keychain, WebView cookies, ChatGPT session material, and diagnostics.
  Source: S03-SUMMARY.md/What Happened

- Provider/error copy can safely improve before full provider redesign when changes are narrow, source-reviewed, and covered by focused XCTest evidence.
  Source: M001-VALIDATION.md/Success Criteria Checklist

- Cleanup work must preserve compatibility and security invariants; S06 proved stale ownership cleanup with cache/export compatibility, credential invariants, settings clamp behavior, provider copy, session keys, and redacted diagnostics.
  Source: M001-VALIDATION.md/Success Criteria Checklist

- A passing milestone validation still needs current closeout freshness checks: code-change diff evidence, slice completion status, summaries, and requirement transitions were rechecked before marking M001 complete.
  Source: M001-VALIDATION.md/Verdict Rationale

### Patterns

- Use build-critical rename first, then classify residual old-identity references as compatibility, history, or release-planning exceptions before downstream inventory and review.
  Source: S01-SUMMARY.md/Patterns established

- Credential inventory tables should map account/material/writer/readers/clearer/service attributes so security review and migration planning can proceed without rediscovery.
  Source: S02-SUMMARY.md/Patterns established

- Cross-slice review baselines should produce ranked findings plus executable invariants; later cleanup slices can then make safe fixes without widening scope.
  Source: M001-VALIDATION.md/Cross-Slice Integration

- Non-destructive public-readiness planning should explicitly list forbidden actions alongside the plan so automatic agents do not rewrite history, push remotes, publish releases, or mutate secrets.
  Source: M001-VALIDATION.md/Success Criteria Checklist

### Surprises

- Some of the most important remaining old names are deliberately correct because they preserve existing user data and credentials rather than indicating missed search-and-replace work.
  Source: S01-SUMMARY.md/Deviations

- The initial app ownership milestone surfaced enough credential and provider workflow risk to split durable credentials, provider-aware UX, and Gemini support into separate later milestones.
  Source: PROJECT.md/Milestone Sequence

- A mostly artifact-based milestone still required executable proof for safety-sensitive cleanup and provider/error changes, not just narrative review reports.
  Source: M001-VALIDATION.md/Verification Class Compliance
