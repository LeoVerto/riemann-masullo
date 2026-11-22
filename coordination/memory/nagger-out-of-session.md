---
name: nagger-out-of-session
description: Notes nagger must run entirely outside the coordinator session — one long-running Haiku loop, not cron ticks
metadata:
  type: feedback
---

The notes nagger is ONE long-running Haiku subagent (sweeptools/NAGGER.md) that loops in a single turn on `nag-wait.sh` (foreground blocking ≤10 min per call) and SendMessages stale hunters by agentId. No cron in the coordinator session for it (user, 2026-11-22 ~07:30Z: "I asked for a haiku subagent to keep it entirely out of this session. Maybe Cron scheduling is the wrong tool then?").

**Why:** cron ticks and per-tick Haiku launches spent coordinator turns and cluttered the session.
**How to apply:** the coordinator only keeps `sweeptools/agents.txt` in sync and relaunches the nagger if it ends; stop it by touching `sweeptools/nagger.stop`. Related: [[low-hanging-mode]], [[one-pr-per-file]].
