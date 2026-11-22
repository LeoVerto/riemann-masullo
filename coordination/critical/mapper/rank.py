import json, re, collections
rows = [json.loads(l) for l in open('/mnt/faststorage/math/riemann-masullo/.agent/wt/crit-map/.agent/deps.jsonl')]
C = {r['n']: r for r in rows}
g = json.load(open('/mnt/faststorage/math/riemann-masullo/.agent/wt/crit-map/.agent/cone.json'))
cone = set(g['cone']); direct = {k: set(v) for k, v in g['direct'].items()}
rev = collections.defaultdict(set)
for a, ds in direct.items():
    for d in ds: rev[d].add(a)
def trans(n, nbr):
    seen=set(); st=[n]
    while st:
        x=st.pop()
        for y in nbr.get(x,()):
            if y not in seen: seen.add(y); st.append(y)
    return seen
# all-constant reverse graph for "decls blocked"
succ = {n: set(r.get('t', [])) | set(r.get('v', [])) for n, r in C.items()}
rall = collections.defaultdict(set)
for a, ds in succ.items():
    for d in ds: rall[d].add(a)
chap = lambda m: bool(re.match(r'RiemannMasullo\.Ch\d\d', m))
res=[]
for n in cone:
    td = trans(n, rev) & cone
    up = trans(n, rall)
    upch = {u for u in up if chap(C[u]['m']) and C[u]['k'] in ('theorem','def')}
    depth = len(trans(n, direct))
    res.append((len(td), len(rev[n]&cone), len(upch), depth, n))
res.sort(reverse=True)
print('transdependents directdependents chapterDeclsAbove sorryDepsBelow name file')
for t in res[:70]:
    r=C[t[4]]; print(*t[:4], t[4].replace('RiemannMasullo.',''), r['m'].replace('RiemannMasullo.','')+':'+str(r['r'][0]))
print('zero-dependent cone nodes', sum(1 for t in res if t[0]==0))
print('roots of sorry DAG in cone (no sorry deps):', sum(1 for t in res if t[3]==0))
