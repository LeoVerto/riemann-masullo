#!/usr/bin/env python3
"""Quick-win shortlist: score every sorry'd declaration by how likely it is to be a trivial/unfolding fact. See SIEVE.md.
usage: shortlist.py [file.lean ...]   (default: files changed on origin/main in the last 48h that contain sorry)
Output: shortlist/latest.tsv (all, sorted) and a top-30 summary on stdout. Pure text analysis, no Lean."""
import json, os, re, subprocess, sys
R = "/mnt/faststorage/math/riemann-masullo"; T = R + "/.agent/sweeptools"; D = T + "/shortlist"
src = open(T + "/sweep.py").read().split("def main():")[0]
exec(src[src.index("WORD ="):])  # find_sorries, DECL, decl_of
def sh(c): return subprocess.run(c, capture_output=True, text=True).stdout

NAMEPAT = ["_apply", "_def", "_mem", "_zero", "_one", "_coe", "_mk", "_natCast", "_iff", "_neg", "_add", "_smul", "_eq", "_comp", "_id", "_symm", "_self", "_ofNat", "_toFun", "_eq_"]
HINTS = ["sanity", "by definition", "immediate", "trivial", "unfold", "tautolog", "restates", "rephras"]
REDFLAGS = ["∫", "Integrable", "HasSum", "Summable", "Tendsto", "Meromorphic", "AnalyticOn", "∃!", "Continuous", "HasDerivAt", "tsum", "∑'", "IsCompact", "Filter", "MeasureTheory", "Differentiable", "LocallyConvex", "Nuclear"]
SHORT = re.compile(r"^PROOF\.?\s*(\(\w\)\s*:?\s*)?(clear|obvious|immediate|trivial|this follows|follows|by definition|direct|easy|straightforward)", re.I)
ITEM = re.compile(r"^\W*(THEOREM|LEMMA|PROPOSITION|COROLLARY|REMARK|DEFINITION|EXAMPLE|CLAIM|NOTATION|SITUATION|CONVENTION|FACT|OBSERVATION|CONJECTURE|QUESTION|PROBLEM)\s+([A-Z]?\.?[\d.]*\d)")
BOUND = re.compile(r"^\W*(\*\*)?(\d+\.\d+\.|\d+\.\d+\.\d+\.\d+\.|\d+\.\d+\.\d+\.\s)|^\*\*[A-Z]?\.?\d+\.\d+")
END = re.compile(r"\\square|\\qed|\\blacksquare|□|∎")

def paper_pages(p, n=3):
    fn = f"{D}/paper/{p}.txt"
    if not os.path.exists(fn):
        open(fn, "w").write(sh([R + "/scripts/paper.sh", str(p), str(p + n - 1)]))
    return open(fn).read().split("\n")

def paper_info(label, page):
    """-> (kind, proof_chars, short, atleast): kind in none (no heading found) | noproof | proof"""
    m = re.match(r"\s*(Theorem|Lemma|Proposition|Corollary|Remark|Definition|Example|Claim|Notation|Situation|Convention)\s+([A-Z]?\.?[\d.]*\d)", label)
    if not m: return ("none", None, False, False)
    num = m.group(2); L = paper_pages(page)
    start = next((i for i, l in enumerate(L) if (ITEM.match(l) or ITEM.match(l.upper())) and (ITEM.match(l) or ITEM.match(l.upper())).group(2) == num), None)
    if start is None: return ("none", None, False, False)
    proof, end, atl = None, len(L), True
    for i in range(start + 1, len(L)):
        l = L[i]
        if re.match(r"^\W*PROOF\b", l):
            if proof is None: proof = i
            continue
        if proof is None and (ITEM.match(l) or BOUND.match(l)) and not l.startswith("## PDF"): end = i; break
        if proof is not None and (ITEM.match(l) or BOUND.match(l)): end = i; atl = False; break
        if proof is not None and END.search(l): end = i + 1; atl = False; break
    if proof is None: return ("noproof" if m.group(1) in ("Remark", "Definition", "Example", "Notation", "Situation", "Convention") else "proofelsewhere", 0, False, False)
    txt = "\n".join(l for l in L[proof:end] if not l.startswith("## PDF") and not l.startswith("**") or l.startswith("PROOF"))
    return ("proof", len(txt), bool(SHORT.match(L[proof])), atl)

def analyze(f, text):
    lines = text.split("\n"); out = {}
    for i, j in find_sorries(lines):
        k = i
        while k >= 0 and not DECL.match(lines[k]): k -= 1
        if k < 0 or k in out: continue
        name = DECL.match(lines[k]).group(1) or f"<anon@{k+1}>"
        # docstring: block comment ending just above k (skip attribute lines)
        d = k - 1
        while d >= 0 and (lines[d].strip().startswith("@[") or not lines[d].strip()): d -= 1
        doc = ""
        if d >= 0 and lines[d].rstrip().endswith("-/"):
            e = d
            while e >= 0 and not lines[e].lstrip().startswith("/--"): e -= 1
            doc = " ".join(lines[max(e, 0):d + 1])
        # signature: from k to first `:=` at bracket depth 0 (or the sorry line)
        sig, depth = "", 0
        for l in lines[k:i + 1]:
            l = re.sub(r"--.*", "", l); sig += l + "\n"
            for ch in l: depth += (ch in "([{⦃⟨") - (ch in ")]}⦄⟩")
            if depth <= 0 and ":=" in l and "fun" not in l.split(":=")[0]: sig = sig[:sig.rindex(":=")]; break
        out[k] = (name, doc, sig)
    return out

def score(f, name, doc, sig, sorries_in_decl=1):
    sc, sg = 50.0, []
    n, nl = len(sig), sig.count("\n")
    sc -= min(30, n / 40); sg.append(f"sig{n}c/{nl}l")
    nb = len(re.findall(r"[({\[⦃]", sig.split(":", 1)[0])) if ":" in sig else 0
    nh = len(re.findall(r"\(h\w*\s*:", sig))
    sc -= max(0, nb - 3) * 0.7 + nh * 1.0
    last = name.split(".")[-1]
    hit = [p for p in NAMEPAT if p in last]
    if hit: sc += min(14, 7 * len(hit)); sg.append("name" + "".join(hit))
    dh = [h for h in HINTS if h in doc.lower()]
    if dh: sc += 10; sg.append("doc:" + ",".join(dh))
    rf = [r for r in REDFLAGS if r in sig]
    if rf: sc -= min(30, 8 * len(rf)); sg.append("red:" + ",".join(rf))
    m = re.search(r"Paper:\s*([^,]*(?:\([^)]*\))?[^,]*?),\s*p\.\s*(\d+)", doc)
    pk = None
    if m:
        label, page = m.group(1).strip(), int(m.group(2))
        kind, ch, short, atl = paper_info(label, page)
        if kind == "noproof": sc += 12; sg.append("paper:no-proof")
        elif kind == "proofelsewhere": sc += 2; sg.append("paper:no-own-proof")
        elif kind == "proof":
            sg.append(f"paper:proof{'>=' if atl else ''}{ch}c")
            sc += 15 if ch < 300 else 8 if ch < 800 else 0 if ch < 2000 else -8 if ch < 5000 else -15
            if short: sc += 10; sg.append("paper:SHORT")
        else: sg.append("paper:?")
    return round(sc, 1), sg

def main():
    os.makedirs(D + "/paper", exist_ok=True)
    files = sys.argv[1:]
    if not files:
        files = sorted({x for x in sh(["git", "-C", R, "log", "--since=48 hours ago", "origin/main", "--name-only", "--format="]).split("\n") if x.startswith("RiemannMasullo/") and x.endswith(".lean") and "/External/" not in x})
    issues, held = {}, {}
    try:
        for it in json.loads(sh(["gh", "issue", "list", "--label", "proof", "--state", "open", "--limit", "2000", "--json", "number,title"], )):
            for nm in re.findall(r"`([^`]+)`", it["title"]): issues[nm.split(".")[-1]] = it["number"]
        for it in json.loads(sh(["gh", "issue", "list", "--label", "sweep", "--state", "open", "--limit", "500", "--json", "number,title,body"])):
            for fn in re.findall(r"RiemannMasullo/[\w/]+\.lean", it["title"] + it["body"]): held[fn] = it["number"]
    except Exception as e: print("gh failed:", e, file=sys.stderr)
    rows = []
    for f in files:
        f = os.path.relpath(os.path.abspath(f), R) if os.path.exists(f) else f
        try: text = open(f"{R}/{f}").read() if os.path.exists(f"{R}/{f}") else sh(["git", "-C", R, "show", f"origin/main:{f}"])
        except Exception: continue
        for k, (name, doc, sig) in analyze(f, text).items():
            sc, sg = score(f, name, doc, sig)
            rows.append((sc, f"{f}:{k+1}", name, issues.get(name.split(".")[-1], ""), held.get(f, ""), " ".join(sg)))
    rows.sort(key=lambda r: -r[0])
    with open(D + "/latest.tsv", "w") as fh:
        fh.write("score\tfile:line\tdecl\tissue\tsweep_issue\tsignals\n")
        for r in rows: fh.write("\t".join(map(str, r)) + "\n")
    print(f"{len(rows)} sorry'd declarations in {len(files)} files -> shortlist/latest.tsv")
    for r in rows[:30]:
        print(f"{r[0]:5} {r[1].replace('RiemannMasullo/','')} {r[2]} #{r[3] or '-'} sw#{r[4] or '-'} {r[5]}"[:210])
main()
