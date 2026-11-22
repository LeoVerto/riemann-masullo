# Blockers found by the critical-path mapper (2026-11-21)

Compacted 2026-11-22. The original report (graph at 626d258, origin/main 0ef6aa7) is in git
history; node data is in `graph.tsv`. Status checked 2026-11-22 ~15:50Z.

## 0. Main.lean depends on nothing in the library: do NOT raise

`Main.lean` imports only `Statements` (pure Mathlib), and nothing under `RiemannMasullo/` mentions
`riemannZeta`, `DirichletCharacter.LFunction` or `completedRiemannZeta`. The Hecke/Dedekind bridge
statements are missing, and Ch.13 has headings only. The user decided this is wave 4 or later (the
project's human coordinator chose to focus on the earlier parts first). Do not post it.

## 1–2. Issue-tracker damage (reported on #3230, now closed)

The 2026-11-21 15:16–15:27Z `issues.py` run opened the fragment-titled batch #3183–#3322 and closed
124 well-formed issues of live sorries; 6 sorries from splits had no issue at all. Posted on #3230;
the integrator has since closed it. Before relying on an issue near those numbers, check that it is
well-formed and that its sorry is live.

## 3. Elaboration timeouts (#1288 class): mostly an artifact

The Ch02 Sec2b / Ch04 Sec5–6 / Ch09 Sec3 "timeouts" were largely due to our use of
`lake env lean`, which skips the lakefile options (confirmed by the #2663 prover). Real traps
found since then, and their fixes, are in HUNTER.md "Elaboration traps".

## 4. Statement notes

- `ApproxProp` (#561, #429, #434): repaired upstream by #3330.
- #1229 area: false before 5e0c7c1 (ERRATA F13), fixed; any fresh worktree is after it.
- `completedHeckeL_continuation_simplePoles` (#1206): `TODO(paper-gap)` on the printed residues;
  the statement avoids them.
- #1212 `finiteHeckeL_exists_continuation` sat above the completed continuation it follows from;
  the issue is closed now.
- The `∃!` predicates of #1890, #1891, #1902, #2170, #2172 and #1906 were checked: not vacuous.
