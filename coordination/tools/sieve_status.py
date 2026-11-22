#!/usr/bin/env python3
"""== sieve section for status.sh (<=15 lines)."""
import json, os, subprocess, time
T = "/mnt/faststorage/math/riemann-masullo/.agent/sweeptools"; A = T + "/sieve"; R = "mccorvie/riemann-masullo"
MAIN = "/mnt/faststorage/math/riemann-masullo"
def sh(c): return subprocess.run(c, capture_output=True, text=True).stdout
try: st = json.load(open(A + "/state.json"))
except Exception: st = {}
pid = st.get("pid"); alive = bool(pid) and os.path.exists(f"/proc/{pid}") and time.time() - st.get("updated", 0) < 7200
swept = [l.split("\t") for l in open(A + "/swept.tsv")] if os.path.exists(A + "/swept.tsv") else []
tos = sum(1 for p in swept if len(p) > 6 and p[6].strip() not in ("timeouts=0", ""))
cur = st.get("current") or ("waiting for lean/RAM" if st.get("waiting") else "idle")
print(f"service {'ALIVE pid '+str(pid) if alive else 'DEAD'}; current {cur}; queue {st.get('queue','?')} passes; swept {len(swept)}; timeouts {tos}")
if st.get("queue_files"): print("  next:", " ".join(f.split("/",1)[1].replace(".lean","") for f in st["queue_files"][:4]))
hits = [l.rstrip("\n").split("\t") for l in open(A + "/hits.tsv")] if os.path.exists(A + "/hits.tsv") else []
rep = set(open(A + "/reported.txt").read().split()) if os.path.exists(A + "/reported.txt") else set()
disp = set(open(T + "/dispatched.txt").read().split()) if os.path.exists(T + "/dispatched.txt") else set()
todo = [h for h in hits if f"{h[1]}::{h[3]}" not in rep and f"{h[1]}::{h[3]}" not in disp]
if not todo: print("hits: none pending"); raise SystemExit
def issues(label):
    o = sh(["gh", "api", "--paginate", f"repos/{R}/issues?state=open&labels={label}&per_page=100", "--jq",
            '.[] | select(.pull_request|not) | [(.number|tostring), .title, ([.labels[].name]|join(",")), (.assignee.login // "")] | @tsv'])
    return [l.split("\t") for l in o.splitlines()]
proof, sweep = issues("proof"), issues("sweep")
newrep = []
for h in todo[:40]:
    base, f, line, decl, tac = h[:5]; k = f"{f}::{decl}"
    short = tac if len(tac) < 50 else tac[:47] + "..."
    still = sh(["git", "-C", MAIN, "show", f"origin/main:{f}"])
    import re
    if not re.search(r"\b(theorem|lemma|def|instance|abbrev)\s+" + re.escape(decl.split(".")[-1]) + r"\b[\s\S]*?\bsorry\b", still) :
        print("DONE", decl); newrep.append(k); continue
    fs = f.split("RiemannMasullo/", 1)[1]
    sw = [i for i in sweep if fs in i[1]]
    if sw: print(f"HINT #{sw[0][0]} {decl} {short}"); continue
    pi = [i for i in proof if f"`{decl}`" in i[1] or f"`{decl.split('.')[-1]}`" in i[1]]
    if not pi: print(f"WAIT {decl} {fs} {short}"); continue
    i = pi[0]
    if "claimed" in i[2].split(",") or i[3]: print(f"CLAIMED #{i[0]} {decl}")
    else: print(f"READY #{i[0]} {decl} {fs} {short}")
if newrep: open(A + "/reported.txt", "a").write("\n".join(newrep) + "\n")
