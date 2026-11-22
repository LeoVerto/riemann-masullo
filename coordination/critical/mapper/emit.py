import json, re, collections, sys, subprocess
A='/mnt/faststorage/math/riemann-masullo/.agent/wt/crit-map/.agent/'
WT='/mnt/faststorage/math/riemann-masullo/.agent/wt/crit-map/'
rows=[json.loads(l) for l in open(A+'deps.jsonl')]
C={r['n']:r for r in rows}
succ={n:set(r.get('t',[]))|set(r.get('v',[])) for n,r in C.items()}
S={n for n,r in C.items() if r.get('s')}
def f(n): return C[n]['m'].replace('.','/')+'.lean'
def short(n):
    s=re.sub(r'^_private\.[\w.]+?\.0\.','',n)
    return s.replace('RiemannMasullo.','',1) if s.startswith('RiemannMasullo.') else s
def closure(starts):
    seen=set(); st=list(starts); out=set()
    while st:
        d=st.pop()
        if d in seen: continue
        seen.add(d)
        if d in S: out.add(d)
        st.extend(succ.get(d,()))
    return out
def sorry_reach(n):
    seen=set(); st=list(succ.get(n,())); out=set()
    while st:
        d=st.pop()
        if d in seen or d==n: continue
        seen.add(d)
        if d in S: out.add(d); continue
        st.extend(succ.get(d,()))
    return out
direct={n:sorry_reach(n) for n in S}
chap=lambda n: bool(re.match(r'RiemannMasullo\.Ch\d\d', C[n]['m']))
broad=closure([n for n in C if chap(n)])
anch=json.load(open(A+'anchors.json'))
anch={k:v for k,v in anch.items() if k in C}
end_anch=[n for n,(num,we,wm) in anch.items() if we]
bridge_names={'RiemannMasullo.completedHeckeL','RiemannMasullo.finiteHeckeL'}
bridge=[n for n in C if (set(C[n].get('t',[]))&bridge_names) or n in bridge_names]
bridgecone=closure(bridge)
endcone=closure(end_anch)
anchcone=closure(list(anch)+bridge)
cone=anchcone  # the anchored cone used for ranking
rev=collections.defaultdict(set)
for a,ds in direct.items():
    for d in ds: rev[d].add(a)
def trans(n,nbr):
    seen=set(); st=[n]
    while st:
        x=st.pop()
        for y in nbr.get(x,()):
            if y not in seen: seen.add(y); st.append(y)
    return seen
rall=collections.defaultdict(set)
for a,ds in succ.items():
    for d in ds: rall[d].add(a)
# issues
iss=[json.loads(l) for l in open(A+'issues.jsonl')]
M=re.compile(r'<!-- sorry: (\S+?)::(\S+) -->')
byfile=collections.defaultdict(list)
for i in iss:
    m=M.search(i['body'] or '')
    if m: byfile[m.group(1)].append((m.group(2),i))
closed=[json.loads(l) for l in open(A+'closed.jsonl')]
cl_by=collections.defaultdict(list)
for i in closed:
    if '::' in i['mark']:
        fl,t=i['mark'].split('::',1); cl_by[fl].append((t,i))
def match(n):
    fl=f(n); sn=short(n)
    ok=lambda tok: sn==tok or sn.endswith('.'+tok) or tok.endswith('.'+sn)
    c=[i for tok,i in byfile.get(fl,[]) if ok(tok)]
    if c: return sorted(i['number'] for i in c), 'open'
    # malformed: snippet-based
    for tok,i in byfile.get(fl,[]):
        if 3183<=i['number']<=3322:
            b=i['body'] or ''; m=re.search(r'```lean\n(.*?)```', b, re.S)
            if m:
                first=[l.strip() for l in m.group(1).splitlines() if l.strip()][:1]
                src=open(WT+fl).read().splitlines()
                r=C[n]['r']
                if first and any(src[k].strip()==first[0] for k in range(r[0]-1, min(r[2],len(src)))):
                    return [i['number']], 'malformed'
    c=[i for tok,i in cl_by.get(fl,[]) if ok(tok)]
    if c: return sorted(i['number'] for i in c), 'closed'
    return [], 'missing'
claims=set(l.strip() for l in open('/mnt/faststorage/math/riemann-masullo/.agent/sweeptools/claims.txt') if l.strip().isdigit())
issue_lab={i['number']:i['labels'] for i in iss}
src_cache={}
def stmt(n):
    fl=f(n)
    if fl not in src_cache: src_cache[fl]=open(WT+fl).read().splitlines()
    r=C[n]['r']; L=src_cache[fl][r[0]-1:r[2]]
    txt='\n'.join(L)
    txt=txt.split(':= by')[0] if ':= by' in txt else txt
    return txt
XL=re.compile(r'exists_continuation|functionalEquation|_fourier_equiv|eLpNorm_eq|plancherel|nuclear|reflexive|montel|TateFactor_existsUnique|poisson|DualEquiv|selfDual|tensor_equiv|traceClassIsometry|schattenIsometry|compactOperatorIsometry|_existsUnique$|riemannRoch|weilIdentity|Eigendistributions_rank|tendstoUniformlyOn$', re.I)
L_=re.compile(r'continuous|tendsto|integrable|isLinearMap_continuous|summable|_equiv|isBigO|analytic|holomorphic|entire|^exists|existsUnique|dense|bound', re.I)
Sx=re.compile(r'_apply|_mk$|_zero|_one$|_spec|_le$|_eq_|_ne_|_pos$|_nonneg|_comm|_symm|measurable|_mono', re.I)
def diff(n):
    s=short(n).split('.')[-1]; st=stmt(n); nl=st.count('\n')+1
    if XL.search(s): return 'XL'
    if L_.search(s): return 'L' if nl>3 else 'M'
    if Sx.search(s) and nl<=4: return 'S'
    return 'M'
out=[]
for n in sorted(cone|broad, key=lambda n:(f(n),C[n]['r'][0])):
    nums,state=match(n)
    td=trans(n,rev)&cone
    up=trans(n,rall)
    upch=sum(1 for u in up if chap(u))
    lab=[l for k in nums for l in issue_lab.get(k,[])]
    cb='claimed-label' if 'claimed' in lab else ('sweep-claims' if any(str(k) in claims for k in nums) else '-')
    if 'stuck' in lab: cb+='/stuck'
    iss_s=','.join('#%d'%k for k in nums) if state=='open' else (('MALFORMED:'+','.join('#%d'%k for k in nums)) if state=='malformed' else ('CLOSED-BUT-SORRY:'+','.join('#%d'%k for k in nums) if state=='closed' else 'MISSING'))
    tier='bridge' if n in bridgecone else ('endgame' if n in endcone else ('anchored' if n in anchcone else 'broad-only'))
    out.append(dict(n=n, decl=short(n), loc='%s:%d'%(f(n),C[n]['sel'][0] if 'sel' in C[n] else C[n]['r'][0]), issue=iss_s, nums=nums, state=state, claimed=cb, ndep=len(td), ndep_direct=len(rev[n]&cone), chap_above=upch, deps=sorted(short(d) for d in direct[n] if d in cone|broad), diff=diff(n), tier=tier, lines=stmt(n).count('\n')+1))
json.dump(out, open(A+'nodes.json','w'))
with open('/mnt/faststorage/math/riemann-masullo/.agent/sweeptools/critical/graph.tsv','w') as w:
    w.write('# commit\t%s\n'%subprocess.run(['git','-C',WT,'rev-parse','--short','HEAD'],capture_output=True,text=True).stdout.strip())
    w.write('# tier: bridge = in the cone of completedHeckeL/finiteHeckeL (link to Mathlib HeckeCharacter.LSeries/dedekindZeta); endgame = reached from items Ch.10-13 cite; anchored = reached from items Ch.5.2-8 or Ch.10-13 cite; broad-only = reached only from some Ch.2-9 declaration\n')
    w.write('# dependents = cone sorry nodes whose statement/proof reaches this node (transitively, through sorry-free constants); chapter_decls_above = all Ch.* constants that transitively use it\n')
    w.write('decl\tfile:line\tissue\tclaimed_by\tdependents_in_cone\tdepends_on\tdifficulty_guess\ttier\tchapter_decls_above\n')
    for o in sorted(out, key=lambda o:(-o['ndep'], o['loc'])):
        w.write('\t'.join([o['decl'],o['loc'],o['issue'],o['claimed'],str(o['ndep']),','.join(o['deps']) or '-',o['diff'],o['tier'],str(o['chap_above'])])+'\n')
c=collections.Counter(o['tier'] for o in out); print(c)
print('S',len(S),'broad',len(broad),'anchored',len(anchcone),'endgame',len(endcone),'bridge',len(bridgecone),'union rows',len(out))
print(collections.Counter(o['state'] for o in out if o['n'] in cone), collections.Counter(o['state'] for o in out))
print('open issues total',len(iss))
