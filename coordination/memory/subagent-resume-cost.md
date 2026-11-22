---
name: subagent-resume-cost
description: After a usage-limit halt, do not resume long-lived subagents via SendMessage; start fresh ones from a handoff note
metadata:
  type: feedback
---

After the 2026-11-21 spend-limit halt (~35 min, longer than the prompt-cache lifetime), resuming four hunter subagents with SendMessage replayed their full ~200k-token transcripts uncached. The user reported it as a big usage hit (21% of the next 5-hour window right after reset).

**Why:** a resumed agent re-sends its whole context; after a gap longer than the cache TTL that is billed as fresh input. Long-lived agents also make every tool call expensive.

**How to apply:** keep subagents short-lived (hunters stop after 2 PRs / ~90 min, see /home/agent/sweeptools/HUNTER.md), have them keep a short `.agent/STATE.md` handoff in their worktree, and after a halt launch fresh agents pointed at those handoff notes instead of resuming old transcripts. Keep the coordinator's own periodic loop sparse. Related: [[low-hanging-sweep]].
