---
id: T01
parent: S02
milestone: M005
key_files:
  - .github/ISSUE_TEMPLATE/bug_report.yml
  - .github/ISSUE_TEMPLATE/bug_report.md
  - .github/ISSUE_TEMPLATE/feature_request.yml
  - .github/ISSUE_TEMPLATE/feature_request.md
  - .github/ISSUE_TEMPLATE/config.yml
  - CONTRIBUTING.md
  - SECURITY.md
  - README.md
  - AGENTS.md
key_decisions:
  - Preserved the existing dual YAML and Markdown issue-template setup because it supports GitHub issue forms while keeping portable checklist links from README/CONTRIBUTING.
  - Preserved SECURITY.md plus issue-template contact links as the private path for credential handling, privacy, and vulnerability reports instead of creating a public security issue template.
duration: 
verification_result: passed
completed_at: 2026-07-01T21:53:17.197Z
blocker_discovered: false
---

# T01: Confirmed the local contributor guidance, bug and feature issue forms, and private security/privacy reporting guidance are present and aligned for sanitized public collaboration.

**Confirmed the local contributor guidance, bug and feature issue forms, and private security/privacy reporting guidance are present and aligned for sanitized public collaboration.**

## What Happened

Inspected the active worktree's contributor and support surfaces. The smallest useful local set was already present: GitHub issue-form YAML files for structured public bug and feature intake, Markdown equivalents for portable checklist-style references, issue-template contact links that disable blank public issues and route security/privacy concerns privately, plus repository-level CONTRIBUTING.md, SECURITY.md, README.md, and AGENTS.md guidance. I did not create duplicate templates or change GitHub state because the existing files already satisfy the slice contract without leaking private process details.

## Verification

Ran a read-only Python verification via gsd_exec that required the expected template and guidance files to exist and checked for core safety/diagnostic language: sanitized diagnostics and safety checklist in the bug form, privacy and credential impact in the feature form, private security advisory routing in config.yml, bug/feature/security guidance in CONTRIBUTING.md and README.md, private-reporting scope in SECURITY.md, and project build/secrets rules in AGENTS.md. The command exited 0.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---------|-----------|---------|----------|
| 1 | `python3 - <<'PY'
from pathlib import Path
required = [
    Path('.github/ISSUE_TEMPLATE/bug_report.yml'),
    Path('.github/ISSUE_TEMPLATE/bug_report.md'),
    Path('.github/ISSUE_TEMPLATE/feature_request.yml'),
    Path('.github/ISSUE_TEMPLATE/feature_request.md'),
    Path('.github/ISSUE_TEMPLATE/config.yml'),
    Path('CONTRIBUTING.md'),
    Path('SECURITY.md'),
    Path('README.md'),
    Path('AGENTS.md'),
]
missing = [str(p) for p in required if not p.exists()]
if missing:
    raise SystemExit('missing required files: ' + ', '.join(missing))
checks = {
    '.github/ISSUE_TEMPLATE/bug_report.yml': ['Sanitized diagnostics', 'Safety checklist', 'SECURITY.md', 'Claude session keys', 'ChatGPT cookies', 'Gemini API keys'],
    '.github/ISSUE_TEMPLATE/feature_request.yml': ['User problem', 'Privacy and credential impact', 'I searched for existing issues'],
    '.github/ISSUE_TEMPLATE/config.yml': ['blank_issues_enabled: false', 'Security or privacy report', 'security/advisories/new'],
    'CONTRIBUTING.md': ['Reporting bugs', 'Requesting features', 'SECURITY.md', 'xcodebuild test'],
    'SECURITY.md': ['Security and Privacy Reporting', 'What to report privately', 'What not to include'],
    'README.md': ['Support and Contributing', 'Markdown bug checklist', 'SECURITY.md', 'Do not open public issues containing session keys'],
    'AGENTS.md': ['Build with `xcodebuild clean build', 'Secrets', 'AWS SSM Parameter Store'],
}
failures = []
for file, needles in checks.items():
    text = Path(file).read_text()
    for needle in needles:
        if needle not in text:
            failures.append(f'{file}: missing {needle!r}')
if failures:
    raise SystemExit('\n'.join(failures))
print('verified contributor template set:')
for p in required:
    print(f'- {p}')
PY` | 0 | ✅ pass | 67ms |

## Deviations

No file edits were needed because the active worktree already contained the planned contributor template and support path set.

## Known Issues

None.

## Files Created/Modified

- `.github/ISSUE_TEMPLATE/bug_report.yml`
- `.github/ISSUE_TEMPLATE/bug_report.md`
- `.github/ISSUE_TEMPLATE/feature_request.yml`
- `.github/ISSUE_TEMPLATE/feature_request.md`
- `.github/ISSUE_TEMPLATE/config.yml`
- `CONTRIBUTING.md`
- `SECURITY.md`
- `README.md`
- `AGENTS.md`
