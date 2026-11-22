---
name: low-hanging-sweep
description: riemann-masullo campaign (since 2026-11-21) - where the source of truth lives; memory only points at it
metadata:
  type: project
---

Since 2026-11-21 I coordinate subagents that close upstream proof issues. Source of truth: `coordination/HANDOVER.md` on the fork branch `coordination/low-hanging-campaign` (worktree `.agent/wt/coord`; `git show FETCH_HEAD:coordination/HANDOVER.md` after a fetch). It holds current state, the user's standing instructions, startup checklist, environment, tools and lessons. The hourly procedure is `.agent/sweeptools/HOURLY.md`, agent rules are in the briefs there.

**How to apply:** edit the live files under `.agent/`, then refresh the snapshot on the branch and commit and push. Keep each rule in one place; memory files hold the user's words and point to that place (user, 2026-11-22: "It should reference the other files, not duplicate them"). Related: [[quick-wins-mode]], [[coordinator-only]].
