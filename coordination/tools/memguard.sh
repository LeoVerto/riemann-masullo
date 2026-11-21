#!/usr/bin/env bash
# Kill the newest exact?-sweep lean process whenever available memory drops below 1.5 GB.
while true; do
  avail=$(awk '/MemAvailable/ {print int($2/1024)}' /proc/meminfo)
  if [ "$avail" -lt 1500 ]; then
    pid=$(pgrep -n -f '^lean --json RiemannMasullo/') && { echo "$(date -Is) avail=${avail}MB killing $pid $(tr '\0' ' ' </proc/$pid/cmdline | cut -c1-120)"; kill -9 $pid; }
    sleep 10
  fi
  sleep 3
done
