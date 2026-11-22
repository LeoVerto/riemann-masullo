---
name: coordinator-only
description: In riemann-masullo campaigns the main session only coordinates and keeps its context small; everything else is delegated
metadata:
  type: feedback
---

The user, 2026-11-22: "make sure the main session acts only as a coordinator to keep its context small"; earlier: "Do not run any work yourself, you are the coordinator."

**Why:** the main session lives for days, and every tool output it reads costs usage on every later turn.

**How to apply:** no proofs, builds or long log reads in the main session; small infrastructure edits of a few commands are fine. Startup order (token check first, then services, types, cron) is the HANDOVER startup checklist. Related: [[low-hanging-sweep]], [[cpu-cheap-tokens-scarce]].
