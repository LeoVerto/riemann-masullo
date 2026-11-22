import json,subprocess,re
o=json.load(open('/mnt/faststorage/math/riemann-masullo/.agent/wt/crit-map/.agent/nodes.json'))
cache={}
for x in o:
    fl=x['loc'].rsplit(':',1)[0]
    if fl not in cache: cache[fl]=subprocess.run(['git','-C','/mnt/faststorage/math/riemann-masullo/.agent/wt/crit-map','show','origin/main:'+fl],capture_output=True,text=True).stdout
    tip=cache[fl]; name=x['decl'].split('.')[-1]
    m=re.search(r'(theorem|lemma) (?:[\w.]*\.)?'+re.escape(name)+r'\b(.*?)(?=\n(?:/--|theorem|lemma|def|noncomputable|instance|@\[|end |section|namespace|variable|open|include|omit)|\Z)', tip, re.S)
    x['tip']='sorry' if m and 'sorry' in m.group(2) else ('proved' if m else 'gone')
json.dump(o,open('/mnt/faststorage/math/riemann-masullo/.agent/wt/crit-map/.agent/nodes.json','w'))
import collections; print(collections.Counter(x['tip'] for x in o))
print([x['decl'] for x in o if x['tip']!='sorry'])
