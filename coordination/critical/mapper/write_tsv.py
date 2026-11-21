import json
A='/home/agent/wt/crit-map/.agent/'
o=json.load(open(A+'nodes.json'))
with open('/home/agent/sweeptools/critical/graph.tsv','w') as w:
    w.write('# built from the constant graph at 626d258 (warm base), sorry status re-checked textually against origin/main 0ef6aa7; issues as of 2026-11-21 18:25 CET\n')
    w.write('# tier: bridge = cone of completedHeckeL/finiteHeckeL (the only link to Mathlib HeckeCharacter.LSeries / dedekindZeta); endgame = reached from items that Ch.10-13 (pp. 433-522) cite; anchored = reached from items cited in Ch.5.2-8 (pp. 230-394); broad-only = reached only from some digested Ch.2-9 declaration (not in the anchored cone)\n')
    w.write('# dependents_in_cone = anchored-cone sorry nodes whose statement or proof reaches this node through sorry-free constants (mostly via Classical.choose / proof fields of definitions); chapter_decls_above = Ch.* constants that transitively use it\n')
    w.write('# issue: #n = open well-formed; MALFORMED?:#n = only a fragment-titled issue of the #3183-#3322 batch matches (by snippet; weak); CLOSED-BUT-SORRY:#n / (orig CLOSED #n@hh:mm UTC) = issue closed 15:23-15:27Z today while the sorry is live; MISSING = no issue. claimed_by: PR#n / comment:user@time / claimed-label / sweep-claims (claims.txt); "-" = no claim found (comments were checked only for queue/short-list candidates)\n')
    w.write('decl\tfile:line\tissue\tclaimed_by\tdependents_in_cone\tdepends_on\tdifficulty_guess\ttier\tchapter_decls_above\n')
    order={'bridge':0,'endgame':1,'anchored':2,'broad-only':3}
    for x in sorted(o, key=lambda x:(order[x['tier']], -x['ndep'], x['loc'])):
        if x['tip']!='sorry': continue
        w.write('\t'.join([x['decl'],x['loc'],x['issue'],x.get('claimed2',x['claimed']),str(x['ndep']),','.join(x['deps']) or '-',x['diff'],x['tier'],str(x['chap_above'])])+'\n')
