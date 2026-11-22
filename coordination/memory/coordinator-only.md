---
name: coordinator-only
description: In riemann-masullo campaigns the main session only coordinates (small context); on the 2026-11-22 restart, settle Lake caching with one subagent before launching any other
metadata:
  type: feedback
---

The user, 2026-11-22: "make sure the main session acts only as a coordinator to keep its context small". Earlier: "Do not run any work yourself, you are the coordinator."

**Why:** the main session lives for days, and every tool output it reads stays in its context and costs usage on every turn.

**How to apply:**
- No proofs, builds or long log reads in the main session. Delegate them to subagents and keep only their short reports.
- Small infrastructure edits are fine when they are a few commands.
- For the fresh session started after 2026-11-22: first launch ONE subagent to figure out the Lake artifact cache (test `LAKE_RESTORE_ARTIFACTS=true`; see the HANDOVER.md startup checklist), and only then start hunters or provers.

Related: [[critical-path-workstream]], [[low-hanging-sweep]], [[riemann-masullo-sandbox-quirks]].
- **Coordinator startup (user asked 2026-11-22):** before launching any agent, run `.agent/sweeptools/tokencheck.sh` (exit 0 + `TOKEN OK` needed; it requires a classic token with repo, workflow, read:org). On `TOKEN FAIL`, ask the user to fix the token: `sbx secret set github --sandbox riemann-masullo-faststorage -t <classic token>`. status.sh runs it every hour too, and HUNTER.md / CRITICAL_PROVER.md make it every agent's step 0.
