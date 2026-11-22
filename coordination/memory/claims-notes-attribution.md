---
name: claims-notes-attribution
description: Agents read full issue threads before claiming, keep per-issue approach notes (failed approaches first) posted on release, and tag claims/PRs with model and effort
metadata:
  type: feedback
---

The user, 2026-11-22: read issue comments for earlier approaches when claiming; when the watchdog returns an issue, leave hints for the next solver ("Failed approaches are especially relevant for the watchdog hint"); mention model and effort in comments and PRs.

**Why:** released issues get re-attempted from scratch otherwise, and the project wants to know which model produced what.

**How to apply:**
- Rules are in the last section of HUNTER.md and CRITICAL_PROVER.md. Launch prompts give the tag <M>, e.g. `Claude Sonnet 5.5, effort medium` or `Claude Opus 5.5, default effort`.
- Claim with first line `Claiming (<M>)`. Upstream's claims.yml only parses the first word, so this is safe.
- Notes live in .agent/sweeptools/notes/<n>.md and are the ONLY handoff file (STATE.md dropped 2026-11-22 as duplicate): Model, Status, Failed approaches (first), Blocked by, Useful, Next idea. Agents must update it after every build/failed approach, since the watchdog posts it on the issue and stale notes lose hours of work.
- Release ONLY via .agent/sweeptools/release.sh <n> "<reason>": it posts `Releasing (<M>): reason` plus the notes, updates claims.txt and archives to notes/released/. watchdog.sh calls it, and so should the coordinator for stale or orphan claims.
- PR bodies carry `Prover: <M>` above the 🤖 line.
Related: [[low-hanging-sweep]], [[critical-path-workstream]].

Update (user, 2026-11-22 ~08:45Z): "Why are we not claiming these if we're working on them?" — claim every issue we work on OR have queued for one of our agents. When a Sonnet releases an issue as stuck and it is escalated to Opus, re-claim it immediately ("Claiming (Claude Opus 5.5, default effort)", noting it is queued), add to claims.txt; never leave queued work released. Stale-claim releases must skip the ESCALATION QUEUE in leads.txt.
