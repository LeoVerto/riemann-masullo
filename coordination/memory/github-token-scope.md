---
name: github-token-scope
description: Use the sandbox GitHub token only for the LeoVerto fork and the mccorvie upstream; it must be a classic token
metadata:
  type: feedback
---

The user, 2026-11-21, when swapping in a classic token: use it only for `LeoVerto/riemann-masullo` (remote `fork`) and `mccorvie/riemann-masullo` (remote `origin`), never any other repo.

**Why:** the user's restriction; a fine-grained PAT also failed upstream (403) on 2026-11-22.

**How to apply:** check the target before any `gh` or `git push`. Token check and fix: HANDOVER "Token" and startup step 2 (`tokencheck.sh`). Related: [[riemann-masullo-sandbox-quirks]].
