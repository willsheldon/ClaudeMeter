# M003: Multi-provider workflow polish

**Vision:** Make the existing Claude and ChatGPT monitoring flows feel like one coherent multi-provider product: setup, status, menu bar usage, recovery actions, and diagnostics are provider-aware, sanitized, and verifiable without fragile manual credential loops.

## Success Criteria

- Setup and settings surfaces show provider-aware credential status and recovery actions for Claude and ChatGPT without exposing credential material.
- Menu bar usage surfaces clearly represent configured, partially configured, loading, error, and empty states across Claude and ChatGPT.
- Provider refresh, retry, clear, and reconnect workflows are observable, tested, and route through AppModel/service boundaries rather than direct view access to secrets.
- First-run, reset, and expired-session workflows have automated tests and a UAT checklist that can be rerun by auto-mode.

## Slices

- [x] **S01: Provider status surfaces** `risk:high` `depends:[]`
  > After this: Settings and setup show sanitized Claude and ChatGPT credential status with provider-specific next actions.

- [x] **S02: Provider recovery actions** `risk:high` `depends:[S01]`
  > After this: A user can retry, reconnect, repair, or clear provider credentials from consistent provider-aware actions.

- [x] **S03: Menu bar multi-provider usage** `risk:medium` `depends:[S01]`
  > After this: The menu bar popover accurately communicates Claude-only, ChatGPT-only, both-provider, loading, and error states.

- [x] **S04: Workflow UAT and diagnostics** `risk:medium` `depends:[S02,S03]`
  > After this: A documented reset and UAT flow proves first-run, partial-provider, two-provider, and expired-session behavior.

## Boundary Map

Not provided.
