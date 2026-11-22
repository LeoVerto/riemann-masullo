---
name: github-token-scope
description: The GitHub token in this sandbox may only be used for the LeoVerto fork and the mccorvie upstream of riemann-masullo; it must be a classic token
metadata:
  type: feedback
---

Use the sandbox's GitHub token only for `LeoVerto/riemann-masullo` (fork, remote `fork`) and `mccorvie/riemann-masullo` (upstream, remote `origin`). Never for any other repo.

**Why:** the user set this restriction on 2026-11-21 when swapping in a classic token.

**How to apply:** before any `gh` or `git push` call, check that the target is one of these two. The token must be CLASSIC, with repo, workflow and read:org. A fine-grained PAT gets 403 on upstream comments and PRs, and its fork pushes are rejected (seen 2026-11-22). Check with `.agent/sweeptools/tokencheck.sh` (also in status.sh and step 0 of every brief). On failure ask the user to run `sbx secret set github --sandbox riemann-masullo-faststorage -t <classic token>`. See [[coordinator-only]], [[riemann-masullo-sandbox-quirks]].
