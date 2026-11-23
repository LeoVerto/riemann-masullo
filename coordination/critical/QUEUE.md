# Route notes for open Opus candidates

Left from the 2026-11-22 critical-path mapper run (the ranking was dropped: "pick any open issue
for Opus", HOURLY.md step 8c). On 2026-11-23 01:17Z these two were still open and unclaimed;
re-check claims and the sweep list before use. The full old list is in git history.

- **#2837** `euclideanSchwartz_hermite_estimates`, Ch02 Sec1 (L/XL). Hermite basis of L² with
  polynomial seminorm growth; Mathlib has Hermite polynomials but not the Hilbert basis. Possibly
  split into basis-in-L² and seminorm estimates.
- **#3880** `hasSlowGrowthNearPoles_completedHeckeL_logDeriv`, AppB Sec4b (M). Depends on the
  height bounds of Definition B.3.1.1.
