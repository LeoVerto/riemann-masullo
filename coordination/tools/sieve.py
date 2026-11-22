#!/usr/bin/env python3
"""sieve service loop; see SIEVE.md. Run via sieve.sh."""
import json, os, re, subprocess, sys, time, datetime
R = "/mnt/faststorage/math/riemann-masullo"; T = R + "/.agent/sweeptools"; WT = R + "/.agent/wt/sieve"
A = T + "/sieve"; BASE = T + "/base"
TMO = {"cheap": 3600, "exact": 10800, "grind": 7200, "unfold": 10800}
PASSES = ("cheap", "exact", "grind", "unfold")
ONLY = os.environ.get("SIEVE_ONLY")  # test: comma list of files
sys.path.insert(0, T)
exec(open(T + "/sweep.py").read().split("def main():")[0])  # find_sorries, decl_of

def log(*a): print(datetime.datetime.now().isoformat(timespec="seconds"), *a, flush=True)
def sh(cmd, **k): return subprocess.run(cmd, capture_output=True, text=True, **k)
def now(): return datetime.datetime.now().isoformat(timespec="seconds")
def state(**kw):
    d = {}
    try: d = json.load(open(A + "/state.json"))
    except Exception: pass
    d.update(kw); d["pid"] = os.getpid(); d["updated"] = time.time()
    json.dump(d, open(A + "/state.json.tmp", "w")); os.replace(A + "/state.json.tmp", A + "/state.json")

def descendants(pid):
    kids, out = {}, set()
    for p in os.listdir("/proc"):
        if p.isdigit():
            try: kids.setdefault(int(open(f"/proc/{p}/stat").read().rsplit(")", 1)[1].split()[1]), []).append(int(p))
            except Exception: pass
    st = [pid]
    while st:
        for k in kids.get(st.pop(), []): out.add(k); st.append(k)
    return out
def lean_running():
    """another sieve-style sweep: a lean process with cwd under $R/.agent/wt/sieve* that is not our own descendant."""
    mine = descendants(os.getpid())
    for p in sh(["pgrep", "-x", "lean"]).stdout.split():
        try: cwd = os.readlink(f"/proc/{p}/cwd")
        except Exception: continue
        if cwd.startswith(R + "/.agent/wt/sieve") and int(p) not in mine: return True
    return False
def memavail():
    for l in open("/proc/meminfo"):
        if l.startswith("MemAvailable"): return int(l.split()[1]) // 1024
def wait_ready():
    while True:
        if (os.environ.get("SIEVE_NOWAIT") or not lean_running()) and memavail() > 6000: return
        state(waiting=True); time.sleep(30)

def refresh():
    """Move worktree to base commit; returns commit."""
    c = open(BASE + "/COMMIT").read().strip()
    if not os.path.isdir(WT):
        sh(["git", "-C", R, "worktree", "add", "-q", "--detach", WT, c]); os.makedirs(WT + "/.lake", exist_ok=True)
        sh(["ln", "-sfn", R + "/.lake/packages", WT + "/.lake/packages"])
    cur = sh(["git", "-C", WT, "rev-parse", "HEAD"]).stdout.strip()
    done = os.path.exists(A + "/installed") and open(A + "/installed").read().strip() == c
    if cur == c and done: return c
    log("refresh to", c)
    sh(["git", "-C", WT, "checkout", "-q", "-f", "--detach", c])
    sh(["git", "-C", WT, "clean", "-fdq", "RiemannMasullo"])
    for _ in range(3):
        sh(["rm", "-rf", WT + "/.lake/build"]); sh(["cp", "-r", BASE + "/build", WT + "/.lake/build"])
        if open(BASE + "/COMMIT").read().strip() == c: break
        c = open(BASE + "/COMMIT").read().strip(); sh(["git", "-C", WT, "checkout", "-q", "-f", "--detach", c])
    for n, f in (("Sweep", "Sweep.lean.txt"), ("Sweep2", "Sweep2.lean.txt"), ("Sweep3", "Sweep3.lean.txt")):
        sh(["cp", f"{T}/lean/{f}", f"{WT}/RiemannMasullo/{n}.lean"])
    wait_ready()
    p = sh(["nice", "-n", "10", "lake", "build", "RiemannMasullo.Sweep", "RiemannMasullo.Sweep2", "RiemannMasullo.Sweep3"], cwd=WT)
    log("macro build rc", p.returncode, p.stdout[-200:] if p.returncode else "")
    if p.returncode: return None
    open(A + "/installed", "w").write(c)
    return c

def fails():
    try: return json.load(open(A + "/fails.json"))
    except Exception: return {}
def set_fail(key, v):
    d = fails()
    if v is None: d.pop(key, None)
    else: d[key] = v
    json.dump(d, open(A + "/fails.json.tmp", "w")); os.replace(A + "/fails.json.tmp", A + "/fails.json")

def due_files(c):
    swept = {}
    if os.path.exists(A + "/swept.tsv"):
        for l in open(A + "/swept.tsv"):
            p = l.rstrip("\n").split("\t")
            if len(p) >= 7 and p[6].startswith("status=done"): swept.setdefault((p[0], p[2]), []).append(p[1])  # (file,pass) -> blobs
    out = sh(["git", "-C", WT, "grep", "-lw", "sorry", c, "--", "RiemannMasullo"]).stdout.split()
    files = [x.split(":", 1)[1] for x in out if "/External/" not in x and not x.endswith(("/Sweep.lean", "/Sweep2.lean", "/Sweep3.lean"))]
    if ONLY: files = [f for f in files if f in ONLY.split(",")]
    q = []
    prio = open(A + "/priority.txt").read().split() if os.path.exists(A + "/priority.txt") else []
    for f in files:
        blob = sh(["git", "-C", WT, "rev-parse", f"{c}:{f}"]).stdout.strip()
        ct = int(sh(["git", "-C", WT, "log", "-1", "--format=%ct", c, "--", f]).stdout.strip() or 0)
        passes = [ps for ps in PASSES if blob not in swept.get((f, ps), [])]
        if not passes: continue
        if fails().get(f"{f}|{passes[0]}|{blob}", {}).get("after", 0) > time.time(): continue  # backing off
        changed = any((f, ps) in swept for ps in PASSES)
        tier = 0 if (changed or ct > time.time() - 12 * 3600) else 1
        if f in prio: tier, ct = -1, -prio.index(f)
        q.append((tier, -ct, f, blob, passes))
    q.sort()
    return q

def bad(d):
    """killed (137/143/signal), timed out (124) or lake failed without any message: not a result."""
    rc = d["rc"]
    return rc == 124 or rc >= 128 or rc < 0 or (rc != 0 and d.get("nmsgs", 1) == 0)

def run_sweep(f, ps, out, extra):
    p = sh(["python3", T + "/sweep.py", WT, f, out, "--pass", ps] + extra)
    try: return json.load(open(out))
    except Exception: return {"rc": -1, "sorries": [], "other_errors": []}

def run_scope(f, ps, out, only=None, tries=2):
    extra = ["--timeout", str(TMO[ps])] + (["--only", ",".join(map(str, only))] if only else [])
    for t in range(tries):
        wait_ready(); d = run_sweep(f, ps, out, extra)
        if not bad(d): return d
        log("bad run rc", d["rc"], f, ps, "only=", only, "try", t + 1); time.sleep(60 * (t + 1))
    return None

def sweep_file(f, blob, ps, c):
    """returns True if a result was recorded; False if the whole-file run failed and was requeued with backoff."""
    out = f"{A}/res/{ps}/{f.replace('/', '_')}.json"
    key = f"{f}|{ps}|{blob}"; nf = fails().get(key, {}).get("n", 0)
    state(current=f"{f} [{ps}]", since=time.time())
    gaveup = 0; attempts = nf + 1
    if nf < 2:
        wait_ready(); d = run_sweep(f, ps, out, ["--timeout", str(TMO[ps])])
        if bad(d):
            set_fail(key, {"n": nf + 1, "after": time.time() + 900 * 2 ** nf, "rc": d["rc"]})
            with open(A + "/swept.tsv", "a") as fh:
                fh.write(f"{f}\t{blob}\t{ps}\t{d['rc']}\t{out}\t{now()}\tstatus=retry attempts={nf + 1}\n")
            log("requeue", f, ps, "rc", d["rc"], "attempt", nf + 1); return False
    else:
        log("chunk mode", f, ps)
        lines = sorted({i + 1 for i, _ in find_sorries(open(f"{WT}/{f}").read().split("\n"))})
        src = open(f"{WT}/{f}").read().split("\n"); merged = {}; rcs = []
        def take(dd, fallback_lines):
            for s in dd["sorries"]: merged[(s["line"], s["col"])] = s
        for k in range(0, len(lines), 4):
            ch = lines[k:k + 4]; o = out + ".chunk"
            cd = run_scope(f, ps, o, ch)
            if cd is not None: take(cd, ch); continue
            for l in ch:
                sd = run_scope(f, ps, o, [l])
                if sd is not None: take(sd, [l])
                else: gaveup += 1; merged[(l, -1)] = {"line": l, "col": -1, "decl": decl_of(src, l - 1), "tac": None, "err": "gaveup"}
        os.path.exists(out + ".chunk") and os.remove(out + ".chunk")
        d = {"file": f, "rc": 0 if not gaveup else 124, "sorries": list(merged.values()), "other_errors": [], "chunked": True, "gaveup": gaveup}
        json.dump(d, open(out, "w"), indent=1)
    set_fail(key, None)
    with open(A + "/swept.tsv", "a") as fh:
        fh.write(f"{f}\t{blob}\t{ps}\t{d['rc']}\t{out}\t{now()}\tstatus=done attempts={attempts} gaveup={gaveup}\n")
    # hits
    seen = set()
    if os.path.exists(A + "/hits.tsv"):
        for l in open(A + "/hits.tsv"):
            p = l.rstrip("\n").split("\t")
            if len(p) >= 7: seen.add((p[1], p[3], p[6]))
    for s in d["sorries"]:
        t = s.get("tac") or (s.get("try") and re.sub(r"\s+", " ", s["try"].split("Try this:", 1)[-1]).strip())
        if not t or (f, s["decl"], blob) in seen: continue
        seen.add((f, s["decl"], blob))
        open(A + "/hits.tsv", "a").write(f"{c}\t{f}\t{s['line']}\t{s['decl']}\t{t}\t{now()}\t{blob}\n")
        log("HIT", f, s["decl"], t)
    log("done", f, ps, "rc", d["rc"], "closed", sum(1 for s in d["sorries"] if s.get("tac")), "/", len(d["sorries"]), "gaveup", gaveup)
    return True

def main():
    os.makedirs(A + "/res/cheap", exist_ok=True); os.makedirs(A + "/res/exact", exist_ok=True)
    log("start pid", os.getpid())
    while True:
        try:
            c = refresh()
            if not c: time.sleep(300); continue
            q = due_files(c)
            state(queue=sum(len(x[4]) for x in q), queue_files=[x[2] for x in q][:12], current=None, waiting=False)
            if not q: time.sleep(300 if not fails() else 120); continue
            tier, _, f, blob, passes = q[0]
            sh(["git", "-C", WT, "checkout", "-q", "-f", "--", f])
            for ps in passes:
                if not sweep_file(f, blob, ps, c): break
                if open(BASE + "/COMMIT").read().strip() != c: break  # base moved: re-evaluate queue
        except Exception as e:
            log("error", repr(e)); time.sleep(120)
main()
