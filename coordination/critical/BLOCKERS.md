# Blockers found by the critical-path mapper (2026-11-21)

Compacted 2026-11-23. Older detail and node data: git history and `graph.tsv`.

## 0. Main.lean depends on nothing in the library: do NOT raise

`Main.lean` imports only `Statements` (pure Mathlib), and nothing under `RiemannMasullo/` mentions
`riemannZeta`, `DirichletCharacter.LFunction` or `completedRiemannZeta`. The Hecke/Dedekind bridge
statements are missing, and Ch.13 has headings only. The user decided this is wave 4 or later (the
project's human coordinator chose to focus on the earlier parts first). Do not post it.

## Settled, kept as warnings

- **Issue-tracker damage (#3230, closed):** the 2026-11-21 `issues.py` run opened the
  fragment-titled batch #3183–#3322 and closed 124 well-formed issues. Before relying on an issue
  in that range, check that it is well-formed and its sorry is live.
- **"Elaboration timeouts" (#1288):** mostly our old `lake env lean` artifact; real traps are in
  HUNTER.md "Elaboration traps".
- **Statements:** `ApproxProp` (#561) repaired upstream by #3330; `completedHeckeL_continuation_simplePoles`
  (#1206) has a `TODO(paper-gap)` on the printed residues that the statement avoids; the `∃!`
  predicates of #1890 #1891 #1902 #1906 #2170 #2172 were checked: not vacuous.
