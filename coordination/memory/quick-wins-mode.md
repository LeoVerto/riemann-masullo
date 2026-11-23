---
name: quick-wins-mode
description: Staffing instructions in riemann-masullo (user, 2026-11-22) - Sonnet/Opus budget and Opus work order; procedure in HOURLY.md steps 7-8
metadata:
  type: feedback
---

The user's staffing instructions, 2026-11-22, in order (each refines the last):
- 04:40Z: "focus on the low-hanging fruits"; ~07:30Z: "Just pick any open issue for Opus"; ~08:30Z: "If sonnet gets stuck on the proofs, hand them off to opus".
- ~17:10Z: "If there's enough escalation work to be done, use them all for it, otherwise scale back escalation and use them as hunters." Then: "starting an opus hunter on a random issue should be the last option, after escalation and continuing prior work have been exhausted"; "If we have prior work on an issue, we should strive to build on top of it"; "include others' attempts too".
- ~17:30Z: "when two sonnets are idle, spawn an opus instead. keep at minimum two opuses and at maximum six sonnets". Unit costs (Sonnet 1, Opus 2) are my reading. ~20:20Z: "bump the budget to twelve" (was 10); 23:10Z, CPU pegged: "let's drop to 10 slots for now", so the max budget is 10 units. ~22:30Z: "The fable consultant is not budgeted for right now. Can we introduce it at budget 2 but ensure that consultations are preferred to new work?" (it costs 2 units; held units go to it before Sonnet hunters or extra Opus). ~23:00Z: "We appear to be hitting some hard issues now. Bump the allowed fable consultant concurrency to 2". 2026-11-23 ~01:05Z: "dynamically scale down from the max budget if the remaining token budget gets low (included in status.sh, directly available via usage.sh). Once the reset has hit, it's free to scale up again" The earlier one-off cuts (00:20Z "drop to budget 8 until the reset at 0130Z", ~00:25Z "budget 2 until the reset") are replaced by the usage table.

**Why:** quick wins are cheapest on Sonnet; stuck issues hold our claim and released attempts carry paid-for work, so both come before fresh Opus work. Opus is the scarce budget.

**How to apply:** HOURLY.md steps 7–8 (budget, order a/b/c, `resumable.sh`); HUNTER.md "Prior work first". Related: [[escalation-ladder]], [[subagent-model-effort]].
