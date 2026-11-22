#!/usr/bin/env bash
export LAKE_ARTIFACT_CACHE=true
export LAKE_CACHE_DIR=/mnt/faststorage/math/riemann-masullo/.lake/artifact-cache
export LAKE_RESTORE_ARTIFACTS=true
# build.sh <worktree> [lake build args]: run `lake build` in <worktree>, log to
# <worktree>/.agent/build.log, and write the exit status to <worktree>/.agent/build.exit when done.
# To wait for it: test -s <worktree>/.agent/build.exit  (never pgrep: other agents build too).
wt=$1; shift; mkdir -p "$wt/.agent"; rm -f "$wt/.agent/build.exit"
cd "$wt" && lake build "$@" >"$wt/.agent/build.log" 2>&1; s=$?
echo $s >"$wt/.agent/build.exit"; exit $s
