---
estimated_steps: 12
estimated_files: 12
skills_used: []
---

# T02: Classify final identity and hygiene scan findings

---
skills_used:
  - verify-before-complete
---
Why: S07 must prove remaining old names and public-readiness gaps are understood rather than accidentally shipping active ClaudeMeter identity or secret-shaped content.

Do: Run concise gsd_exec scans for remaining `ClaudeMeter`, `claudemeter`, `CLAUDEMETER`, and `Claude Meter` references excluding `.git`, `.gsd/exec`, and build artifacts. Run a public hygiene inventory for README, LICENSE, SECURITY, CONTRIBUTING, CODE_OF_CONDUCT, changelog, Dependabot, issue templates, and PR template. Run a secret-shaped content scan over public/source/test surfaces that reports only paths and classes, not secret values. Classify every relevant finding into compatibility, historical attribution, operational secret path, pending public URL/distribution decision, expected provider/session/security code surface, missing public-hygiene file, or active defect. Do not rename legacy Keychain/cache/access-group/SSM identifiers in this task.

Done when: `.gsd/milestones/M001/slices/S07/S07-FINAL-AUDIT.md` exists with scan evidence IDs, remaining-reference classification, public hygiene inventory, secret-shaped scan summary, and explicit no-source-change or source-change notes.

Q3 Threat Surface: Secret-shaped scans must never dump token, cookie, password, or session values; summarize only file paths, line categories, and rationale.
Q4 Requirement Impact: Supports R001 closure and R009 planning; reinforces R004 security baseline without changing credential handling.
Q5 Failure Modes: An unclassified active identity reference, real secret, or unexpected public URL claim should become a blocker or explicitly deferred finding.
Q6 Load Profile: Repository scans are lightweight but should avoid ignored/generated paths.
Q7 Negative Tests: The audit must include a section for unexpected findings even if empty, so absence is explicit.

## Inputs

- `README.md`
- `LICENSE`
- `CHANGELOG.md`
- `site/index.html`
- `.github/workflows/test.yml`
- `.github/workflows/release.yml`
- `.github/workflows/deploy-pages.yml`
- `scripts/provider_workflow_copy_audit.py`
- `Pinemeter`
- `PinemeterTests`
- `work-to-date.md`
- `.gsd/milestones/M001/slices/S01/S01-ASSESSMENT.md`
- `.gsd/milestones/M001/slices/S03/S03-ASSESSMENT.md`
- `.gsd/milestones/M001/slices/S06/S06-ASSESSMENT.md`

## Expected Output

- `.gsd/milestones/M001/slices/S07/S07-FINAL-AUDIT.md`

## Verification

test -f .gsd/milestones/M001/slices/S07/S07-FINAL-AUDIT.md

## Observability Impact

Creates a durable final audit table that separates safe compatibility/history exceptions from actionable release blockers.
