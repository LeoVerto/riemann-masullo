#!/usr/bin/env bash
# Keep a warm, built copy of origin/main for subagents.
# Every $INTERVAL s: fetch; if origin/main moved, check it out in /home/agent/wt/base, lake build,
# dump signatures, and publish a snapshot:
#   /home/agent/sweeptools/base/COMMIT        commit hash of the latest ready snapshot
#   /home/agent/sweeptools/base/build/        its .lake/build (copy this, do not modify it)
#   /home/agent/sweeptools/base/sig.txt       scripts/signatures.sh output at COMMIT
# A snapshot is swapped in with mv, so readers see either the old or the new one.
set -u
T=/home/agent/sweeptools; B=$T/base; WT=/home/agent/wt/base; MAIN=/home/user/git/riemann-masullo
INTERVAL=${INTERVAL:-600}
mkdir -p $B
if [ ! -d $WT ]; then
  git -C $MAIN worktree add -q --detach $WT origin/main
  mkdir -p $WT/.lake && ln -sfn $MAIN/.lake/packages $WT/.lake/packages
  cp -r /home/agent/wt/sweep/.lake/build $WT/.lake/build
fi
while true; do
  git -C $MAIN fetch -q origin 2>/dev/null
  want=$(git -C $MAIN rev-parse origin/main)
  have=$(cat $B/COMMIT 2>/dev/null || true)
  if [ "$want" != "$have" ]; then
    cd $WT && git checkout -q --detach "$want"
    if lake build >$B/build.log 2>&1 && scripts/signatures.sh >$B/sig.tmp 2>>$B/build.log; then
      rm -rf $B/build.new && cp -r $WT/.lake/build $B/build.new
      # publish: COMMIT is written last, so a reader who reads COMMIT first and then copies
      # may get a newer build than COMMIT names; readers re-check COMMIT after copying.
      rm -rf $B/build.old; [ -d $B/build ] && mv $B/build $B/build.old
      mv $B/build.new $B/build && mv $B/sig.tmp $B/sig.txt && echo "$want" >$B/COMMIT
      rm -rf $B/build.old
      echo "$(date -Is) ready $want"
    else
      echo "$(date -Is) build failed at $want (see $B/build.log)"
    fi
  fi
  touch $T/activity
  sleep $INTERVAL
done
