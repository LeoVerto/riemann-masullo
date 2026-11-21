# Short-looking unclaimed issues inside the critical-path cone (for the Sonnet hunters)

Built 2026-11-21 ~18:50 CET. All of these are open, well-formed issues. At 18:30 CET none had a
`claimed` label, an unreleased `Claiming` or an open PR. Re-check before claiming (HUNTER.md loop step 1).
"Tier" and "deps" (cone sorries resting on the node) are from `graph.tsv`; see QUEUE.md for the definitions.

Hunters already mined most of Ch02, Ch03 and AppD for one-liners. What is left here needs a few to 20
lines of thought, usually citing a sorry'd sibling (allowed).

## Bridge tier (directly on the path to the Hecke/Dedekind targets)

| issue | decl | file:line | deps | why short / hint |
|---|---|---|---|---|
| #2514 | `infiniteStandardGaussian_mem` | Ch03_IdelicZeta/Sec4.lean:464 | 6 | `mem_archimedeanSchwartzBruhat_iff` (Ch02/Sec2b:250, proved, imported) reduces it to Schwartz decay of `x^k e^{-πx²}` and `z^m e^{-2π|z|²}`. |
| #2516 | `finiteStandardGaussian_mem` | Ch03_IdelicZeta/Sec4.lean:499 | 5 | A locally constant compactly supported function on a local field. The Ch02/Sec1 helper `finitePlace_mem_of_locallyConstant_compactSupport` is `private`, so copy its proof into a local helper. |
| #2518 | `adelicStandardGaussian_mem` | Ch03_IdelicZeta/Sec4.lean:527 | 3 | Restricted tensor of #2514 and #2516 (citable). Do it after them. |
| #1047 | `sAdeleSchwartz_toGlobal_mem` | Ch02_AdelicTheta/Sec1.lean:2830 | 9 | Same file as the private helpers `finitePlace_mem_of_locallyConstant_compactSupport`, `finitePlace_mem_cyclicStage` and `finitePlace_mem_characterStage`. Also listed as queue item 10 for the Opus prover; whoever is first takes it. |

## Endgame tier (cited by Ch.10–12)

| issue | decl | file:line | deps | why short / hint |
|---|---|---|---|---|
| #1783 | `bruhatCompactSupport_le_modulatedExponentialDecay` | AppD_SchwartzBruhat/Sec3b.lean:426 | 5 | Compact support gives every exponential-decay seminorm finite. Unfold the two submodules. |
| #1779 | `bruhatCompactSupportStage_realization_mem` | AppD_SchwartzBruhat/Sec3b.lean:377 | 14 | Stage realization of a compactly supported stage function. Probably unfolds to support ⊆ preimage of a compact set. Check `bruhatCompactSupportSubmodule`'s definition first. |
| #1769 | `quasiCharacter_mem_bruhatSmooth` | AppD_SchwartzBruhat/Sec3b.lean:170 | 1 | A quasi-character is smooth in Bruhat's sense: it factors through Lie quotients as exp of a linear map. Medium. |
| #2553 | `modulatedCyclicExponential_mem` | Ch04_PeriodicSchauderBases/Sec4.lean:408 | 5 | A character on a compact quotient is Schwartz–Bruhat (continuous on a compact group). Sec4, not the timeout-prone Sec5/Sec6. |
| #1924 | `sLocalRhoFactor_norm_criticalLine` | Ch03_IdelicZeta/Sec3.lean:643 | 0 | Combine the siblings #1921 `_mul_dual`, #1922 `_conj` and #1923 `_analyticAt_criticalLine` (all citable): the codiscrete identities give the value on a dense set, and continuity on the line gives the rest. |
| #2619 | `measurable_hardySobolevTranslation_norm` | Ch09_HardySobolev/Sec3.lean:189 | 0 | g ↦ ‖ρ g‖ is a sup of continuous functions (joint continuity from the `.choose_spec` of `exists_hardySobolevTranslation`), so it is lower semicontinuous and hence measurable. Watch Ch09 elaboration (#2614). |

## Anchored tier (cited by Ch.5.2–8)

| issue | decl | file:line | deps | why short / hint |
|---|---|---|---|---|
| #2515 | `infiniteStandardGaussian_trivial_zero` | Ch03_IdelicZeta/Sec4.lean:478 | 0 | Evaluation at 0 of `infiniteStandardGaussianValue w 1`: split on `w.IsReal`, then simp. |
| #1236 | `globalThetaMellinIntegral_eq_continuation_of_vanishing` | Ch03_IdelicZeta/Sec2.lean:812 | 0 | Identity theorem. `globalThetaMellinIntegral_entire_of_vanishing` (Sec2:806) and `globalThetaMellinIntegral_eq_idelic` (#1232) can be cited; `globalIdelicZFunction_eq_integral` gives agreement on `rightHalf`. Then use NF uniqueness chart by chart. |
| #1900 | `sLocalRhoFactor_meromorphic` | Ch03_IdelicZeta/Sec3.lean:410 | 0 | Finite product of local Tate factors, each NF-meromorphic in its charts (from `.choose_spec` of #1890/#1891, citable). You may need a small lemma that the restriction of an S-chart is a local chart. |
| #2360, #2361 | `globalIdelicZFunction_mem`, `_isLinear` | Ch05_ThetaZSpaces/Sec1.lean:159, 164 | 5 each | Membership in the meromorphic Z-space follows from the pole bounds of Ch03 (citable). Linearity comes from uniqueness of NF continuation (the sum of continuations continues the sum). |
| #2366, #2367 | `sLocalIdelicZFunction_mem`, `_isLinear` | Ch05_ThetaZSpaces/Sec1.lean:211, 216 | 6 each | The S-local version of the pair above; same proofs. |
| #2797 | `modulatedPeriodicMomentIndex_enumerable` | Ch04_PeriodicSchauderBases/Sec6.lean:348 | 0 | `Nonempty (ℕ ≃ J)` for a countably infinite index type (`Denumerable` / `nonempty_equiv_of_countable`). No Schwartz–Bruhat arithmetic, but Sec6 has build hangs: use the fail-fast rule. |

## Not listed on purpose

- **#1212 `finiteHeckeL_exists_continuation`** (Ch03/Sec2:505) looks like "completed continuation
  times Γ⁻¹". But `completedHeckeL_exists_continuation` (Sec2:713) and #1223 (Sec2:662) both come
  *after* it in the file, so a proof cannot cite them. As placed it is as hard as Tate's theorem; see
  BLOCKERS §4.

- **Ch04/Sec5–Sec6 `_apply` / `_mem` lemmas** (#2781, #2782, #2794, #2806, #2669 …) look short but hit
  the #1288-class elaboration timeouts (LeoVerto's release notes). See BLOCKERS §3.
- **Claimed by marozols since about 03:00 UTC with no PR:** #1946, #1947, #1948, #1951 (Ch04/Sec2,
  endgame tier) and #1827, #1831 (AppB/Sec2). Ask for a release before pointing hunters there.
- **In-cone sorries whose issues were wrongly closed** (for example `schwartzBruhat_translate_mem`,
  36 deps): they need the integrator to reopen them first (BLOCKERS §2).
