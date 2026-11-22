---
name: sieve-naming
description: Our automated tactic screen is called the "sieve" (service sieve.sh, hand-in role "siever", brief SIEVER.md) to avoid confusion with upstream's "sweeper" role
metadata:
  type: project
---

Named 2026-11-22 at the user's request. Upstream's `sweeper` (prompts/sweeper.md) is a reasoning agent that closes out one file's hard tail. Ours is a mechanical tactic screen over every sorry.
- Service: .agent/sweeptools/sieve.sh (renamed from "autosweep" while it was being built). State in sieve/ (hits.tsv, swept.tsv, res/). Worktree .agent/wt/sieve, log sieve.log, docs SIEVE.md, status.sh section `== sieve`.
- Hand-in agent: "siever", brief .agent/sweeptools/SIEVER.md. Launch: "Read SIEVER.md and follow it. Your model tag <M> is ...; your hits: <READY/HINT lines>". Sonnet, effort medium.
- Low-level tools keep their old names: sweep.py, lean/Sweep*.lean.txt, and the res1-res4 results. Older notes say "sweep4" and "sweep agent" for the first one-off sieve run.
Related: [[low-hanging-sweep]], [[claims-notes-attribution]].

State 2026-11-22 ~04:25Z: sieve.sh is live (wrapper PID 45589, sieve.py 45591, log sieve.log), base a7fe037. Ch07 Sec1a test: 0/8 closed in either pass (~4 min). sieve/priority.txt lists Ch06 Sec1, Sec2 and Ch07 Sec1a, 1b first; it started on Ch06 Sec1 at 03:55Z. sweep.py gained `--only L1,L2` and process-group kills on timeout. Status: sieve_status.py prints the `== sieve` section at the end of status.sh. The READY/HINT/CLAIMED/WAIT classes have not been tested against real issues yet; verify on the first real hits. The one-off sweep4 agent is retired, and its worktree and branch sweep/run4 are removed. Hourly cron 68ea7858 dispatches ONE Sonnet siever on READY/HINT lines and launches no blind hunters.
