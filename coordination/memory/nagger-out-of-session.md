---
name: nagger-out-of-session
description: The notes nagger is one long-running Haiku subagent, not cron ticks; all agents wait in the FOREGROUND
metadata:
  type: feedback
---

The user, 2026-11-22 ~07:30Z: "I asked for a haiku subagent to keep it entirely out of this session. Maybe Cron scheduling is the wrong tool then?" ~17:50Z, after a nagger message resumed an idle agent and its results went to the nagger: everyone waits in the foreground, never `run_in_background`; nag cooldown 20 min; the idle-skip workaround reverted.

**Why:** cron ticks spent coordinator turns; a SendMessage to an agent that ended its turn resumes it and reroutes its results to the sender (mechanical, not promptable).

**How to apply:** NAGGER.md (loop, `nag-wait.sh`), HUNTER.md "Builds and processes" (170 s foreground calls), HOURLY.md step 4 (relaunch), HANDOVER "Lessons" (the harness facts). Related: [[cpu-cheap-tokens-scarce]].
