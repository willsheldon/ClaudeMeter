# S02: Contributor templates and support paths

**Goal:** Add local repository templates for useful public collaboration.
**Demo:** Contributors see clear issue templates, contribution guidance, and support boundaries with no private process leakage.

## Must-Haves

- Contribution guidance explains build/test commands, coding conventions, and secret handling.
- Issue templates collect provider, macOS, app version, setup state, and sanitized diagnostic details.
- Templates do not expose private GSD process, secrets, or unsupported promises.

## Proof Level

- This slice proves: contract

## Integration Closure

.github templates, CONTRIBUTING-style docs, README links, and support guidance are consistent.

## Verification

- Improves quality of external bug reports through structured diagnostic prompts.

<tasks>
- [x] **T01**: Confirmed the local contributor guidance, bug and feature issue forms, and private security/privacy reporting guidance are present and aligned for sanitized public collaboration. _(small)_
  Inspect existing GitHub configuration and decide the smallest useful set of local contribution/support templates: contribution guide, bug report, feature request, and security or privacy report if appropriate.
  - Files: `.github`, `README.md`, `AGENTS.md`
  - Verify: Task summary records chosen template files and rationale without creating remote issues or changing GitHub state.
- [x] **T02**: Added and verified public contributor guidance plus portable Markdown bug and feature templates for sanitized Pinemeter reporting. _(medium)_
  Create local template files that ask for sanitized provider state, macOS version, app version, setup path, expected behavior, actual behavior, and logs or screenshots with secrets removed. Link them from README where appropriate.
  - Files: `.github/ISSUE_TEMPLATE/bug_report.md`, `.github/ISSUE_TEMPLATE/feature_request.md`, `CONTRIBUTING.md`, `README.md`
  - Verify: `find .github -maxdepth 3 -type f | sort` and `rg -n "secret|token|cookie|session|provider|xcodebuild|Pinemeter" .github CONTRIBUTING.md README.md` reviewed for safe wording.
- [x] **T03**: Verified the public issue templates and contributor guidance remain Pinemeter-focused, sanitized, and non-destructive without requiring source changes. _(small)_
  Review templates for stale names, private process leakage, unsupported promises, and destructive-action suggestions. Fix inconsistencies and record verification evidence.
  - Files: `.github/ISSUE_TEMPLATE/bug_report.md`, `.github/ISSUE_TEMPLATE/feature_request.md`, `CONTRIBUTING.md`, `README.md`
  - Verify: `rg -n "ClaudeMeter|GSD|secret|token|cookie|push|rewrite|Pinemeter" .github/ISSUE_TEMPLATE CONTRIBUTING.md README.md` reviewed; no template asks users to paste secrets.
</tasks>

## Files Likely Touched

- .github
- README.md
- AGENTS.md
- .github/ISSUE_TEMPLATE/bug_report.md
- .github/ISSUE_TEMPLATE/feature_request.md
- CONTRIBUTING.md
