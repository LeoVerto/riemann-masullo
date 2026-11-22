#!/usr/bin/env bash
# escalate.sh <issue> "<reason>" [--to opus|fable]
# Hands a STUCK issue to the next tier WITHOUT releasing it: our upstream claim stays (no comment
# is posted), the issue stays in claims.txt, notes/<issue>.md stays in place, and a row is added
# to escalations.txt.
#   --to opus  (default): a Sonnet is stuck; an Opus escalator continues (HUNTER.md "Escalators").
#   --to fable: an Opus agent is stuck; a Fable consultant reads the "## Stuck packet" in the notes
#               and writes a route (FABLE.md); then an Opus escalator implements it (--to opus again).
# Use release.sh instead when the issue was merely not attempted or someone else holds it.
set -u
T=/mnt/faststorage/math/riemann-masullo/.agent/sweeptools
n=${1:?usage: escalate.sh <issue> "<reason>" [--to opus|fable]}; reason=${2:?give a one-line reason}
level=opus; [ "${3:-}" = --to ] && level=${4:?--to needs opus or fable}
case $level in opus|fable) ;; *) echo "escalate: unknown level $level"; exit 1;; esac
N=$T/notes/$n.md; Q=$T/escalations.txt
[ -s "$N" ] || { echo "escalate #$n: notes/$n.md missing or empty; write it first"; exit 1; }
if [ $level = fable ] && ! grep -q '^## Stuck packet' "$N"; then
  echo "escalate #$n: add a '## Stuck packet' section to notes/$n.md first (HUNTER.md 'Stuck packet')"; exit 1
fi
grep -qx "$n" "$T/claims.txt" || { echo "escalate #$n: not in claims.txt (claim lost?); tell the coordinator"; exit 1; }
grep -qE "^$n $level [^ ]+ [^ ]+ (QUEUED|TAKEN)" "$Q" 2>/dev/null && { echo "escalate #$n: already queued for $level"; exit 0; }
model=$(grep -m1 -i '^model:' "$N" | cut -d: -f2- | sed 's/^ *//')
printf '\nEscalated to %s %s from %s: %s\n' "$level" "$(date -u +%FT%H:%MZ)" "${model:-?}" "$reason" >> "$N"
file=$(gh issue view "$n" --repo mccorvie/riemann-masullo --json body \
  --jq '.body | capture("<!-- sorry: (?<f>[^ ]+) -->").f? // "-"' 2>/dev/null | cut -d: -f1)
echo "$n $level ${file:--} $(date -u +%FT%H:%MZ) QUEUED ${model:-?}: $reason" >> "$Q"
echo "escalated #$n to $level (claim kept)"
