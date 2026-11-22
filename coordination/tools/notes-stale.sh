#!/usr/bin/env bash
# Lists running hunters (agents.txt) whose notes are stale: newest of notes/<issue>.md and
# notes/handoff-<name>.md older than ${1:-20} minutes (or none since the hunter started).
# Output: STALE <name> <agentId> <age_min>   or   OK <name> <age_min>
S=$(cd "$(dirname "$0")" && pwd); lim=${1:-20}; now=$(date +%s)
grep -v '^#' "$S/agents.txt" | while read -r name id start issues; do
  [ -z "$name" ] && continue
  newest=$start
  for f in "$S/notes/handoff-$name.md" $(for i in $issues; do echo "$S/notes/$i.md"; done); do
    [ -f "$f" ] && m=$(stat -c %Y "$f") && [ "$m" -gt "$newest" ] && newest=$m
  done
  age=$(( (now-newest)/60 ))
  if [ "$age" -gt "$lim" ]; then echo "STALE $name $id $age"; else echo "OK $name $age"; fi
done
