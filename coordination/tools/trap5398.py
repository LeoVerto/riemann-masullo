#!/usr/bin/env python3
"""trap5398.py <issue>... | --decl <path>::<name>...  : flag the #5398 trap without Lean.

Upstream #5398 lists type synonyms (abbrevs such as SchwartzBruhat, ModulatedExponentialDecay)
whose instance terms are astronomically large: Lean hangs when it compares two of them, so a
mathematically trivial proof never finishes. This prints, per issue, which of them its statement
or the section `variable`s in scope mention, directly or through abbrevs, type-valued defs
(Submodule, Set, Type, ...) and notations built on them (index cached per main commit):
  #<n> RISK-5398 <decl>: SchwartzBruhat (statement), BruhatCompactSupport (variable)
  #<n> ok <decl>
The list comes from the #5398 body, cached in S/trap5398.names for a day (--refresh forces it).
Declarations are read from the warm main checkout (S/../wt/base), not a worktree.
"""
import json, os, re, subprocess, sys, time

S = "/mnt/faststorage/math/riemann-masullo/.agent/sweeptools"
BASE = "/mnt/faststorage/math/riemann-masullo/.agent/wt/base"
R = "mccorvie/riemann-masullo"
CACHE = f"{S}/trap5398.names"
# fallback: the 22 names of the #5398 table as of 2026-11-22
FALLBACK = """StrongCoprimalityDecaySpace ModulatedExponentialDecay SLocalGammaOrbitalQuotient
SLocalPWOrbitalQuotient ModulatedExponentialDecayStage StrongCoprimalityLayer SLocalThetaL2
SLocalPolarFreeThetaSpace FiniteNuclearityQuotient ArchNuclearityQuotient SLocalPrimaryOrbitalQuotient
StrongCoprimalityQuotient ArchimedeanWeightedSchwartz GlobalPolarFreeThetaSpace
StrongCoprimalityThetaSpace SLocalHomogeneousThetaSpace SLocalAdelicThetaSpace
GlobalHomogeneousThetaSpace GlobalAdelicThetaSpace BruhatCompactSupport spectralSobolevIsotypeQuotient
SchwartzBruhat""".split()


def gh(*a):
    return subprocess.run(["gh", *a], capture_output=True, text=True, timeout=60).stdout


def names(refresh=False):
    if not refresh and os.path.exists(CACHE) and time.time() - os.path.getmtime(CACHE) < 86400:
        ns = open(CACHE).read().split()
        if ns:
            return ns
    body = gh("issue", "view", "5398", "--repo", R, "--json", "body", "-q", ".body")
    ns = re.findall(r"^\|\s*`([A-Za-z_][\w.']*)`\s*\|\s*`[^`]+\.lean:\d+`", body, re.M)
    ns = sorted(set(ns)) or FALLBACK
    open(CACHE, "w").write("\n".join(ns) + "\n")
    return ns


TYPE_HEADS = re.compile(r"^\s*(Type|Sort|Submodule|ClosedSubmodule|Set|Subgroup|AddSubgroup|Subalgebra|"
                        r"Subspace|Ideal|Subring|Subsemiring|Submonoid|AddSubmonoid|LinearPMap)\b")
DECL = re.compile(r"^(@\[[^\]]*\]\s*)*((private|protected|noncomputable|nonrec|public|partial)\s+)*"
                  r"(def|abbrev)\s+([^\s({\[:]+)")
NOTA = re.compile(r'^\s*((local|scoped)\s+)?notation(:\d+)?\s+"([^"]+)"')


def result_type(sig):
    """Text after the last depth-0 ':' of a declaration signature (before ':=')."""
    depth, last = 0, -1
    for i, c in enumerate(sig):
        if c in "([{⦃⟨": depth += 1
        elif c in ")]}⦄⟩": depth -= 1
        elif c == ":" and depth == 0 and sig[i:i + 2] != ":=": last = i
    return sig[last + 1:] if last >= 0 else ""


def mentions(text, words, lits):
    for w in words:
        if re.search(r"(?<![\w'])" + re.escape(w) + r"(?![\w'])", text):
            return w
    for l in lits:
        if l in text:
            return l
    return None


def index(ns):
    """Trap names plus everything built on them: abbrevs, type-valued defs and notations.
    Returns {name_or_literal: reason}; cached per warm-base commit."""
    commit = open(f"{S}/base/COMMIT").read().strip() if os.path.exists(f"{S}/base/COMMIT") else ""
    cf = f"{S}/trap5398.index.json"
    try:
        c = json.load(open(cf))
        if c.get("commit") == commit and commit and c.get("names") == ns:
            return c["words"], c["lits"]
    except (OSError, ValueError):
        pass
    decls, notas = [], []
    for root, _, files in os.walk(f"{BASE}/RiemannMasullo"):
        for fn in files:
            if not fn.endswith(".lean"): continue
            L = open(os.path.join(root, fn), errors="replace").read().split("\n")
            for i, l in enumerate(L):
                m = DECL.match(l)
                if m:
                    chunk = [l]
                    for k in range(i + 1, min(i + 60, len(L))):
                        if L[k] == "" or re.match(r"^\S", L[k]): break
                        chunk.append(L[k])
                    text = "\n".join(chunk); sig = text.split(":=")[0]
                    decls.append((m.group(5).split(".")[-1], m.group(4), sig, text))
                    continue
                m = NOTA.match(l)
                if m and len(m.group(4)) >= 2:
                    rhs = [l.split("=>", 1)[-1]]
                    for k in range(i + 1, min(i + 8, len(L))):
                        if not re.match(r"^\s{2,}\S", L[k]): break
                        rhs.append(L[k])
                    notas.append((m.group(4), "\n".join(rhs)))
    words = {n: "listed in #5398" for n in ns}; lits = {}
    changed = True
    while changed:
        changed = False
        for name, kind, sig, text in decls:
            if name in words: continue
            rt = result_type(sig)
            hit = mentions(text if kind == "abbrev" else rt, words, lits) if (kind == "abbrev" or TYPE_HEADS.match(rt)) else None
            if hit:
                words[name] = f"{kind} on {hit}"; changed = True
        for tok, rhs in notas:
            if tok in lits: continue
            hit = mentions(rhs, words, lits)
            if hit:
                lits[tok] = f"notation for {hit}"; changed = True
    json.dump({"commit": commit, "names": ns, "words": words, "lits": lits}, open(cf, "w"))
    return words, lits


def chain(x, words, lits):
    out, seen = [x], set()
    while x not in seen:
        seen.add(x)
        r = words.get(x) or lits.get(x) or ""
        m = re.search(r" (?:on|for) (.+)$", r)
        if not m: break
        x = m.group(1); out.append(x)
    return " ← ".join(out)


def decl_of_issue(n):
    for line in open(f"{S}/issues.tsv"):
        f = line.rstrip("\n").split("\t")
        if f[0] == n and "::" in f[-1]:
            return f[-1]
    body = gh("issue", "view", n, "--repo", R, "--json", "body", "-q", ".body")
    m = re.search(r"<!-- sorry: (\S+?::\S+?)\s", body)
    return m.group(1) if m else None


def check(decl, idx):
    path, name = decl.split("::", 1)
    short = name.split(".")[-1]
    try:
        lines = open(f"{BASE}/{path}").read().split("\n")
    except OSError:
        return None, "file not on main"
    head = re.compile(r"^\s*(@\[[^\]]*\]\s*)*((private|protected|noncomputable|nonrec|public)\s+)*"
                      r"(theorem|lemma|def|abbrev|instance)\s+(\S*\.)?" + re.escape(short) + r"(\s|$|\{|\(|\[|:)")
    start = next((i for i, l in enumerate(lines) if head.match(l)), None)
    if start is None:
        return None, "declaration not found on main"
    stmt = []
    for l in lines[start:start + 80]:
        stmt.append(l.split(":=")[0])
        if ":=" in l or re.search(r"\bwhere\s*$", l):
            break
    stmt = "\n".join(stmt)
    # section variables in scope at the declaration: track section/namespace nesting
    scopes, cur, i = [], [], 0
    while i < start:
        l = lines[i]
        if re.match(r"^\s*(section|namespace)\b", l):
            scopes.append(cur); cur = list(cur)
        elif re.match(r"^\s*end\b", l) and scopes:
            cur = scopes.pop()
        elif re.match(r"^\s*variable\b", l):
            block = [l]
            while i + 1 < start and re.match(r"^\s{2,}\S", lines[i + 1]):
                i += 1; block.append(lines[i])
            cur.append("\n".join(block))
        i += 1
    var = "\n".join(cur)
    words, lits = idx
    hits = []
    for n in list(words) + list(lits):
        if n == short: continue
        pat = (lambda t: re.search(r"(?<![\w'])" + re.escape(n) + r"(?![\w'])", t)) if n in words else (lambda t: n in t)
        where = "statement" if pat(stmt) else "variable" if pat(var) else None
        if where:
            hits.append((0 if words.get(n) == "listed in #5398" else 1, f"{chain(n, words, lits)} ({where})"))
    return [h for _, h in sorted(hits)][:4], None


def main(argv):
    refresh = "--refresh" in argv
    argv = [a for a in argv if a != "--refresh"]
    if not argv:
        print(__doc__.strip()); return 2
    ns = names(refresh)
    idx = index(ns)
    decls = argv[1:] if argv[0] == "--decl" else argv
    for a in decls:
        a = a.lstrip("#")
        d = a if "::" in a else decl_of_issue(a)
        tag = "" if "::" in a else f"#{a} "
        if not d:
            print(f"{tag}unknown (no declaration found)"); continue
        hits, err = check(d, idx)
        if err:
            print(f"{tag}unknown {d}: {err}")
        elif hits:
            print(f"{tag}RISK-5398 {d}: {', '.join(hits)}")
        else:
            print(f"{tag}ok {d}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
