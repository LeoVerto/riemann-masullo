---
name: state-in-dot-agent
description: Keep all campaign state (sweeptools, worktrees, agent types, Claude memory) inside the repo's git-ignored .agent dir, not under /home/agent
metadata:
  type: feedback
---

The user, 2026-11-22: "please keep all state in .agent instead of your local dir".

**Why:** the 2026-11-22 sandbox recreation wiped /home/agent; the repo on /mnt/faststorage persists.

**How to apply:** new tools, briefs, scripts and state go under `.agent/`. This memory dir is a symlink to `.agent/memory`; after a recreation follow HANDOVER startup step 1. Related: [[low-hanging-sweep]].
