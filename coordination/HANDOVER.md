# Coordinator handover: low-hanging fruit and critical path

State as of 2026-11-21 ~23:55Z. This branch (`coordination/low-hanging-campaign` on the `LeoVerto`
fork) is **not meant to be merged**. `scripts/` and `prompts/` are integrator-owned, and
`lean/Sweep*.lean.txt` define tactic macros, which the project bans from the library. The branch
records the strategy, the tools and the state needed to take over the coordinator role. The live
copies are in `/home/agent/sweeptools/`; `tools/`, `state/` and `critical/` here are snapshots.

## Role and standing instructions (from the user)

- **You are the coordinator:** do no proof work yourself. Route work to subagents in their own
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

## State right now

- **Paused for usage (93%; reset 2026-11-22 12:40Z).** The user authorized usage credits so that
  **only** the Opus prover on **#1219** (`globalIdelicZetaIntegral_integrable`, worktree
  `/home/agent/wt/crit-1219`, branch `crit/1219`) can finish. It was in its last checks (module
  rebuilds, axioms, signatures) before opening a PR. Its plan and progress are in that worktree's
  `.agent/STATE.md`.
- **Nothing else runs.** No hourly cron (deleted). `/home/agent/sweeptools/no-resume` exists, so
  the watchdog does not auto-resume.
- **A one-shot cron** was scheduled in the old session for 12:41Z, but it is session-only. If you
  are a new session, do its steps yourself after the reset:
  1. `rm /home/agent/sweeptools/no-resume`; check that `warm.sh`, `watchdog.sh` and `memguard.sh`
     are running.
  2. Create ONE hourly check (run `CronList` first: a duplicate cron once ran every check twice).
  3. #1219: if there is no PR, hand it to a fresh agent from its `STATE.md`. If there is a PR,
     check its Verdict and comments.
  4. **New sections were being digested** on 2026-11-21 ~23:50Z. Look for new labels or newest
     issue numbers in `status.sh`'s census, and launch up to 2 Sonnet hunters there.
  5. Start the next Opus critical prover: the top unclaimed entry of `critical/QUEUE.md`, likely
     #1902.

## Results so far

- **About 50 PRs from LeoVerto merged**, closing roughly 200 proof issues. Today's include #3335
  #3344 #3346 #3356 #3365 #3367 #3384 #3395 #3607 #3650.
- **Critical path:**
  - #3660 proves #1223 (Tate's theorem for the global idelic zeta integral) apart from #1219 and
    older upstream sorries, by porting the Tate split from AppB Sec1.
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
| **Lake artifact cache** | `LAKE_ARTIFACT_CACHE=true`, `LAKE_CACHE_DIR=/home/user/git/riemann-masullo/.lake/artifact-cache`, exported in `/etc/sandbox-persistent.sh`, `warm.sh` and `build.sh`. On the same filesystem as `.lake/packages`, so Mathlib artifacts are hardlinked (~45 MB real use; plain `du` shows ~6.8 GB). The user approved writing to that `.lake` subdirectory only. Tested with concurrent builds |

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
