---
name: subagent-resume-cost
description: After a halt, start fresh agents from notes/<n>.md handoffs; never resume long transcripts
metadata:
  type: feedback
---

After the 2026-11-21 spend-limit halt, resuming four hunters with SendMessage replayed ~200k-token transcripts uncached; the user reported it as a big usage hit (21% of the next 5-hour window).

**Why:** a resumed agent re-sends its whole context, billed as fresh input once the cache has expired.

**How to apply:** HANDOVER startup step 6: fresh agents from `notes/` and `notes/released/`. Continuing a just-finished agent with a warm cache is fine. Related: [[subagent-model-effort]], [[cpu-cheap-tokens-scarce]].
