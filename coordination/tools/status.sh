#!/usr/bin/env bash
# One-shot status for the coordinator's periodic check.
T=/home/agent/sweeptools; R=mccorvie/riemann-masullo
echo "== $(date '+%H:%M') host"; free -m | awk 'NR==2{print "mem avail "$7"MB"}'; df -h / | awk 'NR==2{print "disk free "$4}'; uptime | sed 's/.*load/load/'
echo "lake cache (unique, excluding hardlinks into packages) $(du -sh /home/user/git/riemann-masullo/.lake/packages /home/user/git/riemann-masullo/.lake/artifact-cache 2>/dev/null | tail -1 | cut -f1)"
echo "== PRs (LeoVerto, open + merged today)"
gh pr list --repo $R --author LeoVerto --state all --limit 30 --json number,state,title,statusCheckRollup,reviews,comments \
  --jq '.[] | select(.state=="OPEN" or .state=="MERGED") | "\(.number) \(.state) \([.statusCheckRollup[]? | select(.name=="Verdict") | .conclusion] | join(",")) rev=\(.reviews|length) com=\(.comments|length) \(.title[:60])"' 2>&1 | head -30
echo "== claims.txt ($(wc -l < $T/claims.txt))"; tr '\n' ' ' < $T/claims.txt; echo
echo "== warm base"; echo "ready $(cut -c1-8 $T/base/COMMIT)  main $(git -C /home/user/git/riemann-masullo rev-parse --short=8 origin/main)  $(tail -1 $T/warm.log)"
echo "== memguard"; tail -1 $T/memguard.log
echo "== sweep"; echo "res1 $(ls $T/res1 | wc -l) files, res2 $(ls $T/res2 | wc -l) files; chain: $(tail -1 $T/chain.log 2>/dev/null)"
python3 - <<'PY'
import json,glob,os
seen=set(open('/home/agent/sweeptools/dispatched.txt').read().split()) if os.path.exists('/home/agent/sweeptools/dispatched.txt') else set()
for f in sorted(glob.glob('/home/agent/sweeptools/res[123]/*.json')):
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
  [ $age -gt 180 ] && echo "STALE #$n claimed ${age}m ago"
done
true
echo "== label census (unclaimed open proof issues; newest issue number; last hunter start)"
gh api --paginate "repos/$R/issues?state=open&labels=proof&per_page=100" --jq '.[] | select(.pull_request|not) | select([.labels[].name] | (index("claimed") or index("blocked") or index("stuck")) | not) | "\([.labels[].name] | map(select(. != "proof")) | join(",")) \(.number)"' |
  awk '{c[$1]++; if ($2>m[$1]) m[$1]=$2} END {for (l in c) print l, c[l], m[l]}' | sort -k2 -nr |
  while read l c m; do h=$(awk -v l="$l" '$1==l {h=$2} END {print h}' $T/hunted.txt); echo "$l unclaimed=$c newest=#$m last_hunt=${h:-NEVER}"; done
true
