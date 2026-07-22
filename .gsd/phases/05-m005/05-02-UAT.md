# S02: Contributor templates and support paths — UAT

**Milestone:** M005
**Written:** 2026-07-01T21:59:30.745Z

# S02: Contributor templates and support paths — UAT

**Milestone:** M005
**Written:** 2026-07-01

## UAT Type

- UAT mode: artifact-driven
- Why this mode is sufficient: This slice ships repository documentation and templates only; no runtime app behavior, browser UI, server, or external GitHub state is required to evaluate it.

## Preconditions

- Worktree contains the public collaboration files under `.github/ISSUE_TEMPLATE/`, `CONTRIBUTING.md`, `README.md`, and `SECURITY.md`.
- Tester reviews files locally only and does not create remote issues, push branches, or edit GitHub settings.

## Smoke Test

Open `README.md` and `CONTRIBUTING.md`; confirm a new contributor can find how to contribute, how to report bugs/features, and where to send sensitive security or privacy concerns.

## Test Cases

### 1. Bug report guidance collects sanitized diagnostics

1. Open `.github/ISSUE_TEMPLATE/bug_report.md`.
2. Confirm it asks for Pinemeter version, macOS version, affected provider or area, setup path, expected behavior, actual behavior, reproduction steps, and sanitized provider state.
3. Confirm it warns not to include session values, cookies, tokens, API keys, request headers, account identifiers, or raw provider responses.
4. **Expected:** A contributor can file an actionable bug report without exposing credential-equivalent material.

### 2. Feature request guidance handles privacy and provider impact

1. Open `.github/ISSUE_TEMPLATE/feature_request.md`.
2. Confirm it asks for the problem, proposed behavior, affected provider or app area, and privacy/credential impact.
3. Confirm optional context is explicitly sanitized.
4. **Expected:** Feature requests include enough scope and safety context without promising unsupported provider behavior.

### 3. Contributor guide explains local verification and conventions

1. Open `CONTRIBUTING.md`.
2. Confirm it includes the project build command and test command for `Pinemeter.xcodeproj`.
3. Confirm it mentions keeping SwiftUI UI state on `@MainActor @Observable` types and non-UI work in actor services/repositories.
4. Confirm it tells contributors not to paste secrets or credential material.
5. **Expected:** A fresh contributor can understand local verification expectations and coding boundaries.

### 4. Sensitive reports route privately

1. Open `.github/ISSUE_TEMPLATE/config.yml` and `SECURITY.md`.
2. Confirm security, privacy, and credential concerns are directed to a private reporting path rather than a public issue template.
3. **Expected:** Sensitive reports have a clear private support boundary.

## Edge Cases

### Stale or private process wording

1. Search public templates and contribution docs for stale `ClaudeMeter` naming, private GSD process names, destructive git commands, and prompts asking users to paste secrets.
2. **Expected:** Any ClaudeMeter reference is limited to legacy compatibility documentation, no private GSD process leaks appear, no destructive git publishing/history rewrite instructions appear, and templates only request sanitized or redacted diagnostics.

## Failure Signals

- Missing bug or feature issue templates.
- CONTRIBUTING lacks build/test commands or coding conventions.
- README does not point to contribution or reporting paths.
- Public templates ask users to paste tokens, cookies, session keys, API keys, raw headers, or account identifiers.
- Security/privacy concerns are routed to public issues instead of private reporting.

## Not Proven By This UAT

- It does not prove the full Xcode build or test suite passes.
- It does not prove GitHub renders YAML issue forms exactly as intended.
- It does not prove later release/signing documentation, which is covered by S03.

## Notes for Tester

Legacy `ClaudeMeter` references may appear only when documenting compatibility paths such as `~/.claudemeter/usage.json`; those are not stale project branding if they are explicitly framed as legacy compatibility.
