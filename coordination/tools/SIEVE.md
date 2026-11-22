# sieve: standing background sweep of every sorry (replaces nothing; sweep.py and macros unchanged)
- Start: cd S && setsid nohup ./sieve.sh >> sieve.log 2>&1 < /dev/null &   Stop: kill $(cat sieve/wrapper.pid) and the python child (pid in sieve/state.json).
- sieve.py: worktree $R/.agent/wt/sieve (detached, follows base/COMMIT, build copied from base/build, Sweep*.lean installed only there, untracked).
- Queue: files with `sorry` whose git blob differs from the last completed pass in sieve/swept.tsv; tier 0 = changed since last sweep or touched <12h, then backlog; newest commit first. Per file: cheap pass (30 min) then exact? pass (120 min).
- Timeout: file is re-run in chunks of 4 sorries (sweep.py --only L1,L2), then per sorry; timeouts recorded in swept.tsv (last column).
- One lean at a time; waits until no other `lean --json` runs and MemAvailable > 6000 MB; nice 10; kills only its own process group.
- Output: sieve/res/{cheap,exact}/<file>.json, sieve/hits.tsv (commit, file, line, decl, tactic, date, blob), sieve/state.json, sieve.log.
- status.sh `== sieve` (sieve_status.py) classifies unreported hits via gh + origin/main:
  READY #n (open unclaimed proof issue, file not in an open sweep issue), HINT #n (file held by open sweep issue), CLAIMED #n, WAIT (no issue yet), DONE (no longer sorry on origin/main).
- DONE hits go to sieve/reported.txt; hits listed in dispatched.txt (`<file>::<decl>`) are hidden. READY/HINT/WAIT repeat until dispatched.
- sieve/priority.txt: files listed there (one per line) go first, in order, while due.
