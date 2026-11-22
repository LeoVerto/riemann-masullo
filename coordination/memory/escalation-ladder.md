---
name: escalation-ladder
description: Stuck issues climb Sonnet -> Opus escalator -> Fable consultant (route only, from a stuck packet) -> Opus implements; claim kept throughout; the advisor tool is off
metadata:
  type: feedback
---

The user, 2026-11-22: "If sonnet gets stuck on the proofs, hand them off to opus" (~08:30Z). Then they asked to keep the claim during escalation (~16:00Z). On getting a Fable allowance (~16:00Z) they asked how to escalate from Opus to Fable "without burning too many tokens", agreed that using Fable as the advisor would burn too much, and turned the advisor off.

**Why:** the advisor sends the agent's whole transcript (100–200k tokens for our Opus provers) on every call, and the advisor model is one session-wide setting. A cold Fable agent reading a ~5–10k-token stuck packet costs a fraction of that, and the build-and-fix iteration stays on Opus.

**How to apply:**
- A Sonnet that is stuck runs `escalate.sh <n> "<reason>"`. An Opus escalator (HUNTER.md "Escalators") continues under our claim.
- An Opus agent that is stuck writes the "## Stuck packet" (HUNTER.md) and runs `escalate.sh <n> "<reason>" --to fable`.
- One Fable consultant at a time (`FABLE.md`, model fable, outside the 8 standing slots). It writes a "## Fable route" (ROUTE / SPLIT / FINDING / NO-ROUTE) and hands ROUTE/SPLIT back with `--to opus`.
- Fable is consulted only once per issue: if its route also fails, release.
- The coordinator may escalate to Fable directly (user, ~16:00Z: "ensure the coordinator knows it can also escalate to Fable if needed"). Cases: Opus gave up without escalating, an UNCLEAR finding, a blocker shared by several issues, repeated failed attempts upstream. It claims the issue if needed, writes a short packet from the notes without running Lean ("Goal: to compute"), and runs `escalate.sh --to fable` (HOURLY.md step 8b).
- The queue is `.agent/sweeptools/escalations.txt` (rows carry a level). The coordinator never calls an advisor; there is none now.
Related: [[quick-wins-mode]], [[claims-notes-attribution]], [[subagent-model-effort]].
