---
name: quick-wins-mode
description: Staffing in riemann-masullo (user, 2026-11-22) - 4 Sonnet hunters on quick wins plus 3 Opus slots assigned by need, escalation first, otherwise Opus hunters
metadata:
  type: feedback
---

Staffing rule (HOURLY.md steps 7–8):
- **4 Sonnet hunters** on triage rows rated 1–2, then 3 (shortlist.py, Haiku triage, HUNTER.md). One file per hunter, no overlap (claims.txt).
- **3 Opus slots, filled by need** (user, 2026-11-22 ~18:30Z: "If there's enough escalation work to be done, use them all for it, otherwise scale back escalation and use them as hunters"). At each check every free slot goes to an escalator for the oldest file with QUEUED `opus` rows in `escalations.txt` that our Sonnet has left and no escalator holds. Only when no file waits does it go to an Opus hunter (CRITICAL_PROVER.md, any open unclaimed issue, prefer rows rated 3–4). Running agents are not stopped to rebalance.
- Fable consultant and findings evaluator run outside these slots ([[escalation-ladder]], [[paper-findings-opus]]).

History: 04:40Z Sonnets only; ~07:30Z "Just pick any open issue for Opus"; ~08:30Z "If sonnet gets stuck on the proofs, hand them off to opus"; ~16:00Z 2 Opus hunters + 2 escalators; ~16:20Z cut to 1 Opus hunter + 2 escalators; ~18:30Z the 3 Opus became one dynamic pool.

**Why:** fresh sections carry many easy lemmas for Sonnet. Stuck issues already hold our claim (upstream auto-releases after 8 h), so they come before fresh Opus work. Opus is the scarce budget.

**How to apply:** count the slots at every check. Escalation comes first. Leave a slot idle only if neither escalation work nor a suitable open issue exists. Related: [[critical-path-workstream]], [[subagent-model-effort]], [[low-hanging-sweep]].
