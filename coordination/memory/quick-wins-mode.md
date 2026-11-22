---
name: quick-wins-mode
description: Quick-wins mode (renamed from "low-hanging mode", 2026-11-22) - since ~16:30Z always 4 Sonnet hunters, 2 Opus hunters (any open issue), 2 Opus escalators (stuck Sonnet issues)
metadata:
  type: feedback
---

The user's instructions, 2026-11-22:
- 04:40Z: "focus on the low-hanging fruits, i.e. back to running multiple Sonnets and no Opus until the problem space changes again."
- ~06:05Z: "Only resume opus when you're out of low-hanging fruits."
- ~07:30Z: "Just pick any open issue for Opus."
- ~08:30Z: "If sonnet gets stuck on the proofs, hand them off to opus."

**Why:** fresh sections carry many easy sanity lemmas, while the hard tails are held by upstream sweepers. Opus usage is the scarce budget.

**How to apply (in this order):**
1. Every check looks for new proof issues first: shortlist.py, then Haiku triage (TRIAGE.md), then 4 Sonnet hunters on rows rated 1–2 (then 3). One file per hunter, no overlap (claims.txt).
2. Issues a Sonnet is *stuck* on (tried and failed) are handed over with `escalate.sh`, which keeps our claim, to an Opus escalation prover. It uses the HUNTER.md brief with the Opus tag, one file per prover, after our Sonnet left that file. No re-claim ([[claims-notes-attribution]]). The queue lives in `.agent/sweeptools/escalations.txt`.
3. Opus hunters on any open unclaimed issue ([[critical-path-workstream]]), without asking.
4. Superseded cap: the user, 2026-11-22 ~16:30Z, after the token allowance increased: "we can now always keep two Opus hunters running plus 4 Sonnets and two Opus escalators". Keep those slots filled at every check: 4 Sonnet hunters (steps 1), 2 Opus escalators (step 2; empty if nothing to escalate), 2 Opus hunters on any open issue (step 3 no longer waits for quick wins to run out; prefer rows rated 3–4). The "Opus hunter" = CRITICAL_PROVER.md brief is my reading.
Back to Sonnets as soon as new issues bring quick wins. Related: [[subagent-model-effort]], [[low-hanging-sweep]].
