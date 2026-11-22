---
name: ask-on-conflict
description: When the user's riemann-masullo instructions conflict, ask them to resolve it instead of picking one
metadata:
  type: feedback
---

The user, 2026-11-22: "If my instructions conflict, ask me to resolve. The parameters and tools of the whole operation changed a couple times after all."

**Why:** the rules were layered over two days; an older instruction may survive in a brief or memory after a newer one replaced it.

**How to apply:** in a live session, ask (AskUserQuestion) and record the answer where the rule lives. In the unattended hourly check, follow the newer instruction and name the conflict in the report. Rule recorded in HANDOVER "Standing instructions". Related: [[low-hanging-sweep]].
