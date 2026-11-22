#!/usr/bin/env bash
# Below LOW MB available: kill the newest exact?-sweep lean process; if none, the newest lean process of any kind
# (a failed build is cheap; an OOM-killed sandbox is not). Changed 2026-11-22 after an OOM kill of the sandbox.
LOW=${LOW:-3000}
while true; do
  avail=$(awk '/MemAvailable/ {print int($2/1024)}' /proc/meminfo)
  if [ "$avail" -lt "$LOW" ]; then
    pid=""; for q in $(pgrep -x lean | sort -rn); do case "$(readlink /proc/$q/cwd 2>/dev/null)" in */.agent/wt/sieve*) pid=$q; break;; esac; done
    [ -n "$pid" ] || pid=$(pgrep -n -x lean)
    [ -n "$pid" ] && { echo "$(date -Is) avail=${avail}MB killing $pid $(tr '\0' ' ' </proc/$pid/cmdline | cut -c1-120)"; kill -9 $pid; }
    sleep 10
  fi
  sleep 2
done
