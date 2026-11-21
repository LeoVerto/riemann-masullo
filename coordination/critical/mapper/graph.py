import json, re, collections, sys
rows = [json.loads(l) for l in open('/home/agent/wt/crit-map/.agent/deps.jsonl')]
C = {r['n']: r for r in rows}
succ = {n: set(r.get('t', [])) | set(r.get('v', [])) for n, r in C.items()}
S = {n for n, r in C.items() if r.get('s')}
def mod2file(m): return m.replace('.', '/') + '.lean'
# sorry-deps: from node, DFS through non-sorry constants, collect sorry nodes reached
memo = {}
def reach_sorry(n):
    # sorry nodes reachable from n's successors, stopping at sorry nodes (not traversing past)
    if n in memo: return memo[n]
    memo[n] = set()
    out = set()
    stack = list(succ.get(n, ())); seen = set()
    while stack:
        d = stack.pop()
        if d in seen or d == n: continue
        seen.add(d)
        if d in S: out.add(d); continue
        stack.extend(succ.get(d, ()))
    memo[n] = out
    return out
direct = {n: reach_sorry(n) for n in S}
# all-constant transitive closure to sorry (for chapter declarations)
def all_sorry_reach(n):
    seen = set(); stack = [n]; out = set()
    while stack:
        d = stack.pop()
        if d in seen: continue
        seen.add(d)
        if d in S and d != n: out.add(d)
        stack.extend(succ.get(d, ()))
    return out
chap = lambda m: bool(re.match(r'RiemannMasullo\.Ch\d\d', m))
roots = [n for n, r in C.items() if chap(r['m'])]
cone = set()
for n in roots:
    if n in S: cone.add(n)
    cone |= all_sorry_reach(n)
print('sorry nodes', len(S), 'chapter roots', len(roots), 'cone', len(cone))
by = collections.Counter(C[n]['m'].split('.')[1] for n in cone)
byall = collections.Counter(C[n]['m'].split('.')[1] for n in S)
for k in sorted(byall): print(k, by.get(k, 0), '/', byall[k])
json.dump({'cone': sorted(cone), 'direct': {n: sorted(v) for n, v in direct.items()}}, open('/home/agent/wt/crit-map/.agent/cone.json', 'w'))
