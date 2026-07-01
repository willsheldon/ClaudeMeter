---
estimated_steps: 1
estimated_files: 3
skills_used: []
---

# T02: Updated the README, landing page, and public changelog links so fresh readers see current Pinemeter provider support, privacy posture, setup, reset, build, and troubleshooting guidance.

Update README and site copy so a fresh reader understands what Pinemeter is, supported providers, privacy/security posture, setup, reset, build/test commands, and troubleshooting.

## Inputs

- `README.md`
- `site/index.html`
- `CHANGELOG.md`

## Expected Output

- `README.md`
- `site/index.html`

## Verification

`rg -n "ClaudeMeter|Pinemeter|xcodebuild|provider|privacy|credential|Gemini|ChatGPT|Claude" README.md site/index.html CHANGELOG.md` reviewed for accurate public copy.

## Observability Impact

Makes diagnostic and privacy expectations discoverable.
