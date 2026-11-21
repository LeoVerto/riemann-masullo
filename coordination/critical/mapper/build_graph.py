import json, re, collections
A='/home/agent/wt/crit-map/.agent/'
rows=[json.loads(l) for l in open(A+'deps.jsonl')]
C={r['n']:r for r in rows}
succ={n:set(r.get('t',[]))|set(r.get('v',[])) for n,r in C.items()}
S={n for n,r in C.items() if r.get('s')}
def f(n): return C[n]['m'].replace('.','/')+'.lean'
def short(n):
    s=re.sub(r'^_private\.[\w.]+?\.0\.','',n)
    return s.replace('RiemannMasullo.','',1) if s.startswith('RiemannMasullo.') else s
def sorry_reach(n, include_self=False):
    seen=set(); st=list(succ.get(n,())); out=set()
    while st:
        d=st.pop()
        if d in seen or d==n: continue
        seen.add(d)
        if d in S: out.add(d); continue
        st.extend(succ.get(d,()))
    return out
def closure(starts):
    seen=set(); st=list(starts); out=set()
    while st:
        d=st.pop()
        if d in seen: continue
        seen.add(d)
        if d in S: out.add(d)
        st.extend(succ.get(d,()))
    return out
direct={n:sorry_reach(n) for n in S}
chap=lambda n: bool(re.match(r'RiemannMasullo\.Ch\d\d', C[n]['m']))
broad=closure([n for n in C if chap(n)])
anch=json.load(open(A+'anchors.json'))
end_anch=[n for n,(num,we,wm) in anch.items() if we]
all_anch=list(anch)
bridge_names={'RiemannMasullo.completedHeckeL','RiemannMasullo.finiteHeckeL'}
bridge=[n for n in C if (set(C[n].get('t',[]))&bridge_names) or n in bridge_names]
endcone=closure(end_anch)
anchcone=closure(all_anch+bridge)
bridgecone=closure(bridge)
# issues
iss=[json.loads(l) for l in open(A+'issues.jsonl')]
M=re.compile(r'<!-- sorry: (\S+?)::(\S+) -->')
byfile=collections.defaultdict(list)
for i in iss:
    m=M.search(i['body'] or '')
    if m: byfile[m.group(1)].append((m.group(2),i))
issue_of={}; used=set()
for n in S:
    fl=f(n); sn=short(n)
    cands=[i for tok,i in byfile.get(fl,[]) if sn==tok or sn.endswith('.'+tok) or tok.endswith('.'+sn)]
    if cands:
        cands.sort(key=lambda i:i['number'])
        issue_of[n]=cands; used.update(i['number'] for i in cands)
stale=[i for i in iss if i['number'] not in used]
missing=[n for n in S if n not in issue_of]
# try malformed fallback by snippet
def snippet_match(i):
    b=i['body'] or ''
    m=re.search(r'```lean\n(.*?)```', b, re.S)
    if not m: return None
    lines=[l.strip() for l in m.group(1).splitlines() if l.strip()]
    mm=M.search(b); fl=mm.group(1)
    try: src=open('/home/agent/wt/crit-map/'+fl).read().splitlines()
    except: return None
    for l in lines[:1]:
        for k,s in enumerate(src):
            if s.strip()==l:
                # find enclosing sorry node in that file containing line k+1
                best=None
                for n in S:
                    if f(n)==fl and C[n]['r'][0]<=k+1<=C[n]['r'][2]: best=n
                return best
    return None
mal_map={}
for i in stale:
    n=snippet_match(i)
    if n: mal_map[i['number']]=n
json.dump(dict(S=sorted(S), direct={k:sorted(v) for k,v in direct.items()}, broad=sorted(broad), endcone=sorted(endcone), anchcone=sorted(anchcone), bridgecone=sorted(bridgecone),
  issue_of={k:[i['number'] for i in v] for k,v in issue_of.items()}, stale=[i['number'] for i in stale], missing=sorted(missing), mal_map=mal_map, bridge=bridge), open(A+'graph.json','w'))
print('S',len(S),'broad',len(broad),'end-anchored',len(endcone),'all-anchored',len(anchcone),'bridge',len(bridgecone))
print('issues',len(iss),'matched nodes',len(issue_of),'multi',sum(1 for v in issue_of.values() if len(v)>1),'missing',len(missing),'stale issues',len(stale),'stale→node via snippet',len(mal_map))
print('missing:',[short(n)+'@'+f(n).split('RiemannMasullo/')[1] for n in missing][:40])
print('stale (non-malformed range):',[(i['number'],i['title'][:60]) for i in stale if not 3183<=i['number']<=3322][:30])
print('stale in malformed range:',sum(1 for i in stale if 3183<=i['number']<=3322))
print('bridge cone:', sorted(short(n) for n in bridgecone))
by=collections.Counter(C[n]['m'].split('.')[1] for n in anchcone); print('anchcone by chapter', by)
by=collections.Counter(C[n]['m'].split('.')[1] for n in endcone); print('endcone by chapter', by)
