# Hourly coordinator check

The scheduled run reads this file every time. **Edit it here** (live: `S/HOURLY.md`) to change what
the hourly check does; the cron job never needs re-creating. Keep it short: it is read every hour.
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
consultant to `agents.txt` (the nagger's roster).

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
   last check (last seen: AGENTS ed9dbb7, ERRATA 92c9ed9), re-read the change, update the briefs
   (HUNTER.md first), and update "last seen" here.
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
5. Services: warm, watchdog, memguard, sieve (restart commands in HANDOVER startup step 3). RAM:
   count memguard kills of agent builds (not sieve runs) in `memguard.log` over the last hour. If
   there are more than 3, launch no new agents this tick and say so in the report; tell the user if
   it repeats.
6. READY or HINT lines in `== sieve`: launch ONE siever unless one runs. No blind hunters.
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
   "Files in sequence"). No overlap (`claims.txt`, `hunters.txt`), no file crowded by 2–3 other
   claimants or open PRs.
8. Opus work: each Opus that step 7 allows takes the first of these that exists (user,
   2026-11-22: escalation and prior work before any fresh issue).
   a. Escalator: the oldest file with QUEUED `opus` or `refute` rows in `S/escalations.txt` that our
      Sonnet has left and no escalator holds; one file each (`refute` rows: HUNTER.md "Refutations"). Never re-claim an issue `escalate.sh` queued.
   b. Prior work, ours and others': `resumable.sh` lists open unclaimed issues with earlier
      attempts, ours first, by file. Skip rows whose agents.txt agent still runs. Take a file's
      rows together, only when the escalator launches this tick: post `Claiming (Claude Opus 5.5, default effort): continuing an earlier
      attempt` on each, add them to `claims.txt`, and run `escalate.sh <n> "continuing prior
      work: <source> <summary>" --prior`. They are now a.
   c. Last resort, an Opus hunter: any open proof issue that `prior.sh <n>` shows unclaimed (the `claimed` label lags: on 2026-11-23 01:40Z three hunters found fresh issues already claimed by comment) (not stuck/gap/ERRATA/
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
