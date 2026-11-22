#!/usr/bin/env bash
export LAKE_ARTIFACT_CACHE=true
export LAKE_CACHE_DIR=/mnt/faststorage/math/riemann-masullo/.lake/artifact-cache
export LAKE_RESTORE_ARTIFACTS=true
# build.sh <worktree> [lake build args]: run `lake build` in <worktree>, log to
# <worktree>/.agent/build.log, and write the exit status to <worktree>/.agent/build.exit when done.
# To wait for it: test -s <worktree>/.agent/build.exit  (never pgrep: other agents build too).
# BUILD_TIMEOUT=<seconds> (default 3600) caps the build; a timeout writes exit status 124.
wt=$1; shift; mkdir -p "$wt/.agent"
# One build per worktree: a second one would share build.log/build.exit (esc-ch10sec3, 2026-11-22).
exec 9>"$wt/.agent/build.lock"; if ! flock -n 9; then echo "build.sh: another build is running in $wt; wait for its build.exit" >&2; exit 75; fi
rm -f "$wt/.agent/build.exit"
cd "$wt" && timeout "${BUILD_TIMEOUT:-3600}" lake build "$@" >"$wt/.agent/build.log" 2>&1; s=$?
echo $s >"$wt/.agent/build.exit"; exit $s
