# Critical-path queue for the Opus prover

Rebuilt 2026-11-22 by the critical-path mapper (previous queue: `QUEUE-2026-11-21.md`, all of it closed upstream).
Constant graph from `scripts/progress/Deps.lean` at 23cbb63 (warm base; origin/main was 453a2b8), sorry status checked
textually against origin/main, open `proof` issues / claims / open PRs / sweep issues read from GitHub on 2026-11-22.
Data: `graph.tsv` (every anchored-cone sorry, column `status` = QUEUE or the exclusion reason). Short work: `CONE_SHORT.md`.

## How "critical" was decided
Same pipeline as before (see QUEUE-2026-11-21.md): the cone is anchored (bridge = cone of `completedHeckeL`/`finiteHeckeL`;
endgame = items cited on pp. 433-522; anchored = items cited on pp. 230-394). Caveat: `anchors.py` still treats only
Ch.2-4, 5.1, 9, A-D as digested, so Ch.5.2-8 are still "the undigested region" even though digested now; the cone is a lower bound.
- The anchored cone shrank from 416 to 91 sorry nodes (88 still sorry, with an open proof issue). The library has 436 sorry nodes.
- Of the 88: 46 claimed (44 by `claimed` label, 2 by a live Claiming comment), 15 in ERRATA.md, 3 held by open sweeps
  (Ch02 Sec3/Sec4, AppD Sec1c/1d, ...), 3 next to `TODO(paper-gap)` (#3891, #3878, #2654), leaving 21; the 12 best are below.
- "Dependents" is now small (max 3): most of the former hubs are proved. Rank = dependents, then chapter declarations above, then size.
- Checked unclaimed 2026-11-22 (no claimed label, no unreleased Claiming, no open PR naming the issue). Re-check before claiming.
- Open sweeps on 2026-11-22 hold: AppD Sec1c, Sec1d, Sec3a_part2; Ch05 Sec2; Ch03 Sec2; AppA Sec3; Ch02 Sec3, Sec4; AppB Sec1.

## Queue

1. #1526 `modulatedExponentialDecayStage_separable`: AppD_SchwartzBruhat/Sec3a.lean:4745 (M). 3 dependents, 17 chapter decls above.
   Route: the stage is a subspace of a separable metrizable/Fréchet space of functions on an interval; give a countable dense
   family (rational-coefficient polynomial-times-exponential or compactly supported smooth) or embed in a second-countable space.
2. #2526 `infiniteEigendistribution_normalized`: Ch03_IdelicZeta/Sec4.lean:3211 (L). 23 chapter decls above.
   Route: existence/uniqueness of the eigendistribution D s from the local zeta integral at the Gaussian, holomorphy in s
   from the Mellin integral; uses `schwartzBruhat_fourier_equiv` (now proved). Split: uniqueness, holomorphy, meromorphic identity (3.4.3.13).
3. #2667 `modulatedCyclicDifference_isClosed_range`: Ch04_PeriodicSchauderBases/Sec5.lean:826 (M). 9 chapter decls above.
   Route: Prop 4.5.1.1(6): Δ is a Fourier multiplier on isotypic pieces; closed range from a bounded left inverse off the kernel.
4. #4070 `exists_schwartzBergman_entireInclusion`: Ch07_SchauderBasesZeta/Sec1b.lean:651 (L). 1 dependent (#4072), 7 above.
   Route: the inclusion Aℂ -> Entire is evaluation at points; show continuity into the compact-open topology from the
   defining seminorms (sup over discs controlled by the Bergman weight).
5. #4072 `exists_schwartzBergman_jetRestriction`: Ch07 Sec1b.lean:679 (L). Do after #4070 (uses its inclusion): injectivity + dense range of the restriction to the quotient dual (Hahn-Banach / Bergman density).
6. #3895 `exists_finiteConnesPrincipalValue`: AppB_AnalyticNT/Sec4b.lean:648 (L). 2 dependents.
   Route: B.4.4.1(1), p. 619: integrability of the log-Fourier kernel against the scaled self-dual measure, then continuity of f -> integral from the seminorm bound.
7. #3899 `exists_finiteWeilTestMap`: AppB Sec4b.lean:782 (L). 2 dependents. Route: weighted translate of a zero-extended test is a locally constant compactly supported function; continuity in the inductive-limit topology of 𝒟(units).
8. #4060 `exists_globalPolarThetaMellin`: Ch07 Sec1b.lean:346 (L). Route: descend the Mellin integral of homogeneous theta through the quotient by ker T; entire in s from `globalIdelicZFunction` continuation (proved).
9. #2837 `euclideanSchwartz_hermite_estimates`: Ch02_AdelicTheta/Sec1.lean:427 (L/XL). Hermite basis of L2 with polynomial seminorm growth; check Mathlib/External SURVEY first (`Mathlib` has Hermite polynomials but not the Hilbert basis); may split into basis-in-L2 and seminorm estimates.
10. #4447 `heckeEulerProductOutside_eq_finite`: Ch06_LocalGlobal/Sec3.lean:109 (M). Identity of meromorphic normal forms: both sides agree on the half plane, so they agree after `toMeromorphicNFOn` (identity theorem; `MeromorphicNFOn` uniqueness).
11. #783 `exists_injectiveTensorCompletion_compactOperatorIsometry`: AppC_LCTVS/Sec3a_part2.lean:2887 (XL). Prop C.3.6.4(3): splits into uniform continuity of the injective norm, isometry on finite-rank tensors, range = compact operators (approximation property needed: check it is a hypothesis).
12. #3880 `hasSlowGrowthNearPoles_completedHeckeL_logDeriv`: AppB Sec4b.lean:56 (M). 0 dependents but bridge tier; depends on the height bounds of Definition B.3.1.1.

Also free, cone, 0 dependents (see graph.tsv): #3749 (AppB Sec5:367), #3872/#3875/#3877 (AppB Sec6), #3908 (AppB Sec4b:1115),
#2526 neighbours #2798/#2799/#2800/#2805 (Ch04 Sec6), #2837 above.
