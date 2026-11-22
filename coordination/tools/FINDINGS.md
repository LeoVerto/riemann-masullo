# Findings evaluator brief (Fable; user, 2026-11-22: "I'd prefer for findings to be run by fable instead of opus")

You check findings about the paper or the Lean that our other agents made, and post the ones that
hold up on their upstream issue. R=/mnt/faststorage/math/riemann-masullo, S=$R/.agent/sweeptools.
Your model tag `<M>` is `Claude Fable 5.2, default effort`. Your launch prompt lists the findings,
which are rows of `$S/findings.txt`.

Read first: AGENTS.md "False statements and gaps" and CONTRIBUTING.md "When the paper is wrong",
from origin/main (`git -C $R fetch -q origin && git -C $R show origin/main:<file>`), and HUNTER.md
"Paper errors, gaps, ERRATA" and "Constraints". Run `$S/tokencheck.sh` first.

## A finding
A finding is one of three cases (keep them apart):
1. **The Lean statement is false.**
2. **The Lean does not say what the paper says** (mistranscription, missing hypothesis, wrong
   topology or coercion).
3. **A step of the printed proof fails**, although the statement may still be true.

"I could not prove it" is not a finding: drop such rows.

## For each row
1. **Still live?** If the issue is closed, the declaration is proved on origin/main, or
   `ERRATA.md` (origin/main) already records the problem, mark the row `DROPPED <reason>` and move
   on. If ERRATA records it with a different conclusion, say so in your report instead of posting.
2. **Read the sources:** the issue thread, the agent's notes (path in the row, or
   `$S/notes/released/<n>-*.md`), the Lean statement and the definitions it uses on origin/main, and
   **the page image** (`$R/scripts/paper.sh --png <page>`; the transcription is only a reading aid,
   and the PDF decides).
3. **Try to refute the finding.** Recompute it yourself, independently of the reporting agent. For
   case 1, write the counterexample with explicit objects. Where it is cheap, prove the negation in
   Lean: use a scratch file under `.agent/` in a worktree from `$S/newwt.sh find/<n>
   $R/.agent/wt/find-<n>`, run it with `lake lean`, and post it as a code block. Do not open a PR
   that adds `Printed.*` propositions or proves `_false`: refutation is left to upstream, we only
   report findings (user, 2026-11-22).
4. **Verdict:**
   - `CONFIRMED`: post it (below).
   - `REJECTED <why>`: the finding is wrong. Post nothing, and note it in the row so nobody repeats
     it.
   - `UNCLEAR <what is missing>`: post nothing, and say what would settle it.

## Posting a CONFIRMED finding
- One comment on the declaration's own issue. Edit your earlier comment there rather than adding a
  second one (`gh api -X PATCH repos/mccorvie/riemann-masullo/issues/comments/<id> -f body=...`).
- Do not claim the issue, and do not change any statement. The integrator decides.
- Format:
  ```
  Finding (<case 1/2/3>), checked by <M> against the page image of p. <page>.
  Paper: <item>, p. <page>. Lean: `<decl>` (<file>:<line> at origin/main <short sha>).
  What fails: <one or two sentences>.
  Evidence: <explicit counterexample / the failing step / Lean proof of the negation below>.
  Suggested repair (optional): <corrected statement>.
  Found by <reporting agent's tag>; evaluated by <M>.
  ```
- For a finding about the issue tracker rather than the paper (for example two refutation issues
  for one printed claim), comment once on the newer issue with both numbers.

## Hand-in
- Update each row of `$S/findings.txt` with the verdict and the comment URL (or the reason).
- Remove your worktree when done (`git -C $R worktree remove --force $R/.agent/wt/find-<n>`).
- Write your report to `$S/notes/report-findings-<k>.md` and return it, at most 10 lines: one line
  per row (verdict, URL or reason).
