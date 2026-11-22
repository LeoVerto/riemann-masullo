---
name: quick-wins-mode
description: Staffing in riemann-masullo (user, 2026-11-22) - 4 Sonnet hunters plus 3 Opus slots by need - escalation, then our released prior work, a fresh Opus hunter only as last resort
metadata:
  type: feedback
---

Staffing rule (HOURLY.md steps 7–8):
- **4 Sonnet hunters** on triage rows rated 1–2, then 3 (shortlist.py, Haiku triage, HUNTER.md). One file per hunter, no overlap (claims.txt).
- **3 Opus slots, filled by need** (user, 2026-11-22 ~18:30Z: "If there's enough escalation work to be done, use them all for it, otherwise scale back escalation and use them as hunters"; then: "starting an opus hunter on a random issue should be the last option, after escalation and continuing prior work have been exhausted"). Each free slot takes the first that exists: (a) an escalator for the oldest file with QUEUED `opus` rows in `escalations.txt` that our Sonnet has left; (b) prior work: `resumable.sh` rows (open, unclaimed, ours released after a real attempt), re-claimed and queued with `escalate.sh`, so they become (a); (c) an Opus hunter on a fresh issue (CRITICAL_PROVER.md). Running agents are not stopped to rebalance.
- **Build on prior work** (user: "If we have prior work on an issue, we should strive to build on top of it"): every agent runs `prior.sh <n>` and reads the `Releasing` comments first (HUNTER.md "Prior work first").
- Fable consultant and findings evaluator run outside these slots ([[escalation-ladder]], [[paper-findings-opus]]).

History: 04:40Z Sonnets only; ~07:30Z "Just pick any open issue for Opus"; ~08:30Z "If sonnet gets stuck on the proofs, hand them off to opus"; ~16:00Z 2 Opus hunters + 2 escalators; ~16:20Z cut to 1 Opus hunter + 2 escalators; ~18:30Z the 3 Opus became one dynamic pool, with prior work ahead of fresh issues.

**Why:** fresh sections carry many easy lemmas for Sonnet. Stuck issues already hold our claim (upstream auto-releases after 8 h), so they come before fresh Opus work; released attempts carry hours of paid-for work. Opus is the scarce budget.

**How to apply:** count the slots at every check and go down a, b, c. Leave a slot idle only if all three are empty. Related: [[critical-path-workstream]], [[subagent-model-effort]], [[low-hanging-sweep]].
