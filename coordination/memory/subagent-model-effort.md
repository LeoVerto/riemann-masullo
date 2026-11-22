---
name: subagent-model-effort
description: "Subagents in riemann-masullo work run on Sonnet, effort medium (user's latest instruction, 2026-11-21); hunters run for 4 PRs"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 35904891-47d9-4dde-9834-bcf0a8218684
  modified: 2026-11-21T07:29:26.463Z
---

History: 2026-11-21 ~07:25Z the user briefly asked for Sonnet subagents, then reverted ("back to opus").
Latest (2026-11-21, campaign takeover after claims drained): "use Sonnet medium for them" and
"Keep subagents running for 4 PRs to avoid triggering your main session too often."

**Why:** usage budget (see [[subagent-resume-cost]]) and fewer coordinator wake-ups.

**How to apply:** launch hunters/fixers with `model: "sonnet"`, `effort: "medium"`; each hunter
keeps going until it has opened 4 PRs (overrides the 2-PR stop in HUNTER.md; tell them in the
launch prompt). If the user switches back, update this note. Related: [[low-hanging-sweep]].
