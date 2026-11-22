#!/usr/bin/env bash
# resumable.sh: open, unclaimed proof issues on which we left real prior work (a released note
# whose Status is more than "not started"/"started"), not in claims.txt or the escalation queue. These
# are the coordinator's second choice for a free Opus slot (HOURLY.md step 8): re-claim, restore the
# notes, queue with escalate.sh. One line each: issue, model of the last attempt, its Status, and
# the agents.txt line that still lists it, if any (check that agent before queuing). Claims are
# comments upstream: an issue whose latest Claiming/Releasing comment is someone else's claim is
# skipped.
set -u
S=/mnt/faststorage/math/riemann-masullo/.agent/sweeptools; R=mccorvie/riemann-masullo
free=$(gh api --paginate "repos/$R/issues?state=open&labels=proof&per_page=100" --jq '.[]
  | select(.pull_request|not) | select([.labels[].name]
  | (index("gap") or index("refutation") or index("sweep")) | not) | .number' | sort -u)
[ -n "$free" ] || { echo "resumable: no open unclaimed proof issues (gh failed?)"; exit 0; }
for n in $(ls "$S/notes/released" | sed -n 's/^\([0-9]*\)-.*\.md$/\1/p' | sort -un); do
  grep -qx "$n" <<<"$free" || continue
  grep -qx "$n" "$S/claims.txt" && continue
  grep -qE "^$n (opus|fable) [^ ]+ [^ ]+ (QUEUED|TAKEN)" "$S/escalations.txt" && continue
  f=$(ls "$S"/notes/released/"$n"-*.md | sort | tail -1)
  last=$(gh api "repos/$R/issues/$n/comments?per_page=100" --jq '[.[] | select(.body | test("^(Claiming|Releasing)"))]
    | last | "\(.user.login) \(.body | split(" ")[0])"' 2>/dev/null)
  case $last in *" Claiming"*) [ "${last%% *}" = LeoVerto ] || continue;; esac
  st=$(grep -m1 '^Status:' "$f" | cut -d: -f2- | sed 's/^ *//')
  grep -qiE '^(not (yet )?(started|attempted)|started|starting|just claimed)[ .]*$' <<<"$st" && continue
  held=$(awk -v n="$n" '!/^#/ {for (i = 4; i <= NF; i++) if ($i == n) {print "agents.txt:" $1; exit}}' "$S/agents.txt")
  printf '%s\t%s\t%s\t%s\n' "$n" "$(grep -m1 '^Model:' "$f" | cut -d: -f2- | sed 's/^ *//')" "${st:0:120}" "$held"
done
