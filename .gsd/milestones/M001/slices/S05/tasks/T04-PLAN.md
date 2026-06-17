---
estimated_steps: 15
estimated_files: 4
skills_used: []
---

# T04: Updated public provider positioning and wrote the S05 provider/error workflow assessment with passing audit and focused test verification.

---
skills_used: [verify-before-complete, write-docs]
---
Why: App code already supports optional ChatGPT quota visibility, but README/site copy still presents Pinemeter as Claude-only. S05 also needs a durable assessment for S06/S07/M002/M003 that distinguishes safe copy fixes from deferred provider workflow redesign.

Do:
- Update `README.md` and `site/index.html` to position Pinemeter as primarily Claude.ai usage tracking with optional ChatGPT quota visibility. Do not claim Gemini support, generic provider support, durable credential redesign, or open-source history changes.
- Run the default `scripts/provider_workflow_copy_audit.py` and fix any remaining source/docs copy or logging issues it reports.
- Write `.gsd/milestones/M001/slices/S05/S05-ASSESSMENT.md` with: audited surfaces, changed files, safe fixes applied, security/redaction notes, remaining deferred work, requirement impact for R006/R003/R004, and downstream handoff to S06/S07/M002/M003.
- The assessment should explicitly say S05 did not redesign provider interfaces, Keychain storage, settings credential rehydration, ChatGPT token handling, or git history.

Done when: the audit script passes in default mode, focused Xcode tests pass, and S05-ASSESSMENT.md records the provider/error workflow audit and deferred risks.

Q3 Threat Surface: Public docs must not instruct users to paste secrets into logs/issues and assessment must avoid secret values.
Q4 Requirement Impact: Validates R006 and documents how R003/R004 were preserved.
Q5 Failure Modes: If a copy decision is ambiguous or risky, document it as deferred instead of silently broadening provider claims.
Q6 Load Profile: Static docs/source scan plus focused tests only.
Q7 Negative Tests: Audit script should fail if public docs regress to Claude-only positioning, claim unsupported generic providers, or if source diagnostics reintroduce body/credential logging.

## Inputs

- `scripts/provider_workflow_copy_audit.py`
- `README.md`
- `site/index.html`
- `Pinemeter/Models/Errors/AppError.swift`
- `Pinemeter/Models/Errors/NetworkError.swift`
- `Pinemeter/Models/SessionKey.swift`
- `Pinemeter/Views/MenuBar/UsagePopoverView.swift`
- `Pinemeter/Views/Setup/SetupWizardView.swift`
- `Pinemeter/Views/Settings/SettingsView.swift`
- `Pinemeter/Services/NetworkService.swift`
- `.gsd/milestones/M001/slices/S05/S05-RESEARCH.md`

## Expected Output

- `README.md`
- `site/index.html`
- `scripts/provider_workflow_copy_audit.py`
- `.gsd/milestones/M001/slices/S05/S05-ASSESSMENT.md`

## Verification

python3 scripts/provider_workflow_copy_audit.py && xcodebuild test -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug -only-testing:PinemeterTests/SecurityInvariantTests -only-testing:PinemeterTests/ProviderErrorWorkflowTests -only-testing:PinemeterTests/SessionKeyTests

## Observability Impact

Provides the final documented audit trail and executable copy/logging drift signal for downstream verification.
