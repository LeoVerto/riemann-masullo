---
name: quick-wins-mode
description: Staffing in riemann-masullo (user, 2026-11-22) - 10-unit budget, Sonnet 1 and Opus 2, at least 2 Opus and at most 6 Sonnets; Opus work order escalation, prior work (incl. others'), fresh issue last
metadata:
  type: feedback
---

Staffing rule (HOURLY.md steps 7–8):
- **One budget of 10 units** (user, 2026-11-22 ~17:30Z: "when two sonnets are idle, spawn an opus instead. keep at minimum two opuses and at maximum six sonnets"). Sonnet hunter = 1, Opus prover (escalator or Opus hunter) = 2. 10 is my reading: the previous 4 Sonnets + 3 Opus. Free units go: Opus until 2 run; then Sonnets while quick-win triage rows (rated 1–2, then 3) exist, up to 6; the rest, in pairs, to Opus. Running agents are not stopped to rebalance. Fixers, sievers, triage, nagger, Fable and the findings evaluator are outside the budget.
- **Opus work order** (user, ~17:10Z: "If there's enough escalation work to be done, use them all for it, otherwise scale back escalation and use them as hunters"; then: "starting an opus hunter on a random issue should be the last option, after escalation and continuing prior work have been exhausted"): (a) an escalator for the oldest file with QUEUED `opus` rows in `escalations.txt` that our Sonnet has left; (b) prior work: `resumable.sh` rows (open, unclaimed, a real earlier attempt: ours first, then others', user: "include others' attempts too"), re-claimed and queued with `escalate.sh … --prior`, so they become (a); (c) an Opus hunter on a fresh issue (CRITICAL_PROVER.md).
- **Build on prior work** (user: "If we have prior work on an issue, we should strive to build on top of it"): every agent runs `prior.sh <n>` first: current claim, full thread, referencing PRs, our local work (HUNTER.md "Prior work first").
- **Comments on our claims** (user, ~17:30Z): status.sh lists others' new comments on `claims.txt` issues (`NEW #<n>`); HOURLY step 3 routes them to the holding agent ([[claims-notes-attribution]]).

History: 04:40Z Sonnets only; ~07:30Z "Just pick any open issue for Opus"; ~08:30Z "If sonnet gets stuck on the proofs, hand them off to opus"; ~16:00Z 2 Opus hunters + 2 escalators; ~16:20Z 1 Opus hunter + 2 escalators; ~17:10Z 3 Opus as one pool, prior work ahead of fresh issues; ~17:30Z Sonnet/Opus split dynamic (2 idle Sonnets = 1 Opus).

**Why:** fresh sections carry many easy lemmas for Sonnet; when those run out, the same budget buys Opus time. Stuck issues already hold our claim (upstream auto-releases after 8 h), and released attempts carry hours of paid-for work, so both come before fresh Opus work.

**How to apply:** count units at every check and hand them out in the order above. Leave units idle only if no work of either kind exists. Related: [[critical-path-workstream]], [[subagent-model-effort]], [[low-hanging-sweep]].
