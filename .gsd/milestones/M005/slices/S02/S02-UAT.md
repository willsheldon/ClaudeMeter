# S02: Contributor templates and support paths — UAT

**Milestone:** M005
**Written:** 2026-07-01T18:20:36.097Z

# S02: Contributor templates and support paths — UAT

**Milestone:** M005
**Written:** 2026-07-01

## UAT Type

- UAT mode: artifact-driven
- Why this mode is sufficient: This slice changes repository documentation and GitHub issue/support templates only; no app runtime, browser UI, server, or local build execution is required to prove the contributor support contract.

## Preconditions

- Review from the repository root of the M005 worktree.
- No GitHub remote actions are required; inspect local files only.
- Treat real provider credentials, cookies, tokens, API keys, request headers, account identifiers, and workspace names as sensitive and do not paste them into any template.

## Smoke Test

Open `README.md`, `CONTRIBUTING.md`, `SECURITY.md`, `.github/ISSUE_TEMPLATE/bug_report.yml`, `.github/ISSUE_TEMPLATE/feature_request.yml`, `.github/ISSUE_TEMPLATE/bug_report.md`, and `.github/ISSUE_TEMPLATE/feature_request.md`. Confirm a new contributor can find contribution guidance, public bug/feature reporting paths, and a private path for credential, privacy, or vulnerability concerns.

## Test Cases

### 1. Bug reporter can submit a useful sanitized report

1. Open `.github/ISSUE_TEMPLATE/bug_report.yml` or `.github/ISSUE_TEMPLATE/bug_report.md`.
2. Follow the prompts as a reporter with a provider-specific issue.
3. **Expected:** The template asks for Pinemeter version or commit, macOS details, affected provider, setup path, expected behavior, actual behavior, reproduction steps, and sanitized logs or screenshots with secrets removed.

### 2. Feature requester sees privacy and credential impact prompts

1. Open `.github/ISSUE_TEMPLATE/feature_request.yml` or `.github/ISSUE_TEMPLATE/feature_request.md`.
2. Draft a feature request for a provider integration or workflow change.
3. **Expected:** The template asks for the user problem, proposed behavior, alternatives or workarounds, and privacy/security or credential/session impact without asking for sensitive values.

### 3. Contributor can find local build and test guidance

1. Open `CONTRIBUTING.md`.
2. Review the code contribution section and useful local commands.
3. **Expected:** The guide describes Pinemeter coding conventions, secret handling, the Debug build command, and the local xcodebuild test command.

### 4. Sensitive reports are routed away from public issues

1. Open `SECURITY.md` and `.github/ISSUE_TEMPLATE/config.yml`.
2. Follow the reporting guidance for a credential, privacy, or vulnerability concern.
3. **Expected:** The docs direct the reporter to private vulnerability reporting or the documented fallback path and warn against sending real secrets in public issues.

## Edge Cases

### Portable template fallback

1. Ignore GitHub YAML issue forms and use only the Markdown checklists in `.github/ISSUE_TEMPLATE/bug_report.md` and `.github/ISSUE_TEMPLATE/feature_request.md`.
2. **Expected:** The Markdown templates still collect the same sanitized diagnostic or feature-impact details for contributors using non-GitHub tooling or copying checklists manually.

### Legacy or private process leakage

1. Search the public templates and support docs for stale project names, GSD process details, or destructive git instructions.
2. **Expected:** Public issue/support guidance does not expose private GSD workflow, does not ask users to push, rewrite history, or perform remote-side actions, and does not contain stale ClaudeMeter branding in the support templates.

## Failure Signals

- Required issue template files are missing from `.github/ISSUE_TEMPLATE`.
- Bug templates omit provider, setup state, macOS/app version, expected/actual behavior, or sanitized diagnostics.
- Feature templates omit privacy/security or credential impact prompts.
- Public templates ask users to paste real secrets, cookies, tokens, session identifiers, request headers, or raw provider responses.
- Contributor docs omit local build/test commands or secret-handling guidance.
- Security/privacy concerns are routed to public issues instead of private reporting guidance.

## Not Proven By This UAT

- GitHub-hosted issue form rendering after repository settings or GitHub product changes.
- Whether private vulnerability reporting is enabled in the eventual public repository; `SECURITY.md` documents a fallback path.
- App runtime behavior, provider authentication, release signing, and fresh-reader end-to-end build/test success; later slices cover release documentation and fresh-reader public UAT.

## Notes for Tester

The README intentionally may mention legacy ClaudeMeter compatibility in product history or migration context. Treat that as acceptable product documentation, but do not accept stale ClaudeMeter branding or private GSD process language in the public issue templates and support guidance.

