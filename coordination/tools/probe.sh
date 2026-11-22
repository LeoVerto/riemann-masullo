#!/usr/bin/env bash
# probe.sh: detached Lean probes and builds, so agents' Bash calls stay simple one-liners.
# (A command with `rm -f .agent/$x.exit`, a loop or `setsid` in it can trigger a permission prompt
#  even in bypass mode: "Dangerous rm operation not ruled out". Inside this script it cannot.)
#
#   probe.sh start [-t <s>] <name>...      run from the worktree root: for each name, start
#                                          `timeout <s> lake lean .agent/<name>.lean` detached
#                                          (default 300 s); log .agent/<name>.log, status .agent/<name>.exit
#   probe.sh wait [-t <s>] <name>...       wait up to <s> (default 100) until every .agent/<name>.exit
#                                          exists; prints "<name> exit <n>" or "<name> running"
#   probe.sh run [-t <s>] <name> -- <cmd> [<arg>...]   run from the worktree root: start any long
#                                          command detached (default 900 s), e.g. `scripts/signatures.sh`;
#                                          stdout .agent/<name>.out, stderr .agent/<name>.log, status
#                                          .agent/<name>.exit; then `probe.sh wait <name>`
#   probe.sh build [-t <s>] <wt> [<Module>...]  start S/build.sh detached (default 900 s;
#                                          give 3600 for the full build); log/status <wt>/.agent/build.{log,exit}
#   probe.sh waitbuild [-t <s>] <wt>       wait up to <s> (default 100) for <wt>/.agent/build.exit
# Exit codes of `wait`/`waitbuild`: 0 all done, 3 something still running; `build`: 75 = a build already runs there. 124 in an exit file = timeout.
export LAKE_ARTIFACT_CACHE=true
export LAKE_CACHE_DIR=/mnt/faststorage/math/riemann-masullo/.lake/artifact-cache
export LAKE_RESTORE_ARTIFACTS=true
S=/mnt/faststorage/math/riemann-masullo/.agent/sweeptools
cmd=$1; shift || true
t=; if [ "$1" = -t ]; then t=$2; shift 2; fi
ok() { [[ $1 =~ ^[A-Za-z0-9_.-]+$ && $1 != *..* ]] || { echo "bad name: $1" >&2; exit 2; }; }
case $cmd in
  start)
    [ -d .agent ] && [ -f lakefile.toml ] || { echo "run from a worktree root" >&2; exit 2; }
    for x in "$@"; do ok "$x"; [ -f ".agent/$x.lean" ] || { echo "no .agent/$x.lean" >&2; exit 2; }; done
    for x in "$@"; do
      rm -f ".agent/$x.exit"
      setsid nohup bash -c 'timeout "$1" lake lean ".agent/$2.lean" > ".agent/$2.log" 2>&1; echo $? > ".agent/$2.exit"' _ "${t:-300}" "$x" >/dev/null 2>&1 < /dev/null &
      echo "$x started"
    done ;;
  wait)
    end=$((SECONDS + ${t:-100}))
    while :; do
      all=1; for x in "$@"; do ok "$x"; [ -s ".agent/$x.exit" ] || all=0; done
      [ $all = 1 ] || [ $SECONDS -ge $end ] && break; sleep 5
    done
    for x in "$@"; do
      if [ -s ".agent/$x.exit" ]; then echo "$x exit $(cat ".agent/$x.exit")"; else echo "$x running"; fi
    done
    [ $all = 1 ] || exit 3 ;;
  run)
    [ -d .agent ] && [ -f lakefile.toml ] || { echo "run from a worktree root" >&2; exit 2; }
    x=$1; ok "$x"; shift; [ "$1" = -- ] && shift; [ $# -gt 0 ] || { echo "no command given" >&2; exit 2; }
    rm -f ".agent/$x.exit"
    setsid nohup bash -c 'n=$2; t=$1; shift 2; timeout "$t" "$@" > ".agent/$n.out" 2> ".agent/$n.log"; echo $? > ".agent/$n.exit"' _ "${t:-900}" "$x" "$@" >/dev/null 2>&1 < /dev/null &
    echo "$x started: $* (timeout ${t:-900} s)" ;;
  build)
    wt=$1; shift; [ -d "$wt" ] || { echo "no worktree $wt" >&2; exit 2; }
    mkdir -p "$wt/.agent"
    # build.sh holds this lock while it builds; refuse loudly instead of starting a build that exits 75
    if ! flock -n "$wt/.agent/build.lock" true; then
      echo "a build is already running in $wt: probe.sh waitbuild $wt, then start again if you edited since" >&2; exit 75; fi
    rm -f "$wt/.agent/build.exit"
    BUILD_TIMEOUT=${t:-900} setsid nohup "$S/build.sh" "$wt" "$@" >/dev/null 2>&1 < /dev/null &
    echo "build started in $wt (timeout ${t:-900} s)" ;;
  waitbuild)
    f=$1/.agent/build.exit; end=$((SECONDS + ${t:-100}))
    until [ -s "$f" ] || [ $SECONDS -ge $end ]; do sleep 5; done
    if [ -s "$f" ]; then echo "build exit $(cat "$f")"; else echo "build running"; exit 3; fi ;;
  *) grep '^#' "$0" | tail -n +2; exit 2 ;;
esac
