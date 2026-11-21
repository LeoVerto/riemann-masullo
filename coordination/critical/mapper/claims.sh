#!/usr/bin/env bash
# claims.sh n1 n2 ... -> "n<TAB>status<TAB>who<TAB>last" ; status CLAIMED if last Claiming/Claimed comment not followed by release
for n in "$@"; do
  gh api "repos/mccorvie/riemann-masullo/issues/$n/comments?per_page=100" --jq '[.[] | {u: .user.login, b: (.body[0:200] | gsub("\n";" ")), t: .created_at}]' 2>/dev/null | python3 -c "
import json,sys,re
c=json.load(sys.stdin); n='$n'
st='free'; who='-'; when='-'
for x in c:
    b=x['b'].strip().lower()
    if re.match(r'^(claiming|claimed)', b): st='CLAIMED'; who=x['u']; when=x['t'][:16]
    elif re.match(r'^(releas|unclaim|dropping|giving up|i.m releasing)', b) or 'releasing' in b[:60] or 'released' in b[:40]: st='released'; who=x['u']; when=x['t'][:16]
last=(c[-1]['u']+': '+c[-1]['b'][:90]) if c else '-'
print(f'{n}\t{st}\t{who}\t{when}\t{len(c)}\t{last}')
"
done
