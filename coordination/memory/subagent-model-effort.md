---
name: subagent-model-effort
description: "riemann-masullo subagent models: Sonnet effort medium for hunters/sievers/fixers (4 PRs or ~3 h), Opus default effort for provers, Haiku for triage and nagger, Fable as consultant and findings evaluator"
metadata:
  type: feedback
---

The user (2026-11-21): "use Sonnet medium for them" and "Keep subagents running for 4 PRs to avoid triggering your main session too often." Haiku approved for triage and the nagger; Fable as the consultant (at most 2 at once since 2026-11-22 ~23:00Z) ([[escalation-ladder]]) and, since 2026-11-22 ~21:40Z, as the findings evaluator ([[paper-findings-opus]]).

**Why:** usage budget and fewer coordinator wake-ups.

"4 PRs" means files in sequence, one PR per file ([[one-pr-per-file]]).

**How to apply:** the agent definitions in `.agent/agents/` fix model and effort; fixers are `general-purpose` with model sonnet, effort medium (HOURLY.md table). Related: [[custom-subagents]], [[subagent-resume-cost]].
