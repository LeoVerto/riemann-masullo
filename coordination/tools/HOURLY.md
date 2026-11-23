# Hourly coordinator check (runs every 30 min: cron `17,47 * * * *`, user 2026-11-23 ~02:10Z)

The scheduled run reads this file every time. **Edit it here** (live: `S/HOURLY.md`) to change what
the hourly check does; the cron job never needs re-creating. Keep it short: it is read every 30 min.
The cron prompt is only: `Read /mnt/faststorage/math/riemann-masullo/.agent/sweeptools/HOURLY.md and follow it.`

S=/mnt/faststorage/math/riemann-masullo/.agent/sweeptools.

Coordinator only; CPU is cheap, tokens are scarce. Work autonomously and post nothing new upstream
beyond normal Claiming/Releasing. Ask the user when a decision is theirs (for example, two of their
instructions conflict), but never wait for the answer: they may be away. Carry on with the newer
instruction or the safer choice and say which in the report. We claim an issue when one of our agents starts on
it. A hand-over (escalation to an Opus escalator or the Fable consultant) keeps the claim for at
most 2 h; then it is released with the notes. Never re-post a claim to dodge upstream's 8 h
auto-release on an issue nobody works on (user, 2026-11-22).

**Launching agents.** Use the Agent tool's `subagent_type`. The definitions (`.agent/agents/`) fix
model, effort and tools and send each agent to its brief, so the prompt carries only the specifics
below. `<M>` is `Claude Sonnet 5.5, effort medium` for Sonnet types, `Claude Opus 5.5, default
effort` for Opus types. If the Agent tool does not list these types, the session started before
`.claude/agents` existed: launch with the definition's model and begin the prompt with its "read
<brief>" line. Units are step 7's budget. Add hunters, escalators, Opus hunters and the Fable
consultant to `agents.txt` (the nagger's roster), one line `<name> <agentId> $(date +%s) <issue numbers without #>` (an ISO time there broke notes-stale.sh on 2026-11-23).

| Type (model) | Units | Prompt |
|---|---|---|
| `hunter` (Sonnet) | 1 | `Your name is w<k>, branch prefix hunt/w<k>, model tag <M>. Your issues: <list>.` |
| `escalator` (Opus) | 2 | `Your name is esc-<file>, branch prefix esc/<file>, model tag <M>. Your escalated issues: <rows>.` |
| `opus-hunter` (Opus) | 2 | `Your issue is #<n>. Your model tag <M>.` |
| `siever` (Sonnet) | – | `Your name is siev<k>, model tag <M>. Your hits: <lines>.` |
| `triage` (Haiku) | – | `N = 60.` |
| `fable-consultant` (Fable) | 2 | `Your issue: <row>.` |
| `findings-evaluator` (Fable) | – | `Your findings: <rows>.` |
| `nagger` (Haiku) | – | `Start the loop.` |
| fixer: `general-purpose`, model sonnet, effort medium | – | `Fix <failing check or review comment> on PR #<p> in worktree <wt>, following S/HUNTER.md "Checks and pull request". Model tag <M>.` |

0. `git fetch origin`. If AGENTS.md, CONTRIBUTING.md or ERRATA.md changed on origin/main since the
   last check (last seen: AGENTS 9d44796, ERRATA ecf567d), re-read the change, update the briefs
   (HUNTER.md first), and update "last seen" here.
0a. **#5889 MERGED** (2026-11-23 ~03:45Z, merge 0b7a2349). Claimed and queued (opus): #3878 (AppB Sec6,
   crowded: elmismisimoxhunca holds #3879), #5673 (Ch01 Sec4; #6012 merged 03:58Z, so no longer crowded; launch once warm has fb3acbf0), #4973
   (Ch10 Sec2, RISK-5398). #3878 LAUNCHED 04:00Z (esc-appbsec6b); #4973 LAUNCHED 04:1xZ (esc-ch10sec2, PR #6063); #3878 PR #6071; #5673 LAUNCHED 05:0xZ (esc-ch01sec4). Step done. Launch the rest (step 8a, one escalator each) only once
   `git merge-base --is-ancestor 0b7a2349 <warm base>` holds (warm.log `ready` line); prompts name the
   vendored `RiemannMasullo/External/Grh/` lemmas the PR body assigns (horizontal estimates: finite zero
   factors, disk lower bound, log averaging; #4973: real-line L2, tail and pairing) and say "crowded file"
   where noted. Held ones (#3879 #3869 #3875 #3884 #3889 elmismisimoxhunca, #4982 factory-davidgu):
   no hints (user 04:0xZ: the integrator already commented on them). Then mark this step done.
0b. (Done 2026-11-23 ~03:15Z: #4078/#4079 re-claimed by us after the user noted the last claims were ~5 h old; escalator esc-ch07sec1b4.)
0c. **#6043 MERGED** (~04:45Z). #4666 claimed and queued (opus). Launch its escalator when 2 units are
   free and the warm base contains #6043 (`gh pr view 6043 --json mergeCommit`), AFTER the 0d fixes. Its prompt
   says: use `IsCompact.isConnected_compl_iff_forall_differentiableOn_exists_polynomial_norm_sub_lt`
   (import `RiemannMasullo.External.TauCeti.Analysis.Complex.Runge.Approximation`); what is left is the
   inductive entire-function construction of ERRATA F22 plus connected complements of each stage's
   square ∪ discs ∪ points; vendored Tau Ceti names live in `RiemannMasullo.External.TauCeti` except
   `_root_` ones. Weaker leads (leads.txt): #4072, #4079, #4078. Tell the user it merged (done 04:5xZ).
0d. **`import all` fixes** (AGENTS.md 9d44796 bans new `import all`): #6071 KEEPS its `import all` of External/Grh (user 05:1xZ: vendoring means we don't copy code in; asked the
   integrator on the PR 05:1xZ, wait for their answer) and #6072 (adds `import all` of Ch06 Sec2 and Ch03 Sec3;
   fix: make the private lemmas it uses public in place per AGENTS.md, plain imports). One Sonnet fixer
   (general-purpose, model sonnet, 1 unit) per PR, first free units; each re-checks the PR is OPEN, edits
   its worktree, rebuilds, lint, signatures compare (expect only the made-public names), axioms unchanged,
   pushes, one-line PR comment. fix6072 stopped 05:2xZ: #6072 had merged 04:53Z with its import all (left to #5966); fix6071 stopped by the user. Step done except #6071 awaiting the integrator. Then: #4666 FIRST (warm has #6043; user 05:3xZ: it was closed by mistake at 04:46Z by the phrase "does not close #4666" in the vendor PR, so nobody else will pick it up: get it done; PR still says `Closes #4666`; if we must release it, ask the user about reopening it), then #4911 opus (Fable ROUTE; #6066 MERGED, build on main). 05:2xZ: 5h 87%, budget 2, held until usage allows.
0e. **#5966 "make helpers public" quick wins** (user 05:3xZ: "should be handle-able by sonnet, they just take
   CPU time"): #5998 (AppA Sec2; koffie claimed 05:43Z), #5999 (AppA Sec1), #6000 (Ch02 Sec2a), #6001 (AppC Sec1), #6002 (AppD Sec1a),
   #6003 (AppA Sec3), #6004 (AppD Sec1b); #5997 is sflicht's. Not proof issues; the issue body is the task
   (remove `private` in place, descriptive names + docstrings, private instances stay private, plain imports in
   the listed importers, signatures compare lists only the renamed names, PR `Closes #n` + "part of #5966").
   Claim each only when an agent starts it (`claims.py` first). Sonnet `hunter`, 1 unit, ONE issue per agent at
   a time, and AT MOST TWO quick-win agents running at once (user 06:0xZ: "they do tend to peg CPU"; w33/w34/w35 were
   already running when this was set, so launch the next only when fewer than two remain) (importer edits overlap across issues: two agents must not touch the same importer file at once;
   check the issue's "Files with import all" lists). Order (user 05:5xZ: "the quick wins have priority and CPU is plentiful … prioritize them first"): FIRST, before #4666 and #4911. 05:5xZ: w33 #5999, w34 #6004 launched (disjoint importer lists). 06:0xZ: w35 #6001 (minor import-line overlap with w33/w34). Next, as each finishes: #6002, #6000, #6003, picking one whose importer list is disjoint from those running.
   The brief must quote HUNTER "Builds and processes" (never pkill -f) and say full builds are expected.
1. Run `status.sh --mark` (advances the new-comments window) and `cleanup.sh` under timeout,
   output tailed.
2. Failing Verdicts or review comments: one fixer each; re-check the PR's state first.
   A Verdict `error` with "main itself does not build" is not ours: once main builds again
   (Main state check green), push an empty commit to the PR branch to retrigger (pending: leads.txt).
3. Release orphan or STALE claims only via `release.sh`. `QUEUED #<n> RELEASE` (queued over 2 h,
   no agent took it): `release.sh <n> "queued for <level> escalation, no agent free within 2 h; notes
   below"` (it marks the queue row RELEASED; `resumable.sh` offers it again in 8b). `QUEUED #<n>
   (…grace)` and `ESCALATED #<n> (taken …)`: leave them. `ESCALATED … REFRESH-CLAIM` (taken, claim
   older than 7 h): if that agent still runs (agents.txt), post `Claiming (<its M>): still working,
   <one line of progress from notes/<n>.md>` once; if it does not, release instead.
   `NEW #<n>` lines (others' comments on our claims): pass each to the agent that holds the issue
   (agents.txt) with SendMessage, one line: "New comment on #<n> by <author>; read it with
   S/prior.sh <n> and take it into account." For a queued issue, add an `Upstream:` line to
   `notes/<n>.md`. A `Claiming` by someone else, or a github-actions "already claimed" reply to
   ours: check the Claiming/Releasing sequence (`prior.sh <n>`). If an unreleased claim by someone
   else came before ours, release ours. An unreleased Claiming by elmismisimoxhunca always wins, whatever the order (user, 2026-11-23 ~01:35Z: "does not read comments once they've claimed an issue, assume they think it's their claim and will keep working on it"): release ours with notes and stop our agent on it. A leftover `claimed` label (as on #4411, our own claim) is no reason.
   An integrator decision (statement changed, gap, closed) goes to the holder as "stop".
4. Finished agents: read new `S/notes/report-*.md` (agents woken by the nagger report to it), relay
   each in one line, move the file to `notes/reports-done/`. TaskStop them once no Lean process
   remains in their worktree; record in `hunters.txt`; remove their line from `agents.txt`. If
   `pgrep -f nag-wait.sh` finds nothing while agents run, launch the nagger once.
5. Services: warm, watchdog, memguard (the sieve is stopped: user, 2026-11-23 ~02:45Z "I think we can stop the sieve at this point"; do not restart it) (restart commands in HANDOVER startup step 3). RAM:
   count memguard kills of agent builds (not sieve runs) in `memguard.log` over the last hour. If
   there are more than 3, launch no new agents this tick and say so in the report; tell the user if
   it repeats.
6. (Sieve stopped 2026-11-23; no sievers.)
7. Staffing (user, 2026-11-22: "when two sonnets are idle, spawn an opus instead. keep at minimum
   two opuses and at maximum six sonnets"; 20:20Z: "bump the budget to twelve"; 23:10Z, CPU pegged:
   "let's drop to 10 slots for now"). **Max budget 10 units.** Scale it down by token usage (user,
   2026-11-23 ~01:05Z: "dynamically scale down from the max budget if the remaining token budget
   gets low … Once the reset has hit, it's free to scale up again"). Take the `== claude usage`
   line of `status.sh` (or run `usage.sh`) and use the lowest budget any row gives:

   | Usage (5h window, and 7d likewise) | Budget this tick |
   |---|---|
   | under 70% | 10 (max) |
   | 70–85%, or 5h ≥ 50% with more than 3 h to its reset | 6 |
   | 85–95% | 2 |
   | 95% or more | 0: launch nothing |

   No new Fable agent (consultant or findings evaluator) while `fable-7d` ≥ 85%. The scaled
   budget overrides the 2-Opus minimum. If `usage.sh` fails, keep last tick's budget, never raise
   it. After a reset the percentage drops (or reads "window already reset (stale)"): take the row
   for the new value, up to the max again. While running agents exceed the budget, launch nothing.
   At 95% or more with over 30 min to the reset, also wind down the agents beyond the budget,
   newest first, via notes, as on 2026-11-23 ~00:25Z (user: agents done and only waiting for
   builds/checks finish their hand-in). Name the usage, budget and reset time in the report. Count the running
   agents (`agents.txt`), then hand out free units in this order, never stopping a running agent
   to rebalance (the 95% wind-down aside):
   1. Opus (step 8) until 2 run.
   2. Fable consultants (step 8b, 2 units each, at most 2 at once), while QUEUED `fable` rows wait.
      Consultations come before new work (user, 2026-11-22): while such a row waits, hold freed
      units for it instead of starting Sonnet hunters or Opus beyond the two above.
   3. Sonnet hunters while quick-win rows (7a) exist, up to 6 Sonnets.
   4. What is left, two units at a time, to Opus (step 8). One unit left over waits.
7a. New issues first: proof issues newer than the last shortlisted (last: #5820, triage14) get
   `shortlist.py` on their files and a triage agent into a new `triage<k>.tsv`; update "last"
   here. Hunters take rows rated 1–2 (then 3) with unclaimed issues not labelled `stuck`, listed in
   the prompt by file (run `trap5398.py` on them and append `(RISK-5398)` to flagged issues):
   files in sequence, ONE PR PER TOUCHED FILE, until the list is done, 4 PRs or ~3 h (user:
   "Files in sequence"). No overlap (`claims.txt`, `hunters.txt`), prefer files not crowded by 2–3
   other claimants or open PRs. **Crowded files as a fallback** (user, 2026-11-23 ~02:10Z: "Only
   10% of theorems are left unproven so we might not be able to avoid cluttering files much
   longer"): when free units have no uncrowded work, an agent may take an issue that `claims.py`
   shows FREE in a crowded file (never a sweep-held file, never someone's claimed issue); the
   prompt then says "crowded file: diff only inside your theorem and private helpers directly
   above it, rebase on origin/main before handing in". Same in step 8c.
8. Opus work: each Opus that step 7 allows takes the first of these that exists (user,
   2026-11-22: escalation and prior work before any fresh issue).
   a. Escalator: the oldest file with QUEUED `opus` or `refute` rows in `S/escalations.txt` that our
      Sonnet has left and no escalator holds; one file each (`refute` rows: HUNTER.md "Refutations"). Never re-claim an issue `escalate.sh` queued.
   b. Prior work, ours and others': `resumable.sh` lists open unclaimed issues with earlier
      attempts, ours first, by file. Skip rows whose agents.txt agent still runs. Take a file's
      rows together, only when the escalator launches this tick: post `Claiming (Claude Opus 5.5, default effort): continuing an earlier
      attempt` on each, add them to `claims.txt`, and run `escalate.sh <n> "continuing prior
      work: <source> <summary>" --prior`. They are now a.
   c. Last resort, an Opus hunter: any open proof issue that `prior.sh <n>` (or `claims.py <n>`) shows unclaimed (claims are read from comments by `claims.py`, also in the status.sh census and the sieve; the `claimed` label lags: on 2026-11-23 01:40Z three hunters found fresh issues already claimed by comment) (not stuck/gap/ERRATA/
      paper-gap, not sweep-held), preferring triage rows rated 3–4 that no Sonnet holds, never in a
      file another of our agents works in. Record in `hunted.txt`.
8b. Fable: for QUEUED `fable` rows in `escalations.txt`, oldest first, launch Fable consultants up
   to 2 running at once (user, 2026-11-22 ~23:00Z: "Bump the allowed fable consultant concurrency
   to 2"; 2 units each, step 7 item 2), one row each, preferably from different files. Its ROUTE/SPLIT hand-back appears as a new `opus` row (step 8a).
   **The coordinator may escalate to Fable itself** when that is the better use of tokens: an
   Opus agent released an issue it tried and failed without escalating; the same blocker keeps
   stopping several issues (one packet for the shared
   step); or an important issue has had two or more failed attempts upstream. Claim it if it is
   not ours (`Claiming (Claude Fable 5.2, default effort)`, add to `claims.txt`), append a short
   `## Stuck packet` to `notes/<n>.md` from the notes, release comments and the issue (no Lean
   runs: leave "Goal at the stuck point" as `to compute`), then run
   `escalate.sh <n> "<reason>" --to fable`.
9. Findings: add every `Finding:` line from new reports and every SUSPECT triage row to
   `S/findings.txt` as QUEUED. If QUEUED rows exist and no evaluator runs, launch ONE findings
   evaluator (outside the budget); it posts confirmed findings itself, and queues a `refute` row
   (step 8a) for a finding it judges refutable in Lean.
10. Report in one or two lines.
