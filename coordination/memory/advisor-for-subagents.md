---
name: advisor-for-subagents
description: The advisor tool (Opus) is for Sonnet subagents to escalate to; the Opus coordinator should not call it
metadata:
  type: feedback
---

The user set `/advisor` to Opus 5.5 on 2026-11-21 and said: "The advisor is also Opus, you don't need to use it, it's for the subagents to escalate".

**Why:** the coordinator already runs on Opus, so calling an Opus advisor only adds cost; the advisor is there to lift Sonnet hunters when they are stuck.

**How to apply:** do not call `advisor` from the main session. In hunter/fixer launch prompts (and HUNTER.md), tell subagents they may call the advisor when stuck or before releasing a promising issue. Related: [[subagent-model-effort]], [[low-hanging-sweep]].
