# M006-fd23vy: Automated VM first run validation

**Vision:** Make Pinemeter first-run provider onboarding fully agent-verifiable on the Wills-AUTH-vm.local macOS VM: build and install the app, reset local state, drive onboarding from Chrome Profile 1, validate Claude and ChatGPT credential loading, capture evidence, and leave a reusable validation command for future agents. This can be planned while M005 public polish runs separately, but source edits should be coordinated if both milestones touch the same files.

## Success Criteria

- An agent can build or locate a Pinemeter app bundle, transfer it to Wills-AUTH-vm.local, install it, and launch it without manual VM work.
- A clean first-run reset clears Pinemeter preferences plus exact Claude and ChatGPT Keychain items before every validation attempt.
- Computer-use or equivalent visual automation can drive onboarding against Chrome Profile 1 and handle expected macOS or browser-access prompts without exposing secrets.
- Claude and ChatGPT browser import succeeds from the authenticated Chrome Profile 1 session, or failures are categorized with sanitized logs and screenshots that identify the root cause.
- Post-onboarding verification proves credential presence through Keychain/state checks without printing raw cookie, token, or session values.
- The milestone leaves a documented rerunnable validation command or script that future agents can execute end to end.

## Slices

- [ ] **S01: VM automation access harness** `risk:high` `depends:[]`
  > After this: After this: the agent has a proven command surface for SSH, sudo, AppleScript, computer-use, screenshot capture, PineShot fallback, and sanitized artifact collection on Wills-AUTH-vm.local.

- [ ] **S02: Clean install and first run reset** `risk:high` `depends:[S01]`
  > After this: After this: Pinemeter can be built, copied to the VM, installed, reset to clean first-run state, and launched reproducibly.

- [ ] **S03: Computer use onboarding import** `risk:high` `depends:[S02]`
  > After this: After this: visual automation drives Pinemeter onboarding and imports Claude and ChatGPT from Chrome Profile 1, or captures a root-caused sanitized failure.

- [ ] **S04: Runtime state and diagnostic verification** `risk:medium` `depends:[S03]`
  > After this: After this: menu-bar state, app logs, Keychain presence, preferences, and screenshots prove what the VM onboarding achieved.

- [ ] **S05: Fix loop and validation rerun** `risk:high` `depends:[S04]`
  > After this: After this: any discovered onboarding/import defect is fixed or escalated with root-cause evidence, and the clean validation loop has been rerun.

- [ ] **S06: Reusable validation command and handoff** `risk:medium` `depends:[S05]`
  > After this: After this: future agents can rerun the VM validation end to end using documented commands and know where evidence is stored.

## Boundary Map

## Boundary Map

- **Local repo host**: builds Pinemeter, stores plans, receives sanitized evidence.
- **Wills-AUTH-vm.local**: clean first-run validation target; accessed as SSH user `will` with passwordless sudo.
- **Chrome Profile 1**: authenticated browser source for Claude and ChatGPT imports; raw cookies must never be printed or persisted in artifacts.
- **Computer-use**: preferred visual UI driver for onboarding and prompts.
- **AppleScript and screencapture**: deterministic fallback for menu-bar interactions and screenshot evidence.
- **PineShot**: installed GUI fallback for screenshot workflows documented in the local wiki.
