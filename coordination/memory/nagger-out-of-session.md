---
name: nagger-out-of-session
description: Notes nagger must run entirely outside the coordinator session — one long-running Haiku loop, not cron ticks
metadata:
  type: feedback
---

The notes nagger is ONE long-running Haiku subagent (sweeptools/NAGGER.md) that loops in a single turn on `nag-wait.sh` (foreground blocking ≤10 min per call) and SendMessages stale hunters by agentId. No cron in the coordinator session for it (user, 2026-11-22 ~07:30Z: "I asked for a haiku subagent to keep it entirely out of this session. Maybe Cron scheduling is the wrong tool then?").

**Why:** cron ticks and per-tick Haiku launches spent coordinator turns and cluttered the session.
**How to apply:** the coordinator only keeps `sweeptools/agents.txt` in sync and relaunches the nagger if it ends; stop it by touching `sweeptools/nagger.stop`. Related: [[quick-wins-mode]], [[one-pr-per-file]].

**Rerouting (2026-11-22 ~18:40Z):** a SendMessage to an agent that has ended its turn (idle, e.g. waiting on a background build) RESUMES it, and the harness then routes its results to the sender (the nagger), not the coordinator. A busy (mid-tool) agent only queues the message. This is mechanical, not promptable. It started once agents ran builds in the background (CPU-load timeouts). Fix: nag-wait.sh skips agents whose last transcript entry is assistant end_turn. Interval is 20 min (user): `nag-wait.sh 20 20 1170`, run in the background.
