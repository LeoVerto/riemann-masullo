---
name: nagger-out-of-session
description: Notes nagger must run entirely outside the coordinator session — one long-running Haiku loop, not cron ticks
metadata:
  type: feedback
---

The notes nagger is ONE long-running Haiku subagent (sweeptools/NAGGER.md) that loops in a single turn on `nag-wait.sh` (foreground blocking ≤10 min per call) and SendMessages stale hunters by agentId. No cron in the coordinator session for it (user, 2026-11-22 ~07:30Z: "I asked for a haiku subagent to keep it entirely out of this session. Maybe Cron scheduling is the wrong tool then?").

**Why:** cron ticks and per-tick Haiku launches spent coordinator turns and cluttered the session.
**How to apply:** the coordinator only keeps `sweeptools/agents.txt` in sync and relaunches the nagger if it ends; stop it by touching `sweeptools/nagger.stop`. Related: [[quick-wins-mode]], [[one-pr-per-file]].

**Rerouting and foreground waits (user, 2026-11-22 ~18:50Z):** a SendMessage to an agent that has ended its turn (idle, e.g. waiting on a background build) RESUMES it, and its results then go to the sender. This is mechanical, not promptable. Fix chosen by the user: everyone waits in the FOREGROUND, never `run_in_background` (HUNTER.md "Builds and processes": `timeout 540` direct, longer via detached `BUILD_TIMEOUT=… setsid nohup build.sh` plus repeated `timeout 590` until-loops). The nagger too (`timeout 590 nag-wait.sh 20 20 570` in the foreground), or every background completion pings the coordinator's session. The idle-skip workaround in nag-wait.sh was reverted at the user's request. Nag cooldown 20 min (user).

**Harness limits (tested 2026-11-22 17:27Z):** a subagent's foreground Bash call is moved to the background after 180 s ("Command was moved to the background … after running for 180s"), and any SendMessage to a busy agent also moves its running call to the background. So foreground waits are `timeout 170` calls, repeated (HUNTER.md "Builds and processes"; nagger `nag-wait.sh 20 20 160`), and the coordinator messages running agents only when needed.
