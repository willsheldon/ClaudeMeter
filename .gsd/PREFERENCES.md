---
version: 1
mode: solo
models:
  planning: openai-codex/gpt-5.5
  discuss: openai-codex/gpt-5.5
  research: openai-codex/gpt-5.5
  execution: openai-codex/gpt-5.5
  execution_simple: openai-codex/gpt-5.5
  completion: openai-codex/gpt-5.5
  validation: openai-codex/gpt-5.5
  uat: openai-codex/gpt-5.5
  subagent: openai-codex/gpt-5.5
thinking:
  planning: high
  discuss: high
  research: medium
  execution: medium
  execution_simple: low
  completion: low
  validation: high
  uat: medium
  subagent: medium
dynamic_routing:
  enabled: false
flat_rate_providers:
  - openai-codex
context_management:
  observation_masking: true
  observation_mask_turns: 8
  compaction_threshold_percent: 0.50
  tool_result_max_chars: 1200
context_selection: smart
search_provider: auto
git:
  auto_push: false
  push_branches: false
  pre_merge_check: true
  merge_strategy: squash
  isolation: none
  manage_gitignore: true
unique_milestone_ids: true
uok:
  enabled: true
  legacy_fallback:
    enabled: false
  plan_v2:
    enabled: true
reactive_execution:
  enabled: true
parallel:
  enabled: false
auto_supervisor:
  model: openai-codex/gpt-5.5
  soft_timeout_minutes: 20
  idle_timeout_minutes: 10
  hard_timeout_minutes: 30
min_request_interval_ms: 1000
verification_auto_fix: true
verification_max_retries: 2
per_unit_cost_cap_usd: 5
notifications:
  enabled: true
  on_error: true
  on_attention: true
  on_milestone: true
  on_budget: true
auto_report: true
auto_visualize: false
custom_instructions:
  - "Operate in GSD-2 autonomy mode: do not ask for permission to continue between steps."
  - "Do not pause between phases or sub-tasks. Do not ask 'should I continue?' — execute the full task end-to-end."
  - "When information is missing, make a reasonable assumption, state it briefly, and proceed."
  - "Only stop for credentials/secrets, destructive or irreversible actions, or genuinely ambiguous goals."
  - "Run the loop: plan → execute → verify → continue until complete."
  - "Prefer action over discussion. Output complete results, not partial progress."
---

# GSD Skill Preferences

Project-local GPT subscription first baseline. Claude remains available for explicit special-event use, but automatic routing should prefer `openai-codex/gpt-5.5`.

See `~/.gsd/agent/extensions/gsd/docs/preferences-reference.md` for full field documentation and examples.
