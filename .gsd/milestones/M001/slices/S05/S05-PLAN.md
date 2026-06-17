# S05: Provider and error workflow audit

**Goal:** Audit provider-specific setup, status, error, diagnostic, recovery, and public-copy workflows against the S02 credential inventory and S03 security baseline; apply only obvious safe provider-copy and redaction fixes while documenting deferred provider-aware workflow redesign.
**Demo:** After this: stale Claude-only or provider-ambiguous setup, status, error, and recovery messages are identified, and obvious safe copy fixes are applied.

## Must-Haves

- R006 is advanced and validated by a provider/error workflow audit artifact that covers setup, settings, menu bar status/recovery, model errors, provider services, diagnostics/logging, README, and site copy.
- Claude-specific credential failures that currently originate in Claude-only flows use user-facing copy that says "Claude session key" instead of ambiguous generic "session key" where safe.
- ChatGPT copy remains ChatGPT-specific and no M001 change claims generic multi-provider, Gemini, or durable credential support.
- Network diagnostics touched by the slice do not log response bodies, cookies, session keys, Bearer tokens, or credential-shaped fragments.
- Focused XCTest and executable source/docs audit checks pass without reading `.gsd`, `.planning`, `.audits`, `.git`, or other gitignored paths.

## Proof Level

- This slice proves: Executable proof: focused XCTest coverage for provider/error copy and security invariants, plus a repo-local provider workflow audit script that scans only source/docs paths. Artifact proof: S05-ASSESSMENT.md records the audited surfaces, safe fixes, remaining deferred risks, and downstream handoff to S06/S07/M002/M003.

## Integration Closure

The slice closes when source/docs copy changes compile under the Pinemeter Xcode project, provider/security tests pass, the audit script passes against source/docs, and S05-ASSESSMENT.md links findings to R006 with R003/R004 support. No provider abstraction redesign, Keychain migration, credential acquisition redesign, git history rewrite, or remote operation is in scope.

## Verification

- Improves failure observability by making Claude-specific credential failures explicit and by replacing risky response-body diagnostics with redacted status/endpoint/byte-count style signals. Does not introduce production telemetry, secret leak detection, or centralized logging middleware.

## Tasks

- [x] **T01: Added a fixed-allowlist provider workflow copy audit harness for source and public-doc drift checks.** `est:0.5 day`
  ---
  skills_used: [decompose-into-slices, verify-before-complete]
  ---
  Why: S05 needs repeatable evidence that provider/error workflow copy was audited without making tests read `.gsd` artifacts. A lightweight repo-local audit script gives later tasks an executable checklist over source and public docs while allowing the first task to run in report-only mode before fixes land.
  - Files: `scripts/provider_workflow_copy_audit.py`
  - Verify: python3 scripts/provider_workflow_copy_audit.py --report-only

- [x] **T02: Qualified Claude credential errors, setup/settings recovery copy, and popover recovery-button detection with focused regression tests.** `est:1 day`
  ---
  skills_used: [tdd, verify-before-complete]
  ---
  Why: S02/S03 established that the app has both Claude and ChatGPT credential material. Generic `session key` wording in Claude-only setup, error, and recovery paths is now provider-ambiguous and can send users to the wrong recovery workflow.
  - Files: `Pinemeter/Models/Errors/AppError.swift`, `Pinemeter/Models/Errors/NetworkError.swift`, `Pinemeter/Models/SessionKey.swift`, `Pinemeter/Views/MenuBar/UsagePopoverView.swift`, `Pinemeter/Views/Setup/SetupWizardView.swift`, `Pinemeter/Views/Settings/SettingsView.swift`, `PinemeterTests/ProviderErrorWorkflowTests.swift`, `PinemeterTests/SessionKeyTests.swift`
  - Verify: xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/ProviderErrorWorkflowTests -only-testing:PinemeterTests/SessionKeyTests

- [x] **T03: Redacted NetworkService HTTP and decode failure diagnostics while adding a source-level security invariant against response-body and credential-fragment logging.** `est:0.5 day`
  ---
  skills_used: [tdd, verify-before-complete]
  ---
  Why: S03 flagged future diagnostics/request dumps as credential-sensitive, and S05 research found `NetworkService` logs full HTTP/decode response bodies. Even if current Claude response bodies are not known secrets, provider/error workflow diagnostics should not normalize body logging around credential-authenticated endpoints.
  - Files: `Pinemeter/Services/NetworkService.swift`, `PinemeterTests/SecurityInvariantTests.swift`
  - Verify: xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests -only-testing:PinemeterTests/ProviderErrorWorkflowTests

- [x] **T04: Updated public provider positioning and wrote the S05 provider/error workflow assessment with passing audit and focused test verification.** `est:0.5 day`
  ---
  skills_used: [verify-before-complete, write-docs]
  ---
  Why: App code already supports optional ChatGPT quota visibility, but README/site copy still presents Pinemeter as Claude-only. S05 also needs a durable assessment for S06/S07/M002/M003 that distinguishes safe copy fixes from deferred provider workflow redesign.
  - Files: `README.md`, `site/index.html`, `scripts/provider_workflow_copy_audit.py`, `.gsd/milestones/M001/slices/S05/S05-ASSESSMENT.md`
  - Verify: python3 scripts/provider_workflow_copy_audit.py && xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests -only-testing:PinemeterTests/ProviderErrorWorkflowTests -only-testing:PinemeterTests/SessionKeyTests

## Files Likely Touched

- scripts/provider_workflow_copy_audit.py
- Pinemeter/Models/Errors/AppError.swift
- Pinemeter/Models/Errors/NetworkError.swift
- Pinemeter/Models/SessionKey.swift
- Pinemeter/Views/MenuBar/UsagePopoverView.swift
- Pinemeter/Views/Setup/SetupWizardView.swift
- Pinemeter/Views/Settings/SettingsView.swift
- PinemeterTests/ProviderErrorWorkflowTests.swift
- PinemeterTests/SessionKeyTests.swift
- Pinemeter/Services/NetworkService.swift
- PinemeterTests/SecurityInvariantTests.swift
- README.md
- site/index.html
- .gsd/milestones/M001/slices/S05/S05-ASSESSMENT.md
