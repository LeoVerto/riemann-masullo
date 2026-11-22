# Coordinator handover: low-hanging fruit and critical path

State as of 2026-11-22 ~00:45Z. This branch (`coordination/low-hanging-campaign` on the `LeoVerto`
fork) is **not meant to be merged**. `scripts/` and `prompts/` are integrator-owned, and
`lean/Sweep*.lean.txt` define tactic macros, which the project bans from the library. The branch
records the strategy, the tools and the state needed to take over the coordinator role. The live
copies are in `/home/agent/sweeptools/`; `tools/`, `state/` and `critical/` here are snapshots.

## Role and standing instructions (from the user)

- **You are the coordinator, and only that:** do no proof work, builds or long log reads yourself, so the main context stays small. Route work to subagents in their own
  worktrees and keep the main context lean.
- **Models:**
  - Hunters and fixers run on Sonnet, effort medium (`model: "sonnet"`, `effort: "medium"`). Hunters
    keep going until they have opened 4 PRs (or about 3 h).
  - Critical-path provers run on Opus with no effort override, one issue each.
- **Advisor:** the `advisor` tool (Opus) is for subagents to escalate to. The coordinator does not
  call it. Both briefs tell agents to use it when stuck.
- **Token:** use it only for `mccorvie/riemann-masullo` (remote `origin`) and
  `LeoVerto/riemann-masullo` (remote `fork`).
- **Upstream posting:** ask the user before posting anything new upstream. Extending a report
  already filed is fine: #1288 (instance timeouts), #561 (`ApproxProp`), #3230 (issue-sync damage).
- **Open question to the user:** whether to raise BLOCKERS §0 with the integrator: nothing in the
  library connects to `Main.lean`, and there is no `riemannZeta` or Dirichlet bridge.

## State at handoff (2026-11-22 ~00:45Z)

- **Nothing is running.** No subagents, no crons: the old session's scheduled run was cancelled. `/home/agent/sweeptools/no-resume` exists, so the watchdog does not resume anything. The background services `warm.sh`, `watchdog.sh` and `memguard.sh` are still running.
- **Last results:**
  - PR #3823 fully proves #1219 (standard axioms only; PR check pending at handoff; one lemma raises `maxHeartbeats` to 4000000, so expect a `read` verdict).
  - PR #3660 (#1223) and PR #3681 (#1906) merged.
  - `claims.txt` is empty.
- **The Lake artifact cache is DISABLED.** When Lake reuses a module from the cache it writes no local `.olean`, which breaks `scripts/signatures.sh` and `lake env lean` (found by the #1219 prover, which worked around it by copying cached files back by the hashes in each `.trace`).
  - The exports are removed from `/etc/sandbox-persistent.sh`, which now `unset`s them, and commented out in `warm.sh` and `build.sh`.
  - The running `warm.sh` still has the variables in its environment.
  - The cache dir `/home/user/git/riemann-masullo/.lake/artifact-cache` is kept.
- **New sections were being digested** on 2026-11-21 ~23:50Z (user's note), so new low-hanging fruit may exist. Issue numbers such as #3484/#3792 suggest a new duplicate batch: choose the well-formed open issue per declaration.

## Startup checklist for the next (fresh) coordinator session

**The user's instructions for this start:**
- The main session acts ONLY as a coordinator, to keep its context small: no proofs, no builds, no long log reads. Delegate those to subagents and relay short reports.
- Before starting ANY other subagent, use one subagent to figure out caching.

1. **Caching first.** Launch one Sonnet medium subagent; wait for its report before launching anything else. Its task:
   - In two tmp worktrees (`newwt.sh tmp/... /home/agent/wt/tmp-...`), test `LAKE_ARTIFACT_CACHE=true`, `LAKE_CACHE_DIR=/home/user/git/riemann-masullo/.lake/artifact-cache` and `LAKE_RESTORE_ARTIFACTS=true`.
   - Show that a module reused from the cache leaves a real local `.olean`, that `scripts/signatures.sh` and `lake env lean` work, that two concurrent builds are safe, and that `lake build --no-build Mathlib` stays up to date.
   - Measure the disk cost: is restore a hardlink or a copy? Small modules only, under `timeout`; remove the tmp worktrees afterwards.
   - If it all works, roll out `export LAKE_ARTIFACT_CACHE=true LAKE_CACHE_DIR=... LAKE_RESTORE_ARTIFACTS=true`: replace the `unset` line at the end of `/etc/sandbox-persistent.sh` (python rewrite, since `sed -i` cannot create its temp file in /etc), and uncomment and extend the lines in `warm.sh` and `build.sh`. Restart `warm.sh` when idle (its child is `sleep`).
   - If it does not work, leave the cache off. In either case, restart `warm.sh` when idle so its environment matches.
   - Background: the user approved writing only to that `.lake/artifact-cache` subdirectory of the main checkout. The cache's real size is shown by `status.sh`; plain `du` over-counts hardlinks.
2. **Services.**
   - Check that `warm.sh`, `watchdog.sh` and `memguard.sh` run (`ps -eo args | grep -E '^bash ./(warm|watchdog|memguard).sh'`), and that `warm.log` says "ready" at a recent main.
   - The watchdog resumes a HARDCODED old session (`SESSION` default in `watchdog.sh`). To use auto-resume, restart it with `SESSION=<your session id>`, then `rm no-resume`. Otherwise leave `no-resume` in place.
3. **One hourly check.** Run `CronList` first: a surviving duplicate once ran every check twice. Then create the check at minute 17. Prompt: run status.sh and cleanup.sh; fix failing Verdicts or review comments with short Sonnet subagents; release orphan or stale claims; relay finished agents' results; check the services; keep at most 1 Opus critical prover and 2 Sonnet medium hunters; record launches in hunted.txt; report in one or two lines.
4. **PR #3823:** check its Verdict and the merger's comments, and use a short Sonnet fixer if needed.
5. **New sections:** in `status.sh`'s label census, look for new labels (ch06–ch14, appE) or jumps in newest issue numbers. Launch up to 2 Sonnet medium hunters on the freshest labels, newest issues first (HUNTER.md, 4 PRs or ~3 h), skipping the malformed batch #3183–#3322.
6. **Critical path:** ONE Opus prover on the first of the four sorries at the top of `critical/QUEUE.md`:
   - `schwartzBruhat_fourier_equiv`
   - `lcaCosetIntegral_mem_schwartzBruhat`
   - `schwartzBruhat_poisson`
   - `exists_ratAdeleDualEquiv`

   They are what #1223's continuation theorem still depends on; then #1902. Prompt: `Read /home/agent/sweeptools/critical/CRITICAL_PROVER.md and follow it. Your issue is #<n>.` If the newly digested sections add anchors, consider a short Opus mapper refresh first (scripts in `critical/mapper/`).
7. **Still open with the user:** whether to raise BLOCKERS §0 with the integrator (nothing in the library connects to `Main.lean`).

## Results so far

- **About 50 PRs from LeoVerto merged**, closing roughly 200 proof issues. Today's include #3335
  #3344 #3346 #3356 #3365 #3367 #3384 #3395 #3607 #3650.
- **Critical path:**
  - #3660 proves #1223 (Tate's theorem for the global idelic zeta integral) apart from #1219 and
    older upstream sorries, by porting the Tate split from AppB Sec1.
  - #3823 fully proves #1219 (lattice-count bound plus a Weil-formula reduction; adds `adelicTheta_normSum_decay_large` and `adelicTheta_normSum_le_small` in Ch02 Sec2a, the majorant #1220 and #1222 need).
  - #3681 fully proves #1906 and adds `ForMathlib/MeasureTheory/Measure/{Count,Haar/Units}.lean`.
- **Low-hanging fruit is mostly gone.** `state/leads.txt` lists what is left per label, and why.
  - ch02, ch04 and ch09: blocked by `SchwartzBruhat` / `ModulatedExponentialDecay` elaboration
    timeouts (#1288 class).
  - appA–appD, ch03 and ch05: mined out.
  - `critical/CONE_SHORT.md` is exhausted apart from #1769 and #1236.

## Upstream problems reported (integrator decides)

- **#3230, issue-sync damage** (two comments):
  - The batch #3183–#3322 has fragment titles (`e`, `act`, ...).
  - The same run *closed* 124 live proof issues as completed at 15:23–15:27Z (e.g. #862, #848,
    #1288).
  - Six live sorries have no issue at all, including `exists_archimedeanHeckeTest` and
    `exists_globalHeckeTest`, which #1223's chain needs.
  - No reply yet. When a merged-batch issue is proved, the merger asks for `Closes #<original>`:
    find the original by title.
- **#1288:** the consolidated instance-timeout report. Note that #1288 itself was closed by the
  sync run.
- **#561:** the `ApproxProp` statements were false as stated. #3330 repaired them upstream.

## Workstreams

### 1. Hunters (`tools/HUNTER.md`)

- Each hunter gets one label, or a list file such as `critical/CONE_SHORT.md`, and claims batches
  of 2–8 short issues in one file.
- It runs the full checks and opens one PR per batch. It stops after 4 PRs or ~3 h.
- The brief includes:
  - a fail-fast probe for the #1288 elaboration blocker: elaborate the bare statement under
    `timeout 120` first;
  - the advisor hint;
  - "never pipe `lake build` into `head`";
  - the heartbeat rule: proofs that raise `maxHeartbeats` are held for a human read.
- Launch prompt: `Read /home/agent/sweeptools/HUNTER.md and follow it exactly. Your label <L> is
  `X` and your branch prefix <P> is `hunt/X<n>`.` Add overrides, leads and exclusions. Always tell
  hunters to read an issue's latest comments before claiming: one wrongly claimed issues someone
  else held.

### 2. Critical path (`critical/`)

- **Mapper findings:**
  - `Main.lean`'s own cone is **empty**: it imports only `Statements` (pure Mathlib), and all 7
    targets are bare `sorry`.
  - The mapper used an *anchored* cone instead: the `completedHeckeL` bridge plus the items that
    Ch.5.2–13 cite, 416 sorry nodes in all. That gives `QUEUE.md` (ranked tasks with approaches),
    `BLOCKERS.md`, `CONE_SHORT.md` and `graph.tsv`.
  - Regenerate the cone with the scripts in `critical/mapper/` (live in
    `/home/agent/wt/crit-map/.agent/`; the graph dump uses upstream `scripts/progress/Deps.lean`).
    It takes about a minute on a built tree. Claim and closed-issue annotations are separate,
    hand-run steps.
- **Provers:** one Opus agent per issue, started one after another. Prompt: `Read
  /home/agent/sweeptools/critical/CRITICAL_PROVER.md and follow it. Your issue is #<n>.`
  - Worktree `/home/agent/wt/crit-<n>`, branch `crit/<n>`.
  - The prover either proves the issue or splits it (prompts/prover.md), and appends to
    `critical/status.txt`.
  - `scripts/agent.sh` is unusable here: it puts worktrees under `/home/user/git`, which is not
    writable, and pushes to `origin`, which here is upstream.
- **Queue after #1219:** #1902, then #1891 and #1890. `state/leads.txt` has notes on #1912 (not a
  Weil application; uniqueness needs a section into the S-ideles) and a possible quick win at
  Ch04 Sec5:605 using `Count.lean`.

## Infrastructure (`/home/agent/`; copies in `tools/`)

| Piece | What it does |
|---|---|
| `wt/base` + `warm.sh` | keeps a worktree built at `origin/main` and publishes `sweeptools/base/{COMMIT,build,sig.txt}`. **Falls back to building failed index modules one at a time** (added after it silently failed for 4 h) |
| `newwt.sh <branch> <dir>` | new worktree at the warm commit with a copied `.lake/build` and baseline signatures in `<dir>-before.txt` |
| `build.sh <wt>` | `lake build` with its exit status in `<wt>/.agent/build.exit` |
| `status.sh` | RAM, disk, real Lake-cache size, PR verdicts, claims, orphans, stale claims, warm base, sweep hits, label census |
| `cleanup.sh` | removes worktrees whose PR merged (run it on every check; disk is tight, ~7 GB free) |
| `watchdog.sh` | releases idle claims after 20 min; auto-resumes after 2 h idle unless `no-resume` exists |
| `memguard.sh` | kills the newest sweep Lean process when RAM < 1.5 GB |
| **Lake artifact cache** | **DISABLED** (see "State at handoff"). When on: `LAKE_ARTIFACT_CACHE=true`, `LAKE_CACHE_DIR=/home/user/git/riemann-masullo/.lake/artifact-cache` (same filesystem as `.lake/packages`, so Mathlib artifacts are hardlinked; ~45 MB real use). Cache reuse without `LAKE_RESTORE_ARTIFACTS=true` leaves no local `.olean` and breaks the hand-in checks. Startup step 1 tests the fix |

## Lessons (read before changing anything)

- **The sandbox can crash.** Afterwards:
  - Background services are dead: restart them with `cd /home/agent/sweeptools && setsid nohup
    ./<name>.sh >> <name>.log 2>&1 < /dev/null &`.
  - Session-only crons are gone, but a pre-crash cron can also *survive*: run `CronList`.
  - Some subagents restart automatically, others do not; check `ListAgents` and the worktrees'
    `.agent/STATE.md`.
- **Watch `warm.log`.** If the base stops advancing, every agent recompiles hours of upstream
  changes after rebasing.
- **"Too many open files" / "failed to open file":** the ~20 chapter index modules each import
  all of Mathlib. Build them one at a time with `lake build <Module>`, then re-run.
- **AppD Sec2b takes about 30 minutes** in a full build. That is upstream, not the agent.
- **Agents often go silent while "waiting on a build".** Twice an agent died there without
  pushing. Check its worktree (local commits vs `fork/<branch>`) and hand the rest to a fresh
  agent with exact steps.
- **Bound every build with `timeout`.** Never `pgrep`/`pkill` on lake or lean patterns, and never
  `pkill -f` a pattern from your own command line. Kill only PIDs you started.
- **Never resume long-lived subagents with SendMessage after a pause.** Start fresh agents from
  their `STATE.md` instead.
- **Re-check a PR's state right before editing it or commenting on it.** A comment once went onto
  an already merged PR and had to be deleted.
- **`gh` caches GraphQL responses for 24 h** (`~/.cache/gh`): an instant 401 is a cached one.
- **Issues of merged PRs stay open** until the merger's `scripts/issues.py --apply`: they are not
  orphans.
- **The "PR check" Verdict is the merge gate.** Cancelled "Lean Action CI" runs are expected: do
  not re-run them.
