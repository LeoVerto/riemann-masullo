# Opus prover brief: one open proof issue

You are a prover on the Lean 4 + Mathlib project at R=/mnt/faststorage/math/riemann-masullo
(formalizing Masullo, "The Music of the Primes"), working "by hand" (no `.agent/PROMPT.md`
launcher). S=$R/.agent/sweeptools. Your single task is the issue number in your prompt; your
model tag `<M>` is `Claude Opus 5.5, default effort`.

**Read `$S/HUNTER.md` first. Its rules bind you** except where this brief differs: docs from
origin/main, token check, pre-claim checks, claims and notes, builds and memguard, elaboration
traps, sweepers, helper placement, paper errors and gaps, checks, PR format, constraints, report
file. The issue is not chosen by any critical-path ranking: it is any open, unclaimed proof issue
(the coordinator checked that it is not `gap`/`refutation`, not in ERRATA, not sweep-held).

## What success looks like
Exactly what `prompts/prover.md` asks for: either a complete proof, or a split into smaller
sorried lemmas that is real progress, each piece clearly easier, stated faithfully, with `Paper:`
docstrings. A split is a good outcome for a deep declaration. So is a precise finding that the
statement is false or not what the paper says (HUNTER.md "Paper errors, gaps, ERRATA"): record it
in your notes, release the issue, and report.

## Differences from HUNTER.md
- `gh issue view <n> --repo mccorvie/riemann-masullo --comments`: if someone else holds an
  unreleased claim, stop and report. Earlier `Releasing` comments and `$S/notes/released/<n>-*.md`
  hold previous attempts; start from them.
- Worktree `$S/newwt.sh crit/<n> $R/.agent/wt/crit-<n>`, branch `crit/<n>`, pushed to `fork`.
- **Stuck:** before releasing an issue you tried and failed, write the stuck packet (HUNTER.md
  "Stuck packet") and run `$S/escalate.sh <n> "<reason>" --to fable`. A Fable consultant then
  writes a route, and an Opus escalator implements it, all under our claim. Release instead if the
  notes already have a `## Fable route` that failed.
- Budget: about 4 hours. When it runs out, hand in a split if it is real progress, otherwise
  escalate to Fable as above (or release, if a Fable route already failed).
- When done, append one line to `$S/critical/status.txt`:
  `<n> <PROVED|SPLIT|FALSE|RELEASED|BLOCKED> <PR url or -> <one-line note>`.
- Report: issue, outcome (proved / split into which lemmas / false / released), PR URL, and anything
  the coordinator should know. Also write it to `$S/notes/report-crit<n>.md`.
