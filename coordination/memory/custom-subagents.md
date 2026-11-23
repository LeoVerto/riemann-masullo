---
name: custom-subagents
description: riemann-masullo agents launch by subagent type (definitions in .agent/agents) from the session after 2026-11-22 ~18:00Z; edits need a restart
metadata:
  type: project
---

At the user's request (2026-11-22 ~17:45Z) eight thin definitions live in `.agent/agents/` (hunter, siever, escalator, opus-hunter, fable-consultant, findings-evaluator, triage, nagger), linked as `.claude/agents`. Launch table: HOURLY.md "Launching agents"; load and reload behaviour (tested with claude -p probes): HANDOVER startup step 4.

**Why:** briefs change often during a campaign and the coordinator runs for days.
**How to apply:** keep role logic in the briefs, not the definitions; to change a type's model or tools mid-session, add a new file under a new name. Related: [[subagent-model-effort]].
