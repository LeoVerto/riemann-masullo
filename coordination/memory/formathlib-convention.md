---
name: formathlib-convention
description: Helper lemmas are private and in the issue's file; ForMathlib only for Mathlib-worthy lemmas (rule in HUNTER.md)
metadata:
  type: feedback
---

The user, 2026-11-22: worried that cross-chapter reuse was blocked but did not want ForMathlib polluted; ~16:00Z asked for a compliance check against CONTRIBUTING ("Build as little as possible", "Get merged without waiting").

**Why:** a public helper in a lower paper file recompiles everything above it and sends the PR to a human reader.

**How to apply:** HUNTER.md "Where helper lemmas go" is the rule. Related: [[read-docs-origin-main]].
