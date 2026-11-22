---
name: custom-subagents
description: Draft custom subagent types for riemann-masullo live in .agent/agents (symlinked as .claude/agents); edits to a definition need a session restart, new files do not
metadata:
  type: project
---

2026-11-22 ~17:45Z, at the user's request: eight thin-wrapper definitions in `.agent/agents/` (hunter, siever, escalator, opus-hunter, fable-consultant, findings-evaluator, triage, nagger). Each fixes model/effort/tools and points to its brief in `.agent/sweeptools/`. `.claude/agents` -> `../.agent/agents` (symlink, listed in `.git/info/exclude`). HOURLY.md does not use them yet; switching over is the user's call.

Reload behaviour, tested with Claude Code 2.1.330 and claude -p probes:
- A session sees `.claude/agents` only if that directory existed when the session started. Sessions started earlier must restart.
- In a session that has the directory, a NEW definition file is picked up mid-session.
- An EDIT to an existing definition (body, and probably frontmatter) is NOT picked up until restart.

**Why:** briefs change often during a campaign and the coordinator runs for days.
**How to apply:** keep role logic in the briefs, not the definitions. To change a type's model or tools without a restart, add a new file under a new name. Related: [[subagent-model-effort]], [[escalation-ladder]], [[coordinator-only]].
