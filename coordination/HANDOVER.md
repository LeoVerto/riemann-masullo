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

## Current state (2026-11-22 ~16:35Z, coordinator session 09ff2a64)

- **Campaign resumed ~16:05Z.** Services (warm, watchdog, memguard, sieve) restarted; `no-resume`
  kept. Hourly cron at minute 17 (job in this session). Nagger running.
- **Running (agents.txt):** crit2526 (the one Opus hunter, #2526 SPLIT plan); esc-sec5 (Opus,
  Ch05 Sec5 #4408 #4420 #4423 #4429 #4431 #4409 #4411); esc-sec4 (Opus, Ch05 Sec4 #4344 #4352 #4356
  #4338); Sonnet w17 Ch11 Sec1b, w18 Ch10 Sec4a (not #5248: FleckiBunti), w19 Ch10 Sec3, w20 Ch10
  Sec4b #5298 + Ch07 Sec5 #5131; Opus findings evaluator on #5108.
- **Triage 7a–7d done** (top 240 of `shortlist/untriaged7.tsv`, issues >4616); 182 rows (untriaged7
  rows 242+) still untriaged. Rated-3 rows outside the hunters' files are in `triage7*.tsv`.
- **Findings:** #4255 #4574 #4575 DONE (closed/proved), #4430 #4432 #4603 REJECTED
  (`notes/report-findings-1.md`); #5108 under evaluation.
- #4535 released by w16 (rate 4–5). #2517 still on local branch `hunt/ch03n-1` (jcosmos0 holds it).
- Saved partial proofs: `S/patches/`.

## Standing instructions from the user

- **Coordinator only.** No proofs, builds or long log reads in the main session; delegate and
  relay short reports. The `advisor` tool is turned off (user, 2026-11-22); escalation goes
  through `escalate.sh` and the Fable consultant instead.
- **CPU is cheap, tokens are scarce.** Automate (sieve, shortlist, scripts) before reasoning.
  Agents wait on builds with one blocking wait, never polling turns. Keep wake-ups sparse.
- **Staffing (user, 2026-11-22 ~16:00Z, after the token allowance increased):** "we can now
  always keep two Opus hunters running plus 4 Sonnets and two Opus escalators". Keep these slots
  filled at every check (quick-wins mode now runs alongside Opus, not before it):
  1. **4 Sonnet hunters** on quick wins: triage rows rated 1–2, then 3 (HUNTER.md).
  2. **2 Opus escalators:** a Sonnet that is *stuck* (tried and failed) hands the issue over with
     `escalate.sh`, keeping our claim; an Opus escalation prover (HUNTER.md "Escalators") takes the
     queued rows of `escalations.txt`, one file per prover, once our Sonnet has left that file. A
     slot with nothing to escalate stays empty.
  3. **1 Opus hunter** (user, 2026-11-22 ~16:20Z: "Let's stick with one opus hunter for now"; was 2) on **any** open unclaimed proof issue (CRITICAL_PROVER.md; not
     `gap`/`refutation`/ERRATA/`TODO(paper-gap)`, not sweep-held), preferring triage rows rated
     3–4 that no Sonnet holds. No cone remapping ("the cone doesn't matter at this point").
  4. **1 Fable consultant at a time** (user, 2026-11-22 ~16:00Z, Fable allowance; outside the 8
     slots): issues an Opus agent tried and failed go `--to fable` with a stuck packet
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
  and the sieve; the 8-agent staffing above is untested at that RAM. Agents build only their module
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
   `cd S && setsid nohup ./<name>.sh >> <name>.log 2>&1 < /dev/null &` for warm, watchdog, memguard
   and sieve (sieve details in `SIEVE.md`). Check that `warm.log` says "ready" at a recent main. The
   watchdog's auto-resume uses a hard-coded old `SESSION`: leave `no-resume` in place unless you
   restart it with `SESSION=<your id>`.
4. **One hourly check:** `CronList` first (duplicates have happened), then create it with the
   one-line prompt under "Hourly check".
5. **Relaunch:** the nagger (if any agent runs), the quick-win loop on the new issues, and
   escalations or Opus per quick-wins mode. Never resume long dead transcripts with SendMessage
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
  and follow it. Your findings: <rows>.`, on top of the 8 standing slots) re-checks each against
  the page image and the Lean, then posts confirmed ones on the issue (HOURLY.md step 10).
- **Nagger:** see `NAGGER.md`; stop it with `touch S/nagger.stop`.
- `scripts/agent.sh` does not work here: it assumes the integrator's layout and pushes to `origin`.

## Infrastructure (`S`; copies in `tools/`)

| Piece | What it does |
|---|---|
| `warm.sh` + `wt/base` | Keeps a worktree built at origin/main; publishes `base/{COMMIT,sig.txt}`; rebuilds failed index modules one at a time. |
| `newwt.sh <branch> <dir>` | New worktree at the warm commit with a copied build and baseline signatures in `<dir>-before.txt`. |
| `build.sh <wt>` | `lake build`, exit status in `<wt>/.agent/build.exit`. |
| `status.sh` | RAM, disk, token, cache, PR verdicts, claims, orphan and stale claims, warm base, label census, `== sieve`. |
| `cleanup.sh` | Removes worktrees whose PR merged. |
| `tokencheck.sh` | Classic token with the right scopes? Step 0 of every brief. |
| `escalate.sh <n> "<reason>"` | Hands a stuck issue to the next tier (`--to opus` default, `--to fable` with a stuck packet) without releasing it: no comment, stays in `claims.txt`, row in `escalations.txt`, note appended. |
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
- Never `pgrep`/`pkill -f` a pattern from your own command line; kill only PIDs you started.

## Upstream reports (integrator decides)

- **#3230:** issue-sync damage (fragment batch #3183–#3322, 124 issues wrongly closed, 6 sorries
  without issue). Details in `critical/BLOCKERS.md`.
- **#1288:** consolidated instance-timeout report (much of it turned out to be the `lake env lean`
  artifact).
- **#561:** `ApproxProp` false statements, repaired by #3330.
