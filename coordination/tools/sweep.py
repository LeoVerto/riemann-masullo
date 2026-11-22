#!/usr/bin/env python3
"""Tactic sweep: replace every `sorry` in a Lean file by a macro that tries cheap tactics,
compile the file, and report which sorries were closed and by which tactic.

usage: sweep.py <worktree> <file.lean> <out.json> [--exact | --pass cheap|exact|grind|unfold] [--hb N] [--timeout S] [--only L1,L2,..]  (--only: replace just the sorries on those 1-based lines)
The file is modified in place and restored afterwards.
"""
import json, os, re, subprocess, sys

TACS = [
    "rfl", "infer_instance", "exact inferInstance", "trivial", "assumption", "decide",
    "norm_num", "simp", "simp_all", "fun_prop", "positivity", "continuity",
    "measurability", "omega", "linarith", "tauto", "aesop",
]

def macro_block(tacs, hb):
    alts = "\n".join(f'    | (({t}); done; trace "SWEEP:{t}")' for t in tacs)
    return (f"set_option maxHeartbeats {hb}\n"
            "syntax \"sweeptac\" : tactic\n"
            "macro_rules | `(tactic| sweeptac) => `(tactic| first\n"
            f"{alts})\n"
            "macro \"sweeptac\" : term => `(by sweeptac)\n").splitlines()

WORD = re.compile(r"\bsorry\b")

def find_sorries(lines):
    """(line_idx, col) of every `sorry` outside comments and strings."""
    out, depth = [], 0
    for i, ln in enumerate(lines):
        j, n, instr = 0, len(ln), False
        while j < n:
            if depth:
                if ln.startswith("/-", j): depth += 1; j += 2; continue
                if ln.startswith("-/", j): depth -= 1; j += 2; continue
                j += 1; continue
            if instr:
                if ln[j] == "\\": j += 2; continue
                if ln[j] == '"': instr = False
                j += 1; continue
            if ln.startswith("--", j): break
            if ln.startswith("/-", j): depth += 1; j += 2; continue
            if ln[j] == '"': instr = True; j += 1; continue
            m = WORD.match(ln, j)
            if m and (j == 0 or not (ln[j-1].isalnum() or ln[j-1] in "_.'")):
                out.append((i, j)); j += 5; continue
            j += 1
    return out

DECL = re.compile(r"^\s*(?:@\[[^\]]*\]\s*)?(?:(?:private|protected|noncomputable|public|nonrec)\s+)*"
                  r"(?:theorem|lemma|def|instance|abbrev|example)\s+([^\s:({\[]+)?")

def decl_of(lines, i):
    for k in range(i, -1, -1):
        m = DECL.match(lines[k])
        if m: return m.group(1) or f"<anon@{k+1}>"
    return "?"


DEFRE = re.compile(r"^\s*(?:@\[[^\]]*\]\s*)?(?:(?:protected|noncomputable|nonrec)\s+)*(?:def|abbrev)\s+([^\s:({\[]+)")
NSRE = re.compile(r"^\s*namespace\s+(\S+)"); ENDRE = re.compile(r"^\s*end(?:\s+(\S+))?\s*$")
SECRE = re.compile(r"^\s*(?:noncomputable\s+)?section\b")
_DEFS = {}
def repo_defs(wt):
    """set of qualified names declared by def/abbrev in RiemannMasullo sources (approximate namespace tracking)."""
    if wt in _DEFS: return _DEFS[wt]
    names = set()
    for root, _, fs in os.walk(os.path.join(wt, "RiemannMasullo")):
        if "/External" in root: continue
        for fn in fs:
            if not fn.endswith(".lean") or fn in ("Sweep.lean", "Sweep2.lean", "Sweep3.lean"): continue
            stack = []
            for ln in open(os.path.join(root, fn), errors="replace"):
                m = NSRE.match(ln)
                if m: stack.append(m.group(1)); continue
                if SECRE.match(ln): stack.append(None); continue
                m = ENDRE.match(ln)
                if m and stack: stack.pop(); continue
                m = DEFRE.match(ln)
                if m:
                    ns = ".".join(x for x in stack if x)
                    names.add((ns + "." if ns else "") + m.group(1)); names.add(m.group(1))
    _DEFS[wt] = names
    return names

TOK = re.compile(r"[A-Za-z_\u0370-\u03ff][\w.'!?\u0370-\u03ff]*")
def stmt_consts(wt, lines, i, limit=12):
    """repo def/abbrev names occurring in the statement of the declaration containing 0-based line i."""
    k = i
    while k >= 0 and not DECL.match(lines[k]): k -= 1
    txt = "\n".join(re.sub(r"--.*", "", l) for l in lines[max(k, 0):i + 1])
    defs = repo_defs(wt); out = []
    for m in TOK.finditer(txt):
        t = m.group(0).rstrip(".")
        if txt[m.start()-1:m.start()] == "." or t in out: continue
        if t in defs and t not in ("sorry",) and not any(t == o for o in out): out.append(t)
        if len(out) >= limit: break
    return out

def main():
    wt, rel, outp = sys.argv[1:4]
    args = sys.argv[4:]
    hb = int(args[args.index("--hb") + 1]) if "--hb" in args else 400000
    tmo = int(args[args.index("--timeout") + 1]) if "--timeout" in args else 3600
    only = {int(x) for x in args[args.index("--only") + 1].split(",")} if "--only" in args else None
    global MAC
    ps = args[args.index("--pass") + 1] if "--pass" in args else ("exact" if "--exact" in args else "cheap")
    MAC = {"cheap": "sweeptac", "exact": "sweepxtac", "grind": "sweepgtac", "unfold": "sweepdtac"}[ps]
    imp = {"cheap": "Sweep", "exact": "Sweep2"}.get(ps, "Sweep3")
    path = os.path.join(wt, rel)
    orig = open(path).read()
    lines = orig.split("\n")
    sorries = find_sorries(lines)
    if only is not None:
        sorries = [(i, j) for (i, j) in sorries if i + 1 in only]
    last_imp = max((k for k, l in enumerate(lines) if re.match(r"^\s*(public\s+)?(meta\s+)?import\b", l)), default=-1)
    block = [f"import RiemannMasullo.{imp}", f"set_option maxHeartbeats {hb}"]
    K = len(block)
    new = list(lines)
    per_line = {}  # line idx -> list of (orig col, new col, replacement length)
    reps = {}
    for (i, j) in sorries:
        if ps in ("grind", "unfold"):
            cs = stmt_consts(wt, lines, i)
            if ps == "unfold" and not cs: reps[(i, j)] = "sorry"; continue
            reps[(i, j)] = f"{MAC} [{', '.join(cs)}]"
        else: reps[(i, j)] = MAC
    for (i, j) in sorted(sorries, key=lambda p: (p[0], -p[1])):
        new[i] = new[i][:j] + reps[(i, j)] + new[i][j+5:]
    for i in sorted({i for i, _ in sorries}):
        shift = 0
        for (ii, j) in sorted([p for p in sorries if p[0] == i], key=lambda p: p[1]):
            per_line.setdefault(i, []).append((j, j + shift)); shift += len(reps[(ii, j)]) - 5
    new = new[:last_imp+1] + block + new[last_imp+1:]
    try:
        open(path, "w").write("\n".join(new))
        try:
            # own process group, so a timeout kills lake and the lean it spawned
            p = subprocess.Popen(["nice", "-n", "19", "ionice", "-c3", "lake", "lean", rel, "--", "--json"], cwd=wt,
                                 stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True, start_new_session=True)
            try:
                stdout, _ = p.communicate(timeout=tmo); rc = p.returncode
            except subprocess.TimeoutExpired:
                os.killpg(p.pid, 9)
                stdout, _ = p.communicate(); rc = 124
        except Exception as e:
            stdout, rc = "", -1
    finally:
        open(path, "w").write(orig)
    # map new positions back
    def back(line1, col):
        i = line1 - 1
        if i > last_imp: i -= K
        cols = per_line.get(i, [])
        if not cols: return None
        best = min(cols, key=lambda p: abs(p[1] - col))
        return (i, best[0])
    res = {(i, j): {"line": i+1, "col": j, "decl": decl_of(lines, i), "tac": None, "err": None}
           for (i, j) in sorries}
    other = []; nmsgs = 0
    for l in stdout.splitlines():
        try: m = json.loads(l)
        except Exception: continue
        nmsgs += 1
        d = m.get("data", "")
        pos = m.get("pos") or {}
        key = back(pos.get("line", 0), pos.get("column", 0))
        if m.get("severity") == "information" and "SWEEP:" in d:
            t = d.split("SWEEP:", 1)[1].strip()
            if key in res: res[key]["tac"] = t
        elif m.get("severity") == "information" and "Try this" in d:
            if key in res: res[key]["try"] = d[:500]
        elif m.get("severity") == "error":
            if key in res and res[key]["err"] is None:
                res[key]["err"] = d[:200]
            else:
                other.append({"line": pos.get("line", 0) - (K if pos.get("line", 0) - 1 > last_imp else 0),
                              "msg": d[:300]})
    json.dump({"file": rel, "rc": rc, "nmsgs": nmsgs, "sorries": list(res.values()), "other_errors": other},
              open(outp, "w"), indent=1)
    closed = sum(1 for r in res.values() if r["tac"])
    print(f"{rel}: {closed}/{len(res)} closed, rc={rc}, other_errors={len(other)}")

main()
