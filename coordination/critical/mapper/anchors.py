import re, json, collections
R=re.compile(r'(?<![\d.])((?:[1-9]|[A-E])\.\d+(?:\.\d+)+)(?![\d])')
def refs(path, skip):
    cnt=collections.Counter()
    for m in R.finditer(open(path).read()):
        num=m.group(1)
        h=num.split('.')[0]
        if skip(num): continue
        cnt[num]+=1
    return cnt
def digested(num):
    h=num.split('.')
    if h[0] in 'ABCD': return True
    c=int(h[0])
    if c in (2,3,4,9): return True
    if c==5 and h[1]=='1': return True
    return False
end=refs('.agent/endgame.txt', lambda n: not digested(n))
mid=refs('.agent/mid.txt', lambda n: not digested(n))
rows=[json.loads(l) for l in open('.agent/deps.jsonl')]
P=re.compile(r'Paper:\s*([^,]*?)((?:[1-9]|[A-E])\.\d+(?:\.\d+)+)')
anch={}
for r in rows:
    d=r.get('doc') or ''
    m=P.search(d)
    if not m: continue
    num=m.group(2)
    # match exact or parent item (e.g. equation (3.2.1.8) vs theorem 3.2.1.3)
    w_end=end.get(num,0); w_mid=mid.get(num,0)
    if w_end or w_mid: anch[r['n']]=(num,w_end,w_mid)
json.dump(anch, open('.agent/anchors.json','w'))
print('anchors',len(anch))
miss_end=[n for n in end if not any(a[0]==n for a in anch.values())]
print('endgame-cited digested items with no Lean decl:', sorted(miss_end))
miss_mid=[n for n in mid if not any(a[0]==n for a in anch.values())]
print('mid-cited items with no decl:', len(miss_mid), sorted(miss_mid)[:80])
