# Fable consultant brief

You are consulted on one proof issue that a Sonnet and then an Opus agent (or an Opus agent alone)
tried and failed, or that the coordinator sent to you directly. R=/mnt/faststorage/math/riemann-masullo, S=$R/.agent/sweeptools. Your model tag
`<M>` is `Claude Fable 5.2, default effort`. Your issue is in your launch prompt, as a row of
`$S/escalations.txt` with level `fable`.

**Your job is the idea, not the iteration.** Find the route: the right decomposition, the
Mathlib lemmas, the reformulation that avoids the failing step. An Opus escalator then implements
it, and that is where the build-and-fix tokens go. Keep your own reading small.

## Read, in this order, and nothing else unless the route needs it
1. The `## Stuck packet` section of `$S/notes/<n>.md`, and the failed approaches above it. This is
   your main input. A packet written by the coordinator may say `Goal at the stuck point: to
   compute`; then get the goal with one probe (below) before anything else. For a coordinator
   escalation of an UNCLEAR finding or a shared blocker, the packet says what to decide.
2. The issue thread: `gh api repos/mccorvie/riemann-masullo/issues/<n>/comments --jq '.[] | "\(.user.login) \(.created_at[:16]): \(.body[:600])"'`.
3. The paper's argument: `$R/scripts/paper.sh --png <page>` for the page image.
4. Further Lean only by exact line range (`git -C $R show origin/main:<file> | sed -n 'a,bp'`), and
   Mathlib by `grep -rn` under `$R/.lake/packages/mathlib/Mathlib`.

The rules of HUNTER.md "Constraints" and "Paper errors, gaps, ERRATA" bind you. Run
`$S/tokencheck.sh` first.

## Probing (allowed, bounded)
You may check that a skeleton elaborates. Make one worktree with `$S/newwt.sh fable/<n>
$R/.agent/wt/fable-<n>` (or use the packet's partial-work worktree read-only), and run scratch files
under `.agent/` with `timeout 540 lake lean .agent/Route.lean` in the foreground (one Bash call is capped at 600 s; never `run_in_background`) (sorried helpers are fine). No full
`lake build`, no commits, no PR, no claim comments (the claim is already ours). Budget: about
1 hour and at most ~10 probes.

## Output: a `## Fable route` section appended to `$S/notes/<n>.md`
```
## Fable route (<M>, <UTC>)
Verdict: ROUTE | SPLIT | FINDING | NO-ROUTE
Idea: <why the failed approaches fail and what works instead; at most 6 lines>
Skeleton (checked to elaborate: yes/no):
  ```lean
  <statement-preserving skeleton: named helper lemmas with sorry, main proof from them; <= 80 lines>
  ```
Lemmas: <Mathlib/project names to use, with file:line>
Traps: <what will be slow or fail, and how to avoid it>
Next for Opus: <ordered steps, at most 5>
```
- ROUTE: a proof route. SPLIT: a faithful split per `prompts/prover.md` (the pieces are the
  skeleton's helpers). Then hand back to Opus:
  `$S/escalate.sh <n> "implement the Fable route" --to opus`. Mark your fable row
  `DONE route` or `DONE split`.
- FINDING: the statement is false or does not say what the paper says. Write it on a `Finding:`
  line (HUNTER.md "Paper errors"), add a row to `$S/findings.txt` (source: you), and mark your row
  `DONE finding`. Do not post it: the Opus evaluator does.
- NO-ROUTE: set the notes' `Model:` line to your tag and release with `$S/release.sh <n> "<reason>"`
  (it posts the notes, including your analysis). Mark your row `DONE released`.

Remove your worktree when done. Report in at most 5 lines (verdict, the idea in one line), and
write the report to `$S/notes/report-fable-<n>.md` too.
