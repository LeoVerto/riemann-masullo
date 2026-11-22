#!/usr/bin/env python3
"""sieve service loop; see SIEVE.md. Run via sieve.sh."""
import json, os, re, subprocess, sys, time, datetime
R = "/mnt/faststorage/math/riemann-masullo"; T = R + "/.agent/sweeptools"; WT = R + "/.agent/wt/sieve"
A = T + "/sieve"; BASE = T + "/base"
TMO = {"cheap": 1800, "exact": 7200}
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

def lean_running():
    return sh(["pgrep", "-x", "lean"]).stdout.split() and \
        any("--json" in open(f"/proc/{p}/cmdline").read() for p in sh(["pgrep", "-x", "lean"]).stdout.split() if os.path.exists(f"/proc/{p}/cmdline"))
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
    for n, f in (("Sweep", "Sweep.lean.txt"), ("Sweep2", "Sweep2.lean.txt")):
        sh(["cp", f"{T}/lean/{f}", f"{WT}/RiemannMasullo/{n}.lean"])
    wait_ready()
    p = sh(["nice", "-n", "10", "lake", "build", "RiemannMasullo.Sweep", "RiemannMasullo.Sweep2"], cwd=WT)
    log("macro build rc", p.returncode, p.stdout[-200:] if p.returncode else "")
    if p.returncode: return None
    open(A + "/installed", "w").write(c)
    return c

def due_files(c):
    swept = {}
    if os.path.exists(A + "/swept.tsv"):
        for l in open(A + "/swept.tsv"):
            p = l.rstrip("\n").split("\t")
            if len(p) >= 4: swept.setdefault((p[0], p[2]), []).append(p[1])  # (file,pass) -> blobs
    out = sh(["git", "-C", WT, "grep", "-lw", "sorry", c, "--", "RiemannMasullo"]).stdout.split()
    files = [x.split(":", 1)[1] for x in out if "/External/" not in x and not x.endswith(("/Sweep.lean", "/Sweep2.lean"))]
    if ONLY: files = [f for f in files if f in ONLY.split(",")]
    q = []
    prio = open(A + "/priority.txt").read().split() if os.path.exists(A + "/priority.txt") else []
    for f in files:
        blob = sh(["git", "-C", WT, "rev-parse", f"{c}:{f}"]).stdout.strip()
        ct = int(sh(["git", "-C", WT, "log", "-1", "--format=%ct", c, "--", f]).stdout.strip() or 0)
        passes = [ps for ps in ("cheap", "exact") if blob not in swept.get((f, ps), [])]
        if not passes: continue
        changed = any((f, ps) in swept for ps in ("cheap", "exact"))
        tier = 0 if (changed or ct > time.time() - 12 * 3600) else 1
        if f in prio: tier, ct = -1, -prio.index(f)
        q.append((tier, -ct, f, blob, passes))
    q.sort()
    return q

def run_sweep(f, ps, out, extra):
    p = sh(["python3", T + "/sweep.py", WT, f, out] + extra)
    return p.stdout.strip()

def sweep_file(f, blob, ps, c):
    out = f"{A}/res/{ps}/{f.replace('/', '_')}.json"
    flag = ["--exact"] if ps == "exact" else []
    tmo = TMO[ps]
    wait_ready()
    state(current=f"{f} [{ps}]", since=time.time())
    run_sweep(f, ps, out, flag + ["--timeout", str(tmo)])
    d = json.load(open(out)); timeouts = 0
    if d["rc"] == 124:
        timeouts += 1; log("timeout", f, ps, "-> chunks")
        lines = [s["line"] for s in d["sorries"]]
        merged = {}
        for k in range(0, len(lines), 4):
            ch = lines[k:k + 4]; wait_ready()
            o = out + ".chunk"; run_sweep(f, ps, o, flag + ["--timeout", str(tmo), "--only", ",".join(map(str, ch))])
            cd = json.load(open(o))
            if cd["rc"] == 124 and len(ch) > 1:
                timeouts += 1
                for l in ch:
                    wait_ready(); run_sweep(f, ps, o, flag + ["--timeout", str(tmo), "--only", str(l)])
                    sd = json.load(open(o))
                    if sd["rc"] == 124: timeouts += 1
                    for s in sd["sorries"]: s["timeout"] = sd["rc"] == 124; merged[(s["line"], s["col"])] = s
            else:
                for s in cd["sorries"]: s["timeout"] = cd["rc"] == 124; merged[(s["line"], s["col"])] = s
        os.path.exists(out + ".chunk") and os.remove(out + ".chunk")
        d["sorries"] = list(merged.values()) or d["sorries"]; d["chunked"] = True; d["timeouts"] = timeouts
        json.dump(d, open(out, "w"), indent=1)
    with open(A + "/swept.tsv", "a") as fh:
        fh.write(f"{f}\t{blob}\t{ps}\t{d['rc']}\t{out}\t{now()}\ttimeouts={timeouts}\n")
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
    log("done", f, ps, "rc", d["rc"], "closed", sum(1 for s in d["sorries"] if s.get("tac")), "/", len(d["sorries"]))

def main():
    os.makedirs(A + "/res/cheap", exist_ok=True); os.makedirs(A + "/res/exact", exist_ok=True)
    log("start pid", os.getpid())
    while True:
        try:
            c = refresh()
            if not c: time.sleep(300); continue
            q = due_files(c)
            state(queue=sum(len(x[4]) for x in q), queue_files=[x[2] for x in q][:12], current=None, waiting=False)
            if not q: time.sleep(300); continue
            tier, _, f, blob, passes = q[0]
            sh(["git", "-C", WT, "checkout", "-q", "-f", "--", f])
            for ps in passes:
                sweep_file(f, blob, ps, c)
                if open(BASE + "/COMMIT").read().strip() != c: break  # base moved: re-evaluate queue
        except Exception as e:
            log("error", repr(e)); time.sleep(120)
main()
