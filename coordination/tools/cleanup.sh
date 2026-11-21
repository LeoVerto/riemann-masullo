#!/usr/bin/env bash
# Remove worktrees under /home/agent/wt whose branch has a merged PR upstream.
MAIN=/home/user/git/riemann-masullo
for d in /home/agent/wt/*/ /home/agent/wt/hunt/*/; do
  d=${d%/}; case $d in */wt/sweep|*/wt/base|*/wt/hunt) continue;; esac
  br=$(git -C $d branch --show-current 2>/dev/null); [ -n "$br" ] || continue
  st=$(gh pr list --repo mccorvie/riemann-masullo --head "$br" --state merged --json number --jq '.[0].number // empty')
  [ -n "$st" ] || continue
  git -C $MAIN worktree remove --force $d && git -C $MAIN branch -D "$br" >/dev/null && rm -f $d-* && echo "removed $d (PR #$st merged)"
done
df -h / | awk 'NR==2{print "disk free "$4}'
