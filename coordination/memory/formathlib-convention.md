---
name: formathlib-convention
description: Where helper lemmas go in riemann-masullo (same file / public in earliest file + import / ForMathlib only for Mathlib-worthy lemmas without paper objects)
metadata:
  type: project
---

Settled 2026-11-22 from prompts/prover.md (lines ~40-44), prompts/merger.md ("read" verdict list) and scripts/proof_review.sh (imports of Mathlib.* and RiemannMasullo.* are "routine", not flagged). The user worried that cross-chapter reuse was blocked, and also did not want ForMathlib polluted.
- Same file, directly above first use, private: the default.
- ForMathlib at the Mathlib path: only lemmas that mention no RiemannMasullo definition and that Mathlib ought to have. The merger treats these as ordinary.
- Cross-file reuse of paper-object helpers: make them public in the earliest file that defines the objects, then import it. The only limit is the import DAG (no cycles), not a rule. Don't copy helpers.
- Earlier file held by an upstream sweep: copy privately and flag it for deduplication in the PR body.
- Siblings with no import path: generalise into ForMathlib, or report it. A new shared paper file needs the integrator.
Written into HUNTER.md and CRITICAL_PROVER.md. Related: [[critical-path-workstream]].
