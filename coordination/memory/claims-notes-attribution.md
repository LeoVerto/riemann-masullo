---
name: claims-notes-attribution
description: Agents read full issue threads before claiming, claim everything we work on or queue, keep notes/<n>.md (failed approaches first) posted on release, and tag claims/PRs with model and effort
metadata:
  type: feedback
---

The user, 2026-11-22:
- Read issue comments for earlier approaches when claiming.
- When the watchdog returns an issue, leave hints for the next solver ("Failed approaches are especially relevant for the watchdog hint").
- Mention model and effort in comments and PRs.
- ~08:45Z: "Why are we not claiming these if we're working on them?"

**Why:** released issues otherwise get re-attempted from scratch, the project wants to know which model produced what, and unclaimed queued work invites collisions.

**How to apply:**
- Tag <M> = `Claude Sonnet 5.5, effort medium` / `Claude Opus 5.5, default effort`. Claims start `Claiming (<M>)` (upstream parses only the first word). PR bodies carry `Prover: <M>` above the 🤖 line.
- Claim every issue we work on OR have queued for one of our agents. An escalated issue is re-claimed for Opus at once ("queued for an Opus prover") and added to claims.txt. Stale-claim releases skip the ESCALATION QUEUE.
- `.agent/sweeptools/notes/<n>.md` is the only handoff file: Model, Status, Failed approaches (first), Blocked by, Useful, Next idea. Update it after every build or failed approach.
- Release ONLY via `release.sh <n> "<reason>"`: it posts the notes, updates claims.txt and archives to notes/released/. The watchdog uses it too.
- The watchdog releases ALL claims when every session is idle, as at the usage halts (10:03Z and 12:03Z on 2026-11-22). After resuming, re-claim what the resumed agents and the escalation queue hold.
Related: [[quick-wins-mode]], [[low-hanging-sweep]].
