# Coordinator handover: low-hanging campaign

Compacted 2026-11-22 ~18:00Z. Superseded rules are gone (git history has them). Each rule lives in
one place: procedures in `S/HOURLY.md` and the briefs, the user's standing instructions here, and
Claude memory only points at them.

This branch (`coordination/low-hanging-campaign` on the `LeoVerto` fork) is **not for merging**:
`scripts/` and `prompts/` are integrator-owned, and `lean/Sweep*.lean.txt` define tactic macros,
which the library bans. The folders here (`tools/`, `state/`, `critical/`, `sieve/`, `shortlist/`,
`memory/`, `lean/`) are snapshots of the live copies in `/mnt/faststorage/math/riemann-masullo/.agent/`
(persistent, git-ignored): `sweeptools/` (tools, state; below `S`), `wt/` (worktrees), `memory/`
(Claude memory). Edit the live copies, then refresh the snapshot.

**Time zones:** the shell, `status.sh` and service logs use CET (UTC+1); the cron tool uses UTC.

## Current state (2026-11-22 ~20:40Z, coordinator session a9c138b2, running)

- **Restarted after a sandbox reboot** (~18:05Z): services restarted (watchdog with all-projects
  `PROJ`, memguard, warm and sieve at nice 19); the token needed `sbx secret set` again after the
  reboot. Hourly cron at minute 17 (session-only). Nagger running.
- **Budget 10 units (user, 23:10Z; was 12), 12 in use until two agents finish:** Opus escalators esc-ch11sec1b (Ch11 Sec1b #5175
  #5177 #5181 #5184), esc-ch07sec4 (#5078 #5079 #5108), esc-ch10sec3 (#5207 #5208 #5204),
  esc-ch07sec3a (#4603, ours, prior work), esc-ch05sec3a2 (Ch05 Sec3a #4135 #4136 #4140 #4141
  #4174 #4175 #4181 #4184: elmismisimoxhunca's attempts built but their auditor gave no verdict);
  Sonnets w27 (follow-up #5478, Ch11 Sec2b), w29 (Ch11 Sec3 rated-3: #5494 first, #5495 #5497
  #5492 #5502 #5512).
- **Reserved:** #5135 (Ch07 Sec5) waits for esc-ch11sec1b's adelePrincipalValue helpers (one
  follow-up by SendMessage), so two Opus do not build the same helpers.
- **PRs opened this session:** #5433 #5441 #5447 #5450 merged; open #5454 (#5288; Verdict
  `error` because main cec1c13 did not build: push an empty commit once main builds, leads.txt),
  #5538 (#4344, Fable route), #5542 (#4144), #5547 (#4535), #5551 (Ch11 Sec3, 5 issues), #5553
  (Ch11 Sec2b, 7 issues).
- **Released:** #5514 (Haar-null singleton needs >100 lines; route on the issue).
- **Triage:** done up to #5525 (triage10). Ch05 Sec3a still has ~30 more issues with failed
  automated attempts by elmismisimoxhunca, most failing only on inherited sorryAx: good Opus work.
- **Posted with user approval:** the #5275 route hint for troyjlee.
- **New traps in HUNTER.md:** abbrev towers (AGENTS.md ed9dbb7), destructuring a sibling inside
  an abbrev space (#4344), unascribed `_mk`/`_apply` lemmas (#4535). Foreground limit is now
  110 s (the harness backgrounds calls after 120 s).

## Standing instructions from the user

Where a rule is carried out, the procedure is named; the quotes and dates are there too.

- **Ask, but don't wait** (2026-11-22: "the main session can always ask me, I just might not be
  around"): put decisions that are the user's, such as conflicting instructions, to the user, and
  meanwhile carry on with the newer instruction or the safer choice (HOURLY.md header).
- **Coordinator only.** No proofs, builds or long log reads in the main session; delegate and
  relay short reports. No `advisor` tool (off since 2026-11-22: it sends the whole transcript);
  escalation goes through `escalate.sh` and the Fable consultant.
- **CPU is cheap, tokens are scarce.** Automate (sieve, shortlist, scripts) before reasoning; keep
  wake-ups sparse. Agents and the nagger wait in the FOREGROUND, every call under 170 s (HUNTER.md
  "Builds and processes"); never `run_in_background`.
- **Staffing and Opus work** (2026-11-22): 10-unit budget (user, 23:10Z, CPU pegged; was 12 from 20:20Z), at least 2 Opus, at most 6 Sonnets;
  Opus goes to escalation, then prior work (ours and others'), a fresh issue last; Fable
  consultants cost 2 units each, at most 2 at once (user, ~23:00Z), and come right after the 2-Opus minimum, before any new work (user,
  2026-11-22 ~22:30Z); the findings evaluator stays outside the budget. HOURLY.md steps 7–9. No two agents
  share a file. A prover that finishes with a warm cache may get ONE related issue by SendMessage.
- **Build on prior work** (2026-11-22): every agent starts from `prior.sh <n>` (HUNTER.md "Prior
  work first"); `resumable.sh` feeds HOURLY.md step 8b.
- **Claims** (user, 2026-11-22 ~22:00Z: "we definitely should not be re-posting to beat the
  auto-release on issues we are not actively working on"): claim when an agent starts; an
  escalation keeps the claim only as a hand-over, at most 2 h in the queue, then `release.sh`
  posts the notes (HOURLY.md step 3, `status.sh` `QUEUED … RELEASE`); re-post a claim only while an
  agent is still working on it; release only via `release.sh`; skip `stuck` issues; watch others'
  comments on our claims. After a halt (the watchdog releases everything), re-claim only what the
  resumed agents work on.
- **Parallel probes are fine** (user, 2026-11-22: upstream's one-check-at-a-time rule is for
  hardware-bound provers; we are token-bound). `probe.sh start` builds the shared imports once
  under the worktree lock, so they cannot race.
- **Slow types (#5398):** agents get the trap and upstream's fixes (HUNTER.md "Elaboration
  traps"); `trap5398.py` flags at-risk issues in `prior.sh` and the hunters' lists.
- **Refutations** (user, 2026-11-22, reversing "leave refutation to upstream"): the Fable findings
  evaluator decides whether a confirmed false statement is refutable in Lean ("I trust it to make
  the call"), posts the finding first, writes a `## Refutation sketch` and queues a `refute` row; an
  Opus escalator hands in `Printed.<name>` + `_false` in `<section>_Printed.lean` with `Refs #n`
  (FINDINGS.md, HUNTER.md "Refutations", HOURLY 8a). `refutation`-labelled proof issues are
  ordinary work for our agents (prove the `_false` sorry, `Closes #n`).
- **Collaborative, not a race.** No pre-proving of sorries without an issue (the sieve may compute
  hits on CPU only). Do not race other contributors or upstream sweepers; help on held files with
  hints. Step back when someone else claimed first.
- **One PR per touched Lean file**; don't crowd a file that 2–3 others hold (HUNTER.md).
- **Models and tags:** fixed by the agent definitions (`.agent/agents/`); tags `<M>` per HOURLY.md.
  Claims start `Claiming (<M>)` (upstream parses only the first word); PR bodies carry `Prover: <M>` above the 🤖 line. Sonnet agents
  run until their list is done, 4 PRs or about 3 h.
- **Token:** only for `mccorvie/riemann-masullo` (`origin`) and `LeoVerto/riemann-masullo`
  (`fork`). It must be a CLASSIC token (repo, workflow, read:org); check with `tokencheck.sh`.
- **Upstream posting:** ask the user before posting anything new. Standing exceptions: normal
  Claiming/Releasing; sieve hints on open `sweep` issues; extensions of #1288, #561 and #3230;
  paper findings that the Fable evaluator confirmed (`FINDINGS.md`). **Never raise BLOCKERS §0**
  (Main.lean integration is wave 4+, by the project's choice).
- **Read AGENTS.md, CONTRIBUTING.md and ERRATA.md from origin/main** (`git show origin/main:<file>`)
  at session start and when they change (HOURLY.md step 0); HUNTER.md carries their rules (gaps,
  false statements, private helpers in the issue's file, no `maxHeartbeats`).
- **State lives in `.agent/`**, never only under `/home/agent`.
- **Notes nagger out of session:** one long-running Haiku loop (`NAGGER.md`), no cron ticks in the
  coordinator session; the coordinator keeps `agents.txt` in sync and relaunches it.

## Environment (sandbox `riemann-masullo-faststorage`)

- Repo `/mnt/faststorage/math/riemann-masullo` (writable, ~65 GB free; its parent is not writable).
  The overlay root (~16 GB) does not survive a sandbox recreation.
- 20 GB RAM (raised from 16 GB on 2026-11-22), 24 cores. **RAM is the limit.** The old ceiling was one prover, one hunter or siever,
  and the sieve; staffing of up to 8 agents (6 Sonnets + 2 Opus) is untested at 20 GB. Agents build only their module
  while working, the sieve waits for >6 GB free, and memguard kills the newest Lean below 1000 MB
  (cheap, rc 137). The hourly check watches `memguard.log` (HOURLY.md step 5). An OOM of the host
  is not cheap.
- elan in `~/.elan`; `/etc/sandbox-persistent.sh` sets its PATH and `LAKE_ARTIFACT_CACHE=true`,
  `LAKE_CACHE_DIR=<repo>/.lake/artifact-cache`, `LAKE_RESTORE_ARTIFACTS=true` (tested: restores
  leave real local `.olean`s; concurrent builds are fine). Never drop RESTORE: without it no local
  `.olean` is written and `signatures.sh` breaks. Set these only through the env, never the
  lakefile; the user approved writes only to that `.lake` subdirectory.
- A full `lake build` can fail on the chapter index modules with "Too many open files" (the host
  mount's handles, not the ulimit): build them one at a time and re-run; `warm.sh` does this.
- Transcripts: `~/.claude/projects/-mnt-faststorage-math-riemann-masullo` (plus one dir per
  worktree a coordinator runs from; the watchdog's `PROJ` covers them all).
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
4. **Subagent types:** the Agent tool must list `hunter`, `escalator`, `opus-hunter`, `siever`,
   `triage`, `fable-consultant`, `findings-evaluator`, `nagger`. They load from `.claude/agents`
   (symlink to `../.agent/agents`, in `.git/info/exclude`) only if it existed when the session
   started; a new definition file loads mid-session, an edited one only after a restart, so keep
   role logic in the briefs.
5. **One hourly check:** `CronList` first (duplicates have happened), then create it with the
   one-line prompt under "Hourly check".
6. **Relaunch** per HOURLY.md (nagger if any agent runs, then steps 7–8). Never resume long dead
   transcripts with SendMessage (an uncached replay is expensive): start fresh agents from
   `notes/` and `notes/released/`.

## Hourly check

The checklist lives in **`S/HOURLY.md`** (snapshot `tools/HOURLY.md`), and the scheduled run reads
it on every tick. Change the hourly behaviour by editing that file, never the cron. Create the
cron (hourly, e.g. minute 17, after `CronList`) with only this prompt:
`Read /mnt/faststorage/math/riemann-masullo/.agent/sweeptools/HOURLY.md and follow it.`

## Workstreams

Launch prompts: HOURLY.md "Launching agents".
- **Quick-win loop:** `shortlist.py <files>` scores every sorry without Lean into
  `shortlist/latest.tsv`; a triage agent rates rows 1–5 (`-` for ERRATA/gap items) and flags
  SUSPECT statements; hunters take rows rated 1–2, then 3, preferring files low in the import order
  and nearly finished (CONTRIBUTING). Rated-3 rows in Ch05 Sec4/Sec5 hit slow-compile traps and
  ended in escalations. Caveats: `paper: no proof` only means no proof before the next item, and
  `paper:SHORT` over-fires on "This follows…".
- **Opus work and Fable:** HOURLY.md steps 8–8b; Opus-hunter results in `critical/status.txt`.
- **Sieve:** the service (`SIEVE.md`) tries cheap, `exact?`, `grind` and unfold-defs passes on every
  new or changed file, one Lean process at a time, into `sieve/hits.tsv`; `status.sh` classifies
  hits READY / HINT / CLAIMED / WAIT / DONE, and a siever hands in READY and posts HINT hits on
  the sweep issue. Low yield so far (e.g. #4035). If it pays off, propose it upstream as an
  integrator tool in an issue, not a PR (user, 2026-11-21; `scripts/` is integrator-owned).
- **Findings:** `Finding:` lines and SUSPECT rows go to `findings.txt`; the evaluator re-checks
  each against the page image and the Lean and posts confirmed ones (HOURLY.md step 9).
- **Nagger:** `NAGGER.md`; stop it with `touch S/nagger.stop`.
- `scripts/agent.sh` does not work here: it assumes the integrator's layout and pushes to `origin`.

## Infrastructure (`S`; copies in `tools/`)

| Piece | What it does |
|---|---|
| `warm.sh` + `wt/base` | Keeps a worktree built at origin/main; publishes `base/{COMMIT,sig.txt}`; rebuilds failed index modules one at a time. |
| `newwt.sh <branch> <dir>` | New worktree at the warm commit with a copied build and baseline signatures in `<dir>-before.txt`. |
| `build.sh <wt>` | `lake build`, exit status in `<wt>/.agent/build.exit`; a per-worktree lock refuses a second concurrent build (exit 75). |
| `probe.sh start/wait/build/waitbuild` | The only way agents start detached probes and builds (an `rm` with a variable path, `setsid` or a process-starting loop in a Bash call triggers permission pop-ups even in bypass mode); usage in HUNTER.md "Builds and processes". |
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
| `.agent/agents/*.md` (snapshot `agents/`) | Subagent type definitions: model, effort, tools, and which brief to read. |
| `HOURLY.md` | The hourly check's instructions, read by the cron on every tick. |
| `FABLE.md` | Fable consultant brief: route from a stuck packet, no builds or PRs. |
| `trap5398.py <n>…` / `--decl <path>::<name>` | Flags #5398 slow-type risk without Lean (statement or section variables use one of the 22 synonyms, directly or via defs/abbrevs/notations); called by `prior.sh`. |
| `FINDINGS.md`, `findings.txt` | Fable findings-evaluator brief (Opus until 2026-11-22 ~21:40Z, user) and its queue. |

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
- **The `claimed` label lags and can stick; claim comments do not.** `prior.sh` prints the claim
  state from the comments; a plain `Claiming` counts.
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
