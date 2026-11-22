# Hourly coordinator check

The scheduled run reads this file every time. **Edit it here** (live: `S/HOURLY.md`) to change what
the hourly check does; the cron job never needs re-creating. Keep it short: it is read every hour.
The cron prompt is only: `Read /mnt/faststorage/math/riemann-masullo/.agent/sweeptools/HOURLY.md and follow it.`

S=/mnt/faststorage/math/riemann-masullo/.agent/sweeptools.

Coordinator only; CPU is cheap, tokens are scarce. Work autonomously, ask nothing, and post nothing
new upstream beyond normal Claiming/Releasing. QUICK-WINS MODE: Sonnet hunters first. We claim every
issue we work on or have queued for one of our agents.

0. `git fetch origin`. If AGENTS.md, CONTRIBUTING.md or ERRATA.md changed on origin/main since the
   last check (last seen: AGENTS 3de969e), re-read the change, update the briefs (HUNTER.md first),
   and update "last seen" here.
1. Run `status.sh` and `cleanup.sh` under timeout, output tailed.
2. Fix failing Verdicts or review comments with short Sonnet fixers; re-check the PR's state first.
3. Release orphan or stale claims only via `release.sh`, never those in the leads.txt ESCALATION
   QUEUE. Queued claims with no PR are auto-released upstream after 8 h: re-claim them if still
   queued.
4. Finished agents: read new `S/notes/report-*.md` (agents woken by the nagger report to it), relay
   each in one line, move the file to `notes/reports-done/`. TaskStop them once no Lean process
   remains in their worktree; record in `hunters.txt`; remove their line from `agents.txt`. If
   `pgrep -f nag-wait.sh` finds nothing while agents run, relaunch the nagger once (model haiku):
   "Follow the brief S/NAGGER.md exactly. It is a long-running loop: keep looping in this single
   turn and do not stop or write a final answer until its stop condition holds."
5. Services: warm, watchdog, memguard, sieve (restart commands in HANDOVER startup step 3).
6. READY or HINT lines in `== sieve`: launch ONE siever (SIEVER.md) unless one runs. No blind
   hunters.
7. New issues first: proof issues newer than the last shortlisted (last: #4616) get
   `shortlist.py` on their files and a Haiku triage (TRIAGE.md) into a new `triage<k>.tsv`; update
   "last" here. Keep 2–3 Sonnet hunters (HUNTER.md, tag "Claude Sonnet 5.5, effort medium") on rows
   rated 1–2 (then 3) with unclaimed issues: one file per hunter, ONE PR PER TOUCHED FILE, each
   issue listed in its prompt, no overlap (`claims.txt`, `hunters.txt`), no file crowded by 2–3
   other claimants or open PRs. Add each new hunter to `agents.txt`.
8. Escalation: issues a Sonnet released as STUCK (tried and failed, not merely unattempted or taken
   by others) go to Opus. Re-claim each at once if still free (`Claiming (Claude Opus 5.5, default
   effort)`, noting it is queued for an Opus prover), add it to `claims.txt` and the ESCALATION
   QUEUE, and launch one Opus escalation prover per file once our Sonnet has left it (HUNTER.md
   brief + the issue's notes and release comments; report `notes/report-esc-<file>.md`). Max 2 Opus.
9. No quick wins and no escalations: ONE Opus prover on any open unclaimed proof issue
   (`critical/CRITICAL_PROVER.md`; not gap/refutation/ERRATA/paper-gap, not sweep-held). Record in
   `hunted.txt`, add to `agents.txt`.
10. Report in one or two lines.
