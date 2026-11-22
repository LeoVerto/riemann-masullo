---
name: low-hanging-mode
description: Since 2026-11-22 04:40Z — run several Sonnet hunters on quick wins from new issues, no Opus agents until the quick wins run out; then resume Opus without asking
metadata:
  type: feedback
---

The user, 2026-11-22 04:40Z: "Tell the next run to check on new issues and focus on the low-hanging fruits, i.e. back to running multiple Sonnets and no Opus until the problem space changes again."

**Why:** the critical path is mostly held by upstream sweepers (only hard leftovers remain), while fresh digested sections (Ch05 Sec2b/3a/3b, Ch07 Sec1a/1b, Ch06 Sec1) carry many easy sanity lemmas. Opus usage is also the scarce budget.

**How to apply:** every check looks for new proof issues first, then shortlist.py, Haiku triage (TRIAGE.md), and 2–3 parallel Sonnet hunters on rows rated 1–2 (then 3), no issue overlap (claims.txt). Start no Opus critical provers. Resume Opus (one critical prover at a time, hunted.txt) ONLY when the quick wins are exhausted: no unclaimed rows rated 1–3 left in any triage file and no new proof issues to triage. No need to ask (user, 2026-11-22 ~06:05Z: "Only resume opus when you're out of low-hanging fruits"). Return to Sonnet hunters as soon as new issues bring quick wins. Related: [[critical-path-workstream]], [[subagent-model-effort]], [[low-hanging-sweep]].

Update (user, 2026-11-22 ~07:30Z): "The cone doesn't matter at this point, there are enough agents working on this repo now. Just pick any open issue for Opus." Opus provers take ANY open unclaimed proof issue (not gap/refutation/ERRATA/paper-gap, not sweep-held); no cone remapping needed.

Update (user, 2026-11-22 ~08:30Z): "If sonnet gets stuck on the proofs, hand them off to opus." Issues a Sonnet hunter released as stuck (not merely unattempted, not claimed by others) go to an Opus escalation prover (HUNTER.md brief, Opus tag), one file per prover, after our Sonnet leaves that file. Assumed cap: at most 2 Opus agents at once (one may be the any-open-issue prover). Escalation queue lives in sweeptools/leads.txt.
