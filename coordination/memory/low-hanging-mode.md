---
name: low-hanging-mode
description: Since 2026-11-22 04:40Z — run several Sonnet hunters on quick wins from new issues, no Opus agents until the problem space changes; ask before resuming Opus
metadata:
  type: feedback
---

The user, 2026-11-22 04:40Z: "Tell the next run to check on new issues and focus on the low-hanging fruits, i.e. back to running multiple Sonnets and no Opus until the problem space changes again."

**Why:** the critical path is mostly held by upstream sweepers (only hard leftovers remain), while fresh digested sections (Ch05 Sec2b/3a/3b, Ch07 Sec1a/1b, Ch06 Sec1) carry many easy sanity lemmas. Opus usage is also the scarce budget.

**How to apply:** every check looks for new proof issues first, then shortlist.py, Haiku triage (TRIAGE.md), and 2–3 parallel Sonnet hunters on rows rated 1–2 (then 3), no issue overlap (claims.txt). Start no Opus critical provers. "Problem space changes" = quick wins exhausted or a new chapter needs mapping; then ask the user before relaunching Opus. Related: [[critical-path-workstream]], [[subagent-model-effort]], [[low-hanging-sweep]].
