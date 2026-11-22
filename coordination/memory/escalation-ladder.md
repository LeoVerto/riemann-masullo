---
name: escalation-ladder
description: Stuck issues climb Sonnet -> Opus escalator -> Fable consultant (route only, from a stuck packet) -> Opus, claim kept; no advisor tool
metadata:
  type: feedback
---

The user, 2026-11-22: "If sonnet gets stuck on the proofs, hand them off to opus" (~08:30Z); keep the claim during escalation (~16:00Z); on getting a Fable allowance, escalate Opus to Fable "without burning too many tokens", and turned the advisor off; "ensure the coordinator knows it can also escalate to Fable if needed"; ~17:10Z: "I'd rather Opus give them a try before we split them."

**Why:** the advisor sends the whole transcript (100–200k tokens) per call; a cold Fable reading a ~5–10k-token stuck packet costs a fraction, and build-and-fix stays on Opus.

**How to apply:** HUNTER.md "Claims, notes, release" (escalate, escalators, stuck packet), FABLE.md, HOURLY.md steps 8a–8b, `escalate.sh`. Fable is consulted once per issue. Related: [[quick-wins-mode]], [[claims-notes-attribution]].
