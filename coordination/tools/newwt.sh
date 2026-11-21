#!/usr/bin/env bash
# newwt.sh <branch> <dir>: create a worktree on a new branch at the warm-base commit, with a
# ready .lake/build and the baseline signatures in <dir>-before.txt. No build needed.
set -euo pipefail
br=$1; dir=$2; B=/home/agent/sweeptools/base; MAIN=/home/user/git/riemann-masullo
[ -s $B/COMMIT ] || { echo "warm base not ready yet" >&2; exit 1; }
for try in 1 2 3; do
  c=$(cat $B/COMMIT); cp $B/sig.txt "$dir-before.txt.tmp"
  rm -rf "$dir-build.tmp"; cp -r $B/build "$dir-build.tmp"
  [ "$(cat $B/COMMIT)" = "$c" ] && break
done
git -C $MAIN worktree add -q -b "$br" "$dir" "$c"
mkdir -p "$dir/.lake" "$dir/.agent"
ln -sfn $MAIN/.lake/packages "$dir/.lake/packages"
mv "$dir-build.tmp" "$dir/.lake/build"; mv "$dir-before.txt.tmp" "$dir-before.txt"
echo "worktree $dir on $br at $c (baseline signatures: $dir-before.txt)"
