# Candidate issues for Opus provers, with routes

Since 2026-11-22 ~07:30Z the user's rule is "the cone doesn't matter at this point; pick any open
issue for Opus", so this is **no longer a ranked queue**: it is a list of open issues with route
notes from the last mapper run (2026-11-22, graph at 23cbb63, 91 cone sorries). Re-check the claim
state and the open sweep list before use. States below are as of 2026-11-22 ~15:50Z. `graph.tsv`
holds the cone data; the mapper scripts in `mapper/` hardcode `wt/crit-map` and treat Ch5.2–8 as
undigested, so do not regenerate it without fixing them.

Done: #1526 (PR #5045, PROVED). #3899 closed upstream. #2667 is claimed by someone else.

- **#2526** `infiniteEigendistribution_normalized`, Ch03 Sec4:3211 (L). crit2526 (Opus) planned a
  SPLIT: assembly with sorried helpers (notes in `S/notes/released/2526-20261122T1303.md`). Route:
  D s from the local zeta integral at the Gaussian, holomorphy from the Mellin integral; uses
  `schwartzBruhat_fourier_equiv`. Split into uniqueness, holomorphy and the identity (3.4.3.13).
- **#4070** `exists_schwartzBergman_entireInclusion`, Ch07 Sec1b:651 (L). The inclusion into
  entire functions is evaluation at points; continuity into the compact-open topology from the
  defining seminorms (sup over discs bounded by the Bergman weight).
- **#4072** `exists_schwartzBergman_jetRestriction`, Ch07 Sec1b:679 (L). After #4070: injectivity
  and dense range of the restriction to the quotient dual (Hahn–Banach / Bergman density).
- **#3895** `exists_finiteConnesPrincipalValue`, AppB Sec4b:648 (L). B.4.4.1(1), p. 619:
  integrability of the log-Fourier kernel against the scaled self-dual measure, then continuity
  from the seminorm bound.
- **#4060** `exists_globalPolarThetaMellin`, Ch07 Sec1b:346 (L). Descend the Mellin integral of the
  homogeneous theta through the quotient by ker T; entire from the proved `globalIdelicZFunction`
  continuation.
- **#2837** `euclideanSchwartz_hermite_estimates`, Ch02 Sec1:427 (L/XL). Hermite basis of L² with
  polynomial seminorm growth; Mathlib has Hermite polynomials but not the Hilbert basis. Possibly
  split into basis-in-L² and seminorm estimates.
- **#4447** `heckeEulerProductOutside_eq_finite`, Ch06 Sec3:109 (M). Both sides agree on a half
  plane, so they agree after `toMeromorphicNFOn` (identity theorem, `MeromorphicNFOn` uniqueness).
- **#783** `exists_injectiveTensorCompletion_compactOperatorIsometry`, AppC Sec3a_part2:2887 (XL).
  Prop. C.3.6.4(3): uniform continuity of the injective norm, isometry on finite-rank tensors,
  range = compact operators (check that the approximation property is a hypothesis).
- **#3880** `hasSlowGrowthNearPoles_completedHeckeL_logDeriv`, AppB Sec4b:56 (M). Depends on the
  height bounds of Definition B.3.1.1.
- Also M-size from the last cone list: #3908 (AppB Sec4b:1115), #3872 (AppB Sec6:551), #2798 #2799
  #2800 #2805 (Ch04 Sec6).
