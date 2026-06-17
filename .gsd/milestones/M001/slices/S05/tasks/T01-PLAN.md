---
estimated_steps: 16
estimated_files: 1
skills_used: []
---

# T01: Added a fixed-allowlist provider workflow copy audit harness for source and public-doc drift checks.

---
skills_used: [decompose-into-slices, verify-before-complete]
---
Why: S05 needs repeatable evidence that provider/error workflow copy was audited without making tests read `.gsd` artifacts. A lightweight repo-local audit script gives later tasks an executable checklist over source and public docs while allowing the first task to run in report-only mode before fixes land.

Do:
- Create `scripts/provider_workflow_copy_audit.py`.
- Make the script read only explicit source/docs files under `Pinemeter/`, `PinemeterTests/`, `README.md`, and `site/index.html`; it must not traverse or read `.gsd`, `.git`, `.planning`, `.audits`, derived data, caches, or other ignored paths.
- In `--report-only` mode, print categorized findings and exit 0 for current stale/ambiguous provider copy.
- In default mode, fail on the final desired invariants: Claude-only credential messages should say `Claude session key`, ChatGPT copy should remain ChatGPT-specific, public docs should mention optional ChatGPT quota visibility without claiming generic providers, and `NetworkService` should not log full response bodies.
- Keep output concise enough for task summaries.

Done when: `--report-only` executes successfully and lists the current S05 categories that later tasks will fix.

Q3 Threat Surface: The script must never print credential values and should scan only code/docs, not runtime stores.
Q4 Requirement Impact: Establishes executable support for R006 and protects R003/R004 by checking copy/redaction invariants.
Q5 Failure Modes: If path assumptions are wrong, fail with a clear missing-file message naming the relative path.
Q6 Load Profile: Small static scan over a fixed file list; no network or Xcode build.
Q7 Negative Tests: Default mode should be capable of failing on intentionally stale phrases or response-body logging, but this task verifies report-only mode because fixes are not landed yet.

## Inputs

- `Pinemeter/Models/Errors/AppError.swift`
- `Pinemeter/Models/Errors/NetworkError.swift`
- `Pinemeter/Models/SessionKey.swift`
- `Pinemeter/Views/MenuBar/UsagePopoverView.swift`
- `Pinemeter/Views/Setup/SetupWizardView.swift`
- `Pinemeter/Views/Settings/SettingsView.swift`
- `Pinemeter/Services/NetworkService.swift`
- `Pinemeter/Services/UsageService.swift`
- `Pinemeter/Services/ChatGPTUsageService.swift`
- `README.md`
- `site/index.html`

## Expected Output

- `scripts/provider_workflow_copy_audit.py`

## Verification

python3 scripts/provider_workflow_copy_audit.py --report-only

## Observability Impact

Adds a repeatable local signal for provider/error copy drift without touching runtime logging.
