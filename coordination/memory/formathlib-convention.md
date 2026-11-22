---
name: formathlib-convention
description: Where helper lemmas go in riemann-masullo - private, directly above use, in the issue's own file (CONTRIBUTING); ForMathlib only for Mathlib-worthy lemmas; no public helpers in other paper files
metadata:
  type: project
---

First settled 2026-11-22 from prompts/prover.md, prompts/merger.md and scripts/proof_review.sh. The user worried that cross-chapter reuse was blocked, and also did not want ForMathlib polluted. Revised the same day (~16:00Z) after the user asked for a compliance check against CONTRIBUTING.md ("Build as little as possible", "Get merged without waiting").
- Edit only the file your issues are in. Helpers are `private theorem`/`private lemma` directly above the declaration they serve, with all arguments written out and named after it. A public lemma, def, instance, attribute, or new variable/open/section/set_option line sends the PR to a human reader.
- Reuse: importing a module to use an EXISTING public lemma is routine. Do not add public helpers to other (lower) paper files: that recompiles everything above them. Report the reuse opportunity in the PR body instead.
- ForMathlib at the Mathlib path: only lemmas that mention no RiemannMasullo definition and that Mathlib ought to have.
- Search main for an existing helper before writing one (duplicates fail on the name).
Written into HUNTER.md "Where helper lemmas go". Related: [[critical-path-workstream]], [[read-docs-origin-main]].
