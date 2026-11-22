# Hourly coordinator check

The scheduled run reads this file every time. **Edit it here** (live: `S/HOURLY.md`) to change what
the hourly check does; the cron job never needs re-creating. Keep it short: it is read every hour.
The cron prompt is only: `Read /mnt/faststorage/math/riemann-masullo/.agent/sweeptools/HOURLY.md and follow it.`

S=/mnt/faststorage/math/riemann-masullo/.agent/sweeptools.

Coordinator only; CPU is cheap, tokens are scarce. Work autonomously, ask nothing, and post nothing
new upstream beyond normal Claiming/Releasing. STAFFING (user): one budget shared by Sonnet
hunters and Opus provers, at least 2 Opus and at most 6 Sonnets (step 7). We claim every issue we
work on or have queued for one of our agents.

0. `git fetch origin`. If AGENTS.md, CONTRIBUTING.md or ERRATA.md changed on origin/main since the
   last check (last seen: AGENTS 3de969e, ERRATA a04742c), re-read the change, update the briefs (HUNTER.md first),
   and update "last seen" here.
1. Run `status.sh --mark` (advances the new-comments window) and `cleanup.sh` under timeout,
   output tailed.
2. Fix failing Verdicts or review comments with short Sonnet fixers; re-check the PR's state first.
3. Release orphan or STALE claims only via `release.sh`. `ESCALATED` lines are not stale: leave
   them. For `ESCALATED … REFRESH-CLAIM` (claim older than 7 h; upstream auto-releases after 8 h),
   post `Claiming (Claude Opus 5.5, default effort): queued for an Opus escalator` once.
   `NEW #<n>` lines (others' comments on our claims, user): pass each to the agent that holds the
   issue (agents.txt) with SendMessage, one line: "New comment on #<n> by <author>; read it with
   S/prior.sh <n> and take it into account." For a queued issue, add an `Upstream:` line to
   `notes/<n>.md`. A `Claiming` by someone else, or a github-actions "already claimed" reply to
   ours: check the Claiming/Releasing sequence (`prior.sh <n>`). If an unreleased claim by someone
   else came before ours, release ours; a stuck label (as on #4411, our own claim) is no reason.
   An integrator decision (statement changed, gap, closed) goes to the holder as "stop".
4. Finished agents: read new `S/notes/report-*.md` (agents woken by the nagger report to it), relay
   each in one line, move the file to `notes/reports-done/`. TaskStop them once no Lean process
   remains in their worktree; record in `hunters.txt`; remove their line from `agents.txt`. If
   `pgrep -f nag-wait.sh` finds nothing while agents run, relaunch the nagger once (model haiku):
   "Follow the brief S/NAGGER.md exactly. It is a long-running loop: keep looping in this single
   turn and do not stop or write a final answer until its stop condition holds. Every Bash call is FOREGROUND (never run_in_background) and must finish within 170 s (the harness backgrounds longer calls). Never end your turn to wait for anything. If a hunter sends you its final results, ignore them and carry on."
5. Services: warm, watchdog, memguard, sieve (restart commands in HANDOVER startup step 3). RAM:
   count memguard kills of agent builds (not sieve runs) in `memguard.log` over the last hour. If
   there are more than 3, launch no new agents this tick and say so in the report; tell the user if
   it repeats.
6. READY or HINT lines in `== sieve`: launch ONE siever (SIEVER.md) unless one runs. No blind
   hunters.
7. Staffing (user, 2026-11-22: "when two sonnets are idle, spawn an opus instead. keep at minimum
   two opuses and at maximum six sonnets"). Budget 10 units: a Sonnet hunter costs 1, an Opus
   prover (escalator or Opus hunter) 2. Fixers, sievers, triage, nagger, Fable and the findings
   evaluator are outside it. Count the running ones (`agents.txt`), then hand out free units in
   this order, and never stop a running agent to rebalance:
   1. Opus (step 8) until 2 Opus run.
   2. Sonnet hunters while quick-win rows (7a) exist, up to 6 Sonnets.
   3. What is left, two units at a time, to Opus (step 8). One unit left over waits.
7a. New issues first: proof issues newer than the last shortlisted (last: #5344, triage7a-f) get
   `shortlist.py` on their files and a Haiku triage (TRIAGE.md) into a new `triage<k>.tsv`; update
   "last" here. Sonnet hunters (HUNTER.md, tag "Claude Sonnet 5.5, effort medium") take rows
   rated 1–2 (then 3) with unclaimed issues: one file per hunter, ONE PR PER TOUCHED FILE, each
   issue listed in its prompt, no overlap (`claims.txt`, `hunters.txt`), no file crowded by 2–3
   other claimants or open PRs. Add each new hunter to `agents.txt`.
8. Opus work: each Opus that step 7 allows takes the first of these that exists (user,
   2026-11-22).
   a. Escalation: the oldest file with QUEUED `opus` rows in `S/escalations.txt` that our Sonnet
      has left and no escalator holds.
   b. Prior work (user: "If we have prior work on an issue, we should strive to build on top of
      it", including others' attempts): `resumable.sh` lists open unclaimed issues with earlier
      attempts, ours first, then others' write-ups, by file. Skip rows whose agents.txt agent still
      runs. Take a file's rows together: post `Claiming (Claude Opus 5.5, default effort):
      continuing an earlier attempt` on each, add them to `claims.txt`, and run
      `escalate.sh <n> "continuing prior work: <source> <summary>" --prior`. They are now a.
   c. Last resort: an Opus hunter on a fresh issue, only when a and b are empty.
   Both kinds run on model opus, tag "Claude Opus 5.5, default effort"; add each to `agents.txt`.
   - Escalator, one file each: "Read S/HUNTER.md and follow it exactly; you are an escalator (see
     'Escalators'). Your name is esc-<file>, branch prefix esc/<file>, model tag Claude Opus 5.5,
     default effort. Your escalated issues: <rows>." Report `notes/report-esc-<file>.md`. Never
     re-claim an issue `escalate.sh` queued (the claim is kept).
   - Opus hunter: "Read S/critical/CRITICAL_PROVER.md and follow it. Your issue is #<n>. Your model
     tag <M> is Claude Opus 5.5, default effort." Any open unclaimed proof issue (not
     gap/refutation/ERRATA/paper-gap, not sweep-held), preferring triage rows rated 3–4 that no
     Sonnet holds, never in a file another of our agents works in. Record in `hunted.txt`.
8b. Fable: if `escalations.txt` has a QUEUED row with level `fable` and no Fable consultant runs,
   launch ONE (model fable, outside the step-7 budget): "Read S/FABLE.md and follow it. Your issue:
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
   <rows>." It runs outside the step-7 budget and posts confirmed findings itself.
10. Report in one or two lines.
