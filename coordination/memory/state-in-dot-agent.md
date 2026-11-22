---
name: state-in-dot-agent
description: Keep all campaign state (sweeptools, worktrees, Claude memory) inside the repo's git-ignored .agent/ dir, not under /home/agent
metadata:
  type: feedback
---

The user, 2026-11-22: "please keep all state in .agent instead of your local dir".

**Why:** the 2026-11-22 sandbox recreation wiped everything under /home/agent (tools, worktrees, elan); /mnt/faststorage/math/riemann-masullo persists and has ~65 GB free.

**How to apply:**
- Tools and state: /mnt/faststorage/math/riemann-masullo/.agent/sweeptools (compat symlink /home/agent/sweeptools).
- Worktrees: .agent/wt (compat symlink /home/agent/wt). Migration done by a Sonnet agent on 2026-11-22.
- Claude memory: .agent/memory, with ~/.claude/projects/-mnt-faststorage-math-riemann-masullo/memory symlinked to it. After a sandbox recreation, re-create that symlink first.
- New briefs, crons and scripts use the .agent paths. Only elan and Claude transcripts stay under /home/agent.

Related: [[riemann-masullo-sandbox-quirks]], [[low-hanging-sweep]].
