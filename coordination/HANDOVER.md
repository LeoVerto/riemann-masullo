# Coordinator handover: critical path, sieve and hunters

State as of 2026-11-22 ~04:35Z (03:35 local CET in the service logs, which use local time). This
branch (`coordination/low-hanging-campaign` on the `LeoVerto` fork) is **not meant to be merged**:
`scripts/` and `prompts/` are integrator-owned, and `lean/Sweep*.lean.txt` define tactic macros,
which the project bans from the library. It records the strategy, tools and state needed to take
over the coordinator role.

**Live copies are in `/mnt/faststorage/math/riemann-masullo/.agent/`**, which is persistent and
ignored by git: `sweeptools/` (tools and state), `wt/` (worktrees) and `memory/` (Claude memory).
The folders here (`tools/`, `state/`, `critical/`, `sieve/`, `memory/`, `lean/`) are snapshots of
them. `/home/agent/{sweeptools,wt}` are compatibility symlinks, and they are lost when the sandbox
is recreated.

## Standing instructions from the user

- **Coordinator only:** no proofs, builds or long log reads in the main session. Delegate them and
  relay short reports.
- **CPU time is cheap; tokens are the bottleneck.** Prefer automation, such as the sieve and
  `exact?` runs, over agent reasoning. Agents wait on builds with one blocking wait, not polling.
- **Models:**
  - Hunters, sievers and fixers run on Sonnet at effort medium, until 4 PRs or about 3 h.
  - Critical-path provers run on Opus with no effort override, one issue each.
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
   - Critical-path prover: one Opus agent ("Critical path" below).
   - A siever when the sieve shows READY or HINT lines.
   - Hunters only on concrete leads.

## State at handoff

**Running:**
- Opus prover on **#2663** (`modulatedCyclicDifference_isLinearMap_continuous`, Ch04 Sec5, 19
  dependents). Its brief: elaborate the statement under `timeout 120` first, because Ch04 has
  #1288-class elaboration timeouts; if it times out, switch to **#2364** (Ch05 Sec1). Worktree
  `.agent/wt/crit-2663`, claim in `claims.txt`.
- The sieve service, sweeping the never-swept new files first: Ch06 Sec1 and Sec2, Ch07 Sec1a and
  Sec1b. Its first Ch06 Sec1 run was killed by memguard (rc 137) while the prover compiled, and it
  retried by itself.

**Merged today:**
- #3823: fully proves #1219.
- #3978: proves #1902, the S-local continuation (gluing on p. 131). It rests on #1901 and #1900.
- #3993: fully proves #1885 (`analyticOn`), with clean axioms. It used the approach from another
  contributor's release notes.

**Not handed in:**
- #2517 is proved on local branch `hunt/ch03n-1` (commit 1f3ce84). It was NOT handed in because
  jcosmos0 claimed it at 01:18Z, before our hunter started; the hunter missed the claim comment.
  Keep the branch in case they release it (see `state/pending_handins.txt`).

**Blind hunters no longer pay.**
- ch03 hunter: 0 PRs. appB hunter: 0 PRs, because all 46 unclaimed appB issues (#3749–#3914, Sec4b,
  Sec5 and Sec6) are deep.
- Launch Sonnet hunters only on concrete leads, i.e. sieve hits or a script-made short list.
- `state/leads.txt` has notes, e.g. #3864 as a possible Opus target.

**Upstream sweepers** (label `sweep`, `prompts/sweeper.md`, codex agents at xhigh effort) each
claim a whole file's remaining sorries.
- They held 14 files at handoff, including all of Ch03 Sec2, Sec3 and Sec3b (#3991, #3992, #3994
  from 02:12Z). The rest of the #1902 chain (#1890, #1891, #1900, #1901) is theirs.
- An overlap audit found ZERO issue-level duplication with our PRs. Same-file cases were sequential.
  One near-miss: #3823 added helpers to Ch02 Sec2a while #3795 held it.
- Rules now in both briefs:
  - claim publicly first;
  - re-check the open sweep list before pushing;
  - never edit held files;
  - if a file becomes held mid-work, move new helpers out of it (ForMathlib if general, else a
    private copy flagged in the PR).

**Wave 3:**
- The user expects wave 3 to be seeded within a few hours of handoff.
- Ch06 Sec 6.1/6.2 and Ch07 Sec1a/1b are stated, but had no proof issues yet.
- The sieve pre-computes closures so that sievers can hand in the moment the integrator opens
  issues, before the sweepers reach those files.

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
  - Ranking at handoff (178 cone sorries outside held files): #2663 (19 dependents, Ch04 Sec5),
    #2607 (Ch09 Sec3), #2364 and #2359 (Ch05 Sec1), #2541 (Ch04 Sec4), #2609 (Ch09 Sec3).
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

### 3. Hunters (`tools/HUNTER.md`)

- Hunters now run only on concrete leads.
- Launch prompt: `Read <S>/HUNTER.md and follow it exactly. Your label <L> is X, your branch prefix
  <P> is hunt/X<n>, your model tag <M> is Claude Sonnet 5.5, effort medium.` Add leads and
  exclusions.
- HUNTER.md's end sections are binding: token check, upstream sweepers, token thrift, sweeper race,
  helper placement, and claims/notes/attribution.

## Hourly check (cron prompt)

`Hourly riemann-masullo coordinator check (coordinator only; CPU cheap, tokens scarce).
S=<repo>/.agent/sweeptools.`
1. `status.sh` and `cleanup.sh`, under timeout, with the output tailed.
2. Fix failing Verdicts or review comments with short Sonnet fixers; re-check the PR's state first.
3. Release orphan or stale claims only via `release.sh`.
4. Relay finished agents in one line each.
5. Services: warm, watchdog, memguard and sieve.
6. If READY or HINT lines appear, launch ONE siever unless one is running. No blind hunters.
7. Keep at most 1 Opus critical prover, picking from cone sorries outside held files; record
   launches in `hunted.txt`.
8. Report in one or two lines.

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
| `memguard.sh` | Below 3 GB available, kills the newest sieve Lean process, otherwise the newest Lean process of any kind (old version: `memguard.sh.bak`). |
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
- Critical path: #3660 (#1223), #3681 (#1906), #3823 (#1219), #3978 (#1902), #3993 (#1885).
