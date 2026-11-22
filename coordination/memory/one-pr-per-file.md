---
name: one-pr-per-file
description: "Hunters/sievers open one PR per touched Lean file, never a PR spanning files"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 00d88758-043b-469f-b435-e8a706bdbafe
  modified: 2026-11-22T05:55:39.163Z
---

Every hunter/siever PR covers exactly one Lean file; a batch spanning several files is handed in as one PR per file (user instruction, 2026-11-22 ~05:50Z).

**Why:** matches CONTRIBUTING "Take a file, not an issue": per-file PRs don't collide and merge independently.
**How to apply:** assign hunters one file each where possible; written into HUNTER.md "One file at a time". See [[low-hanging-mode]].
