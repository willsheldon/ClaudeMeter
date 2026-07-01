# S04 UAT: Fresh-reader public readiness

## Purpose

This checklist is for a fresh outside contributor starting from the repository root with only public repository files. It verifies that Pinemeter can be understood, built, tested, evaluated for provider setup/privacy boundaries, and reported on safely without relying on private GSD process, local secrets, or maintainer-only context.

## Scope and Public Inputs

Use only these public files and paths:

- `README.md`
- `CONTRIBUTING.md`
- `SECURITY.md`
- `RELEASING.md`
- `.github/ISSUE_TEMPLATE/bug_report.md`
- `.github/ISSUE_TEMPLATE/feature_request.md`
- `Pinemeter.xcodeproj`
- Public source and test files in the repository

Do not use `.gsd/` files, private notes, local credentials, unpublished release secrets, or maintainer-only process knowledge while performing the human fresh-reader pass.

## Automated Artifact Checks

These checks are safe for an agent or contributor to run from the repository root. They inspect public files only and do not build, sign, publish, mutate remote state, or read local secrets.

| ID | Check | How to verify | Expected result |
|---|---|---|---|
| A01 | README describes what Pinemeter is and names supported providers. | Read `README.md` sections `Features`, `Provider Setup`, and `Requirements`. | Claude is the primary provider; ChatGPT and Gemini are optional visibility providers. |
| A02 | README exposes local build and test commands. | Read `README.md` section `Building from Source`. | Includes `xcodebuild clean build -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` and a test command with code signing disabled for CI-style tests. |
| A03 | README explains privacy and credential storage. | Read `README.md` `Disclaimer` and `Data storage` bullets. | Credential/session material is described as Keychain-backed or transient where applicable; diagnostics avoid raw credentials. |
| A04 | README links support and contribution paths. | Read `README.md` `Support and Contributing`. | Links to `CONTRIBUTING.md`, `SECURITY.md`, and issue templates. |
| A05 | CONTRIBUTING tells contributors how to report bugs safely. | Read `CONTRIBUTING.md` `Before opening an issue` and `Reporting bugs`. | It asks for version, macOS, provider/setup path, expected/actual behavior, repro steps, sanitized state, and redacted logs/screenshots. |
| A06 | Issue templates discourage credential disclosure. | Read `.github/ISSUE_TEMPLATE/bug_report.md` and `.github/ISSUE_TEMPLATE/feature_request.md`. | Both templates warn against session keys, cookies, API keys, headers, tokens, account identifiers, or raw provider responses. |
| A07 | SECURITY gives a private vulnerability path. | Read `SECURITY.md`. | Credential/privacy/vulnerability reports are directed away from public issues and ask for sanitized details only. |
| A08 | Release docs preserve signing invariants. | Read `RELEASING.md` and `README.md` `Release signing and publishing safety`. | Both name `Developer ID Application: AUTIMO SYSTEMS INC (HMR9RDR6M2)` and `TeamIdentifier=HMR9RDR6M2`. |
| A09 | Release docs separate safe local checks from publishing. | Read `RELEASING.md` `Non-destructive local verification` and `Publishing and remote mutation boundaries`. | Safe checks read local files/artifacts only; workflow dispatch, notarization, releases, tap edits, pushes, tags, and history rewriting require explicit maintainer confirmation. |
| A10 | Public docs avoid stale ClaudeMeter positioning. | Search public docs for `ClaudeMeter` and review each occurrence. | Remaining references, if any, are limited to compatibility/history wording such as legacy export paths, not product identity or contributor instructions. |

## Human Fresh-reader Checks

Ask someone who has not participated in this milestone to start at the repository root and answer each prompt using public files only.

| ID | Prompt | Pass condition |
|---|---|---|
| H01 | In one sentence, what is Pinemeter? | Reader identifies it as a macOS menu bar app for Claude usage visibility with optional ChatGPT/Gemini status. |
| H02 | What macOS and toolchain do you need? | Reader finds macOS 14+ and Xcode 16+ requirements. |
| H03 | How would you build from source? | Reader finds the `xcodebuild clean build -project Pinemeter.xcodeproj -scheme Pinemeter -configuration Debug` command. |
| H04 | How would you run tests without requiring a local signing identity? | Reader finds the `xcodebuild test` command with `CODE_SIGN_IDENTITY="-"`, `CODE_SIGNING_REQUIRED=NO`, and `CODE_SIGNING_ALLOWED=NO`. |
| H05 | How do Claude, ChatGPT, and Gemini setup differ? | Reader understands Claude is required through browser import/manual session, ChatGPT is optional browser-session visibility, and Gemini is optional API-key visibility. |
| H06 | What should you never paste into a public issue? | Reader lists provider session keys, cookies, tokens, API keys, Cookie/Authorization headers, account identifiers, raw provider responses, and unredacted screenshots/logs. |
| H07 | Where should credential leakage, privacy, or vulnerability concerns go? | Reader chooses `SECURITY.md` or GitHub private vulnerability reporting, not a public issue. |
| H08 | What should a useful bug report include? | Reader finds version/commit, macOS/architecture, provider/area, setup path, expected/actual behavior, repro steps, sanitized provider state, and redacted logs/screenshots. |
| H09 | What should a feature request include? | Reader finds user problem, area, proposed behavior, expected benefit, alternatives, sanitized provider/setup context, and privacy/credential impact. |
| H10 | What release signing identity is safe? | Reader names `Developer ID Application: AUTIMO SYSTEMS INC (HMR9RDR6M2)` and `TeamIdentifier=HMR9RDR6M2`. |
| H11 | Which release actions require explicit maintainer confirmation? | Reader identifies publishing/remote mutation actions: workflow dispatch, notarization submission, GitHub release creation, Homebrew tap edits, `git push`, tag changes, `gh release`, or history rewriting. |
| H12 | What support boundaries should users understand before relying on Pinemeter? | Reader finds the unofficial-tool disclaimer, provider ToS/access risk, use-at-your-own-risk warranty boundary, and no third-party data collection claim. |

## Provider Setup Review

A fresh reader should be able to describe setup without exposing credentials:

- Claude: sign in at `claude.ai`, use supported browser import when possible, or manually paste a `sk-ant-...` session key / `sessionKey=...` cookie header into the app only.
- ChatGPT: optional; import a signed-in browser session; failures or rate limits should not block Claude monitoring.
- Gemini: optional; enter an API key in Settings; raw keys should not appear in UI, diagnostics, issues, or screenshots.

Pass if the reader can explain configured/not configured and connected/disconnected states without needing to disclose raw provider material.

## Privacy and Security Review

Pass if the reader can identify all of the following from public docs:

- Claude session keys, ChatGPT cookies, Gemini API keys, Cookie headers, Authorization headers, browser cookie databases, raw provider responses, account identifiers, and unredacted screenshots/logs are sensitive.
- Public issues must use sanitized app status, sanitized error categories, and reproduction steps only.
- Credential handling, privacy, and vulnerability reports belong in the private reporting path described by `SECURITY.md`.
- Diagnostics and acquisition state should be sanitized and must not include raw cookies, tokens, headers, or API keys.

## Issue Reporting Review

Pass if the reader can choose the correct public path:

- Reproducible app behavior: GitHub bug report form or `.github/ISSUE_TEMPLATE/bug_report.md`.
- Focused workflow or provider improvement: GitHub feature request form or `.github/ISSUE_TEMPLATE/feature_request.md`.
- Credential leakage, privacy, or vulnerability concern: `SECURITY.md` / private vulnerability reporting.

## Release Safety Review

Pass if the reader can explain:

- Release checks must pin the Autimo identity: `Developer ID Application: AUTIMO SYSTEMS INC (HMR9RDR6M2)`.
- `TeamIdentifier=HMR9RDR6M2` is required in signature verification output.
- Generic `Developer ID Application` matches are unsafe unless they include `AUTIMO SYSTEMS INC (HMR9RDR6M2)`.
- Local verification may read project files or built artifacts.
- Publishing and remote mutation require explicit maintainer confirmation for the intended version and target repository.

## Support Boundaries Review

Pass if the reader can find and restate:

- Pinemeter is unofficial and not affiliated with Anthropic, OpenAI, or Google.
- Providers may block, restrict, rate-limit, or terminate access.
- Provider accounts could be affected by using unofficial clients.
- The software is provided under the MIT License without warranty.
- Pinemeter stores credential material locally as described in the README and does not send collected data to third-party servers.

## Failure Modes

| Dependency | Failure path | Expected handling in this checklist |
|---|---|---|
| Public documentation files | A referenced public file is missing, renamed, or lacks the expected section. | Automated artifact checks fail with the missing path/section; the human pass records the gap instead of inferring from private context. |
| Xcode/project availability | A fresh reader cannot run build/test commands because Xcode 16+, macOS 14+, or `Pinemeter.xcodeproj` is unavailable. | Mark build/test execution as blocked by environment and still verify that public docs name the required commands and prerequisites. |
| Provider availability | Claude, ChatGPT, or Gemini login/API access is unavailable, rejected, rate limited, or not configured. | The reader verifies docs explain setup and safe status reporting; no real credentials are required for this UAT checklist. |
| Private reporting availability | GitHub private vulnerability reporting is not enabled or not visible. | `SECURITY.md` provides the fallback of contacting the maintainer through the repository owner's published GitHub contact path without including working secrets initially. |
| Release artifact availability | No local Release `.app` exists for `codesign` inspection. | Treat signature inspection as not run; still verify release docs preserve the pinned signing identity and distinguish local checks from publishing. |

## Load Profile


## Negative Tests

| Negative scenario | Check | Expected result |
|---|---|---|
| Public bug report includes secrets. | Review `CONTRIBUTING.md` and `.github/ISSUE_TEMPLATE/bug_report.md`. | Both warn against pasting provider credentials, cookies, tokens, API keys, headers, account identifiers, or raw responses. |
| Feature request touches provider credential material. | Review `.github/ISSUE_TEMPLATE/feature_request.md`. | Template asks for privacy/credential impact and sanitized context only. |
| Vulnerability is filed publicly. | Review `SECURITY.md`, `CONTRIBUTING.md`, and bug template comments. | Docs direct credential/privacy/vulnerability concerns to private reporting instead of public issues. |
| Release check uses generic signing identity. | Review `RELEASING.md` failure diagnostics and README release safety section. | Docs explicitly reject generic `Developer ID Application` without `AUTIMO SYSTEMS INC (HMR9RDR6M2)`. |
| Agent or reader relies on private `.gsd/` context for public readiness. | Review this UAT scope and public inputs. | Checklist instructs the fresh-reader pass to use public files only and treats private context as out of scope. |

## Observability Impact

This document creates a repeatable public-readiness evidence plan. Future release work can rerun the automated artifact checks, collect a human fresh-reader response table for H01-H12, and record any public-readiness gaps without exposing secrets or requiring maintainer-only GSD context.

## Verification Evidence

| # | Command | Exit Code | Verdict | Duration |
|---|---|---|---|---|
| 1 | `python3 - <<'PY' ...` (verify S04-UAT public-only checklist sections and references) | 0 | ✅ pass | Recorded by `gsd_exec` |
