# BLOCKER — auto-mode recovery failed

Unit `plan-slice` for `M001/S04` failed to produce this artifact after idle recovery exhausted all retries.

**Reason**: Deterministic policy rejection for plan-slice "M001/S04": gsd_resume: HARD BLOCK: Tool Contract failure for unit "plan-slice" — GSD lifecycle tool "gsd_resume" is not permitted; allowed GSD tools: gsd_decision_save, gsd_plan_slice, gsd_reassess_roadmap. This is a mechanical phase-boundary gate. You MUST NOT proceed, retry the same call, or route around this block; the orchestrator owns phase transitions.. Retrying cannot resolve this gate — writing blocker placeholder to advance pipeline.

This placeholder was written by auto-mode so the pipeline can advance.
Review and replace this file before relying on downstream artifacts.