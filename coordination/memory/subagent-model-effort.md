---
name: subagent-model-effort
description: "riemann-masullo subagent models: Sonnet effort medium for hunters/sievers/fixers (4 PRs or ~3 h), Opus default effort for provers, Haiku for triage and nagger, Fable as consultant"
metadata:
  type: feedback
---

The user (2026-11-21): "use Sonnet medium for them" and "Keep subagents running for 4 PRs to avoid triggering your main session too often." Haiku approved for triage and the nagger; Fable only as the one-at-a-time consultant ([[escalation-ladder]]).

**Why:** usage budget and fewer coordinator wake-ups.

**How to apply:** the agent definitions in `.agent/agents/` fix model and effort; fixers are `general-purpose` with model sonnet, effort medium (HOURLY.md table). Related: [[custom-subagents]], [[subagent-resume-cost]].
