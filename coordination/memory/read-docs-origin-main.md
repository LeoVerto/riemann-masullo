---
name: read-docs-origin-main
description: Read AGENTS/CONTRIBUTING/ERRATA from origin/main and keep the briefs in line; gap handling binds hunters
metadata:
  type: feedback
---

The user, 2026-11-22: re-read AGENTS, CONTRIBUTING and ERRATA; "The Gap handling especially seems like something our hunters should know."

**Why:** upstream revises them often, and the main checkout's working tree lags behind origin/main.

**How to apply:** `git show origin/main:<file>`; HOURLY.md step 0 tracks the last-seen commits; HUNTER.md "Paper errors, gaps, ERRATA" carries the rules. Related: [[formathlib-convention]].
