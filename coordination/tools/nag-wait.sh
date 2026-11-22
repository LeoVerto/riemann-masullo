#!/usr/bin/env bash
# Blocks until a hunter in agents.txt has stale notes (> LIM min) and was not nagged in the
# last COOL min; logs "NAGGED" lines to nag.log and prints "STALE <name> <agentId> <age>".
# Prints "TICK" after MAX seconds with nothing to do, "EMPTY" if agents.txt has no hunters.
# Skips agents that are idle (last transcript entry = assistant end_turn, e.g. waiting on a
# background build): a SendMessage would RESUME them and they would then report to the nagger
# instead of the coordinator. A busy agent only queues the message. They are nagged once busy.
# usage: nag-wait.sh [LIM=20] [COOL=20] [MAX=1170]
S=$(cd "$(dirname "$0")" && pwd); LIM=${1:-20}; COOL=${2:-20}; MAX=${3:-1170}; end=$(( $(date +%s) + MAX ))
while :; do
  grep -qv '^#' "$S/agents.txt" 2>/dev/null || { echo EMPTY; exit 0; }
  now=$(date +%s); out=""
  while read -r tag name id age; do
    [ "$tag" = STALE ] || continue
    tr=$(ls ~/.claude/projects/*/*/subagents/agent-"$id".jsonl 2>/dev/null | head -1)
    if [ -n "$tr" ] && tail -1 "$tr" | python3 -c 'import sys,json; r=json.loads(sys.stdin.read()); sys.exit(0 if r.get("type")=="assistant" and r.get("message",{}).get("stop_reason")=="end_turn" else 1)' 2>/dev/null; then continue; fi
    last=$(grep " $name NAGGED" "$S/nag.log" 2>/dev/null | tail -1 | cut -d' ' -f1)
    if [ -n "$last" ] && [ $(( now - $(date -d "$last" +%s) )) -lt $(( COOL*60 )) ]; then continue; fi
    echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) $name NAGGED $age" >> "$S/nag.log"
    out+="STALE $name $id $age"$'\n'
  done < <("$S/notes-stale.sh" "$LIM")
  [ -n "$out" ] && { printf %s "$out"; exit 0; }
  [ "$(date +%s)" -ge "$end" ] && { echo TICK; exit 0; }
  sleep 60
done
