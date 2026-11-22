# Siever brief

You hand in what the **sieve** found. The sieve is our automated tactic screen: it replaces each
`sorry` in the library with a tactic macro (cheap chain, then `exact?`) and records which ones close.

Principle: **CPU time is cheap, tokens are the bottleneck.** The machine has done the search, and
your job is to turn its hits into clean pull requests with as little reasoning and output as
possible.

Paths: R=/mnt/faststorage/math/riemann-masullo (main checkout, never build or edit there),
S=$R/.agent/sweeptools, worktrees under $R/.agent/wt.

## Read first
- `$R/AGENTS.md` (project rules).
- `S/HUNTER.md`, all of it, including the sections at its end: token check, upstream sweepers,
  token thrift, sweeper overlap, helper placement, and claims/notes/attribution. It defines how you
  claim, build, check and hand in. This brief only adds what is specific to sieve hits.
- `S/SIEVE.md` (how the sieve service works, where its results are).

## Your inputs
The launch prompt gives you a list of sieve hits, usually copied from the `== sieve` section of
`S/status.sh`. Each line is one of:
- `READY #<issue> <decl> <file> <tactic>`: an open, unclaimed proof issue in a file no upstream
  sweeper holds. Hand it in.
- `HINT #<sweep issue> <decl> ...`: the file is held by an open upstream `sweep` issue. Post a hint
  (below); never edit that file.
- `CLAIMED`, `WAIT` and `DONE` lines: ignore them. `WAIT` hits wait until the integrator opens
  issues.
If you are given no list, run `S/status.sh` and take the READY and HINT lines yourself.

Your model tag <M> is given in the launch prompt (default `Claude Sonnet 5.5, effort medium`).

## Handing in READY hits
1. Re-check each issue right before claiming: read the full comment thread (command in
   HUNTER.md), check the open sweep list, and check that the `sorry` is still on origin/main.
   Drop anything that changed. Claim with `Claiming (<M>)` and keep `S/notes/<n>.md`, as HUNTER.md
   says.
2. Batch by file, 2–8 issues per PR, one worktree per batch (`S/newwt.sh <P>-<k> $R/.agent/wt/<P>-<k>`).
   Use branch prefix <P> = `sieve/<label>` unless the prompt says otherwise.
3. Put in the **concrete** proof: never the macro (`sweeptac`/`sweepxtac` are banned in the
   library, and the macro modules `Sweep.lean`/`Sweep2.lean` must never be committed). For `exact?`
   hits, use the term it printed (`exact foo bar`), and simplify only if that is trivial.
   Re-elaborate each one. A hit can fail on a newer main; if so, release it with `S/release.sh`,
   with the failure in its notes.
4. Run the full checks from HUNTER.md (build, `scripts/lint.sh`, signature compare, axioms) and open
   the PR. The body has one `Closes #<n>` line per issue, a line saying the proofs were found by the
   automated sieve and checked by hand, and `Prover: <M>` above the 🤖 line.
5. Append `<file>::<decl>` for each handed-in hit to `S/dispatched.txt`, and delete
   `S/notes/<n>.md` once the PR is open.

## Posting HINT hits (user-approved, 2026-11-22)
- First check that the sweep issue is still open and the `sorry` is still on origin/main. Skip
  declarations the sweep table marks as claimed by someone else.
- Post **one comment per sweep issue**, batching all its hits. If you already commented there,
  edit that comment instead of adding a new one (`gh api -X PATCH repos/mccorvie/riemann-masullo/issues/comments/<id> -f body=...`).
- Format:
  ```
  Hint from an automated tactic sieve (<M>, LeoVerto, at origin/main <short sha>): these sorries
  close with a single tactic. Not run through lint/signature checks; use or ignore as you see fit.
  | Issue | Declaration | Line | Tactic |
  |---|---|---|---|
  | #NNNN | `foo_bar` | 123 | `exact baz qux` |
  ```
- Append `<file>::<decl> hint:#<sweep issue>` to `S/dispatched.txt`.

## Manual full sieve (only if the sieve service is down or the prompt asks for it)
1. `S/newwt.sh sieve/run<k> $R/.agent/wt/sieve-manual` at the warm base. Install
   `S/lean/Sweep.lean.txt` and `Sweep2.lean.txt` there as `RiemannMasullo/Sweep.lean` /
   `Sweep2.lean`. Never commit or push that branch.
2. `S/sweep.py <wt> <file> <out.json> [--exact]` per file with a `sorry`, cheap pass then `--exact`,
   newest files first, with generous timeouts (tens of minutes per file). If a whole file times out,
   split it rather than give up. Run at most ONE sweep Lean process at a time (an `exact?` process
   needs 3–5 GB; memguard kills the newest sweep Lean process, or any Lean process if none, below 1 GB free; if yours is killed, see the memguard section in HUNTER.md and change approach rather than retrying). Run it in the
   background and wait with one blocking wait.
3. Triage the hits as above (READY / HINT / drop), then hand in and post hints.
4. Remove the manual worktree with `git worktree remove --force` when done.

## Stop and report
Stop after 4 PRs, about 3 h, or when the list is done. Report at most 12 lines: PRs (URL, issues
closed), hints posted (comment URLs), hits dropped and why (stale, claimed, failed on new main), and
anything wrong with the sieve output you noticed (false hits, timeouts, missing files).

## Current project docs (added 2026-11-22)
Read AGENTS.md, CONTRIBUTING.md and ERRATA.md from origin/main (`git -C /mnt/faststorage/math/riemann-masullo show origin/main:<file>`), not from the possibly stale working tree. The section "Read the CURRENT project docs; false statements and gaps" at the end of HUNTER.md is binding for you too.


## Final report file (added 2026-11-22, binding)
Before you finish, ALSO write your final report (the same lines you would return) to `/mnt/faststorage/math/riemann-masullo/.agent/sweeptools/notes/report-<your name>.md` (e.g. `report-w12.md`, `report-crit1526.md`). Your returned answer may reach a different agent than the coordinator; the file is what the coordinator reads.
