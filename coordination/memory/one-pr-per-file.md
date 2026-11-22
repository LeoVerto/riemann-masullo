---
name: one-pr-per-file
description: User rule - every hunter/siever PR covers exactly one Lean file
metadata:
  type: feedback
---

The user, 2026-11-22 ~05:50Z: one PR per touched Lean file.

**Why:** matches CONTRIBUTING "Take a file, not an issue": per-file PRs don't collide and merge independently.

Hunter lifetime (user, 2026-11-22, resolving a conflict with "Keep subagents running for 4 PRs"): "Files in sequence": a hunter works its files one after another, one PR each, until its list is done, 4 PRs or ~3 h.

**How to apply:** HOURLY.md step 7a and HUNTER.md steps 6–7. Related: [[quick-wins-mode]], [[subagent-model-effort]].
