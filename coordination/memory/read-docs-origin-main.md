---
name: read-docs-origin-main
description: Re-read AGENTS.md, CONTRIBUTING.md, ERRATA.md from origin/main (main checkout is stale); their gap/false-statement handling binds our hunters
metadata:
  type: feedback
---

User, 2026-11-22: re-read AGENTS and CONTRIBUTING and ERRATA; "The Gap handling especially seems like something our hunters should know."

**Why:** upstream keeps revising these (e.g. 15e78ca, 02f36f8 added "False statements and gaps": false statements become `Printed.<name>` + `_false`; gaps are named sorried theorems with a `Gap:` line and label `gap`; only the integrator changes statements; findings need evidence). The main checkout's working tree lags (was d2f3f35), so `$R/AGENTS.md` can be stale.

**How to apply:** read them via `git show origin/main:<file>` at session start and whenever `git log origin/main -- AGENTS.md CONTRIBUTING.md ERRATA.md` shows changes; keep the end section of sweeptools/HUNTER.md ("Read the CURRENT project docs; false statements and gaps") in line, and point SIEVER/CRITICAL_PROVER at it. Related: [[low-hanging-mode]], [[claims-notes-attribution]].
