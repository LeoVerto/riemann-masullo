# Coordinator handover: low-hanging-fruit campaign

State as of 2026-11-21 ~07:30Z. This branch (`coordination/low-hanging-campaign` on the
`LeoVerto` fork) is **not meant to be merged**: `scripts/` and `prompts/` are integrator-owned,
and `lean/Sweep*.lean.txt` define tactic macros, which the project bans from the library. It
records the strategy, the tools and the state needed to take over the coordinator role.

## Goal and results

The directive: find and close low-hanging proof issues in `mccorvie/riemann-masullo`,
delegating to subagents in their own worktrees and keeping the coordinator's own context lean.

- 39 PRs from `LeoVerto` merged (3 of them before this campaign), closing about 175 proof issues.
  Open at handover: #2773, #2850, #2859.
- Statement problems found and reported on the issues, for the integrator:
  - **#561 `hilbert_approximationProperty` is false as stated.** The ascription to
    `PrecompactConvergenceCLM` does not change the topology `closure` and `DenseRange` use, so
    it states operator-norm density of finite-rank operators, which is false in infinite
    dimensions. The same flaw affects the `ApproxProp` hypothesis of the Sec3a `nuclearTrace`
    lemmas and #429, #430, #434.
  - #1288 `homogeneousAdelicTheta_isLinear`: instance synthesis on
    `SchwartzBruhat (Multiplicative 𝔸[F])` times out in Ch02 Sec2b.
  - #1784: `rfl` works from a scratch file but elaboration exceeds 100 s inside AppD Sec3b.
- Many proofs are true only by construction (a definition already encodes the claim, or the
  lemma unpacks a `Classical.choose` witness). The PRs say so; the real content sits in the open
  existence issues.

## Strategy

1. **Hunters do the work, the coordinator routes.** A hunter is a subagent given one label
   (chapter). It reads `tools/HUNTER.md`: list unclaimed issues for the label, newest first;
   claim a batch of 2–8 short ones in one file; prove; full checks; one PR per batch. It stops
   after **2 PRs or ~90 minutes**. Short lives keep context and cost low.
2. **At most 3 hunters at once**, each on a different label. Labels are chosen from the label
   census in `tools/status.sh` (unclaimed count, newest issue, last hunt from
   `state/hunted.txt`), not from a fixed list. New chapters keep being digested, and
   "mined-out" labels get new issues from splits and digests.
3. **Model and effort (user's choice):** subagents on Opus (no `model` override), `effort:
   "medium"` for hunters and PR fixers, `"low"` for single-hit checks and rebases.
4. **Knowledge carries between hunters** through `state/leads.txt` (short-looking issues, things
   to skip and why) and `.agent/STATE.md` in each worktree (handoff if cut off).
5. **Tactic sweep (`tools/sweep.py`)** replaces every `sorry` in a file by a `first | rfl |
   simp | aesop | ... | exact?` macro and reports which close. Yield was about 1% (12 of 1191),
   so it is a side channel only. Hits are re-verified by a subagent in a clean worktree before
   any PR. It runs at nice 19 / idle I/O. As agreed with the user, it was **not** proposed
   upstream given that hit rate.

## Infrastructure (all under `/home/agent/`, copies in `tools/`)

| Piece | What it does |
|---|---|
| `wt/base` + `warm.sh` | keeps a worktree built at `origin/main` (checks every 10 min) and publishes `sweeptools/base/{COMMIT,build,sig.txt}` |
| `newwt.sh <branch> <dir>` | new worktree at the warm commit with a ready `.lake/build` and baseline signatures in `<dir>-before.txt`: no baseline build |
| `build.sh <wt>` | `lake build` with exit status in `<wt>/.agent/build.exit`; agents wait on that file, never `pgrep` |
| `status.sh` | one-shot check: RAM/disk, PR verdicts, `claims.txt`, orphan and stale claims, warm base, sweep hits not yet in `dispatched.txt`, label census |
| `cleanup.sh` | removes worktrees whose PR is merged (disk fills fast; run it on every check) |
| `watchdog.sh` | if no Claude transcript changes for 20 min, releases every `claims.txt` issue without an open PR ("Releasing" comment); after 2 h idle it probes the API and resumes the session |
| `memguard.sh` | kills the newest sweep Lean process when available RAM < 1.5 GB (`exact?` needs 3–5 GB per process) |
| `run_sweep.sh`, `run_list*.sh`, `chain.sh` | sweep drivers; `sweep2` worktree sweeps files changed since the first base |

Worktrees: `/home/user/git` is not writable, so everything is under `/home/agent/wt/` (the
overlay disk). Each worktree shares Mathlib via a symlink to the main checkout's
`.lake/packages` and is about 0.5 GB.

## Coordinator loop

A cron job (session-only, so re-create it after any restart; it was deleted at handover to save
budget) ran at :17 and :57 with this prompt:

> Periodic hunter check (budget-conscious: keep it to a few tool calls). Run
> /home/agent/sweeptools/status.sh and /home/agent/sweeptools/cleanup.sh and act on them:
> (1) failing Verdict or review comment on a LeoVerto PR -> fresh short-lived subagent to fix;
> (2) ORPHAN / STALE / NO-CLAIM-COMMENT issues not owned by a live hunter -> release and drop
> from claims.txt; CLOSED -> drop; (3) RAM < 2 GB -> hold off new hunters; (4) NEW HIT lines ->
> if the issue is unclaimed, hand it to a hunter or subagent, then add the key to
> dispatched.txt; (5) relay finished hunters' results; keep at most 3 concurrent fresh hunters
> from HUNTER.md (2-PR cap), labels from the census, preferring never-hunted labels and recent
> issues; record each launch in hunted.txt. Report in one or two lines.

Launching a hunter: Agent tool, `effort: "medium"`, prompt `Read
/home/agent/sweeptools/HUNTER.md and follow it exactly. Your label <L> is `X` and your branch
prefix <P> is `hunt/X<n>`.` plus any leads and exclusions (issues in open PRs).

## State at handover

- Running when this was written, told to finish their current batch and stop: hunters on
  `ch04`, `ch09`, `appB`. Their claims are in `state/claims.txt`; the watchdog releases leftovers
  20 min after activity stops.
- `state/hunted.txt`: last hunt per label. `ch03` and `ch05` were mined out at the time; the
  census shows if that changed. `appB` was hunted last.
- `state/leads.txt`: short-looking issues and skips per label.
- Background services running: `warm.sh`, `watchdog.sh`, `memguard.sh`, and the low-priority
  sweep chain (the `exact?` pass on `wt/sweep`, the cheap pass on `wt/sweep2`).

## Upstream facts worth knowing

- **PR check / Verdict** gates merging: `merge` goes to Auto-merge; `read` means the integrator
  reads it first (usually quick); `fail` needs fixing. The reason is in the run log ("Check the
  pull request" step); the artifact host is blocked from the sandbox.
- "Lean Action CI" only targets non-library PRs; cancelled runs on proof PRs are expected. Do
  not re-run them: they clog the shared queue, which delays claims too.
- `scripts/proof_review.sh` flags any added line starting with `inductive…` (no word boundary),
  e.g. `inductiveTensorMap`, giving `read`. Harmless.
- Issues of merged PRs stay open until the merger's `scripts/issues.py --apply` closes them in a
  batch: not orphans.
- Claims are comments ("Claiming", "Releasing"); the Claims workflow applies labels with a lag,
  so check recent comments, not only the `claimed` label.

## Lessons (read before changing anything)

- **Bound every build with `timeout`.** A new proof can make elaboration or the kernel run away
  (seen in Ch04 Sec5/Sec6 and Ch09 Sec3: 20–40 min at 100% CPU), and a hunter waiting on its
  monitor then waits forever. `status.sh` does not detect this; check Lean processes' CPU time
  under `/home/agent/wt/hunt/` if a hunter reports "waiting for the build" for more than ~15 min.

- **Never `pgrep -f`/`pkill -f` a pattern that occurs in your own command line** (it kills your
  shell, exit 144), and never wait on builds with `pgrep lake`: several agents build at once.
  **Never `pkill -u`, `pkill -x lean`, `killall`**: one hunter did and killed other agents'
  builds. Kill only PIDs you started.
- **After a usage-limit halt, do not resume long-lived subagents with SendMessage**: once the
  prompt cache has expired, each resume re-sends a ~200k-token transcript at full price. Start
  fresh hunters from the `STATE.md` handoffs instead.
- **Re-check a PR's state before touching its branch or description.** One PR was edited after
  it had already merged and had to be restored.
- **`gh` caches GraphQL responses for 24 h** (`~/.cache/gh`). An instant 401 after a token
  change is a cached one: `rm -rf ~/.cache/gh`.
- `lake env lean` fails on a `module` file itself: iterate with `lake build <Module>`, or use
  scratch files under `.agent/` that import the module.
- `git fetch` can fail with "cannot lock ref" while another agent fetches: retry.
- `scripts/paper.sh` needs `poppler-utils` (`sudo apt-get install -y poppler-utils`).
- The GitHub token may be used only for `mccorvie/riemann-masullo` and `LeoVerto/riemann-masullo`.
