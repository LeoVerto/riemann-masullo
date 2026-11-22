#!/usr/bin/env python3
"""Tactic sweep: replace every `sorry` in a Lean file by a macro that tries cheap tactics,
compile the file, and report which sorries were closed and by which tactic.

usage: sweep.py <worktree> <file.lean> <out.json> [--exact] [--hb N] [--timeout S] [--only L1,L2,..]  (--only: replace just the sorries on those 1-based lines)
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

def main():
    wt, rel, outp = sys.argv[1:4]
    args = sys.argv[4:]
    hb = int(args[args.index("--hb") + 1]) if "--hb" in args else 400000
    tmo = int(args[args.index("--timeout") + 1]) if "--timeout" in args else 3600
    only = {int(x) for x in args[args.index("--only") + 1].split(",")} if "--only" in args else None
    global MAC
    MAC = "sweepxtac" if "--exact" in args else "sweeptac"
    path = os.path.join(wt, rel)
    orig = open(path).read()
    lines = orig.split("\n")
    sorries = find_sorries(lines)
    if only is not None:
        sorries = [(i, j) for (i, j) in sorries if i + 1 in only]
    last_imp = max((k for k, l in enumerate(lines) if re.match(r"^\s*(public\s+)?(meta\s+)?import\b", l)), default=-1)
    block = [f"import RiemannMasullo.Sweep2" if MAC == "sweepxtac" else "import RiemannMasullo.Sweep", f"set_option maxHeartbeats {hb}"]
    K = len(block)
    new = list(lines)
    per_line = {}
    for (i, j) in sorted(sorries, key=lambda p: (p[0], -p[1])):
        new[i] = new[i][:j] + MAC + new[i][j+5:]
    for (i, j) in sorries:
        per_line.setdefault(i, []).append(j)
    new = new[:last_imp+1] + block + new[last_imp+1:]
    try:
        open(path, "w").write("\n".join(new))
        try:
            # own process group, so a timeout kills lake and the lean it spawned
            p = subprocess.Popen(["nice", "-n", "19", "ionice", "-c3", "lake", "env", "lean", "--json", rel], cwd=wt,
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
        cols = sorted(per_line.get(i, []))
        if not cols: return None
        # columns shift by +1 for each earlier sorry on the line
        adj = [c + k * (len(MAC) - 5) for k, c in enumerate(cols)]
        best = min(range(len(cols)), key=lambda k: abs(adj[k] - col))
        return (i, cols[best])
    res = {(i, j): {"line": i+1, "col": j, "decl": decl_of(lines, i), "tac": None, "err": None}
           for (i, j) in sorries}
    other = []
    for l in stdout.splitlines():
        try: m = json.loads(l)
        except Exception: continue
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
    json.dump({"file": rel, "rc": rc, "sorries": list(res.values()), "other_errors": other},
              open(outp, "w"), indent=1)
    closed = sum(1 for r in res.values() if r["tac"])
    print(f"{rel}: {closed}/{len(res)} closed, rc={rc}, other_errors={len(other)}")

main()
