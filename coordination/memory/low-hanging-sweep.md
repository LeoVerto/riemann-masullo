---
name: low-hanging-sweep
description: riemann-masullo low-hanging-fruit campaign (since 2026-11-21): where the handover lives, and the durable lessons behind its rules
metadata:
  type: project
---

Since 2026-11-21 the user has had me coordinate subagents (in worktrees under `.agent/wt`) that close short upstream proof issues. **The handover is the source of truth:** `git fetch fork coordination/low-hanging-campaign && git show FETCH_HEAD:coordination/HANDOVER.md` (current state, standing instructions, startup checklist, hourly-check prompt). It was compacted with live state on 2026-11-22 ~15:45Z.

State on 2026-11-22 ~15:45Z: halted by the monthly spend limit since 11:32Z. All claims were released by the watchdog. The user stopped the old coordinator session (00d88758) to start a new one. 76 LeoVerto PRs merged, none open. About 357 new proof issues (up to #5344) are not yet shortlisted.

Lessons behind the rules (details in HANDOVER "Lessons"):
- Blind hunters launched on census counts returned 0 PRs (ch03, appB). Launch agents only on concrete leads: shortlist plus Haiku triage, or sieve hits.
- Upstream codex sweepers (label `sweep`) take whole files within minutes. jcosmos0 and elmismisimoxhunca are active on ch03.
- Re-check a PR's state right before editing or commenting on it: a merged PR was edited once, and a wrong comment was posted on #3367.
- Never `pkill -f`/`pgrep -f` with a pattern from your own command line (it kills the calling shell, exit 144).
- The user agreed (2026-11-21): if the sieve pays off, propose it upstream as an integrator tool in an issue, not a PR (`scripts/` is integrator-owned).

Related: [[quick-wins-mode]], [[coordinator-only]], [[riemann-masullo-sandbox-quirks]], [[github-token-scope]].
