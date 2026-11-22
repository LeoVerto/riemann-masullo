---
name: claims-notes-attribution
description: User rules on claiming, handoff notes and model attribution in riemann-masullo; procedures in HUNTER.md and HOURLY.md
metadata:
  type: feedback
---

The user, 2026-11-22: read issue comments for earlier approaches when claiming; when the watchdog returns an issue, leave hints ("Failed approaches are especially relevant for the watchdog hint"); mention model and effort in comments and PRs; ~08:45Z: "Why are we not claiming these if we're working on them?"; ~16:00Z: keep the claim when an issue moves from Sonnet to Opus; ~17:30Z: have the hourly job check claimed issues for new comments.

**Why:** released issues otherwise get re-attempted from scratch, the project wants to know which model produced what, and unclaimed queued work invites collisions.

**How to apply:** HUNTER.md "Claims, notes, release" (notes format, `escalate.sh`, `release.sh`), HOURLY.md step 3 (stale, refresh, NEW comments) and "Launching agents" (tags), HANDOVER "Claims". Related: [[escalation-ladder]], [[collaborative-not-race]].
