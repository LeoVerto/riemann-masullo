---
name: paper-findings-opus
description: Paper findings (false statement, Lean/paper mismatch, failing printed step) are checked by an Opus evaluator and then posted on the issue - no longer held for the user
metadata:
  type: feedback
---

The user, 2026-11-22 ~16:00Z: "Paper findings should be evaluated by Opus and then raised."

**Why:** CONTRIBUTING asks for findings on the issue (a contribution in its own right). Holding them for the user left them unreported for hours, and the independent Opus re-check keeps weak Sonnet/Haiku leads off the tracker.

**How to apply:** agents write findings on a `Finding:` line in notes and report and never post them. The coordinator queues those, plus Haiku SUSPECT rows, in `.agent/sweeptools/findings.txt`. One Opus evaluator at a time (`FINDINGS.md`, outside the step-7 budget) recomputes each against the page image and the Lean on origin/main and gives CONFIRMED / REJECTED / UNCLEAR / DROPPED. It posts CONFIRMED ones on the declaration's issue (no claim, no statement change; the integrator decides). The ask-before-posting rule still covers everything else new upstream. Related: [[read-docs-origin-main]], [[quick-wins-mode]], [[collaborative-not-race]].
