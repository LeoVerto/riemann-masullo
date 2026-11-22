#!/usr/bin/env bash
# release.sh <issue> [reason]
# Posts a "Releasing" comment (first line parsed by upstream's Claims workflow) that carries the
# approach notes in notes/<issue>.md for the next solver, removes the issue from claims.txt and
# archives the notes. Used by agents, the watchdog and the coordinator.
set -u
T=/mnt/faststorage/math/riemann-masullo/.agent/sweeptools; UP=mccorvie/riemann-masullo
n=${1:?usage: release.sh <issue> [reason]}; reason=${2:-the agent working on this stopped before handing in.}
N=$T/notes/$n.md
model=$( [ -s "$N" ] && grep -m1 -i '^model:' "$N" | cut -d: -f2- | sed 's/^ *//' )
body="Releasing${model:+ ($model)}: $reason"
if [ -s "$N" ]; then
  body+=$'\n\nNotes from this attempt, for the next solver:\n\n'"$(grep -vi '^model:' "$N" | head -c 3000)"
fi
gh issue comment "$n" --repo $UP --body "$body" >/dev/null || { echo "release #$n: comment failed"; exit 1; }
sed -i "/^$n\$/d" "$T/claims.txt"
# a queued escalation row must not be picked up without our claim: mark it released
sed -i -E "s/^($n [a-z]+ [^ ]+ [^ ]+) QUEUED /\1 RELEASED $(date -u +%FT%H:%MZ) /" "$T/escalations.txt"
[ -e "$N" ] && mv "$N" "$T/notes/released/$n-$(date +%Y%m%dT%H%M).md"
echo "released #$n${model:+ ($model)}"
