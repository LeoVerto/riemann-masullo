---
name: subagent-resume-cost
description: After a usage-limit halt, do not resume long-lived subagents via SendMessage; start fresh ones from notes/<n>.md handoffs
metadata:
  type: feedback
---

After the 2026-11-21 spend-limit halt (~35 min, longer than the prompt-cache lifetime), resuming four hunters with SendMessage replayed their ~200k-token transcripts uncached. The user reported it as a big usage hit (21% of the next 5-hour window right after reset).

**Why:** a resumed agent re-sends its whole context; after a gap longer than the cache TTL that is billed as fresh input.

**How to apply:** keep subagents short-lived ([[subagent-model-effort]]), have them keep `notes/<n>.md` current, and after a halt launch fresh agents pointed at those notes (or `notes/released/`) instead of resuming old transcripts. Continuing a just-finished agent while its cache is warm is fine. Keep the coordinator's own loop sparse. Related: [[low-hanging-sweep]].
