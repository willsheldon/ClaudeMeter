---
estimated_steps: 1
estimated_files: 1
skills_used: []
---

# T01: Write Gemini UAT checklist

Create a UAT checklist for Gemini setup, refresh, invalid credential, clear/reconnect, Gemini-only, and all-provider states. Use synthetic or mock credentials unless the user explicitly supplies real credentials through approved secret handling.

## Inputs

- `.gsd/milestones/M004/M004-ROADMAP.md`

## Expected Output

- `.gsd/milestones/M004/slices/S05/S05-UAT.md`

## Verification

Checklist distinguishes automated, runtime, and human-follow-up checks and contains no real secret values.

## Observability Impact

Creates repeatable Gemini workflow evidence plan.
