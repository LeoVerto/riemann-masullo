---
name: subagent-model-effort
description: "riemann-masullo subagents: hunters/sievers/fixers on Sonnet effort medium until 4 PRs or ~3 h; Opus (no effort override) for provers/escalations; Haiku for triage and the nagger"
metadata:
  type: feedback
---

The user (2026-11-21, campaign takeover): "use Sonnet medium for them" and "Keep subagents running for 4 PRs to avoid triggering your main session too often." (Earlier the same day they briefly switched to Sonnet and then back to Opus; the Sonnet instruction is the latest.)

**Why:** usage budget (see [[subagent-resume-cost]]) and fewer coordinator wake-ups.

**How to apply:** hunters, sievers and fixers use `model: "sonnet"`, `effort: "medium"` and run until their list is done, 4 PRs, or about 3 h. Opus provers and escalations use model opus with no effort override ([[quick-wins-mode]]). The user approved Haiku for triage and the notes nagger. Fable (model fable, no effort override) only as the one-at-a-time consultant of [[escalation-ladder]]. Related: [[low-hanging-sweep]].
