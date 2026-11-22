#!/usr/bin/env bash
# One-shot status for the coordinator's periodic check.
# status.sh [--mark]: --mark (the hourly check) advances comments.seen, the start of the
# "new comments on our claims" window; manual runs leave it alone.
T=/mnt/faststorage/math/riemann-masullo/.agent/sweeptools; R=mccorvie/riemann-masullo
echo "== $(date '+%H:%M') host"; free -m | awk 'NR==2{print "mem avail "$7"MB"}'; df -h / | awk 'NR==2{print "disk free "$4}'; uptime | sed 's/.*load/load/'
echo "== token"; $T/tokencheck.sh
echo "lake cache (unique, excluding hardlinks into packages) $(du -sh /mnt/faststorage/math/riemann-masullo/.lake/packages /mnt/faststorage/math/riemann-masullo/.lake/artifact-cache 2>/dev/null | tail -1 | cut -f1)"
echo "== PRs (LeoVerto, open + merged today)"
gh pr list --repo $R --author LeoVerto --state all --limit 30 --json number,state,title,statusCheckRollup,reviews,comments \
  --jq '.[] | select(.state=="OPEN" or .state=="MERGED") | "\(.number) \(.state) \([.statusCheckRollup[]? | select(.name=="Verdict") | .conclusion] | join(",")) rev=\(.reviews|length) com=\(.comments|length) \(.title[:60])"' 2>&1 | head -30
echo "== claims.txt ($(wc -l < $T/claims.txt))"; tr '\n' ' ' < $T/claims.txt; echo
echo "== warm base"; echo "ready $(cut -c1-8 $T/base/COMMIT)  main $(git -C /mnt/faststorage/math/riemann-masullo rev-parse --short=8 origin/main)  $(tail -1 $T/warm.log)"
echo "== memguard"; tail -1 $T/memguard.log
echo "== sweep"; echo "res1 $(ls $T/res1 | wc -l) files, res2 $(ls $T/res2 | wc -l) files; chain: $(tail -1 $T/chain.log 2>/dev/null)"
python3 - <<'PY'
import json,glob,os
seen=set(open('/mnt/faststorage/math/riemann-masullo/.agent/sweeptools/dispatched.txt').read().split()) if os.path.exists('/mnt/faststorage/math/riemann-masullo/.agent/sweeptools/dispatched.txt') else set()
for f in sorted(glob.glob('/mnt/faststorage/math/riemann-masullo/.agent/sweeptools/res[123]/*.json')):
    d=json.load(open(f))
    for s in d['sorries']:
        k=f"{d['file']}::{s['decl']}"
        if s['tac'] and k not in seen: print("NEW HIT", k, s['tac'])
PY
echo "== orphan check (LeoVerto-assigned claims not in claims.txt and not in an open PR)"
open=$(gh pr list --repo $R --author LeoVerto --state open --json body --jq '.[].body' | grep -oiE '(closes|fixes|resolves) #[0-9]+' | grep -oE '[0-9]+' | sort -u)
# Issues of merged PRs stay open until the merger's scripts/issues.py --apply closes them: not orphans.
merged=$(gh pr list --repo $R --author LeoVerto --state merged --limit 100 --json body --jq '.[].body' | grep -oiE '(closes|fixes|resolves) #[0-9]+' | grep -oE '[0-9]+' | sort -u)
nmerged_open=0
gh api --paginate "repos/$R/issues?state=open&assignee=LeoVerto&per_page=100" --jq '.[] | select(.pull_request|not) | "\(.number) \([.labels[].name]|join(","))"' |
while read n labels; do
  grep -qx "$n" $T/claims.txt && continue
  grep -qx "$n" <<<"$open" && continue
  grep -qx "$n" <<<"$merged" && { nmerged_open=$((nmerged_open+1)); continue; }
  echo "ORPHAN #$n ($labels)"
done
echo "(issues of merged PRs awaiting issues.py close: $(comm -12 <(echo "$merged") <(gh api --paginate "repos/$R/issues?state=open&assignee=LeoVerto&per_page=100" --jq '.[].number' | sort -u) | wc -l))"
echo "== stale claims (claims.txt entries claimed >3h ago, no open PR)"
now=$(date +%s)
for n in $(sort -u $T/claims.txt); do
  grep -qx "$n" <<<"$open" && continue
  t=$(gh api "repos/$R/issues/$n/comments?per_page=100" --jq '[.[] | select(.user.login=="LeoVerto" and (.body|test("^Claim";"i")))] | last | .created_at // empty')
  st=$(gh api "repos/$R/issues/$n" --jq .state)
  [ "$st" = closed ] && { echo "CLOSED #$n (remove from claims.txt)"; continue; }
  [ -n "$t" ] || { echo "NO-CLAIM-COMMENT #$n"; continue; }
  age=$(( (now - $(date -d "$t" +%s)) / 60 ))
  row=$(grep -E "^$n [a-z]+ [^ ]+ [^ ]+ (QUEUED|TAKEN)" $T/escalations.txt 2>/dev/null | tail -1)
  if [ -n "$row" ]; then
    # escalated with the claim kept (user, 2026-11-22: only for a hand-over, never to dodge the
    # 8 h auto-release): QUEUED gets a 2 h grace for an agent to take it, TAKEN is active work
    read -r _ lvl _ q st who _ <<<"$row"
    if [ "$st" = QUEUED ]; then
      qa=$(( (now - $(date -d "$q" +%s)) / 60 ))
      if [ $qa -gt 120 ]; then echo "QUEUED #$n RELEASE (queued for $lvl ${qa}m ago, nobody took it within 2 h)"
      else echo "QUEUED #$n (${qa}m of the 2 h grace)"; fi
    elif [ $age -gt 420 ]; then echo "ESCALATED #$n REFRESH-CLAIM (taken by $who and still worked on; last claim ${age}m ago)"
    else echo "ESCALATED #$n (taken by $who, claim ${age}m old)"; fi
    continue
  fi
  [ $age -gt 180 ] && echo "STALE #$n claimed ${age}m ago"
done
true
echo "== new comments on our claims (others' comments since the last status.sh --mark run; read in full with prior.sh <n>)"
seen=$(cat $T/comments.seen 2>/dev/null || date -u -d '-1 hour' +%FT%TZ); stamp=$(date -u +%FT%TZ)
if new=$(gh api --paginate "repos/$R/issues/comments?since=$seen&per_page=100" --jq '.[]
    | select(.user.login != "LeoVerto") | "\(.issue_url | split("/") | last) \(.user.login) \(.created_at[:16])Z \(.body | split("\n")[0] | .[0:100])"'); then
  awk 'NR==FNR {c[$1]; next} $1 in c {n=$1; $1=""; print "NEW #" n ":" $0}' $T/claims.txt <(echo "$new")
  [ "${1:-}" = --mark ] && echo "$stamp" > $T/comments.seen
else echo "(gh failed; will retry from $seen)"; fi
echo "== label census (unclaimed open proof issues; newest issue number; last hunter start)"
gh api --paginate "repos/$R/issues?state=open&labels=proof&per_page=100" --jq '.[] | select(.pull_request|not) | select([.labels[].name] | (index("claimed") or index("blocked") or index("stuck")) | not) | "\([.labels[].name] | map(select(. != "proof")) | join(",")) \(.number)"' |
  awk '{c[$1]++; if ($2>m[$1]) m[$1]=$2} END {for (l in c) print l, c[l], m[l]}' | sort -k2 -nr |
  while read l c m; do h=$(awk -v l="$l" '$1==l {h=$2} END {print h}' $T/hunted.txt); echo "$l unclaimed=$c newest=#$m last_hunt=${h:-NEVER}"; done
true
echo "== sieve"; python3 $T/sieve_status.py 2>&1 | head -15
