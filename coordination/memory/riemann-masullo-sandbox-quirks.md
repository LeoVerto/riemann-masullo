---
name: riemann-masullo-sandbox-quirks
description: Build and tooling pitfalls in the riemann-masullo sandbox (lake lean vs lake env lean, open-file limit, Lake cache, memguard, gh 401 cache, recreation, time zones)
metadata:
  type: project
---

Current facts (compacted 2026-11-22):
- **Use `lake lean <file>`, never `lake env lean`.** Only the former applies lakefile leanOptions (autoImplicit=false, maxSynthPendingDepth=3, linter.unusedSectionVars=false, a linter that took 20 min on one AppD proof). Our sweeps res1–res4 and early hunter probes used `lake env lean`; that explains most of the "#1288 elaboration timeouts". Never print raw Exprs: `repr` has used 70 GB.
- A full `lake build` can fail on the chapter index modules with "Too many open files" (the host mount's file handles, not the ulimit). Build them one at a time and re-run; warm.sh does this itself. Watch warm.log for "build failed".
- The Lake artifact cache is ON: `LAKE_ARTIFACT_CACHE=true`, `LAKE_CACHE_DIR=<repo>/.lake/artifact-cache`, `LAKE_RESTORE_ARTIFACTS=true` in /etc/sandbox-persistent.sh. Without RESTORE it wrote no local .olean (that broke signatures.sh), so never drop RESTORE. Set it only through env, never the lakefile. The user approved writing to that .lake subdir only.
- 16 GB RAM, 24 cores. The 2026-11-22 OOM was the HOST running out of memory. memguard LOW=1000 MB, sieve worktree Lean first; the sieve waits for more than 6 GB free.
- gh caches responses for 24 h, including 401s: `rm -rf ~/.cache/gh` (tokencheck.sh does this).
- `scripts/paper.sh` needs poppler-utils (apt). The overlay root and /home/agent do not survive a sandbox recreation. The repo (with .lake and branches) and .agent/ do. Recovery steps are in the HANDOVER startup checklist.
- After a crash or kill: services die, crons may survive, some agents restart from their transcripts.
- SANDBOX_NAME is riemann-masullo-faststorage. Transcripts are in ~/.claude/projects/-mnt-faststorage-math-riemann-masullo.
- Time zones: the shell's TZ is CET (date, status.sh and logs are UTC+1); CronCreate uses UTC.

Related: [[state-in-dot-agent]], [[github-token-scope]], [[low-hanging-sweep]].
- **CPU contention with 7–8 agents (2026-11-22 17:25Z, user reported subagent timeouts):** load ~19/24 cores; module builds took 3x longer than HUNTER.md's old `timeout 300`. Fix: warm.sh and sieve.sh run at nice 19 (`renice` is not installed; use `nice -n 19` at start, or Python `os.setpriority` on their process group), and HUNTER.md now uses 900 s module builds, 300 s probes, 3600 s full builds in the background, retry once on a timeout under load. One Bash call caps at 600 s.
