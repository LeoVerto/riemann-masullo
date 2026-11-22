---
name: github-token-scope
description: The GitHub token in this sandbox may only be used for the LeoVerto fork and the mccorvie upstream of riemann-masullo
metadata:
  node_type: memory
  type: feedback
  originSessionId: ee383891-aed6-4f02-9fc3-747389749c9d
  modified: 2026-11-21T02:27:47.554Z
---

Use the sandbox's GitHub token only for `LeoVerto/riemann-masullo` (fork, remote `fork`) and `mccorvie/riemann-masullo` (upstream, remote `origin`). Never for any other repo.

**Why:** On 2026-11-21 the user swapped the fine-grained PAT, which couldn't comment or open PRs upstream, for a classic token and set this restriction explicitly.

**How to apply:** Before any `gh`/`git push` call, check the target repo is one of these two. See also [[riemann-masullo-sandbox-quirks]].

2026-11-22: after the sandbox recreation the user first set a FINE-GRAINED PAT (no X-OAuth-Scopes header, expires 2026-12-21): comments and PRs upstream get 403 and pushes to `fork` are rejected (workflow file). Needs the classic token (repo, workflow, read:org). Check with `gh api -i user | grep -i x-oauth-scopes`. Hand-ins waiting on the token are listed in .agent/sweeptools/pending_handins.txt.
Startup check: `.agent/sweeptools/tokencheck.sh` (also in status.sh and as step 0 of both briefs), see [[coordinator-only]].
