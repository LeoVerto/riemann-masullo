---
name: quick-wins-mode
description: Quick-wins mode (renamed from "low-hanging mode" by the user, 2026-11-22) - Sonnet hunters on quick wins first, Opus escalation for stuck Sonnet issues, else one Opus on any open issue; max 2 Opus; no asking
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
1. Every check looks for new proof issues first: shortlist.py, then Haiku triage (TRIAGE.md), then 2–3 Sonnet hunters on rows rated 1–2 (then 3). One file per hunter, no overlap (claims.txt).
2. Issues a Sonnet released as *stuck* (tried and failed) go to an Opus escalation prover. It uses the HUNTER.md brief with the Opus tag, one file per prover, after our Sonnet left that file. Re-claim the issue for Opus at once ([[claims-notes-attribution]]). The queue lives in leads.txt "ESCALATION QUEUE".
3. With no quick wins and no escalations: ONE Opus prover on any open unclaimed issue ([[critical-path-workstream]]), without asking.
4. At most 2 Opus agents at once (my assumption, not the user's).
Back to Sonnets as soon as new issues bring quick wins. Related: [[subagent-model-effort]], [[low-hanging-sweep]].
