# Blockers on the critical path: decisions for the integrator

Built 2026-11-21 ~18:45 CET by the critical-path mapper. Graph at 626d258; sorry status checked
against origin/main 0ef6aa7; issues as of 18:25 CET. Node data is in `graph.tsv`.

## 0. Structural: Main.lean depends on nothing in the library

- `Main.lean` imports only `Statements`, which is pure Mathlib. All 7 targets are `by sorry`, so the
  literal cone of the targets contains **0** library sorries. `QUEUE.md` uses an anchored cone
  instead; the definition is at its top.
- **There is no library bridge to 4 of the 7 targets.** No declaration under `RiemannMasullo/`
  mentions `riemannZeta`, `DirichletCharacter.LFunction` or `completedRiemannZeta`. I checked this by
  scanning every constant's type and value with a metaprogram. So `riemannHypothesis`,
  `riemannZeta_eq_zero_re` and the three Dirichlet targets need statements nobody has digested:
  - ζ = ζ_ℚ, or ζ as the Hecke L-function of the trivial character of ℚ;
  - Dirichlet characters as finite-order Hecke characters of ℚ, with matching L-series;
  - "zeros of the continuation" ↔ zeros of Mathlib's `LFunction` for 0 < Re s < 1.
- **The Hecke and Dedekind bridges are short but unstated.**
  - The library's `completedHeckeL χ` / `finiteHeckeL χ` for `χ : PontryaginDual C[F]` are built on
    Mathlib's `(ideleClassNormTwist χ 0).LSeries`. `completedHeckeL_one_eq_dedekindZeta` is proved.
  - Missing statements:
    - (a) every Mathlib `HeckeCharacter (𝓞 K) K` with `‖χ x‖ = 1` equals `ideleClassNormTwist χ' 0`
      for some unitary χ';
    - (b) any meromorphic continuation in the `Statements` sense agrees with the library's NF
      continuation, giving `meromorphicOrderAt` equality on ℂ (identity theorem);
    - (c) Γ-factor nonvanishing in the strip, which is proved (`heckeGammaFactor_ne_zero_of_re_pos`).
- **The paper has no endgame theorem to aim at.**
  - Ch.13 (pp. 521–522) has headings only. It records the trace formula 13.3.1.1, whose spectral
    side counts zeros on σ = 1/2 with N_spec(c) = min{N(c), [F:Q]}, and refers to "Theorem ??".
  - survey/endgame.md records that the Montel extraction of §1.4.3 / §1.8.4.3 fails for the printed
    test family.
  - Ch.10–12 are not seeded. So everything in QUEUE.md is "on the path" only in the sense that the
    endgame chapters cite it.

## 1. Sorries with no issue at all: please open issues (run `scripts/issues.py --apply` once §2 is understood)

These are still sorry on 0ef6aa7. Most come from splits merged today.

| decl | file:line | from | tier, dependents |
|---|---|---|---|
| `exists_archimedeanHeckeTest` | Ch03_IdelicZeta/Sec2.lean:695 | split #3081 of #1204 | bridge. With #1223 it is all `completedHeckeL_exists_continuation` waits on |
| `exists_globalHeckeTest` | Ch03_IdelicZeta/Sec2.lean:704 | split #3081 | bridge, same |
| `exists_lcaAutocorrelation_measure` | AppD_SchwartzBruhat/Sec1a.lean:1125 | Plancherel split #3374 | bridge, 11 |
| `lcaAutocorrelation_measure_mul_lintegral` | AppD_SchwartzBruhat/Sec1a.lean:1140 | #3374 | bridge, 11 |
| `completedHeckeL_continuation_epsilon_norm` | AppB_AnalyticNT/Sec1.lean:1948 | AppB Sec1 splits (#3380 area) | bridge, 0 |
| `heckeGammaRatio_isBigO_on_strip` | AppB_AnalyticNT/Sec1.lean:2328 | same | bridge, 0 |

## 2. Issue-tracker damage: live sorries whose issues were closed at 15:23–15:27 UTC today

- **Counts.**
  - Across the whole library, **124 live sorry declarations** have their well-formed issue closed
    ("completed") between 15:23 and 15:27 UTC 2026-11-21 and no well-formed open issue.
  - The fragment-titled batch #3183–#3322 was opened at 15:16–15:21 UTC; **132** of its issues are
    still open (reported by the hunters on #3230).
  - **61 of the 124 are in the cone** (bridge 4, endgame 8, anchored 31; plus 18 broad-only).
  - The same run did both, apparently while parsing a stale or shifted base: the bodies cite
    commit 6dd7aa4 and lines that are not sorry lines.
- **Recommendation** (from timestamps, not a diagnosis):
  - Reopen the closed originals.
  - Close the fragment duplicates.
  - Do not rerun `issues.py --apply` until the cause is understood.
  - The prover brief needs a well-formed issue number, so none of these can be queued until they
    are reopened.
- **The most damaging cases:**
  - `schwartzBruhat_translate_mem` (#862 closed; only fragment #3279 open). It has **36 cone
    dependents**, the most of any endgame node.
  - `schwartzBruhat_fourier_equiv` (#848, 11 dependents).
  - `homogeneousAdelicTheta_continuous` (#1286, 8 dependents).
  - `homogeneousAdelicTheta_isLinear`: #1288 is closed although the sorry is live. That is where the
    instance-timeout report (§3) lives.

Full in-cone list (the "(weak match)" rows were paired with a fragment issue by snippet only):

| decl | file:line | closed original (UTC) | open fragment duplicate | tier | dependents |
|---|---|---|---|---|---|
| `schwartzBruhat_fourier_equiv` | AppD_SchwartzBruhat/Sec1c.lean:1491 | #848 15:25 | - | bridge | 11 |
| `lcaCosetIntegral_mem_schwartzBruhat` | AppD_SchwartzBruhat/Sec1c.lean:1533 | #850 15:25 | #3268 | bridge | 2 |
| `schwartzBruhatCosetIntegral_mk` | AppD_SchwartzBruhat/Sec1c.lean:1544 | #851 15:25 | #3269 | bridge | 0 |
| `schwartzBruhat_poisson` | AppD_SchwartzBruhat/Sec1c.lean:1553 | #852 15:25 | #3271 | bridge | 0 |
| `schwartzBruhat_translate_mem` | AppD_SchwartzBruhat/Sec1c.lean:1712 | #862 15:24 | #3279 | endgame | 36 |
| `exists_euclidean_localHomeomorph` | AppD_SchwartzBruhat/Sec1b.lean:240 | #2046 15:23 | - | endgame | 6 |
| `isLocallyEuclidean_of_discrete_torus_kernel` | AppD_SchwartzBruhat/Sec1b.lean:344 | #2190 15:23 | - | endgame | 6 |
| `pontryaginDual_mem_bruhatSmooth` | AppD_SchwartzBruhat/Sec1c.lean:1290 | #837 15:25 | #3256 | endgame | 4 |
| `exists_countable_traceNorm_dense` | AppC_LCTVS/Sec3a.lean:2791 | #582 15:26 | - | endgame | 0 |
| `tendsto_traceNorm_mul_finiteRank` | AppC_LCTVS/Sec3a.lean:2801 | #583 15:26 | - | endgame | 0 |
| `schwartzBruhatStage_transition` | AppD_SchwartzBruhat/Sec1b.lean:2955 | #718 15:26 | #3235 | endgame | 0 |
| `homogeneousAdelicTheta_continuous` | Ch02_AdelicTheta/Sec2b.lean:1026 | #1286 15:24 | - | anchored | 8 |
| `schwartzBruhat_isBruhatSmooth` | AppD_SchwartzBruhat/Sec1b.lean:3022 | #722 15:26 | #3244 | anchored | 4 |
| `homogeneousAdelicTheta_isLinear` | Ch02_AdelicTheta/Sec2b.lean:1045 | #1288 15:24 | #3302 | anchored | 2 |
| `sLocalIdeleFundamentalDomain_precompact` | AppA_AlgebraicNT/Sec2b.lean:2587 | #304 15:27 | #3221 (weak match) | anchored | 0 |
| `sLocalIdeleFundamentalDomain_interior` | AppA_AlgebraicNT/Sec2b.lean:2592 | #305 15:27 | #3221 (weak match) | anchored | 0 |
| `sLocalIdeleFundamentalDomain_cover` | AppA_AlgebraicNT/Sec2b.lean:2599 | #306 15:27 | #3221 (weak match) | anchored | 0 |
| `sLocalIdeleFundamentalDomain_disjoint` | AppA_AlgebraicNT/Sec2b.lean:2605 | #307 15:27 | #3221 (weak match) | anchored | 0 |
| `sLocalIdeleFundamentalDomain_finite_translates` | AppA_AlgebraicNT/Sec2b.lean:2611 | #308 15:27 | #3221 (weak match) | anchored | 0 |
| `sIdeleFundamentalDomain_precompact` | AppA_AlgebraicNT/Sec2b.lean:2626 | #309 15:27 | #3221 (weak match) | anchored | 0 |
| `sIdeleFundamentalDomain_interior` | AppA_AlgebraicNT/Sec2b.lean:2633 | #310 15:27 | #3221 (weak match) | anchored | 0 |
| `sIdeleFundamentalDomain_cover` | AppA_AlgebraicNT/Sec2b.lean:2640 | #311 15:27 | #3221 (weak match) | anchored | 0 |
| `sIdeleFundamentalDomain_disjoint` | AppA_AlgebraicNT/Sec2b.lean:2649 | #312 15:27 | #3221 (weak match) | anchored | 0 |
| `eventually_trivial_sIdealClassGroup` | AppA_AlgebraicNT/Sec2b.lean:2656 | #313 15:26 | #3221 (weak match) | anchored | 0 |
| `sIdeleClassGroup_equiv_of_classNumberOne` | AppA_AlgebraicNT/Sec2b.lean:2663 | #314 15:26 | #3222 (weak match) | anchored | 0 |
| `exists_rat_prime_idele_outside` | AppA_AlgebraicNT/Sec2b.lean:2676 | #315 15:26 | #3221 (weak match) | anchored | 0 |
| `summableLocallyUniformlyOn_expPoleTerms` | AppB_AnalyticNT/Sec4a.lean:746 | #2336 15:23 | - | anchored | 0 |
| `inv_one_sub_exp_eq_mittagLeffler` | AppB_AnalyticNT/Sec4a.lean:751 | #2337 15:23 | - | anchored | 0 |
| `norm_tsum_expPoleTerms_le` | AppB_AnalyticNT/Sec4a.lean:757 | #2338 15:23 | - | anchored | 0 |
| `tsum_norm_expPoleTerms_le` | AppB_AnalyticNT/Sec4a.lean:766 | #2339 15:23 | - | anchored | 0 |
| `schwartzBruhat_t2` | AppD_SchwartzBruhat/Sec1b.lean:3032 | #724 15:25 | #3231 | anchored | 0 |
| `schwartzBruhat_barrelled` | AppD_SchwartzBruhat/Sec1b.lean:3209 | #727 15:25 | #3247 | anchored | 0 |
| `schwartzBruhat_bornological` | AppD_SchwartzBruhat/Sec1b.lean:3215 | #728 15:25 | #3248 | anchored | 0 |
| `schwartzBruhat_complete` | AppD_SchwartzBruhat/Sec1b.lean:3222 | #729 15:25 | - | anchored | 0 |
| `schwartzBruhat_strongDual_complete` | AppD_SchwartzBruhat/Sec1b.lean:3227 | #730 15:25 | - | anchored | 0 |
| `schwartzBruhat_nuclear` | AppD_SchwartzBruhat/Sec1b.lean:3232 | #731 15:25 | - | anchored | 0 |
| `schwartzBruhat_strongDual_nuclear` | AppD_SchwartzBruhat/Sec1b.lean:3237 | #732 15:25 | - | anchored | 0 |
| `schwartzBruhat_reflexive` | AppD_SchwartzBruhat/Sec1b.lean:3257 | #735 15:25 | #3249 | anchored | 0 |
| `schwartzBruhat_quasiComplete` | AppD_SchwartzBruhat/Sec1b.lean:3347 | #745 15:25 | - | anchored | 0 |
| `schwartzBruhat_kernel_equiv` | AppD_SchwartzBruhat/Sec1c.lean:1598 | #856 15:24 | - | anchored | 0 |
| `schwartzBruhat_strongDual_kernel_equiv` | AppD_SchwartzBruhat/Sec1c.lean:1608 | #857 15:24 | #3274 | anchored | 0 |
| `schwartzBruhat_dirac_support` | AppD_SchwartzBruhat/Sec1c.lean:1640 | #858 15:24 | #3260 | anchored | 0 |
| `homogeneousAdelicTheta_integrable` | Ch02_AdelicTheta/Sec2b.lean:1021 | #1285 15:24 | - | broad-only | 0 |
| `homogeneousAdelicTheta_idele_continuous` | Ch02_AdelicTheta/Sec2b.lean:1152 | #1290 15:24 | - | broad-only | 0 |
| `homogeneousAdelicTheta_idele_homogeneous` | Ch02_AdelicTheta/Sec2b.lean:1157 | #1291 15:24 | - | broad-only | 0 |
| `homogeneousAdelicTheta_eq_idele_integral` | Ch02_AdelicTheta/Sec2b.lean:1164 | #1292 15:24 | #3303 | broad-only | 0 |
| `homogeneousAdelicTheta_homogeneous` | Ch02_AdelicTheta/Sec2b.lean:1174 | #1293 15:24 | - | broad-only | 0 |
| `homogeneousAdelicTheta_decay_large` | Ch02_AdelicTheta/Sec2b.lean:1180 | #1294 15:24 | #3304 | broad-only | 0 |
| `homogeneousAdelicTheta_decay_small` | Ch02_AdelicTheta/Sec2b.lean:1201 | #1296 15:24 | - | broad-only | 0 |
| `homogeneousAdelicTheta_directionalDeriv` | Ch02_AdelicTheta/Sec2b.lean:1209 | #1297 15:24 | - | broad-only | 0 |
| `homogeneousAdelicTheta_archimedean_smooth` | Ch02_AdelicTheta/Sec2b.lean:1221 | #1299 15:24 | - | broad-only | 0 |
| `homogeneousAdelicTheta_decay_both` | Ch02_AdelicTheta/Sec2b.lean:1236 | #1300 15:24 | - | broad-only | 0 |
| `homogeneousAdelicTheta_decay_bounded` | Ch02_AdelicTheta/Sec2b.lean:1251 | #1301 15:24 | - | broad-only | 0 |
| `homogeneousAdelicTheta_decay_bounded_threshold_one` | Ch02_AdelicTheta/Sec2b.lean:1264 | #1302 15:24 | - | broad-only | 0 |
| `adeleDirectionalDeriv_preserves_polarSubspace` | Ch02_AdelicTheta/Sec2b.lean:938 | #1279 15:24 | - | broad-only | 0 |
| `adelePolarValues_surjective` | Ch02_AdelicTheta/Sec2b.lean:943 | #1280 15:24 | - | broad-only | 0 |
| `adeleDirectionalDeriv_polarQuotient_diagonal` | Ch02_AdelicTheta/Sec2b.lean:948 | #1281 15:24 | #3293 | broad-only | 0 |
| `adeleDirectionalDeriv_fourier_tendsto` | Ch02_AdelicTheta/Sec2b.lean:962 | #1282 15:24 | - | broad-only | 0 |
| `adeleDirectionalDeriv_fourier_integral` | Ch02_AdelicTheta/Sec2b.lean:975 | #1283 15:24 | #3296 | broad-only | 0 |
| `adeleDirectionalDeriv_fourier_tendstoUniformlyOn` | Ch02_AdelicTheta/Sec2b.lean:998 | #1284 15:24 | #3298 | broad-only | 0 |

## 3. Infrastructure: elaboration timeouts (#1288 class)

`+`, `-` and `•` on `SchwartzBruhat` / `ModulatedExponentialDecay` values, and `Lβ` coercions, can
time out (consolidated on #1288, which is now wrongly closed, see §2). The cone nodes in the
affected files:

- **Ch04/Sec5: 23 cone nodes.**
  - These include #2663 `modulatedCyclicDifference_isLinearMap_continuous` (**19 dependents**, the
    top anchored node), #2658 (6), #2651 (5), #2669 (4) and #2670 (3).
  - Hunter notes on #2841, #2842, #2710 and #2686 sketch workarounds. Nothing has landed.
- **Ch04/Sec6: 22 cone nodes.**
  - Top: #2783 (9), #2793 (6), #2795 (3).
  - A batch hung the Sec6 build (heavy `rfl`). LeoVerto's release notes on #2781, #2794 and #2806 say
    the obvious unfold-and-rewrite proof does not elaborate.
- **Ch02/Sec2b:** `homogeneousAdelicTheta_continuous` / `_isLinear` (see §2).
- **Ch09/Sec3:** #2614 `modulatedExponentialDecayTestAction_apply`: the `choose_spec` term never
  finishes elaborating (probably `Lβ (ModulatedExponentialDecay m I)` coercions). The queued Ch09
  items (#2607, #2609, #2628) carry a warning.
- **Decision needed:** a structural fix, such as explicit `AddCommGroup`/`Module` instances or
  `irreducible_def` wrappers for these function spaces. This is infrastructure, so it is the
  integrator's call; per-lemma workarounds keep failing.

## 4. Statement status of the known suspects

- #561 `hilbert_approximationProperty`, #429, #434 (`ApproxProp`): **not in the anchored cone**.
  #3330 repaired the approximation property using precompact convergence. #561 is claimed by a codex
  prover (17:07). Nothing to decide for the critical path.
- #1229 (`globalIdelicZFunction` area): an integrator note says it was false before 5e0c7c1 (sign of
  `padicStandardCharacter`, ERRATA F13) and is fixed. Provers on Tate items must work on a tree
  after 5e0c7c1; any fresh worktree is.
- `completedHeckeL_continuation_simplePoles` (#1206, claimed): `TODO(paper-gap)` records that the
  printed residues in Prop. 3.2.1.3(2) disagree with the Euler-product normalization. The statement
  avoids them. No action needed.
- **#1212 `finiteHeckeL_exists_continuation` is misplaced** (Ch03/Sec2:505). Its natural proof is
  `completedHeckeL_exists_continuation` (Sec2:713) times `(heckeGammaFactor χ)⁻¹`, made normal form.
  That lemma, and #1223 (Sec2:662) behind it, are later in the file. Since #3081 moved the completed
  continuation below `globalIdelicZFunction`, #1212 can only be proved by redoing Tate's theorem.
  - Suggest moving `finiteHeckeL_exists_continuation` below Sec2:713. #1214 and #1215 take the
    continuation as a hypothesis and can stay where they are. Moving a statement is the integrator's
    call.
- **Checked and fine:** the `∃!` predicates of #1890, #1891 (`IsLocalTateFactor`: NF-meromorphy in
  every chart plus the functional equation on the open critical strip), #1902, #2170, #2172 and #1906
  (`IsWeilQuotientMeasure` includes Haar and Regular). Uniqueness follows from the identity theorem
  or Weil's uniqueness, and none of them is vacuous.
- **`stuck` issues:**
  - #3250, #3308, #3185, #3186 and #3187 are all from the fragment batch.
  - #3250 `norm_hilbertTrace_le` is not a sorry declaration at 626d258, so it is stale.
  - Close them with the batch (§2).
- **Stale claims:** marozols holds `Claiming` on #1946, #1947, #1948, #1951, #1827 and #1831 since
  02:43–03:52 UTC, with no PR. Some are short and in the cone (Ch04/Sec2, endgame tier). The
  coordinator could ask for a release.
