# Hourly coordinator check

The scheduled run reads this file every time. **Edit it here** (live: `S/HOURLY.md`) to change what
the hourly check does; the cron job never needs re-creating. Keep it short: it is read every hour.
The cron prompt is only: `Read /mnt/faststorage/math/riemann-masullo/.agent/sweeptools/HOURLY.md and follow it.`

S=/mnt/faststorage/math/riemann-masullo/.agent/sweeptools.

Coordinator only; CPU is cheap, tokens are scarce. Work autonomously, ask nothing, and post nothing
new upstream beyond normal Claiming/Releasing. STAFFING (user): 4 Sonnet hunters (step 7) and 3
Opus slots filled by need (step 8). We claim every issue we work on or have queued for one of our
agents.

0. `git fetch origin`. If AGENTS.md, CONTRIBUTING.md or ERRATA.md changed on origin/main since the
   last check (last seen: AGENTS 3de969e, ERRATA a04742c), re-read the change, update the briefs (HUNTER.md first),
   and update "last seen" here.
1. Run `status.sh` and `cleanup.sh` under timeout, output tailed.
2. Fix failing Verdicts or review comments with short Sonnet fixers; re-check the PR's state first.
3. Release orphan or STALE claims only via `release.sh`. `ESCALATED` lines are not stale: leave
   them. For `ESCALATED … REFRESH-CLAIM` (claim older than 7 h; upstream auto-releases after 8 h),
   post `Claiming (Claude Opus 5.5, default effort): queued for an Opus escalator` once.
4. Finished agents: read new `S/notes/report-*.md` (agents woken by the nagger report to it), relay
   each in one line, move the file to `notes/reports-done/`. TaskStop them once no Lean process
   remains in their worktree; record in `hunters.txt`; remove their line from `agents.txt`. If
   `pgrep -f nag-wait.sh` finds nothing while agents run, relaunch the nagger once (model haiku):
   "Follow the brief S/NAGGER.md exactly. It is a long-running loop: keep looping in this single
   turn and do not stop or write a final answer until its stop condition holds."
5. Services: warm, watchdog, memguard, sieve (restart commands in HANDOVER startup step 3). RAM:
   count memguard kills of agent builds (not sieve runs) in `memguard.log` over the last hour. If
   there are more than 3, launch no new agents this tick and say so in the report; tell the user if
   it repeats.
6. READY or HINT lines in `== sieve`: launch ONE siever (SIEVER.md) unless one runs. No blind
   hunters.
7. New issues first: proof issues newer than the last shortlisted (last: #5344, triage7a-f) get
   `shortlist.py` on their files and a Haiku triage (TRIAGE.md) into a new `triage<k>.tsv`; update
   "last" here. Keep 4 Sonnet hunters (HUNTER.md, tag "Claude Sonnet 5.5, effort medium") on rows
   rated 1–2 (then 3) with unclaimed issues: one file per hunter, ONE PR PER TOUCHED FILE, each
   issue listed in its prompt, no overlap (`claims.txt`, `hunters.txt`), no file crowded by 2–3
   other claimants or open PRs. Add each new hunter to `agents.txt`.
8. Opus slots: 3, assigned at every check (user, 2026-11-22: "If there's enough escalation work,
   use them all for it, otherwise scale back escalation and use them as hunters"). Escalation work
   = files with QUEUED `opus` rows in `S/escalations.txt` that our Sonnet has left and no escalator
   holds. Fill each free slot with an escalator for the oldest such file; only when none waits,
   with an Opus hunter. Do not stop running agents to rebalance; slots shift as they finish.
   Both run on model opus, tag "Claude Opus 5.5, default effort"; add each to `agents.txt`.
   - Escalator, one file each: "Read S/HUNTER.md and follow it exactly; you are an escalator (see
     'Escalators'). Your name is esc-<file>, branch prefix esc/<file>, model tag Claude Opus 5.5,
     default effort. Your escalated issues: <rows>." Report `notes/report-esc-<file>.md`. Never
     re-claim an escalated issue (`escalate.sh` kept our claim).
   - Opus hunter: "Read S/critical/CRITICAL_PROVER.md and follow it. Your issue is #<n>. Your model
     tag <M> is Claude Opus 5.5, default effort." Any open unclaimed proof issue (not
     gap/refutation/ERRATA/paper-gap, not sweep-held), preferring triage rows rated 3–4 that no
     Sonnet holds, never in a file another of our agents works in. Record in `hunted.txt`.
8b. Fable: if `escalations.txt` has a QUEUED row with level `fable` and no Fable consultant runs,
   launch ONE (model fable, outside the standing slots): "Read S/FABLE.md and follow it. Your issue:
   <row>." Its ROUTE/SPLIT hand-back appears as a new `opus` row (step 8). Add it to
   `agents.txt`.
   **The coordinator may escalate to Fable itself** when that is the better use of tokens: an
   Opus agent released an issue it tried and failed without escalating; the Opus evaluator marked
   a finding UNCLEAR; the same blocker keeps stopping several issues (one packet for the shared
   step); or an important issue has had two or more failed attempts upstream. Claim it if it is
   not ours (`Claiming (Claude Fable 5.2, default effort)`, add to `claims.txt`), append a short
   `## Stuck packet` to `notes/<n>.md` from the notes, release comments and the issue (no Lean
   runs: leave "Goal at the stuck point" as `to compute`), then run
   `escalate.sh <n> "<reason>" --to fable`. One Fable consultant at a time still applies.
9. Findings: add every `Finding:` line from new reports and every SUSPECT triage row to
   `S/findings.txt` as QUEUED. If QUEUED rows exist and no evaluator runs, launch ONE Opus
   evaluator (model opus, no effort override): "Read S/FINDINGS.md and follow it. Your findings:
   <rows>." It runs on top of the standing slots and posts confirmed findings itself.
10. Report in one or two lines.
