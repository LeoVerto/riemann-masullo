# Coordinator handover: low-hanging campaign

Rewritten 2026-11-22 ~15:45Z from the live state in `.agent/`. Earlier layered updates are folded
in; superseded rules are gone (see git history of this file if you need them).

This branch (`coordination/low-hanging-campaign` on the `LeoVerto` fork) is **not for merging**:
`scripts/` and `prompts/` are integrator-owned, and `lean/Sweep*.lean.txt` define tactic macros,
which the library bans. The folders here (`tools/`, `state/`, `critical/`, `sieve/`, `shortlist/`,
`memory/`, `lean/`) are snapshots of the live copies in `/mnt/faststorage/math/riemann-masullo/.agent/`
(persistent, git-ignored): `sweeptools/` (tools, state; below `S`), `wt/` (worktrees), `memory/`
(Claude memory). Edit the live copies, then refresh the snapshot.

**Time zones:** the shell, `status.sh` and service logs use CET (UTC+1); the cron tool uses UTC.

## Current state (2026-11-22 ~17:50Z, coordinator session 09ff2a64 wound down for a restart)

- **Wound down at the user's request** (they are restarting the coordinator with changes). Agents
  were told to save notes and stop; the nagger, the hourly cron and the **watchdog are stopped**
  (so it does not release our claims while nothing runs: restart it in startup step 3, with the
  fixed `PROJ=/home/agent/.claude/projects`). warm, memguard and sieve still run (warm and sieve at
  nice 19). **Claims are kept; do not release them** (user, 17:55Z: "we're continuing soon"; `claims.txt`); upstream auto-releases claims with no PR after 8 h,
  so re-launch or refresh before ~01:00Z on 2026-11-23.
- **Resume these from notes (fresh agents, never resume transcripts):**
  - crit2526 (Opus hunter) #2526, notes/2526.md, wt/crit-2526.
  - esc-sec5 (Opus escalator) Ch05 Sec5: **#4408 #4411 #4420 #4423 #4429 #4431 PROVED**, committed
    f0a3c40 on local branch hunt/esc-sec5-1 (wt/esc-sec5, not pushed, no PR); #4409 checks clean,
    uncommitted edit on top. To hand in one PR for all seven: module build, full `lake build`,
    signature compare, axioms (`.agent/Check.lean` ready); lint passes. Report notes/report-esc-sec5.md.
  - esc-sec4 (Opus escalator) Ch05 Sec4: **#4338 #4352 #4356 PROVED**, two local commits on branch
    hunt/esc-sec4-1 (wt/hunt-esc-sec4-1, from main bd5d15c, clean, not pushed, no PR). Module builds
    in 3m17, lint passes; still to do: full `lake build` (stopped at wind-down, 0 errors so far),
    signature compare, axioms (`.agent/Check.lean` ready). Trap: `have key := …` then
    `with_reducible_and_instances exact key _ ω hP A hA` (plain `exact` unfolds Ẽ(I) for 1.5 h+).
    It released #4344 (see the Fable line).
  - w26 (Sonnet) #5369: proof written, unbuilt; edit in wt/hunt-w26-1 (detached build may have left
    `.agent/build.exit`); next steps in notes/5369.md.
  - #4344 (Ch05 Sec4 separability): Fable returned a partial **ROUTE** (notes/4344.md `## Fable
    route`, skeleton notes/4344-Route.lean): nuclear (proved, Sec2b:311) + metrizable (from sorried
    sibling `_frechet`, Sec4:186) ⇒ separable; per-seminorm helper elaborates; applying the generic
    lemma hit a whnf heartbeat timeout (traps in notes). Re-queued as an `opus` row for an escalator
    (best after esc-sec4's PR, same file).
- **Opus escalation queue** (`escalations.txt`, all claimed by us, notes in notes/<n>.md):
  Ch11 Sec1b #5175 #5177 #5181 #5184 and Ch07 Sec5 #5135 (shared blocker: `adelePrincipalValue`
  algebra — F ∅ = id, composition for T ≤ T', insert factorization; prove as private helpers);
  Ch07 Sec4 #5078 #5079 (range Z = schwartzBergmanDivisible Λ is only a hypothesis) and #5108
  (finest-LC dual bounded sets); Ch10 Sec3 #5207 #5208 #5204; Ch10 Sec4b #5288; Ch07 Sec2 #4535.
  User: Opus tries these before any split.
- **Open PRs:** #5371 (Ch07 Sec4 #5091), #5379 (Ch10 Sec4b #5290 #5316), #5382 (Ch10 Sec3 4
  issues), #5386 (#4908), #5393 (Ch07 Sec5 #5133). Merged this session: #5355 #5356 #5358 #5360
  #5370 (about 18 issues).
- **Triage:** all issues up to #5369 triaged (triage7a–f, triage8); no Sonnet quick wins left.
  #5363–#5368 need Hecke L zero existence (none in the project), rated 4–5.
- **Pending user decisions:** whether idle Sonnet slots may run as extra Opus escalators; whether to
  post w25's unbuilt #5275 route (notes/5275.md) as a hint for troyjlee, who holds #5275.
- Staffing (user): 4 Sonnet hunters, 1 Opus hunter, 2 Opus escalators, 1 Fable consultant.
  Agents and the nagger wait in the foreground, every call under 170 s (HUNTER.md).

## Standing instructions from the user

- **Coordinator only.** No proofs, builds or long log reads in the main session; delegate and
  relay short reports. The `advisor` tool is turned off (user, 2026-11-22); escalation goes
  through `escalate.sh` and the Fable consultant instead.
- **CPU is cheap, tokens are scarce.** Automate (sieve, shortlist, scripts) before reasoning.
  Agents wait on builds in the foreground (never `run_in_background`, user 2026-11-22), never polling turns. Keep wake-ups sparse.
- **Staffing (user, 2026-11-22; HOURLY.md steps 7–8):** one budget of 10 units, Sonnet hunter 1,
  Opus prover 2 (~17:30Z: "when two sonnets are idle, spawn an opus instead. keep at minimum two
  opuses and at maximum six sonnets"). Free units go to Opus until 2 run, then to Sonnets while
  quick-win rows exist (up to 6), the rest in pairs to Opus. Running agents are not stopped to
  rebalance. Opus work order (~17:10Z: "If there's enough escalation work to be done, use them all
  for it, otherwise scale back escalation and use them as hunters"; later: "starting an opus
  hunter on a random issue should be the last option, after escalation and continuing prior work
  have been exhausted"):
  1. **Sonnet hunters** on quick wins: triage rows rated 1–2, then 3 (HUNTER.md).
  2. **Opus work, in this order:**
     a. **Escalation:** a Sonnet that is *stuck* hands the issue over with `escalate.sh`, keeping
        our claim; an escalation prover (HUNTER.md "Escalators") takes the oldest file with QUEUED
        `opus` rows in `escalations.txt` that our Sonnet has left; one file per prover.
     b. **Prior work** ("If we have prior work on an issue, we should strive to build on top of
        it"; others' attempts count too): `resumable.sh` lists open unclaimed issues with earlier
        attempts, ours first, then others' `Releasing` write-ups. The coordinator re-claims a
        file's rows, adds them to `claims.txt` and queues them with `escalate.sh … --prior`
        (restores our archived notes or seeds a stub), so they go to an escalator as in a.
     c. **Last resort, an Opus hunter** on a fresh open unclaimed proof issue (CRITICAL_PROVER.md;
        not `gap`/`refutation`/ERRATA/`TODO(paper-gap)`, not sweep-held), preferring triage rows
        rated 3–4 that no Sonnet holds. No cone remapping.
  3. **Every agent starts from prior work** (HUNTER.md "Prior work first"): `prior.sh <n>` shows
     the current claim, every comment in full, the PRs referencing the issue, and our notes,
     released notes, reports, patches, commits and worktrees for it.
  4. **1 Fable consultant at a time** (user, 2026-11-22 ~16:00Z, Fable allowance; outside the
     step-7 budget): issues an Opus agent tried and failed go `--to fable` with a stuck packet
     (HUNTER.md). The consultant (`FABLE.md`, model fable) reads only the packet, may probe a
     skeleton with `lake lean`, and writes a `## Fable route` (ROUTE / SPLIT / FINDING /
     NO-ROUTE). ROUTE and SPLIT go back to an Opus escalator; the claim stays ours throughout.
     Fable is not used as an advisor: that would send the whole 100–200k-token transcript per call.
     **The coordinator can escalate to Fable directly** when needed (Opus gave up without
     escalating, an UNCLEAR finding, a blocker shared by several issues, repeated failed attempts
     upstream): it writes a short packet from the notes, with no Lean runs, and uses the same
     `escalate.sh --to fable` (HOURLY.md step 8b).
  No two agents share a file. Interpretation of "Opus hunters" (CRITICAL_PROVER.md brief) is the
  coordinator's; confirm with the user if in doubt.
- **Watch our claims** (user, 2026-11-22): `status.sh` prints `NEW #<n>` for others' comments on
  `claims.txt` issues since the last `status.sh --mark` run (the hourly check; `comments.seen`); HOURLY.md step 3 passes each to the
  holding agent, and steps back only if someone else's unreleased claim came before ours.
- **Claim what we work on or have queued.** Escalation keeps the claim (user, 2026-11-22 ~16:00Z:
  no release and re-claim when an issue moves from Sonnet to Opus): `escalate.sh` posts nothing,
  leaves the issue in `claims.txt` and queues it in `escalations.txt`; `status.sh` shows it as
  ESCALATED, not STALE. Upstream auto-releases a claim with no PR after 8 h, so a queued claim
  older than 7 h gets one refresh comment (`REFRESH-CLAIM`). After a usage halt (when the
  watchdog releases everything), re-claim what the resumed agents and the queue hold.
- **Collaborative, not a race.** No pre-proving of sorries without an issue (the sieve may compute
  hits on CPU only). Do not race other contributors or the upstream sweepers. Help on held files
  with hints, not competing PRs. Step back when someone else claimed first.
- **One PR per touched Lean file.** Don't crowd a file that 2–3 others hold.
- **Models and tags:** hunters, sievers and fixers run on Sonnet, effort medium, until 4 PRs or
  about 3 h. Opus runs with no effort override. Triage and the nagger run on Haiku. Tag `<M>` =
  `Claude Sonnet 5.5, effort medium` / `Claude Opus 5.5, default effort`. Claims start
  `Claiming (<M>)`; PR bodies carry `Prover: <M>` above the 🤖 line.
- **Read the thread before claiming** (earlier approaches). Release only via `release.sh`, which
  posts the agent's `notes/<n>.md` (failed approaches first).
- **Token:** only for `mccorvie/riemann-masullo` (`origin`) and `LeoVerto/riemann-masullo`
  (`fork`). It must be a CLASSIC token (repo, workflow, read:org); check with `tokencheck.sh`.
- **Upstream posting:** ask the user before posting anything new. Standing exceptions: normal
  Claiming/Releasing; sieve hints on open `sweep` issues; extensions of #1288, #561 and #3230;
  **paper findings that an Opus evaluator has confirmed** (user, 2026-11-22 ~16:00Z: "Paper
  findings should be evaluated by Opus and then raised"; `FINDINGS.md`, queue `findings.txt`).
  **Never raise BLOCKERS §0** (Main.lean integration is wave 4+, by the project's choice).
- **Read AGENTS.md, CONTRIBUTING.md and ERRATA.md from origin/main** (`git show origin/main:<file>`)
  at each session start and when they change; keep the briefs compliant. Checked 2026-11-22 ~16:00Z:
  HUNTER.md follows AGENTS (Lean rules, false statements and gaps), CONTRIBUTING "Working
  efficiently" (private helpers in the issue's file only, no `maxHeartbeats`, no routine rebase,
  keep the file fast) and ERRATA (`TODO(paper-gap)` marks). Paper findings are reported on the
  issue as CONTRIBUTING asks, after an Opus evaluator has checked them.
- **State lives in `.agent/`**, never only under `/home/agent`.
- **Notes nagger out of session:** one long-running Haiku loop (`NAGGER.md`), never cron ticks in
  the coordinator session. The coordinator only keeps `agents.txt` in sync and relaunches it.

## Environment (sandbox `riemann-masullo-faststorage`)

- Repo `/mnt/faststorage/math/riemann-masullo` (writable, ~65 GB free; its parent is not writable).
  The overlay root (~16 GB) does not survive a sandbox recreation.
- 16 GB RAM, 24 cores. **RAM is the limit.** The old ceiling was one prover, one hunter or siever,
  and the sieve; staffing of up to 8 agents (6 Sonnets + 2 Opus) is untested at that RAM. Agents build only their module
  while working, the sieve waits for >6 GB free, and memguard kills the newest Lean below 1000 MB
  (cheap, rc 137). The hourly check watches `memguard.log` (HOURLY.md step 5). An OOM of the host
  is not cheap.
- elan in `~/.elan`; `/etc/sandbox-persistent.sh` sets its PATH and `LAKE_ARTIFACT_CACHE=true`,
  `LAKE_CACHE_DIR=<repo>/.lake/artifact-cache`, `LAKE_RESTORE_ARTIFACTS=true` (tested: restores
  leave real local `.olean`s; concurrent builds are fine).
- poppler-utils (for `scripts/paper.sh`) comes from apt.
- Claude memory: `~/.claude/projects/-mnt-faststorage-math-riemann-masullo/memory` is a symlink to
  `<repo>/.agent/memory`.

## Startup checklist

1. **After a recreation** (`/home/agent` wiped): re-link the memory dir and the
   `/home/agent/{sweeptools,wt}` compatibility symlinks; reinstall elan (toolchain from
   `lean-toolchain`) and poppler-utils; check `/etc/sandbox-persistent.sh`. Then `git worktree prune`.
2. **Token:** `S/tokencheck.sh` must print `TOKEN OK`. On `TOKEN FAIL` ask the user to run
   `sbx secret set github --sandbox riemann-masullo-faststorage -t <classic token>`.
3. **Services:** start any missing one with
   `cd S && setsid nohup ./<name>.sh >> <name>.log 2>&1 < /dev/null &` for watchdog and memguard, and the same with `nice -n 19` before `./<name>.sh` for warm and sieve (user, 2026-11-22 17:25Z: agents hit timeouts under CPU load; the services must yield; sieve details in `SIEVE.md`). Check that `warm.log` says "ready" at a recent main. The
   watchdog's auto-resume uses a hard-coded old `SESSION`: leave `no-resume` in place unless you
   restart it with `SESSION=<your id>`.
4. **One hourly check:** `CronList` first (duplicates have happened), then create it with the
   one-line prompt under "Hourly check".
5. **Relaunch:** the nagger (if any agent runs), the quick-win loop on the new issues, and
   Opus work per HOURLY.md steps 7–8. Never resume long dead transcripts with SendMessage
   (an uncached replay is expensive): start fresh agents from `notes/` and `notes/released/`.

## Hourly check

The checklist lives in **`S/HOURLY.md`** (snapshot `tools/HOURLY.md`), and the scheduled run reads
it on every tick. Change the hourly behaviour by editing that file, never the cron. Create the
cron (hourly, e.g. minute 17, after `CronList`) with only this prompt:
`Read /mnt/faststorage/math/riemann-masullo/.agent/sweeptools/HOURLY.md and follow it.`

## Workstreams and launch prompts

- **Quick-win loop** (main source of work):
  1. `shortlist.py <files>` scores every sorry without Lean (statement size, name patterns,
     docstring hints, red flags, the paper's proof length) into `shortlist/latest.tsv`.
  2. Haiku triage: `Read S/TRIAGE.md and follow it. N = 60.` (model haiku) rates rows 1–5, or `-`
     for ERRATA/gap items, and flags SUSPECT statements (leads for the findings evaluator).
  3. Sonnet hunters on exactly the rows rated 1–2, then 3. Prefer files low in the import order and
     nearly finished (CONTRIBUTING).
  Rated-3 rows in Ch05 Sec4/Sec5 hit slow-compile traps (w10, w12, w13) and ended in escalations.
- **Hunter:** `Read S/HUNTER.md and follow it exactly. Your name is w<k>, your branch prefix <P> is
  hunt/w<k>, your model tag <M> is Claude Sonnet 5.5, effort medium. Your issues: …` (Sonnet, effort
  medium). Opus escalation provers get the same brief with the Opus tag, the issue's notes and its
  release comments.
- **Opus prover:** `Read S/critical/CRITICAL_PROVER.md and follow it. Your issue is #<n>. Your model
  tag <M> is Claude Opus 5.5, default effort.` Worktree `wt/crit-<n>`, branch `crit/<n>`, result
  line in `critical/status.txt`. A prover that finishes with a warm cache may get ONE related issue
  by SendMessage, then retire it.
- **Sieve and siever:** the sieve service (`SIEVE.md`) tries cheap, `exact?`, `grind` and
  unfold-defs passes on every new or changed file, one Lean process at a time, and writes
  `sieve/hits.tsv`. `status.sh` classifies hits READY / HINT / CLAIMED / WAIT / DONE. A siever
  (`Read S/SIEVER.md and follow it. Your model tag <M> is …; your hits: <lines>`) hands in READY
  hits and posts HINT hits on the sweep issue. Its yield so far is low (e.g. #4035).
- **Findings evaluator:** agents report paper findings on a `Finding:` line; SUSPECT triage rows
  are leads. Both go to `S/findings.txt`, and one Opus evaluator at a time (`Read S/FINDINGS.md
  and follow it. Your findings: <rows>.`, outside the step-7 budget) re-checks each against
  the page image and the Lean, then posts confirmed ones on the issue (HOURLY.md step 9).
- **Nagger:** see `NAGGER.md`; stop it with `touch S/nagger.stop`.
- `scripts/agent.sh` does not work here: it assumes the integrator's layout and pushes to `origin`.

## Infrastructure (`S`; copies in `tools/`)

| Piece | What it does |
|---|---|
| `warm.sh` + `wt/base` | Keeps a worktree built at origin/main; publishes `base/{COMMIT,sig.txt}`; rebuilds failed index modules one at a time. |
| `newwt.sh <branch> <dir>` | New worktree at the warm commit with a copied build and baseline signatures in `<dir>-before.txt`. |
| `build.sh <wt>` | `lake build`, exit status in `<wt>/.agent/build.exit`. |
| `status.sh` | RAM, disk, token, cache, PR verdicts, claims, orphan and stale claims, new comments on our claims (`NEW #n`), warm base, label census, `== sieve`. |
| `cleanup.sh` | Removes worktrees whose PR merged. |
| `tokencheck.sh` | Classic token with the right scopes? Step 0 of every brief. |
| `escalate.sh <n> "<reason>"` | Hands a stuck issue to the next tier (`--to opus` default, `--to fable` with a stuck packet) without releasing it: no comment, stays in `claims.txt`, row in `escalations.txt`, note appended; `--prior` (coordinator) restores archived notes or seeds a stub for a re-claimed issue. |
| `prior.sh <n> [--local]` | All earlier work on an issue: current claim, full comments, referencing PRs; our notes, released notes, reports, patches, queue lines, commits, worktrees. |
| `resumable.sh [max]` | Open unclaimed issues with earlier attempts (ours first, then others'), by file, with any agents.txt holder: HOURLY.md step 8b. ~1.5 min. |
| `release.sh <n> "<reason>"` | Posts `Releasing (<M>): reason` plus `notes/<n>.md`, updates `claims.txt`, archives to `notes/released/`. |
| `watchdog.sh` | When every transcript has been idle for 20 min, releases all claims via `release.sh`; auto-resume after 2 h is disabled by `no-resume`. |
| `memguard.sh` | Below 1000 MB available (`LOW`), kills the newest sieve Lean process, otherwise the newest Lean process. |
| `shortlist.py`, `TRIAGE.md` | Quick-win scorer and Haiku triage brief. |
| `sieve.sh`, `sieve.py`, `sieve_status.py`, `sweep.py` | The sieve. |
| `nag-wait.sh`, `notes-stale.sh`, `NAGGER.md` | Notes nagger. |
| `HUNTER.md`, `SIEVER.md`, `critical/CRITICAL_PROVER.md` | Agent briefs; HUNTER.md holds the rules shared by all three. |
| `HOURLY.md` | The hourly check's instructions, read by the cron on every tick. |
| `FABLE.md` | Fable consultant brief: route from a stuck packet, no builds or PRs. |
| `FINDINGS.md`, `findings.txt` | Opus findings-evaluator brief and its queue. |

State files in `S` (snapshot in `state/`): `agents.txt` (nagger roster), `claims.txt`, `hunters.txt`
(agent log), `hunted.txt` (launch log), `leads.txt` (leads), `escalations.txt` (escalation queue, claims kept), `findings.txt`
(findings queue), `dispatched.txt`
(sieve hits handed out), `pending_handins.txt`, `notes/` (per-issue notes, `report-*.md`,
`released/`, `reports-done/`).

## Lessons

- **Usage halts kill everything at once.** The watchdog then releases every claim, and the agents do
  not come back by themselves. Agents that update `notes/` after every step lose little.
- **After a sandbox kill** the services die, the cron may survive, and agents restart from their
  transcripts. After a recreation everything outside the repo is gone (startup step 1).
- **Upstream sweepers** (label `sweep`, codex agents) claim whole files within minutes and hold most
  of the hard tails. Never edit a held file. Census counts lie about difficulty, and blind hunters
  on "unclaimed=N" returned 0 PRs: send agents only on concrete leads.
- **The `claimed` label lags; claim comments do not.** Read the whole thread; a plain `Claiming`
  counts.
- **Use `lake lean`, never `lake env lean`:** only the former applies the lakefile options. The
  "elaboration timeouts" reported on Ch02/Ch04/AppD before 2026-11-22 05:00Z were mostly this
  artifact, so re-test such verdicts.
- Real slow-compile traps are listed in HUNTER.md: `Classical.choose`/`existsUnique` unfolding, and
  default-transparency unification on quotient and pullback goals.
- Re-check a PR's state right before editing it or commenting on it (a merged PR was edited once).
- `gh` caches responses, including 401s: `rm -rf ~/.cache/gh` (`tokencheck.sh` does it).
- The "PR check" Verdict is the merge gate. Cancelled "Lean Action CI" runs are expected; do not
  re-run them. Issues of merged PRs stay open until the merger runs `issues.py --apply`; they are
  not orphans.
- **A nagger SendMessage to an agent that is waiting on background work resumes it, and it then
  reports to the nagger, not the coordinator** (esc-sec5, 2026-11-22 ~17:50Z). Hence the user's
  rule: all agents and the nagger wait in the FOREGROUND (HUNTER.md "Builds and processes"); a
  coordinator message to an idle agent routes it back to the coordinator.
- **The watchdog must see every project dir** (`PROJ=/home/agent/.claude/projects`): a coordinator
  running from a worktree has its own transcript dir, and on 2026-11-22 17:02Z the watchdog, watching
  only the old dir, released all 25 live claims (re-claimed; #5275 lost to another contributor).
- Never `pgrep`/`pkill -f` a pattern from your own command line; kill only PIDs you started.

## Upstream reports (integrator decides)

- **#3230:** issue-sync damage (fragment batch #3183–#3322, 124 issues wrongly closed, 6 sorries
  without issue). Details in `critical/BLOCKERS.md`.
- **#1288:** consolidated instance-timeout report (much of it turned out to be the `lake env lean`
  artifact).
- **#561:** `ApproxProp` false statements, repaired by #3330.
