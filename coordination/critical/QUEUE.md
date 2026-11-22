# Critical-path queue for the Opus prover

Built 2026-11-21 ~18:40 CET by the critical-path mapper. The constant graph comes from `scripts/progress/Deps.lean`
at 626d258 (the warm base). The sorry status was re-checked against the text of origin/main 0ef6aa7.
Data: `graph.tsv` (one row per cone node). Blockers: `BLOCKERS.md`. Short work for hunters: `CONE_SHORT.md`.

## How "critical" was decided (read once)

- **Main.lean's own cone is empty.** It imports only `Statements`, which imports only Mathlib, and every
  target is `by sorry`. No library `sorry` is in its closure today. Chapters 10–13 (the trace formula and
  the deduction of GRH) are not digested, and Chapter 13 of the paper states no main theorem. The cone
  is therefore *anchored*:
  - **bridge**: the cone of `completedHeckeL` / `finiteHeckeL` (Ch03/Sec2). They are the only library
    objects built on Mathlib's `HeckeCharacter.LSeries` / `dedekindZeta`, which the Hecke and Dedekind
    targets talk about (31 nodes).
  - **endgame**: nodes reached from the items that Ch.10–13 (pp. 433–522) cite, for example 9.3.3.1,
    9.3.2.1, 9.1.2.14, C.3.6.4, C.3.4.4, D.1.2.1, D.3.3.7, 4.4.1.1 and A.5.4.1 (117 nodes).
  - **anchored**: nodes reached from items cited on pp. 230–394, the undigested Ch.5.2–8 (268 nodes).
  - The anchored cone is 416 sorry nodes in total (411 still sorry on 0ef6aa7). The library has 780
    sorry nodes and 804 open proof issues. A broader cone (anything reached from any digested Ch.2–9
    declaration) has 501 nodes.
  - Of the 411: 363 have a well-formed open issue, 26 only a fragment duplicate, 16 a wrongly closed
    issue, and 6 no issue (BLOCKERS §1–2).
  - Out of the cone are 158 of the 301 appendix sorries and 206 of the 479 chapter sorries:
    digested chapter statements that no later chapter cites and nothing cited uses. The largest such
    groups are in the broad-only rows of `graph.tsv`.
- **Caveat.** The anchors are explicit item numbers cited in the undigested pages. The proof of a
  sorry'd anchor has no edges yet, so what its eventual proof will need is not traced; in that sense
  the cone is a lower bound. Regenerate with the scripts in `/mnt/faststorage/math/riemann-masullo/.agent/wt/crit-map/.agent/`:
  `Deps.lean` dump, then `anchors.py`, `emit.py`, `tipcheck.py` and `write_tsv.py`, about 1 minute after a built tree (the claim and closed-issue annotations were added by hand-run steps).
- **"Dependents"** counts the cone sorries whose statement or proof reaches the node. Most edges go
  through `Classical.choose` / proof fields of definitions (for example `globalIdelicZFunction :=
  (…_exists_continuation f).choose`). So the count measures how many statements *mean something* only
  once the node is proved. It does not measure what blocks a prover, who can cite a sorry'd lemma.
- The order below is depth × leverage × tractability for one agent in about 4 hours. A faithful split
  of an XL node into hunter-sized pieces counts as a win.
- All entries below were checked unclaimed at 18:30 CET: no `claimed` label, no unreleased `Claiming`,
  no open PR. Re-check before claiming.

## Queue

- **Promoted (coordinator, 2026-11-22):** #1223 (PR #3660) and #1219 (PR #3823) are proved, and Ch03 Sec2's own chain no longer uses sorry. `globalIdelicZetaIntegral_exists_continuation` and `completedHeckeL_exists_continuation` still carry sorryAx through four declarations. Take these next, before #1902:
  - `schwartzBruhat_fourier_equiv` (AppD Sec1c:1697; issues #3484/#3792)
  - `lcaCosetIntegral_mem_schwartzBruhat` (AppD Sec1c:1739; #3486/#3792)
  - `schwartzBruhat_poisson` (AppD Sec1c:1761; #3488/#3792)
  - `exists_ratAdeleDualEquiv` (AppA Sec3:3052; #3099/#3703/#3806)
  Several issue numbers per declaration means duplicates: pick the well-formed open one. The new bounds `adelicTheta_normSum_decay_large` and `adelicTheta_normSum_le_small` (Ch02 Sec2a) are the majorant that #1220 and #1222 need.

### 1. #1223 `globalIdelicZetaIntegral_exists_continuation`: Ch03_IdelicZeta/Sec2.lean:662 (XL)
- **Why critical:** this is Tate's thesis, Theorem 3.2.2.1(1)(a), p. 124.
  - Since #3081, `completedHeckeL_exists_continuation` (the continuation of the completed Hecke
    L-function, i.e. of Mathlib's `χ.LSeries` times Γ) is *proved from* this lemma plus two new
    lemmas, `exists_archimedeanHeckeTest` and `exists_globalHeckeTest`. Those two have no issue yet
    (see BLOCKERS).
  - It has 19 cone dependents through `globalIdelicZFunction` and 63 chapter declarations above it. It
    is the single node that most directly links the library to the Hecke/Dedekind targets.
- **Depends on:** nothing open in its statement.
  - **Ordering constraint:** every lemma of the split must sit *above* Sec2:662, because Lean has no
    forward references. `globalIdelicZFunction` (Sec2:671) and everything about it, including
    `globalIdelicZFunction_meromorphic`, are defined *from* this theorem, and `globalThetaMellinIntegral`
    with its lemmas (#1230, #1232, Sec2:769+) come later. None of them can be used here.
  - **Usable inputs:** `adelicTheta_riemannRoch` (Ch02/Sec2a:2306, proved,
    θ(f)(g) = |g|⁻¹θ(f̂)(g⁻¹) + |g|⁻¹f̂(0) − f(0)), `quasiCharacterAbscissa_of_unitary_twist`
    (Ch03/Sec1:550, proved), and the sorry'd siblings above it: `globalIdelicZetaIntegral_integrable`
    (#1219), `_tendstoUniformlyOn` (#1220), `_normBand_entire` (#1221) and `_analyticOn` (#1222).
- **Suggested split (Tate's decomposition):**
  1. Z₊(f,c) := ∫_{|g|≥1} f c dμ is entire in every norm-twist chart, for every c.
  2. On `rightHalf`: Z(f,c) = Z₊(f,c) + Z₊(f̂,ĉ) + [c|C¹ = 1]·vol(C¹)·(f̂(0)/(s_c−1) − f(0)/s_c), where
     c = |·|^{s_c}. Prove it by unfolding to C[F] (Weil's formula for the principal ideles) and
     `adelicTheta_riemannRoch`.
  3. Define Z(c) by the right-hand side. It is intrinsic in c: when c is trivial on C¹, s_c is unique
     because the norm is surjective. Pass to `toMeromorphicNFOn`.
  - Two charts through the same c differ by s ↦ s + it, so the normal forms agree.
  - Each of 1–3 is a hunter- or Opus-sized issue.
- **Reference:** Hanke `NumberFieldKB.GlobalZeta.globalZeta_eq_mellin` (survey/arithmetic.md §3.2).
  Reference copies are not on this machine; the survey has the pinned links.

### 2. #1906 `sLocalQuotientTamagawaMeasure_existsUnique`: Ch03_IdelicZeta/Sec3.lean:502 (M/L, fast)
- **Why critical:** `sLocalQuotientTamagawaMeasure` is `.choose` of it. It has 11 cone dependents (all
  S-local zeta integrals of §3.3) and sits in the endgame tier. Likely the best leverage per hour in
  the queue.
- **Approach:** apply the *proved* `weilQuotientMeasure_existsUnique` (AppD/Sec1a:1618) with
  H = projected S-unit diagonal, μ = `sMultiplicativeTamagawaMeasure F S`, μH = `Measure.count`. You
  need:
  - (a) H closed: copy the argument inline in `sIdeleQuotient_hasNormTwistCharts`, Ch03/Sec1:1324,
    `isClosed_range_unitsMap … hd hc` from `sAdele_additive_quotient`.
  - (b) `DiscreteTopology H`, so that `count` is Haar and Regular.
  - (c) `IsHaarMeasure` / `Regular` for `sMultiplicativeTamagawaMeasure`. It is a `map` of a
    `prod`/`pi` of local Haar measures under a `ContinuousMulEquiv`; check the local measures carry
    the instances.
  - If (b) or (c) is missing, state it as a lemma (that is the split).
- Sibling with the same shape: #1912 `sLocalNormOneQuotientMeasure_existsUnique` (6 deps).
  Do it in the same session if time allows.

### 3. #1902 `sLocalIdelicZetaIntegral_exists_continuation`: Ch03_IdelicZeta/Sec3.lean:471 (XL)
- **Why critical:** Theorem 3.3.1.1(1)(b), the S-local continuation. It defines `sLocalIdelicZFunction`
  (12 cone dependents, 56 chapter declarations above). It feeds the Weil identities of §3.4 and Ch.5.
- **Statement check done:** `∃!` is fine. Every quasi-character of J_S lies on a chart that meets
  `positive`, and NF-meromorphic functions on ℂ that agree on an open set agree everywhere. So
  uniqueness is the identity theorem; prove that half outright.
- **Existence:** the same decomposition as #1 with the S-local theta function, or the local route
  Z_S = ρ_S · Z_S(f̂, ĉ) via `sLocalRhoFactor` (which needs #1890/#1891). Prefer the theta route if
  an S-local Riemann–Roch is available (search Ch02/Sec3–4 for `sLocalAdelicTheta` Poisson
  identities). Otherwise split: (i) uniqueness (prove), (ii) entire part, (iii) polar part, (iv)
  identity on `positive`.

### 4. #1891 `finiteLocalTateFactor_existsUnique`: Ch03_IdelicZeta/Sec3.lean:306 (XL, splits well)
- **Why critical:** `finiteLocalTateFactor` is `.choose` of it, with 18 cone dependents and 72 chapter
  declarations above. This is local Tate theory (3.3.1.3, p. 129).
- **Statement check done:** `IsLocalTateFactor` (Sec3:248) asks for NF-meromorphy in every unitary
  chart plus the local functional equation on `criticalStrip`. The strip is open in every chart, so
  uniqueness follows from `IsLocalTateFactor.eq_div` (proved, Sec3:260), a test with nonzero
  transformed integral, and the identity theorem. Not vacuous.
- **Split:**
  - (a) Uniqueness: prove it now.
  - (b) Tate's commutation lemma Z(f,c)·Z(ĝ,ĉ) = Z(g,c)·Z(f̂,ĉ) on the strip.
  - (c) For each c an explicit test with Z(f̂,ĉ) ≠ 0 and a meromorphic closed form of the ratio:
    unramified uses 𝟙_O, ramified uses χ⁻¹𝟙_{O×} (cf. `finiteStandardGaussian`).
- **Reference:** Hanke `NumberFieldKB.LocalZeta.zetaIntegral_fourierV_eq_gammaFactorV`.

### 5. #1890 `infiniteLocalTateFactor_existsUnique`: Ch03_IdelicZeta/Sec3.lean:300 (XL)
- Same shape as #4 at the archimedean places, with 18 cone dependents.
- Split as in #4. Part (c) is the Gaussian computation: the real places use e^{-πx²} and x·e^{-πx²},
  the complex places use z^m e^{-2π|z|²}. Use Mathlib `Complex.Gamma` integrals; Hanke has
  `zetaIntegral_gaussian_real` and `zetaIntegral_gaussian_complex`.
- If #4 is done first, reuse its (a) and (b) verbatim.

### 6. #3099 `exists_ratAdeleDualEquiv`: AppA_AlgebraicNT/Sec3.lean:2892 (XL, bridge tier, 11 dependents)
- **Why critical:** self-duality of 𝔸_ℚ under the standard character. The adelic Fourier transform and
  Tamagawa self-duality hang on it.
- **Split:**
  - (a) ℝ ≃ Pontryagin dual via x ↦ e^{2πixy}: `ForMathlib/Topology/Algebra/PontryaginDual/Real.lean`.
  - (b) ℚ_p ≃ its dual via the standard character, with ℤ_p its own annihilator.
  - (c) Restricted-product assembly: `ForMathlib/Topology/Algebra/PontryaginDual/Pi.lean`,
    `…/RestrictedProduct/TopologicalSpace.lean`, and `…/PontryaginDual/Separation.lean`.
- See also the split of finite-local Tamagawa self-duality in #3141 (d9c9272) for local lemmas
  already stated.

### 7. #2607 `exists_hardySobolevTranslation`: Ch09_HardySobolev/Sec3.lean:44 (L)
- **Why critical:** Definition 9.3.1.1 is the regular representation on the compact-interval
  Hardy–Sobolev space. Ch.10 cites §9.3.1 four times and 9.3.3.1 seven times. It has 8 cone
  dependents (`hardySobolevTranslation` is `.choose` of it).
- **Approach:** construct ρ g on the weighted L² model of §9.2 as composition with left translation.
  You need measure preservation (left Haar) and the weight being translation-compatible on [a,b].
  Joint continuity comes from strong continuity of translation in L² (Mathlib: continuity of
  `Lp` translation for regular Haar measures, via density of `C_c`) plus uniform boundedness on
  compacts.
- **Warning:** Ch09 `Lβ`/`ModulatedExponentialDecay` coercions have elaboration blow-ups (#2614).
  Bound builds with `timeout`.

### 8. #2628 `exists_hardySobolevConvolution`: Ch09_HardySobolev/Sec3.lean:350 (L)
- §9.3.3.1 is the most-cited item of Ch.10–12 (7 citations), with 4 cone dependents.
- **Approach:** Young's inequality for a bounded compactly supported kernel on the weighted L² model.
  Build A u := φ ⋆ u with an a.e. integrability statement, then show linearity and boundedness
  (`ContinuousLinearMap` via `LinearMap.mkContinuous`).
- Do it after #7 if possible: it may reuse ρ.

### 9. #2609 `exists_bruhatRegularizedAction`: Ch09_HardySobolev/Sec3.lean:77 (M/L)
- Remark 9.3.1.2, with 6 cone dependents (`bruhatRegularizedAction`).
- For complete E and a continuous representation, g ↦ φ(g)·ρ g u is continuous with compact support,
  so its Bochner integral exists and is the Pettis integral. Linearity in φ follows from
  `integral_add`.
- **Same warning as #7:** `Lβ E` coercions are slow. Build the map as `LinearMap` first, then coerce.

### 10. #1047 `sAdeleSchwartz_toGlobal_mem` + #1042 `sAdeleSchwartz_transition_mem`: Ch02_AdelicTheta/Sec1.lean:2830, 2758 (M, batch)
- #1047 is in the bridge tier with 9 dependents (`sAdeleSchwartzToGlobal` is built from it); #1042
  has 4 dependents.
- **Approach:** extension by the indicator of ∏_{v∉S} O_v. Use the private helpers in the *same
  file*: `finitePlace_mem_of_locallyConstant_compactSupport` (Sec1:1796), `finitePlace_mem_cyclicStage`
  and `finitePlace_mem_characterStage`.
- Hunters could also do these; queue them only if 1–9 are taken.

### 11. #2514, #2516, #2518 standard Gaussians `_mem`: Ch03_IdelicZeta/Sec4.lean:464, 499, 527 (M, batch)
- Bridge tier, with 6, 5 and 3 dependents. They feed `gaussianCompletedHeckeL_eq_completedHeckeL`
  (Ch03/Sec4 is downstream of Sec2, so they cannot be used by the Sec2 Hecke-test lemmas; they are
  needed by Ch03/Sec4 and Ch.5 instead).
- **#2514:** `mem_archimedeanSchwartzBruhat_iff` (Ch02/Sec2b:250, proved) reduces it to Schwartz
  decay of x^k e^{-πx²} and z^m e^{-2π|z|²}.
- **#2516:** a locally constant compactly supported function. The Ch02/Sec1 helper is `private`, so
  reprove the small lemma locally.
- **#2518:** restricted tensor of #2514 and #2516.

### 12. #1230 `globalThetaMellinIntegral_integrable` + #1232 `globalThetaMellinIntegral_eq_idelic`: Ch03/Sec2.lean:769, 784 (L)
- These are Theorem 3.2.2.1(2) and (3.2.2.11), the theta-side half of Tate's theorem.
- They sit *after* #1223 and `globalIdelicZFunction`, so they cannot feed #1223's proof. They are
  side branches of the cone: take them only once 1–11 are taken.

## Next, once an issue exists (integrator must open them; see BLOCKERS §1)

- `exists_archimedeanHeckeTest` and `exists_globalHeckeTest` (Ch03/Sec2:695, 704, L each). Together
  with #1223 they finish `completedHeckeL_exists_continuation`. Ch03/Sec4 (the Gaussians of #11,
  Weil's identity 3.4.1.6) imports Sec2, so none of it can be cited here. The tests must be built
  inside Sec2 above line 695 (or Sec1 / Ch02): local Gaussians, the local zeta integrals of 𝟙_O and
  χ⁻¹𝟙_{O×}, and an Euler-product factorization of the global integral of a pure tensor.
- `exists_lcaAutocorrelation_measure` and `lcaAutocorrelation_measure_mul_lintegral`
  (AppD/Sec1a:1125, 1140, from the Plancherel split #3374). They have 11 bridge-tier dependents
  through `exists_lcaFourier_eLpNorm_eq_of_hasCompactSupport`.
- `schwartzBruhat_translate_mem` (AppD/Sec1c:1712, **36 cone dependents**, the most in the endgame
  tier). Its original issue #862 was wrongly closed; only the fragment duplicate #3279 is open.
  Translation invariance of the Bruhat space is probably M/L via the stage presentation. #864, its
  continuity companion, is claimed by mccorvie (PR #3376).
- `schwartzBruhat_fourier_equiv` (AppD/Sec1c:1491, XL, 11 dependents): issue #848 was wrongly
  closed.

## Deliberately not queued

- #1205, #1206, #1207 and #864 are claimed by the integrator's codex provers (PRs #3085, #3116 and
  #3376).
- #1208 `completedHeckeL_continuation_zeros` is in the bridge tier but no target needs it: the
  targets only concern 0 < Re s < 1. It is also XL (nonvanishing on Re = 1).
- #2663 `modulatedCyclicDifference_isLinearMap_continuous` (19 dependents) and the rest of Ch04
  Sec5/Sec6 hit known elaboration timeouts (see BLOCKERS §3).
- Weil-identity XLs #2503, #2504, #2505 and the AppC Schatten/tensor XLs #781, #782, #783 are in
  the cone but have 0 dependents. They come after the above.
