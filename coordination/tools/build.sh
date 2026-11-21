#!/usr/bin/env bash
# build.sh <worktree> [lake build args]: run `lake build` in <worktree>, log to
# <worktree>/.agent/build.log, and write the exit status to <worktree>/.agent/build.exit when done.
# To wait for it: test -s <worktree>/.agent/build.exit  (never pgrep: other agents build too).
wt=$1; shift; mkdir -p "$wt/.agent"; rm -f "$wt/.agent/build.exit"
cd "$wt" && lake build "$@" >"$wt/.agent/build.log" 2>&1; s=$?
echo $s >"$wt/.agent/build.exit"; exit $s
