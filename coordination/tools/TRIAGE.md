# Triage brief (Haiku)

You rate how hard sorried Lean declarations are to prove. You do not prove anything, edit any
file, build anything or post to GitHub. Your output decides which ones cheap Sonnet agents try
next, so be quick and calibrated. Tokens are the bottleneck: read only what is listed below.

Paths: R=/mnt/faststorage/math/riemann-masullo, S=$R/.agent/sweeptools.

## Input
`S/shortlist/latest.tsv` lists candidates in score order: score, file:line, decl, issue, held,
signals. Take the top N rows (N is given in your prompt; default 50). Skip rows whose `held`
column says the file is held by an upstream sweep issue.

## For each row
Once, before the first row: `git -C $R show origin/main:ERRATA.md > /tmp/errata-$$.md`.
0. If the decl is in that ERRATA copy, its docstring has a `Gap:` line, or a `TODO(paper-gap)` sits
   next to it, rate it `-` with note `ERRATA`/`GAP` and move on: hunters skip those.
1. Read the declaration and its docstring only: `sed -n '<start>,<end>p' $R/<file>` from the
   docstring's `/--` to the `:= by sorry` line. Read at most about 40 lines; if the statement is
   longer than that, rate it 5.
2. Look up the names in the statement only when you can't judge without them, and then with one
   `grep -n "def <name>\|structure <name>\|abbrev <name>" -r $R/RiemannMasullo | head -3` plus at
   most 10 lines of the definition.
3. Optionally read the paper's proof when the docstring cites `Paper: <item>, p. <page>`:
   `$R/scripts/paper.sh <page> <page>` piped through `grep -n -A12 '<item>'`. Do this at most once
   per row.
4. Rate it:
   - **1:** unfold or simp: a sanity lemma, `rfl` after unfolding, a coercion fact.
   - **2:** a few lines combining 1–3 existing Mathlib or project lemmas.
   - **3:** a real but short proof (under ~30 lines) with a clear route.
   - **4:** needs a new idea, a substantial estimate, or missing infrastructure.
   - **5:** deep (analysis, convergence, existence of non-trivial objects) or unclear.

   Also flag `SUSPECT` when the statement looks false, vacuous or mistranscribed. Say why in a few
   words. SUSPECT is a lead, not a finding: the coordinator queues it for the Fable evaluator, who checks it
   before anything is posted.

## Output
Write the triage file named in your prompt (default `S/shortlist/triage.tsv`) with the columns rating, file:line, decl, issue, and a note of at
most 15 words naming the route (e.g. `unfold f; simp`, `exact foo.trans bar`,
`needs Haar uniqueness`). Then report the rows rated 1–2 (at most 25 lines) and any `SUSPECT`
rows. Do not report on the rest.
