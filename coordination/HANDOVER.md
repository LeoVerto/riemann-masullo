# Coordinator handover: critical path, sieve and hunters

State as of 2026-11-22 04:35Z. **Time zones:** the shell, `status.sh` and the service logs use CET (UTC+1); the cron tool uses UTC. Earlier notes from this day give times about one hour too late when they say "Z". This
branch (`coordination/low-hanging-campaign` on the `LeoVerto` fork) is **not meant to be merged**:
`scripts/` and `prompts/` are integrator-owned, and `lean/Sweep*.lean.txt` define tactic macros,
which the project bans from the library. It records the strategy, tools and state needed to take
over the coordinator role.

**Live copies are in `/mnt/faststorage/math/riemann-masullo/.agent/`**, which is persistent and
ignored by git: `sweeptools/` (tools and state), `wt/` (worktrees) and `memory/` (Claude memory).
The folders here (`tools/`, `state/`, `critical/`, `sieve/`, `memory/`, `lean/`) are snapshots of
them. `/home/agent/{sweeptools,wt}` are compatibility symlinks, and they are lost when the sandbox
is recreated.

## LOW-HANGING MODE (user instruction, 2026-11-22 04:40Z)

**Amended ~06:05Z by the user: "Only resume opus when you're out of low-hanging fruits."** Resume Opus
(one critical prover at a time) WITHOUT asking once no unclaimed rows rated 1–3 remain in any
triage file and there are no new issues to triage; go back to Sonnet hunters when new quick wins
appear. This supersedes "ask the user before resuming Opus" anywhere below.

- **Run several Sonnet agents on quick wins and start NO Opus agents** until the problem space
  changes again (no quick wins left, or a new chapter needs mapping). Ask the user before
  returning to Opus. The #3484 Opus prover that was already running may finish.
- **Every check looks for new proof issues first.** Run the quick-win loop (shortlist, Haiku
  triage, Sonnet hunters), aiming for 2–3 Sonnet hunters at once while leads last, with no issue
  overlap between them (`claims.txt`). Use rated-3 rows once the rows rated 1–2 run out.
- Sonnet agents run on usage credits (user-approved). The usage pause ended at the 05:40Z reset;
  a one-shot cron at 05:45Z (session-only) re-creates the hourly check below. If the session
  died, do that by hand.

## Standing instructions from the user

- **Read the current project docs from origin/main** (user, 2026-11-22): AGENTS.md, CONTRIBUTING.md
  and ERRATA.md (`git show origin/main:<file>`). The main checkout's working tree lags behind
  upstream. Their gap handling binds our agents: AGENTS "False statements and gaps", CONTRIBUTING
  "When the paper is wrong", summarized at the end of HUNTER.md. Re-read them at each session
  start and when upstream changes them (`git log origin/main -- AGENTS.md CONTRIBUTING.md
  ERRATA.md`), and keep the briefs in line.

- **Coordinator only:** no proofs, builds or long log reads in the main session. Delegate them and
  relay short reports.
- **CPU time is cheap; tokens are the bottleneck.** Prefer automation, such as the sieve and
  `exact?` runs, over agent reasoning. Agents wait on builds with one blocking wait, not polling.
- **Models:**
  - Hunters, sievers and fixers run on Sonnet at effort medium, until 4 PRs or about 3 h.
  - Critical-path provers run on Opus with no effort override, one issue each, but are
    **suspended in low-hanging mode** (see above).
  - The `advisor` tool is for subagents to escalate to; the coordinator does not call it.
- **Attribution:** claims read `Claiming (<M>)`. PR bodies carry `Prover: <M>` above the 🤖 line.
  <M> is e.g. `Claude Sonnet 5.5, effort medium` or `Claude Opus 5.5, default effort`.
- **Read the issue thread before claiming,** for earlier approaches. Release only through
  `release.sh`, which posts the agent's `notes/<n>.md` with failed approaches first.
- **Token:** use it only for `mccorvie/riemann-masullo` (remote `origin`) and
  `LeoVerto/riemann-masullo` (remote `fork`). It must be a CLASSIC token with `repo`, `workflow`
  and `read:org`. A fine-grained PAT gets 403 on upstream comments and PRs, and its pushes to the
  fork are rejected. Check with `sweeptools/tokencheck.sh`.
- **Upstream posting:** ask the user before posting anything new upstream. Approved standing
  exceptions:
  - sieve hints on open upstream `sweep` issues;
  - extensions of #1288 (instance timeouts), #561 (`ApproxProp`) and #3230 (issue-sync damage).
- **Do NOT raise BLOCKERS §0** (no library link to `Main.lean`). Main.lean integration is wave 4
  or later, by decision of the project's human coordinator; focus on the earlier parts.
- **State lives in `.agent/`,** never only under `/home/agent`.
- **Collaborative, not a race.** Many closed issues are welcome, but:
  - no pre-proving of sorries that have no issue yet;
  - no racing other contributors or the upstream sweepers for claims;
  - help on held files through hints, not competing PRs;
  - step back when someone else claimed first.
- **Use `lake lean <file>`, never `lake env lean`.** AGENTS.md changed on 2026-11-22: only
  `lake lean` applies lakefile.toml's leanOptions (`maxSynthPendingDepth = 3`,
  `autoImplicit = false`, `linter.unusedSectionVars = false`; that linter took 20 min on one AppD
  proof). All our earlier sweeps (res1–res4) and the hunters' fail-fast probes used
  `lake env lean`. The #2663 prover confirmed that the Ch04 "elaboration timeouts" were this
  artifact (about 30 s under `lake lean`), so re-test any "blocked by #1288 timeouts" verdict.
  Also never print raw `Expr`s: `repr` has used 70 GB here.

## Environment (sandbox `riemann-masullo-faststorage`, recreated 2026-11-22)

- Repo: `/mnt/faststorage/math/riemann-masullo`. It is writable and has about 65 GB free; its
  parent is NOT writable. The overlay root has about 16 GB free.
- RAM is 15 GB with 24 cores. **RAM is the real limit:** the sandbox was OOM-killed once with a
  prover build, a hunter build and a sweep running together.
- elan is in `~/.elan`, with its PATH line in `/etc/sandbox-persistent.sh`. That file also exports
  `LAKE_ARTIFACT_CACHE=true`, `LAKE_CACHE_DIR=<repo>/.lake/artifact-cache` and
  `LAKE_RESTORE_ARTIFACTS=true`.
  - The cache is ON and tested: restored modules leave real local `.olean`s, two concurrent
    builds are fine, and Mathlib stays up to date.
  - Restore is a copy, not a hardlink.
- poppler-utils is installed through apt; the overlay root does not survive a recreation.
- Claude memory: `~/.claude/projects/-mnt-faststorage-math-riemann-masullo/memory` is a SYMLINK
  to `<repo>/.agent/memory`. Re-create the symlink first after a recreation.

## Startup checklist for a fresh coordinator session

1. **Memory symlink and tools.**
   - If `/home/agent` was wiped: re-link the memory dir, re-create the `/home/agent/{sweeptools,wt}`
     symlinks, and reinstall elan (toolchain from `lean-toolchain`) and poppler-utils.
   - Check `/etc/sandbox-persistent.sh`: PATH plus the three cache exports.
   - `git worktree prune`. If a worktree's path is gone, re-create it with `newwt.sh`.
2. **Token:** run `sweeptools/tokencheck.sh`. It needs `TOKEN OK`. On `TOKEN FAIL` ask the user:
   `sbx secret set github --sandbox riemann-masullo-faststorage -t <classic token>`.
3. **Services** (`ps -eo pid,args | grep -E '^ *[0-9]+ bash ./(warm|watchdog|memguard|sieve).sh'`).
   Restart any that are missing with `cd <S> && setsid nohup ./<name>.sh >> <name>.log 2>&1 < /dev/null &`.
   For the sieve see `SIEVE.md`. Check that `warm.log` says "ready" at a recent main.
   - The watchdog's auto-resume uses a hard-coded old `SESSION`. Leave `no-resume` in place unless
     you restart it with `SESSION=<your id>`.
4. **One hourly check.** Run `CronList` first, because duplicates happen. Then create it at minute
   17 with the prompt in "Hourly check" below.
5. **Relaunch work:**
   - Critical-path prover: one Opus agent ("Critical path" below), but **not in low-hanging
     mode**.
   - 2–3 Sonnet hunters on triaged quick wins (quick-win loop under "State at handoff").
   - A siever when the sieve shows READY or HINT lines.
   - Hunters only on concrete leads.

## State at handoff

### Update 2026-11-22 ~06:00Z (user asleep from here; work autonomously, post nothing new upstream)
- Crons (session-only; recreate on restart, CronList first): hourly check **9dc215ca** at :17
  (text below); notes nagger **5d728683** every 15 min (:04/:19/:34/:49), see workstream 5.
- Docs on origin/main unchanged since 02f36f8/15e78ca. HUNTER.md gained "One file at a time"
  (**ONE PR PER TOUCHED FILE**, user instruction; don't crowd a file with 2–3 other claimants) and
  "PR titles" (user-edited: name the declarations/file; "easy"/"trivial" are fine; no ratings,
  branch names, or internal jargon like "average"/"batch"). TRIAGE.md rates ERRATA/`Gap:`/
  `TODO(paper-gap)` declarations `-` (skip).
- New issues Ch05 Sec4 (#4333–#4369) and Sec5 (#4382–#4432) triaged: `shortlist/triage4a.tsv`,
  `triage4b.tsv`. Last shortlisted issue: #4432.
- Hunters running (roster with agent IDs in `state/agents.txt`): **w6** (Ch05 Sec3a + Sec2b, told
  to split into one PR per file), **w8** (Ch05 Sec4, 8 issues), **w9** (Ch05 Sec5, 16 issues).
- w5 finished: PR #4434 (Ch05 Sec3b, 6 issues), PR #4466 (Ch06 Sec2, #4309 #4312); released #4304
  (`choose_spec` unfolding blew the build up to >25 min); handoff in `notes/handoff-hunt-w5.md`.
  w7 finished: PR #4440 (Ch06 Sec1, 8 issues).
- Unassigned: Ch06 Sec2 #4313 (Haar translation) #4314. Held for the user (not posted):
  #4255 `sLocalArchimedeanPoleMultiplicity_eq_sum` possibly unprovable (needs simple poles;
  `notes/4255.md`); SUSPECT Sec5 `globalThetaTranspose_range`, `globalHomogeneousThetaTranspose_range`
  (`Set.range` vs closure of span; local analogue has closure on both sides).

**Update 05:30Z:** finished: w3 (PRs #4323 #4329 #4371 #4374, 8 issues), w4 (PR #4377, 6
issues), the Opus #3484 prover (SPLIT, PR #4375; stopped after hand-in). Running: Sonnet hunters
w5 (triage3b: Ch05 Sec3b, Ch06 Sec2), w6 (triage3a: Ch05 Sec2b/3a), w7 (rated-3 Ch06 Sec1 + #4075).
Triage files: `shortlist/triage.tsv`, `triage2.tsv`, `triage3a.tsv`, `triage3b.tsv`; every row
with an issue in the seven new files is triaged. One-shot cron e984e9ca (05:45Z) re-reads the docs,
re-creates the hourly check and continues in low-hanging mode.

**Running at 04:35Z:**
- **Opus prover on #3484** (`schwartzBruhat_fourier_equiv`, AppD Sec1c, 11 dependents). It started
  from sweep #3792's failure report. Worktree `.agent/wt/crit-3484`.
- **Sonnet hunter `hunt/w3`** on the 12 issues the Haiku triage rated 1–2 in the new sections:
  #4042 #4043 #4066 #4068 #4076 (Ch07 Sec1b), #4144 #4166 #4179 #4187 (Ch05 Sec3a), #4195
  #4213 (Ch05 Sec3b), #4080 (Ch05 Sec2b), plus #4035 (Ch07 Sec1a, closed by the sieve's unfold
  pass with `simp [defs]`).
  - First PR: #4323 (four sanity lemmas, Ch07 Sec1b).
  - Its claims are in `claims.txt`. Its report includes how accurate the triage was.
- **Sonnet hunter `hunt/w4`** (started 04:42Z) on the rated-3 rows: #4050 #4051 (Ch07 Sec1b),
  #4185 #4189 (Ch05 Sec3a), #4214 #4215 (Ch05 Sec3b). After those it takes the rows rated 1–2 in
  Ch06 Sec1 from `shortlist/triage2.tsv`.
- **Haiku triage** (started 04:42Z) of the 42 untriaged rows with issues
  (`shortlist/untriaged.tsv`: Ch06 Sec1 18, Ch07 Sec1a 2, Sec1b 22), written to
  `shortlist/triage2.tsv`. Its rated 1–2 rows **outside Ch06 Sec1** are free for the next
  Sonnet hunter.
- **The sieve v2:**
  - Its queue ranks files with open issues first (Ch07 Sec1a, Sec1b, Ch05 Sec2b, Sec3a, Sec3b),
    then the slow Ch06 Sec1, which takes >60 min per run and gets at most 2 chunks per cycle.
  - Passes: cheap, exact, grind, unfold.
  - Retries rc 124/137, then splits. A completed pass shows rc 1.

**New issues dropped ~04:05Z:** 176 proof issues #4034–#4213 (Ch07 Sec1a 8, Sec1b 38, Ch05 Sec2b 52,
Sec3a 59, Sec3b 18), plus #4033 (AppD Sec1c). Ch06 Sec1 issues (#4264–#4279) appeared by 04:40Z;
Ch06 Sec2 has none yet (no pre-proving). `shortlist.py` was re-run on
these files (223 rows, 182 with an issue), and Haiku rated the top 49 (`shortlist/triage.tsv`).
Rows rated 3 are the next candidates for Sonnet hunters if the w3 ratings prove accurate.

**Quick-win loop for each new batch of issues:**
1. Run `shortlist.py <files>`.
2. Haiku triage: `Read <S>/TRIAGE.md and follow it. N = 60.` with `model: haiku`.
3. Run a Sonnet hunter on exactly the rows rated 1–2 (list them in its prompt).

**Open PRs:** #4323 (hunt/w3).

**Merged today:**
- #4021: proves #2663 (Ch04 Sec5); the integrator accepted the false signature diff caused by #2693.
- #3823: fully proves #1219.
- #3978: proves #1902.
- #3993: fully proves #1885.

**Not handed in:** #2517 is proved on local branch `hunt/ch03n-1` (1f3ce84). jcosmos0 had claimed it
first. Keep the branch in case they release it (see `state/pending_handins.txt`).

**Upstream sweepers** (label `sweep`, `prompts/sweeper.md`, codex agents at xhigh effort) each
claim a whole file's remaining sorries, and they claim fast.
- At handoff they held ~18 files: all of Ch03 Sec2/Sec3/Sec3b, Ch04 Sec5 (#3999), Ch05 Sec1/Sec2,
  Ch09 Sec2/Sec3, much of AppD and Ch02, and others.
- Only **8 free critical-path sorries** remain outside held files. All are hard leftovers the
  sweepers did not close: #3484, #783, #1698, #1700, #1724, #3492, #1155, #1014.
- An overlap audit found zero issue-level duplication with our PRs. Rules in the briefs:
  - claim publicly first;
  - re-check the open sweep list before pushing;
  - never edit held files;
  - if a file becomes held mid-work, move new helpers out of it.

**Blind hunters no longer pay.**
- ch03 hunter: 0 PRs. appB hunter: 0 PRs, since all 46 unclaimed appB issues are deep.
- Launch Sonnet agents only on concrete leads: sieve hits, or shortlist rows that Haiku rated 1–2.

**Wave 3:** the user expected it to be seeded within hours of ~04:00Z. Ch06 Sec 6.1/6.2 and Ch07
Sec1a/1b are stated but had no proof issues yet. The sieve pre-computes hits on CPU only;
hand-ins happen at a normal pace once the issues exist.

### Update 2026-11-22 ~07:20Z: quick wins exhausted, ONE Opus prover running
- w6 PR #4439 (Ch05 Sec3a: #4133 #4142 #4173; released #4121 #4122, quotient-map elaboration
  timeout); w9 PR #4472 (Ch05 Sec5: #4383 #4384; 7 Sec5 issues held by factory-davidgu);
  w11 found Ch06 Sec3 quick wins (#4445 #4452 #4453) claimed by CalebAlbers (PR #4474).
- Running: w8 (Ch05 Sec4), w10 (Ch05 Sec5 rated-3 + Ch06 Sec2 #4313/#4314), **crit/1526 (Opus)**.
- Old critical queue fully closed upstream. Sonnet remap wrote a new `critical/QUEUE.md` (12 entries;
  old kept as `QUEUE-2026-11-21.md`): #1526, #2526, #2667, #4070(+#4072), #3895, ... Cone 91 sorries,
  21 eligible. Pipeline caveats: mapper scripts hardcode `wt/crit-map` (path edits not saved),
  `anchors.py` still treats Ch5.2–8 as undigested (cone is a lower bound), `emit.py` doesn't apply
  claim/ERRATA/paper-gap exclusions. Fix before the next remap (Sonnet job).
- Next Opus item after #1526: next QUEUE entry, one at a time; back to Sonnets when new issues bring quick wins.

### Update 2026-11-22 ~07:30Z (user): nagger out of session; Opus on any open issue
- **Nagger** is now ONE long-running Haiku (`tools/NAGGER.md`) looping in a single turn on
  `tools/nag-wait.sh` (blocks ≤10 min per call, 15-min per-hunter cooldown, logs to `nag.log`),
  SendMessaging stale hunters. The 15-min nagger cron is DELETED — never nag via cron ticks in the
  coordinator session (user: keep it entirely out of this session). Coordinator only keeps
  `agents.txt` in sync and relaunches the nagger if it ends; stop it with `touch sweeptools/nagger.stop`.
- **Opus**: "The cone doesn't matter at this point ... Just pick any open issue for Opus." Any open,
  unclaimed proof issue (not gap/refutation/ERRATA/paper-gap, not sweep-held); no remapping. The
  mapper-fix job is dropped.
- Crons now: only the hourly check **eb59d910** at :17.
- **Escalation (user, ~08:30Z): "If sonnet gets stuck on the proofs, hand them off to opus."** Issues a
  Sonnet released as stuck go to an Opus escalation prover (HUNTER.md brief, one file each, after our
  Sonnet leaves the file); max 2 Opus at once (assumption). Running: **esc-sec2b** (Opus, Ch05 Sec2b
  #4121 #4122). Queue in `state/leads.txt` "ESCALATION QUEUE": #4338 (Sec4, after w12), #4408 (Sec5,
  after w13). #4304 is now troyjlee's. w10 finished with no PR (Sec5 proofs too slow);
  **w13** (Sonnet) is timing and handing in its saved proofs (`patches/w10-*.lean`).
- **Report files (07:50Z):** an agent woken by a nagger message reports to the nagger, not the
  coordinator (happened to crit/1526). So every hunter/siever/prover also writes its final report to
  `notes/report-<name>.md` (HUNTER.md, CRITICAL_PROVER.md, SIEVER.md end sections); the hourly check
  reads those and moves them to `notes/reports-done/`. w8 finished: PR #4488 (Ch05 Sec4 #4336 #4347
  #4353); w12 (Sonnet) now on Sec4 #4344 #4352 #4356. HUNTER.md has a "Slow-compile trap" section.
- Running at 07:35Z (user asleep): Sonnet hunters **w8** (Ch05 Sec4) and **w10** (Ch05 Sec5 rated-3,
  then Ch06 Sec2 #4313/#4314); Opus **crit/1526**; long-running Haiku nagger; services warm/watchdog/
  memguard/sieve. Open LeoVerto PRs awaiting Verdict/merge: #4377 #4434 #4439 #4440 #4466 #4472 (and
  earlier ones in status.sh). Held for the user, not posted: #4255; Sec5 SUSPECT `*_range` pair.
  On restart: CronList, recreate the hourly check from the section below, relaunch the nagger if
  not running (`pgrep -f nag-wait.sh`), and continue; never resume long transcripts (notes/ instead).

## Workstreams

### 1. Critical path (`critical/`)

- **Prover launch prompt:** `Read <S>/critical/CRITICAL_PROVER.md and follow it. Your issue is
  #<n>. Your model tag <M> is Claude Opus 5.5, default effort.` Add fail-fast notes as needed.
- **Brief:** worktree `.agent/wt/crit-<n>`, branch `crit/<n>`. The prover proves the issue or
  splits it faithfully (prompts/prover.md), and appends to `critical/status.txt`.
- **One prover at a time.** If it finishes with a warm cache, you may hand it ONE more related
  issue by SendMessage. That saves re-reading; it worked for #1885 after #1902. Then retire it
  (it was at about 180k tokens by then).
- **Picking the next issue:**
  - `critical/graph.tsv` (cone with dependents) minus the files held by open sweep issues
    (`gh issue list --label sweep --state open`), minus claimed issues, and only declarations still
    `sorry` on origin/main.
  - Ranking at handoff: only 8 free cone sorries remain outside held files (listed above); #3484
    is the top one. As sweepers finish files, their leftovers become free again: re-run the
    ranking (graph.tsv filtered by `gh issue list --label sweep --state open` and claimed
    labels).
  - `QUEUE.md` is older (built at 0ef6aa7) and its top items are now held by sweepers. Regenerate
    the cone with the scripts in `critical/mapper/` if new sections add anchors.
- `scripts/agent.sh` is unusable here: it is built for the integrator's layout and pushes to
  `origin`.

### 2. Sieve (`tools/SIEVE.md`, `tools/SIEVER.md`)

The **sieve** is our automated tactic screen. It is named so as not to be confused with upstream's
`sweeper`.
- `sieve.sh` and `sieve.py` form a service with its own worktree `.agent/wt/sieve`.
- On every warm-base advance it queues files with `sorry` that are new or changed, newest first,
  with `sieve/priority.txt` first.
- It runs the cheap macro pass, then `exact?`, with long timeouts. A file that times out is split
  using `sweep.py --only` into chunks and then single sorries.
- **One sieve Lean process at a time, globally.** It waits for more than 6 GB free and runs at
  `nice 10`.
- Passes: cheap, `exact?`, `grind`, unfold-defs (the last two were being added at handoff).
  It runs `lake lean <file> -- --json`. A killed or timed-out run (rc 137/124) is retried, then
  split.
- Hits go to `sieve/hits.tsv`. `status.sh`'s `== sieve` section (from `sieve_status.py`) labels
  each hit:
  - `READY #issue`: unclaimed and the file is not held;
  - `HINT #sweep-issue`: the file is held by an upstream sweeper;
  - `CLAIMED`;
  - `WAIT`: no issue yet;
  - `DONE`: no longer `sorry` on main.
  The READY, HINT, CLAIMED and WAIT classes are **not yet tested on real issues**; verify them on
  the first real hits.
- **Siever:** a Sonnet medium agent launched on READY and HINT lines. Prompt: `Read <S>/SIEVER.md
  and follow it. Your model tag <M> is ...; your hits: <lines>`. It hands in READY hits in batches
  per file, and posts HINT hits as one batched comment per sweep issue (user-approved).
- History:
  - res1, res2 and res3 are the old one-off sweeps; their 4 res3 hits were all already proved.
  - The one-off `sweep4` agent was retired: it was too slow and its stuck Lean process blocked the
    sieve.

### 3. Quick-win finder: shortlist and Haiku triage (`tools/TRIAGE.md`)

- `shortlist.py [files]` (default: files changed in the last 48 h) writes `shortlist/latest.tsv`
  without running Lean. It scores each sorry by statement size and binders, name patterns
  (`_apply`, `_zero`, `_mem`, `_iff`, …), docstring hints, red-flag notions (∫, `Tendsto`,
  `Meromorphic`, `∃!`, …) and the PAPER's proof length ("Proof. Clear/Immediate" is a strong
  signal).
- Haiku triage (`TRIAGE.md`, `model: haiku`) rates the top N 1–5 from docstring and statement
  only, flags SUSPECT statements, and writes `shortlist/triage.tsv`.
- Sonnet agents take rows rated 1–2 that have unclaimed issues in files nobody holds.

### 4. Hunters (`tools/HUNTER.md`)

- Hunters now run only on concrete leads.
- Launch prompt: `Read <S>/HUNTER.md and follow it exactly. Your label <L> is X, your branch prefix
  <P> is hunt/X<n>, your model tag <M> is Claude Sonnet 5.5, effort medium.` Add leads and
  exclusions.
- HUNTER.md's end sections are binding: token check, upstream sweepers, token thrift, sweeper overlap,
  helper placement, and claims/notes/attribution.

### 5. Notes nagger (`tools/NAGGER.md`, `tools/notes-stale.sh`, user request 2026-11-22)
Every 15 min the cron runs `notes-stale.sh 20`; if a hunter in `agents.txt` has no note
(`notes/<issue>.md` or `notes/handoff-<name>.md`) newer than 20 min, it launches one short Haiku
that SendMessages the stale hunters (sibling SendMessage by agentId works) and logs to `nag.log`.
Purpose: notes stay current in case of a usage-limit hit. **Keep `agents.txt` in sync**: add every
new hunter (`name agentId start_epoch issues...`), remove finished ones.

## Hourly check (cron prompt)

`Hourly riemann-masullo coordinator check (coordinator only; CPU cheap, tokens scarce).
S=<repo>/.agent/sweeptools.`
0. `git fetch origin`; if AGENTS.md, CONTRIBUTING.md or ERRATA.md changed on origin/main since the
   last check, re-read the change and update the briefs (HUNTER.md end section).
1. `status.sh` and `cleanup.sh`, under timeout, with the output tailed.
2. Fix failing Verdicts or review comments with short Sonnet fixers; re-check the PR's state first.
3. Release orphan or stale claims only via `release.sh`.
4. Relay finished agents in one line each; TaskStop them after checking no Lean process remains
   in their worktree; record in hunters.txt and remove their line from `agents.txt`.
5. Services: warm, watchdog, memguard and sieve.
6. If READY or HINT lines appear, launch ONE siever unless one is running. No blind hunters.
7. **New issues first (low-hanging mode).** Check for proof issues newer than the last
   shortlist. If there are any, run `shortlist.py` and a Haiku triage of the untriaged rows.
   Keep 2–3 Sonnet hunters running on rows rated 1–2 (then 3) with unclaimed issues, one file per hunter, ONE PR PER TOUCHED FILE, each listed explicitly in its prompt, no overlap;
   add each new hunter to `agents.txt`.
8. **Opus only when the quick wins are out** (no unclaimed rated 1–3 rows, no new issues): then,
   without asking, ONE Opus critical prover at a time (cone sorries outside held files, recorded
   in `hunted.txt`, added to `agents.txt`). Back to Sonnets when new quick wins appear.
9. Report in one or two lines.

## Infrastructure (`<repo>/.agent/sweeptools`; copies in `tools/`)

| Piece | What it does |
|---|---|
| `warm.sh` + `.agent/wt/base` | Keeps a worktree built at origin/main and publishes `base/{COMMIT,sig.txt}`. Falls back to building failed index modules one at a time. |
| `newwt.sh <branch> <dir>` | New worktree at the warm commit, with a copied `.lake/build` and baseline signatures in `<dir>-before.txt`. |
| `build.sh <wt>` | `lake build` with its exit status in `<wt>/.agent/build.exit`. |
| `status.sh` | RAM, disk, **token check**, cache size, PR verdicts, claims, orphan and stale claims, warm base, label census, `== sieve`. |
| `cleanup.sh` | Removes worktrees whose PR merged. Run it on every check. |
| `tokencheck.sh` | Classic token with repo, workflow and read:org? Step 0 of every brief. |
| `release.sh <n> "<reason>"` | `Releasing (<M>): reason` plus `notes/<n>.md` (failed approaches first). Updates claims.txt and archives to `notes/released/`. Used by agents, the watchdog and the coordinator. |
| `watchdog.sh` | When all transcripts are idle for 20 min, releases claims via release.sh. Auto-resumes after 2 h unless `no-resume` exists (it does). |
| `memguard.sh` | Below 3 GB available, kills the newest Lean process whose cwd is under `.agent/wt/sieve*`, otherwise the newest Lean process of any kind. |
| `shortlist.py`, `TRIAGE.md` | Quick-win scorer and Haiku triage brief (see workstream 3). |
| `sieve.sh`, `sieve.py`, `sieve_status.py`, `sweep.py` | The sieve (see above). `sweep.py` has `--only L1,L2` and kills the whole process group on timeout. |
| `HUNTER.md`, `SIEVER.md`, `critical/CRITICAL_PROVER.md` | Agent briefs. |

## Lessons (read before changing anything)

- **RAM, not CPU, limits parallelism.** One prover, one siever (or hunter) and the sieve is the
  ceiling. memguard kills are expected and cheap; an OOM-killed sandbox is not (every agent then
  replays its transcript).
- **After a sandbox kill:** the services die, the cron may survive, and agents restart from their
  transcripts on their own. Check `ps`, `CronList` and `claims.txt`.
- **After a sandbox recreation:** everything outside the repo is gone. See startup step 1.
- **The `claimed` label lags; claim comments do not.** Read the whole thread. A plain
  `Claiming` by another contributor counts.
- **jcosmos0 and elmismisimoxhunca** are active upstream provers on ch03. Upstream sweepers move
  fast: whole chapters were claimed within minutes.
- **Census counts lie about difficulty.** Unclaimed does not mean short.
- **Helper placement** (prover.md, merger.md, proof_review.sh):
  - Same file by default.
  - ForMathlib only for lemmas with no paper objects that Mathlib ought to have.
  - Reuse across chapters by making the lemma public in the earliest file and importing it.
    Imports are routine; only the import order limits this.
  - Don't copy helpers.
- Bound every build with `timeout`. Never `pgrep`/`pkill -f` a pattern from your own command line.
  Kill only PIDs you started.
- After a pause, don't resume long subagents with SendMessage; start fresh ones from STATE.md and
  notes. Continuing a just-finished agent while its cache is warm is fine.
- Re-check a PR's state right before editing it or commenting on it.
- **`gh` caches responses, including 401s:** `rm -rf ~/.cache/gh`. `tokencheck.sh` does that.
- **The "PR check" Verdict is the merge gate.** Cancelled "Lean Action CI" runs are expected; do
  not re-run them.
- Issues of merged PRs stay open until the merger's `scripts/issues.py --apply`; they are not
  orphans.

## Upstream reports (integrator decides)

- **#3230:** issue-sync damage. The malformed batch #3183–#3322 has fragment titles; 124 issues
  were wrongly closed; 6 sorries have no issue.
- **#1288:** consolidated instance-timeout report.
- **#561:** `ApproxProp` false statements, repaired by #3330.

## Results so far

- About 55 PRs from LeoVerto merged, closing roughly 200 proof issues.
- Critical path: #3660 (#1223), #3681 (#1906), #3823 (#1219), #3978 (#1902), #3993 (#1885), and
  #4021 (#2663).
