#!/usr/bin/env bash
# escalate.sh <issue> "<reason>"
# Hands a STUCK issue from a Sonnet agent to an Opus escalator WITHOUT releasing it: our upstream
# claim stays (no comment is posted), the issue stays in claims.txt, notes/<issue>.md stays in
# place for the escalator, and a row is added to escalations.txt (the escalation queue).
# Use release.sh instead when the issue was merely not attempted or someone else holds it.
set -u
T=/mnt/faststorage/math/riemann-masullo/.agent/sweeptools
n=${1:?usage: escalate.sh <issue> "<reason>"}; reason=${2:?give a one-line reason}
N=$T/notes/$n.md; Q=$T/escalations.txt
[ -s "$N" ] || { echo "escalate #$n: notes/$n.md missing or empty; write it first"; exit 1; }
grep -qx "$n" "$T/claims.txt" || { echo "escalate #$n: not in claims.txt (claim lost?); tell the coordinator"; exit 1; }
grep -q "^$n " "$Q" 2>/dev/null && { echo "escalate #$n: already queued"; exit 0; }
model=$(grep -m1 -i '^model:' "$N" | cut -d: -f2- | sed 's/^ *//')
printf '\nEscalated %s from %s: %s\n' "$(date -u +%FT%H:%MZ)" "${model:-?}" "$reason" >> "$N"
file=$(gh issue view "$n" --repo mccorvie/riemann-masullo --json body \
  --jq '.body | capture("<!-- sorry: (?<f>[^ ]+) -->").f? // "-"' 2>/dev/null | cut -d: -f1)
echo "$n ${file:--} $(date -u +%FT%H:%MZ) QUEUED ${model:-?}: $reason" >> "$Q"
echo "escalated #$n (claim kept)"
