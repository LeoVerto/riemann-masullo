module

public import RiemannMasullo.AppB_AnalyticNT.Sec5
import Mathlib.Algebra.Field.ULift
import Mathlib.NumberTheory.Real.Irrational
import Mathlib.Analysis.Complex.LocallyUniformLimit
import RiemannMasullo.External.TauCeti.Analysis.Complex.Runge.Approximation

/-!
# Appendix B.5: statements that are false as printed

The printed claims are kept as propositions with separate refutation statements.
Nothing imports this file.
-/

@[expose] public noncomputable section

open Filter Function IsDedekindDomain MeasureTheory NumberField Set
open Complex.HadamardThreeLines (verticalStrip)
open scoped Topology

namespace RiemannMasullo

/-- Paper: §B.5.1, injectivity sentence, p. 627. As printed: in every positive
dimension, the torus flow of rationally independent frequencies is injective.
This is the injectivity clause of the sentence. The repaired
`torusFlow_injective_of_linearIndependent` requires dimension at least two.
See ERRATA F19. -/
def Printed.torusFlow_injective_of_linearIndependent : Prop :=
  ∀ (N : ℕ), 1 ≤ N → ∀ (τ : Fin N → ℝ), LinearIndependent ℚ τ → Injective (torusFlow τ)

/-- Paper: §B.5.1, injectivity sentence, p. 627. In dimension one the
single frequency `1` is rationally independent, and times zero and one have the same
image modulo one. -/
theorem Printed.torusFlow_injective_of_linearIndependent_false :
    ¬ Printed.torusFlow_injective_of_linearIndependent := by
  intro h
  have hli : LinearIndependent ℚ (fun _ : Fin 1 ↦ (1 : ℝ)) :=
    linearIndependent_unique_iff.mpr one_ne_zero
  have h01 :
      torusFlow (fun _ : Fin 1 ↦ (1 : ℝ)) 1 = torusFlow (fun _ : Fin 1 ↦ (1 : ℝ)) 0 := by
    rw [torusFlow_one, map_zero]
    funext i
    exact AddCircle.coe_period (1 : ℝ)
  exact one_ne_zero (h 1 le_rfl _ hli h01)

/-- Paper: Theorem B.5.2.1(2), p. 627. As printed: for every frequency vector
and every Riemann-integrable function on its orbit closure, the forward time average
in (B.5.2.1) exists and tends to the Haar probability integral. The forward equality
requires the time integrals to exist for all sufficiently large endpoints.
The repaired `kroneckerWeyl_riemannIntegrable_forward` assumes a measurable time
trace. See ERRATA F20. -/
def Printed.kroneckerWeyl_riemannIntegrable_forward : Prop :=
  ∀ (N : ℕ) [NeZero N] (τ : Fin N → ℝ)
    (μ : Measure (torusFlowClosure τ)) [μ.IsAddHaarMeasure] [IsProbabilityMeasure μ]
    (u : torusFlowClosure τ → ℂ), TorusRiemannIntegrable μ u →
      let trace := fun t ↦ u (torusFlowInClosure τ t)
      (∀ᶠ T : ℝ in atTop, IntervalIntegrable trace volume 0 T) ∧
        Tendsto (fun T : ℝ ↦ T⁻¹ • ∫ t in 0..T, trace t) atTop (𝓝 (∫ x, u x ∂μ))

private theorem Printed.kroneckerWeyl_rat_functional :
    ∃ g : ℝ →ₗ[ℚ] ℚ, ∀ q : ℚ, g (q : ℝ) = q := by
  let f : ℚ →ₗ[ℚ] ℝ := LinearMap.toSpanSingleton ℚ ℝ (1 : ℝ)
  have hf (q : ℚ) : f q = (q : ℝ) := by simp [f, Rat.smul_one_eq_cast]
  have hk : LinearMap.ker f = ⊥ := LinearMap.ker_eq_bot.mpr fun a b hab ↦ by
    rw [hf, hf] at hab; exact_mod_cast hab
  obtain ⟨g, hg⟩ := f.exists_leftInverse_of_injective hk
  refine ⟨g, fun q ↦ ?_⟩
  have := LinearMap.congr_fun hg q
  rwa [LinearMap.comp_apply, hf] at this

open scoped Pointwise in
private theorem Printed.kroneckerWeyl_not_nullMeasurable_ker (g : ℝ →ₗ[ℚ] ℚ)
    (hg : ∀ q : ℚ, g (q : ℝ) = q) :
    ¬ ∀ n : ℕ, NullMeasurableSet ({x | g x = 0} ∩ Icc (-(n : ℝ)) n) volume := by
  intro hA
  set A : Set ℝ := {x | g x = 0} with hAdef
  have hAU : A = ⋃ n : ℕ, A ∩ Icc (-(n : ℝ)) n := by
    ext x
    simp only [mem_iUnion, mem_inter_iff, mem_Icc]
    refine ⟨fun hx ↦ ?_, fun ⟨_, hx, _⟩ ↦ hx⟩
    obtain ⟨n, hn⟩ := exists_nat_ge |x|
    exact ⟨n, hx, neg_le_of_abs_le hn, le_of_abs_le hn⟩
  by_cases h0 : ∀ n : ℕ, volume (A ∩ Icc (-(n : ℝ)) n) = 0
  · have hA0 : volume A = 0 := by rw [hAU]; exact measure_iUnion_null h0
    have hcover : (univ : Set ℝ) = ⋃ q : ℚ, (fun x ↦ x + -(q : ℝ)) ⁻¹' A := by
      ext x
      simp only [mem_univ, mem_iUnion, mem_preimage, true_iff]
      refine ⟨g x, ?_⟩
      change g (x + -(g x : ℝ)) = 0
      rw [map_add, map_neg, hg, add_neg_cancel]
    have : volume (univ : Set ℝ) = 0 := by
      rw [hcover]
      refine measure_iUnion_null fun q ↦ ?_
      rw [measure_preimage_add_right]
      exact hA0
    simp at this
  · push Not at h0
    obtain ⟨n, hn⟩ := h0
    obtain ⟨M, hMs, hMm, hMae⟩ := (hA n).exists_measurable_subset_ae_eq
    have hMpos : 0 < volume M := by rw [measure_congr hMae]; exact pos_iff_ne_zero.mpr hn
    have hMfin : volume M ≠ ⊤ := ((measure_mono (hMs.trans inter_subset_right)).trans_lt
      measure_Icc_lt_top).ne
    have hnhds := Measure.sub_mem_nhds_zero_of_addHaar_pos_ne_top volume M hMm hMpos hMfin
    obtain ⟨δ, hδ, hball⟩ := Metric.mem_nhds_iff.mp hnhds
    obtain ⟨q, hq0, hqδ⟩ := exists_rat_btwn hδ
    have hqmem : (q : ℝ) ∈ M - M := hball (by
      rw [Metric.mem_ball, Real.dist_eq, sub_zero, abs_of_pos hq0]; exact hqδ)
    obtain ⟨a, ha, b, hb, hab⟩ := hqmem
    have ha' : g a = 0 := (hMs ha).1
    have hb' : g b = 0 := (hMs hb).1
    have : g (q : ℝ) = 0 := by rw [← hab, map_sub, ha', hb', sub_self]
    rw [hg] at this
    exact (Rat.cast_pos.mp hq0).ne' this

private theorem Printed.kroneckerWeyl_exists_nonmeasurable :
    ∃ L : ℝ, 0 < L ∧ ∃ E : Set ℝ, E ⊆ Ioc 0 L ∧ ¬ NullMeasurableSet E volume := by
  obtain ⟨g, hg⟩ := Printed.kroneckerWeyl_rat_functional
  have h := Printed.kroneckerWeyl_not_nullMeasurable_ker g hg
  push Not at h
  obtain ⟨n, hn⟩ := h
  set A : Set ℝ := {x | g x = 0} ∩ Icc (-(n : ℝ)) n
  refine ⟨2 * n + 1, by positivity, (fun x ↦ x + -((n : ℝ) + 1)) ⁻¹' A, ?_, fun hE ↦ hn ?_⟩
  · intro x hx
    obtain ⟨-, h1, h2⟩ := hx
    constructor <;> linarith
  · have hpre : A = (fun x ↦ x + ((n : ℝ) + 1)) ⁻¹' ((fun x ↦ x + -((n : ℝ) + 1)) ⁻¹' A) := by
      ext x; simp only [mem_preimage, add_neg_cancel_right]
    rw [hpre]
    exact hE.preimage (measurePreserving_add_right volume _).quasiMeasurePreserving

private theorem Printed.kroneckerWeyl_measure_arc_eq_zero {G : Type*} [AddCommGroup G]
    [TopologicalSpace G] [IsTopologicalAddGroup G] [T2Space G] [MeasurableSpace G] [BorelSpace G]
    (μ : Measure G) [μ.IsAddLeftInvariant] [IsFiniteMeasure μ]
    (φ : ℝ →+ G) (hφc : Continuous φ) (hφ : Injective φ) (L : ℝ) (hL : 0 ≤ L) :
    μ (φ '' Icc 0 L) = 0 := by
  set K := φ '' Icc 0 L
  have hKm : MeasurableSet K := ((isCompact_Icc).image hφc).isClosed.measurableSet
  let P : ℕ → Set G := fun k ↦ (fun h ↦ φ (-((k : ℝ) * (L + 1))) + h) ⁻¹' K
  have hPm (k : ℕ) : MeasurableSet (P k) := measurable_const_add _ hKm
  have hPμ (k : ℕ) : μ (P k) = μ K := measure_preimage_add μ _ K
  have hdisj : Pairwise (Disjoint on P) := by
    intro j k hjk
    refine Set.disjoint_left.mpr fun x hxj hxk ↦ hjk ?_
    obtain ⟨s, ⟨hs0, hsL⟩, hs⟩ := hxj
    obtain ⟨s', ⟨hs0', hsL'⟩, hs'⟩ := hxk
    have heq : φ (s - s') = φ (((k : ℝ) - j) * (L + 1)) := by
      have e1 : φ s = φ (-((j : ℝ) * (L + 1))) + x := hs
      have e2 : φ s' = φ (-((k : ℝ) * (L + 1))) + x := hs'
      rw [map_sub, e1, e2, show ((k : ℝ) - j) * (L + 1) = -((j : ℝ) * (L + 1)) - -((k : ℝ) * (L + 1)) by ring,
        map_sub]
      abel
    have h := hφ heq
    rcases lt_trichotomy j k with hlt | heq' | hgt
    · have : (j : ℝ) + 1 ≤ k := by exact_mod_cast hlt
      nlinarith
    · exact heq'
    · have : (k : ℝ) + 1 ≤ j := by exact_mod_cast hgt
      nlinarith
  by_contra hne
  have hU := measure_iUnion (μ := μ) hdisj hPm
  simp only [hPμ, ENNReal.tsum_const_eq_top_of_ne_zero hne] at hU
  exact measure_ne_top μ (⋃ k, P k) hU

private theorem Printed.kroneckerWeyl_linearIndependent_sqrt_two :
    LinearIndependent ℚ ![(1 : ℝ), √2] := by
  rw [LinearIndependent.pair_iff]
  intro s t hst
  rw [Rat.smul_def, Rat.smul_def, mul_one] at hst
  by_cases ht : t = 0
  · subst ht
    simp only [Rat.cast_zero, zero_mul, add_zero, Rat.cast_eq_zero] at hst
    exact ⟨hst, rfl⟩
  · exfalso
    have ht' : (t : ℝ) ≠ 0 := by exact_mod_cast ht
    have h2 : √2 = ((-s / t : ℚ) : ℝ) := by
      push_cast
      field_simp
      linarith
    exact irrational_sqrt_two ⟨_, h2.symm⟩

/-- Paper: Theorem B.5.2.1(2), p. 627. Take frequencies `(1, √2)` and a
non-Lebesgue-measurable subset `E` of `(0, 1)`. The indicator of the image of `E`
under the flow is bounded and continuous off the compact Haar-null orbit arc of
`[0, 1]`. Injectivity makes its time trace the indicator of `E`, which is
nonmeasurable on every interval `[0, T]` with `T ≥ 1`. -/
theorem Printed.kroneckerWeyl_riemannIntegrable_forward_false :
    ¬ Printed.kroneckerWeyl_riemannIntegrable_forward := by
  intro h
  obtain ⟨L, hL, E, hE, hnm⟩ := Printed.kroneckerWeyl_exists_nonmeasurable
  set τ : Fin 2 → ℝ := ![(1 : ℝ), √2]
  have hinj : Injective (torusFlowInClosure τ) := fun s t hst ↦
    RiemannMasullo.torusFlow_injective_of_linearIndependent le_rfl
      Printed.kroneckerWeyl_linearIndependent_sqrt_two (congrArg Subtype.val hst)
  let φ : ℝ →+ torusFlowClosure τ :=
    { toFun := torusFlowInClosure τ
      map_zero' := Subtype.ext (map_zero (torusFlow τ))
      map_add' := fun s t ↦ Subtype.ext (map_add (torusFlow τ) s t) }
  have hφc : Continuous φ := (torusFlow τ).continuous.subtype_mk _
  have : CompactSpace (torusFlowClosure τ) := isCompact_iff_compactSpace.mp
    (AddSubgroup.isClosed_topologicalClosure _).isCompact
  let μ : Measure (torusFlowClosure τ) := Measure.addHaarMeasure ⊤
  have : IsProbabilityMeasure μ := ⟨Measure.addHaarMeasure_self⟩
  set K := φ '' Icc 0 L with hKdef
  have hK0 : μ K = 0 :=
    Printed.kroneckerWeyl_measure_arc_eq_zero μ φ hφc hinj L hL.le
  have hKc : IsClosed K := ((isCompact_Icc).image hφc).isClosed
  have hEK : φ '' E ⊆ K := image_mono fun x hx ↦ Ioc_subset_Icc_self (hE hx)
  let u : torusFlowClosure τ → ℂ := (φ '' E).indicator fun _ ↦ 1
  have hu : TorusRiemannIntegrable μ u := by
    refine ⟨⟨1, fun x ↦ ?_⟩, ?_⟩
    · by_cases hx : x ∈ φ '' E <;> simp [u, hx]
    · filter_upwards [measure_eq_zero_iff_ae_notMem.mp hK0] with x hx
      refine continuousAt_const.congr (f := fun _ ↦ (0 : ℂ)) ?_
      filter_upwards [hKc.isOpen_compl.mem_nhds hx] with y hy
      exact (indicator_of_notMem (fun h ↦ hy (hEK h)) _).symm
  have htrace : (fun t ↦ u (torusFlowInClosure τ t)) = E.indicator fun _ ↦ (1 : ℂ) := by
    funext t
    by_cases ht : t ∈ E
    · have : torusFlowInClosure τ t ∈ φ '' E := ⟨t, ht, rfl⟩
      simp [u, ht, this]
    · have : torusFlowInClosure τ t ∉ φ '' E := fun ⟨s, hs, hst⟩ ↦ ht (hinj hst ▸ hs)
      simp [u, ht, this]
  have hint := (h 2 τ μ u hu).1
  obtain ⟨T, hT, hLT⟩ := (hint.and (eventually_ge_atTop L)).exists
  rw [htrace] at hT
  have hmeas := (hT.1).aestronglyMeasurable.aemeasurable
  have hET : E ⊆ Ioc 0 T := fun x hx ↦ ⟨(hE hx).1, (hE hx).2.trans hLT⟩
  rw [← aemeasurable_indicator_iff measurableSet_Ioc, indicator_indicator,
    inter_eq_right.mpr hET, aemeasurable_indicator_const_iff] at hmeas
  exact hnm hmeas

/-- Paper: Proposition B.5.3.2(1),(3), p. 632. As printed: for every number field,
finite set of places containing the archimedean places, and continuous character
unramified at its finite places, there are heights with both stated signs and a common
finite bound on the product in (B.5.3.3) for every integer index. The bound is written
as a positive lower bound on the norm of the product of the denominators, so it
excludes zeros of every denominator. These two sign conditions and the bound are
the clauses at issue. The repaired
`exists_heights_reciprocalPartialHeckeEulerProduct_boundedBelow` allows a positive
height at index zero. See ERRATA F21. -/
def Printed.exists_heights_reciprocalPartialHeckeEulerProduct_boundedBelow : Prop :=
  ∀ (F : Type*) [Field F] [NumberField F]
    (S : Finset (HeightOneSpectrum (𝓞 F))) (χ : PontryaginDual (IdeleClassGroup (𝓞 F) F)),
    (∀ v ∈ S, (ideleClassNormTwist χ 0).IsUnramifiedAt v) →
      ∃ (c : ℝ) (T : ℤ → ℝ), 0 < c ∧
        (∀ k, 0 ≤ k → 0 ≤ T k) ∧ (∀ k, k ≤ 0 → T k ≤ 0) ∧
        ∀ k, c ≤ ‖reciprocalPartialHeckeEulerProduct χ S ((T k : ℂ) * Complex.I)‖

/-- Every number field refutes the printed bound: the trivial character has a zero
factor at time zero. -/
private theorem
    Printed.exists_heights_reciprocalPartialHeckeEulerProduct_boundedBelow_false_of_numberField.{u}
    (F : Type u) [Field F] [NumberField F]
    (h : Printed.exists_heights_reciprocalPartialHeckeEulerProduct_boundedBelow.{u}) : False := by
  obtain ⟨m, hm⟩ := Ideal.exists_maximal (𝓞 F)
  let v : HeightOneSpectrum (𝓞 F) := ⟨m, hm.isPrime, NeZero.ne m⟩
  have hone :
      ∀ g, ideleClassNormTwist (1 : PontryaginDual (IdeleClassGroup (𝓞 F) F)) 0 g = 1 := by
    intro g
    change ((1 : Circle) : ℂ) * (_ : ℂ) ^ (0 : ℂ) = 1
    simp
  have hres : ∀ x : v.adicCompletion F, x ≠ 0 →
      (ideleClassNormTwist (1 : PontryaginDual (IdeleClassGroup (𝓞 F) F)) 0).restrict v x =
        1 := by
    intro x hx
    rw [show x = ((Units.mk0 x hx : (v.adicCompletion F)ˣ) : v.adicCompletion F) from rfl,
      HeckeCharacter.restrict, MulChar.ofUnitHom_coe]
    simp [hone]
  have hunr :
      (ideleClassNormTwist (1 : PontryaginDual (IdeleClassGroup (𝓞 F) F)) 0).IsUnramifiedAt
        v := by
    rw [HeckeCharacter.isUnramifiedAt_iff]
    intro x
    exact hres _ (by simp)
  obtain ⟨c, T, hc, hpos, hneg, hbound⟩ := h F {v} 1 (by simpa using hunr)
  have hT : T 0 = 0 := le_antisymm (hneg 0 le_rfl) (hpos 0 le_rfl)
  have h0 := hbound 0
  rw [hT, reciprocalPartialHeckeEulerProduct_singleton _ v hunr,
    hunr.localValue_eq _ Valued.v.exists_isUniformizer_of_isCyclic_of_nontrivial.choose_spec,
    hres _ (Valued.v.exists_isUniformizer_of_isCyclic_of_nontrivial.choose_spec.ne_zero)] at h0
  simp at h0
  linarith

/-- Paper: Proposition B.5.3.2(1),(3), p. 632. Take the rational field,
the trivial character, and the places consisting of infinity and the prime above two.
Both sign conditions apply at index zero, so `T 0 = 0`. The only finite factor
in the denominator is then `|1 - 2^0| = 0`. -/
theorem Printed.exists_heights_reciprocalPartialHeckeEulerProduct_boundedBelow_false :
    ¬ Printed.exists_heights_reciprocalPartialHeckeEulerProduct_boundedBelow := by
  intro h
  have : CharZero (ULift ℚ) := ⟨fun a b hab ↦ by simpa using congrArg ULift.down hab⟩
  have : NumberField (ULift ℚ) := ⟨⟩
  exact
    Printed.exists_heights_reciprocalPartialHeckeEulerProduct_boundedBelow_false_of_numberField
      (ULift ℚ) h

/-- Paper: Lemma B.5.3.4(2), p. 633. As printed: if a holomorphic function on a
bounded nonempty open vertical strip is strongly recurrent on every closed disc it
contains, then the function is strongly recurrent on every compact subset of the strip.
Part (1) is `stronglyRecurrentOn_of_subset`. See ERRATA F22. -/
def Printed.stronglyRecurrentOn_compact_of_closedBall : Prop :=
  ∀ (a b : ℝ), a < b → ∀ (f : ℂ → ℂ), DifferentiableOn ℂ f (verticalStrip a b) →
    (∀ (z : ℂ) (r : ℝ), 0 ≤ r → Metric.closedBall z r ⊆ verticalStrip a b →
      StronglyRecurrentOn f (Metric.closedBall z r)) →
    ∀ (K : Set ℂ), IsCompact K → K ⊆ verticalStrip a b → StronglyRecurrentOn f K

open Complex in
/-- Horizontally convex compact sets have connected complement. -/
private theorem Printed.recurrentCompact_hconn (K : Set ℂ) (M : ℝ) (hM0 : 0 < M)
    (hM : ∀ z ∈ K, |z.re| < M ∧ |z.im| < M)
    (hconv : ∀ z ∈ K, ∀ w ∈ K, z.im = w.im → ∀ x : ℝ, z.re ≤ x → x ≤ w.re →
      ((x : ℂ) + (z.im : ℂ) * I) ∈ K) : IsConnected Kᶜ := by
  classical
  have hy_eq (y : ℂ) : (y.re : ℂ) + (y.im : ℂ) * I = y := Complex.re_add_im y
  set z0 : ℂ := (0 : ℂ) + (M : ℂ) * I
  have hz0 : z0 ∉ K := fun h ↦ by
    have := (hM _ h).2; simp [z0, abs_of_pos hM0] at this
  refine ⟨⟨z0, hz0⟩, isPreconnected_of_forall z0 fun y hy ↦ ?_⟩
  let P : Prop := ∃ w ∈ K, w.im = y.im ∧ y.re < w.re
  set σ : ℝ := if P then -M else M with hσ
  have hσM : |σ| = M := by
    by_cases hP : P <;> simp [hσ, hP, abs_of_pos hM0]
  let t1 : Set ℂ := (fun x : ℝ ↦ (x : ℂ) + (y.im : ℂ) * I) '' uIcc y.re σ
  let t2 : Set ℂ := (fun s : ℝ ↦ (σ : ℂ) + (s : ℂ) * I) '' uIcc y.im M
  let t3 : Set ℂ := (fun x : ℝ ↦ (x : ℂ) + (M : ℂ) * I) '' uIcc σ 0
  have c1 : Continuous fun x : ℝ ↦ (x : ℂ) + (y.im : ℂ) * I := by fun_prop
  have c2 : Continuous fun s : ℝ ↦ (σ : ℂ) + (s : ℂ) * I := by fun_prop
  have c3 : Continuous fun x : ℝ ↦ (x : ℂ) + (M : ℂ) * I := by fun_prop
  have p1 : IsPreconnected t1 := isPreconnected_uIcc.image _ c1.continuousOn
  have p2 : IsPreconnected t2 := isPreconnected_uIcc.image _ c2.continuousOn
  have p3 : IsPreconnected t3 := isPreconnected_uIcc.image _ c3.continuousOn
  have a12 : (σ : ℂ) + (y.im : ℂ) * I ∈ t1 ∩ t2 :=
    ⟨⟨σ, right_mem_uIcc, rfl⟩, ⟨y.im, left_mem_uIcc, rfl⟩⟩
  have a23 : (σ : ℂ) + (M : ℂ) * I ∈ (t1 ∪ t2) ∩ t3 :=
    ⟨Or.inr ⟨M, right_mem_uIcc, rfl⟩, ⟨σ, left_mem_uIcc, rfl⟩⟩
  refine ⟨t1 ∪ t2 ∪ t3, ?_, Or.inr ⟨0, right_mem_uIcc, by simp [z0]⟩,
    Or.inl (Or.inl ⟨y.re, left_mem_uIcc, hy_eq y⟩),
    (p1.union _ a12.1 a12.2 p2).union _ a23.1 a23.2 p3⟩
  rintro _ ((⟨x, hx, rfl⟩ | ⟨s, hs, rfl⟩) | ⟨x, hx, rfl⟩) hK
  · dsimp only at hK
    have hxM := (hM _ hK).1
    simp only [add_re, ofReal_re, mul_re, I_re, mul_zero, ofReal_im, I_im, mul_one,
      sub_self, add_zero] at hxM
    rw [mem_uIcc] at hx
    rcases lt_trichotomy x y.re with hlt | heq | hgt
    · by_cases hP : P
      · obtain ⟨w, hw, hwi, hwr⟩ := hP
        have h1 := hconv _ hK w hw (by simp [hwi]) y.re (by simp; linarith) (by
          linarith)
        have h2 : (y.re : ℂ) + (y.im : ℂ) * I ∈ K := by simpa using h1
        exact hy (by rwa [hy_eq] at h2)
      · simp only [hσ, hP, ite_false] at hx
        rcases hx with ⟨h1, h2⟩ | ⟨h1, h2⟩
        · linarith
        · rw [abs_lt] at hxM; linarith
    · exact hy (by rw [heq, hy_eq] at hK; exact hK)
    · by_cases hP : P
      · simp only [hσ, hP, ite_true] at hx
        rw [abs_lt] at hxM
        rcases hx with ⟨h1, h2⟩ | ⟨h1, h2⟩ <;> linarith
      · exact hP ⟨_, hK, by simp, by simpa using hgt⟩
  · have := (hM _ hK).1
    simp [hσM] at this
  · have := (hM _ hK).2
    simp [abs_of_pos hM0] at this

open Complex in
/-- Membership in a closed disc centred on the imaginary axis. -/
private theorem Printed.recurrentCompact_mem_ball_iff_sq (c : ℤ) (ρ : ℝ) (hρ : 0 ≤ ρ) (z : ℂ) :
    z ∈ Metric.closedBall ((c : ℂ) * I) ρ ↔ z.re ^ 2 + (z.im - c) ^ 2 ≤ ρ ^ 2 := by
  rw [Metric.mem_closedBall, dist_eq, ← sq_le_sq₀ (norm_nonneg _) hρ, Complex.sq_norm,
    normSq_apply]
  simp only [sub_re, mul_re, intCast_re, I_re, mul_zero, intCast_im, I_im, mul_one, sub_self,
    sub_zero, sub_im, mul_im]
  constructor <;> intro h <;> nlinarith

open Complex in
/-- Runge approximation on finitely many vertically separated discs centred on `iℤ`. -/
private theorem Printed.recurrentCompact_runge_slots (S : Finset ℤ) (ρ : ℤ → ℝ) (τ : ℤ → ℂ → ℂ)
    (hτ : ∀ h, Differentiable ℂ (τ h)) (hρ : ∀ h, 0 ≤ ρ h)
    (hsep : ∀ h ∈ S, ∀ h' ∈ S, h ≠ h' → ρ h + ρ h' + 1 / 4 < |(h : ℝ) - h'|)
    {e : ℝ} (he : 0 < e) :
    ∃ p : Polynomial ℂ, ∀ h ∈ S, ∀ z ∈ Metric.closedBall ((h : ℂ) * I) (ρ h),
      ‖τ h z - p.eval z‖ < e := by
  classical
  let B : ℤ → Set ℂ := fun h ↦ {z | |z.im - h| < ρ h + 1 / 8}
  have hBo (h : ℤ) : IsOpen (B h) :=
    isOpen_lt (by fun_prop) continuous_const
  have hdisj : ∀ h ∈ S, ∀ h' ∈ S, ∀ z, z ∈ B h → z ∈ B h' → h = h' := by
    intro h hh h' hh' z hz hz'
    by_contra hne
    have := hsep h hh h' hh' hne
    have h3 : |(h : ℝ) - h'| ≤ |z.im - h| + |z.im - h'| := by
      rw [abs_sub_comm z.im]; exact abs_sub_le _ _ _
    simp only [B, mem_ofPred_eq] at hz hz'
    linarith
  have hball (h : ℤ) (z : ℂ) (hz : z ∈ Metric.closedBall ((h : ℂ) * I) (ρ h)) :
      |z.re| ≤ ρ h ∧ |z.im - h| ≤ ρ h := by
    rw [Printed.recurrentCompact_mem_ball_iff_sq _ _ (hρ h)] at hz
    constructor <;> apply abs_le_of_sq_le_sq _ (hρ h) <;> nlinarith [sq_nonneg z.re,
      sq_nonneg (z.im - h)]
  let K : Set ℂ := ⋃ h ∈ S, Metric.closedBall ((h : ℂ) * I) (ρ h)
  let U : Set ℂ := ⋃ h ∈ S, B h
  let g : ℂ → ℂ := fun z ↦ ∑ h ∈ S, (B h).indicator (τ h) z
  have hg_eq : ∀ h ∈ S, ∀ z ∈ B h, g z = τ h z := by
    intro h hh z hz
    simp only [g]
    rw [Finset.sum_eq_single h (fun h' hh' hne ↦ ?_) (fun hn ↦ (hn hh).elim),
      indicator_of_mem hz]
    exact indicator_of_notMem (fun hz' ↦ hne (hdisj h' hh' h hh z hz' hz)) _
  have hK : IsCompact K := S.isCompact_biUnion fun h _ ↦ isCompact_closedBall _ _
  have hU : IsOpen U := isOpen_biUnion fun h _ ↦ hBo h
  have hKU : K ⊆ U := by
    intro z hz
    simp only [K, mem_iUnion] at hz
    obtain ⟨h, hh, hz⟩ := hz
    exact mem_biUnion hh (show |z.im - h| < ρ h + 1 / 8 by linarith [(hball h z hz).2])
  have hg : DifferentiableOn ℂ g U := by
    intro z hz
    simp only [U, mem_iUnion] at hz
    obtain ⟨h, hh, hz⟩ := hz
    refine ((hτ h z).congr_of_eventuallyEq ?_).differentiableWithinAt
    filter_upwards [(hBo h).mem_nhds hz] with w hw using hg_eq h hh w hw
  set M : ℝ := 1 + ∑ h ∈ S, (|(h : ℝ)| + ρ h)
  have hterm (h : ℤ) (hh : h ∈ S) : |(h : ℝ)| + ρ h < M := by
    have := Finset.single_le_sum (f := fun h : ℤ ↦ |(h : ℝ)| + ρ h)
      (fun i _ ↦ add_nonneg (abs_nonneg _) (hρ i)) hh
    linarith
  have hM0 : 0 < M := by
    have := Finset.sum_nonneg (s := S) (f := fun h : ℤ ↦ |(h : ℝ)| + ρ h)
      (fun i _ ↦ add_nonneg (abs_nonneg _) (hρ i))
    linarith
  have hconnK : IsConnected Kᶜ := by
    refine Printed.recurrentCompact_hconn K M hM0 ?_ ?_
    · intro z hz
      simp only [K, mem_iUnion] at hz
      obtain ⟨h, hh, hz⟩ := hz
      obtain ⟨h1, h2⟩ := hball h z hz
      have := hterm h hh
      refine ⟨by linarith [abs_nonneg (h : ℝ)], ?_⟩
      have : |z.im| ≤ |(h : ℝ)| + |z.im - h| := by
        have := abs_add_le (h : ℝ) (z.im - h); simpa using this
      linarith
    · intro z hz w hw hzw x hzx hxw
      simp only [K, mem_iUnion] at hz hw ⊢
      obtain ⟨h, hh, hz⟩ := hz
      obtain ⟨h', hh', hw⟩ := hw
      have hhh : h = h' := by
        by_contra hne
        have := hsep h hh h' hh' hne
        have h3 : |(h : ℝ) - h'| ≤ |z.im - h| + |w.im - h'| := by
          rw [hzw, abs_sub_comm w.im]; exact abs_sub_le _ _ _
        linarith [(hball h z hz).2, (hball h' w hw).2]
      subst hhh
      refine ⟨h, hh, ?_⟩
      rw [Printed.recurrentCompact_mem_ball_iff_sq _ _ (hρ h)] at hz hw ⊢
      simp only [add_re, ofReal_re, mul_re, I_re, mul_zero, ofReal_im, I_im, mul_one,
        sub_self, add_zero, add_im, mul_im, zero_add]
      rw [hzw] at hz
      have : x ^ 2 ≤ max (z.re ^ 2) (w.re ^ 2) := by
        rcases le_total 0 x with h0 | h0
        · exact (pow_le_pow_left₀ h0 hxw 2).trans (le_max_right _ _)
        · exact (by nlinarith : x ^ 2 ≤ z.re ^ 2).trans (le_max_left _ _)
      rcases le_total (z.re ^ 2) (w.re ^ 2) with h4 | h4
      · rw [max_eq_right h4] at this; rw [hzw]; linarith
      · rw [max_eq_left h4] at this; rw [hzw]; linarith
  obtain ⟨p, hp⟩ :=
    (hK.isConnected_compl_iff_forall_differentiableOn_exists_polynomial_norm_sub_lt).mp
      hconnK U hU hKU g hg e he
  refine ⟨p, fun h hh z hz ↦ ?_⟩
  have := hp z (mem_biUnion hh hz)
  rwa [hg_eq h hh z (show |z.im - h| < ρ h + 1 / 8 by linarith [(hball h z hz).2])] at this

open Complex in
/-- Integer gaps give real gaps. -/
private theorem Printed.recurrentCompact_int_abs_cast (h h' k : ℤ) (H : k ≤ h - h' ∨ k ≤ h' - h) :
    (k : ℝ) ≤ |(h : ℝ) - h'| := by
  have : k ≤ |h - h'| := by
    rcases H with H | H
    · exact le_abs.mpr (Or.inl H)
    · exact le_abs.mpr (Or.inr (by linarith))
  exact_mod_cast this

open Complex in
/-- One stage of the inductive construction of ERRATA F22. -/
private theorem Printed.recurrentCompact_stage_exists (n : ℕ) (b : ℤ) (q : Polynomial ℂ) :
    ∃ p : Polynomial ℂ,
    (∀ z ∈ Metric.closedBall (0 : ℂ) (4 * 2 ^ n - 2), ‖q.eval z - p.eval z‖ < (1 / 2) ^ (n + 2)) ∧
    (∀ m : ℕ, 2 ^ n ≤ m → m + 1 < 2 ^ (n + 1) →
      ∀ w ∈ Metric.closedBall (((b : ℝ) / 8 : ℝ) * I) (3 / 4),
        ‖q.eval w - p.eval (w + (((4 * m + 2 : ℝ) - b / 8 : ℝ) : ℂ) * I)‖ < (1 / 2) ^ (n + 2)) ∧
    (∀ j : ℕ, 2 ^ n ≤ j → j < 2 ^ (n + 1) →
      ‖4 - p.eval (((4 * j : ℝ) : ℂ) * I)‖ < (1 / 2) ^ (n + 2) ∧
      ‖4 - p.eval (((-(4 * j) : ℝ) : ℂ) * I)‖ < (1 / 2) ^ (n + 2)) := by
  classical
  set L : ℕ := 2 ^ n with hL
  have hL1 : 1 ≤ L := Nat.one_le_two_pow
  let S : Finset ℤ := {0} ∪ (Finset.Ico L (2 * L - 1)).image (fun m : ℕ ↦ (4 * m + 2 : ℤ)) ∪
    (Finset.Ico L (2 * L)).image (fun j : ℕ ↦ (4 * j : ℤ)) ∪
    (Finset.Ico L (2 * L)).image (fun j : ℕ ↦ (-(4 * j) : ℤ))
  let ρ : ℤ → ℝ := fun h ↦ if h = 0 then 4 * 2 ^ n - 2 else if h % 4 = 2 then 3 / 4 else 0
  let τ : ℤ → ℂ → ℂ := fun h ↦ if h = 0 then (fun z ↦ q.eval z) else
    if h % 4 = 2 then (fun z ↦ q.eval (z - ((h : ℂ) - ((b : ℝ) / 8 : ℝ)) * I)) else (fun _ ↦ 4)
  have hmem : ∀ h ∈ S, h = 0 ∨ ((4 * L : ℤ) ≤ h ∨ h ≤ -(4 * L : ℤ)) ∧ (h % 4 = 0 ∨ h % 4 = 2) := by
    intro h hh
    simp only [S, Finset.mem_union, Finset.mem_singleton, Finset.mem_image, Finset.mem_Ico] at hh
    rcases hh with ((hh | ⟨m, ⟨h1, h2⟩, rfl⟩) | ⟨j, ⟨h1, h2⟩, rfl⟩) | ⟨j, ⟨h1, h2⟩, rfl⟩
    · exact Or.inl hh
    all_goals right; omega
  have hτ : ∀ h, Differentiable ℂ (τ h) := by
    intro h
    simp only [τ]
    split_ifs
    · exact q.differentiable
    · exact q.differentiable.comp (differentiable_id.sub_const _)
    · exact differentiable_const _
  have hρ : ∀ h, 0 ≤ ρ h := by
    intro h
    simp only [ρ]
    have : (1 : ℝ) ≤ 2 ^ n := one_le_pow₀ (by norm_num)
    split_ifs <;> linarith
  have hρ0 : ρ 0 = 4 * L - 2 := by simp [ρ, hL]
  have hρle : ∀ h, h ≠ 0 → ρ h ≤ 3 / 4 := by
    intro h h0; simp only [ρ, h0, ite_false]; split_ifs <;> norm_num
  have hsep : ∀ h ∈ S, ∀ h' ∈ S, h ≠ h' → ρ h + ρ h' + 1 / 4 < |(h : ℝ) - h'| := by
    intro h hh h' hh' hne
    have hLr : (4 * (L : ℝ)) = ((4 * L : ℤ) : ℝ) := by push_cast; ring
    rcases hmem h hh with rfl | ⟨hb, hm⟩
    · rcases hmem h' hh' with rfl | ⟨hb', hm'⟩
      · exact (hne rfl).elim
      · have := hρle h' (by omega)
        have := Printed.recurrentCompact_int_abs_cast 0 h' (4 * L) (by omega)
        rw [hρ0]
        push_cast at this ⊢
        linarith
    · rcases hmem h' hh' with rfl | ⟨hb', hm'⟩
      · have := hρle h (by omega)
        have := Printed.recurrentCompact_int_abs_cast h 0 (4 * L) (by omega)
        rw [hρ0]
        push_cast at this ⊢
        linarith
      · have h1 := hρle h (by omega)
        have h2 := hρle h' (by omega)
        by_cases hd1 : h % 4 = h' % 4
        · have := Printed.recurrentCompact_int_abs_cast h h' 4 (by omega)
          push_cast at this
          linarith
        · have hsum : ρ h + ρ h' ≤ 3 / 4 := by
            simp only [ρ, show h ≠ 0 by omega, show h' ≠ 0 by omega, ite_false]
            rcases hm with hm | hm <;> rcases hm' with hm' | hm' <;>
              simp only [hm, hm'] <;> first | omega | norm_num
          have := Printed.recurrentCompact_int_abs_cast h h' 2 (by omega)
          push_cast at this
          linarith
  obtain ⟨p, hp⟩ := Printed.recurrentCompact_runge_slots S ρ τ hτ hρ hsep
    (e := (1 / 2) ^ (n + 2)) (by positivity)
  refine ⟨p, fun z hz ↦ ?_, fun m hm1 hm2 w hw ↦ ?_, fun j hj1 hj2 ↦ ⟨?_, ?_⟩⟩
  · have h0 : (0 : ℤ) ∈ S := by simp [S]
    have := hp 0 h0 z (by simpa [hρ0, hL] using hz)
    simpa [τ] using this
  · set h : ℤ := 4 * m + 2 with hh
    have hS : h ∈ S := by
      simp only [S, Finset.mem_union, Finset.mem_image, Finset.mem_Ico]
      left; left; right; exact ⟨m, ⟨hm1, by rw [pow_succ] at hm2; omega⟩, rfl⟩
    have h0 : h ≠ 0 := by omega
    have h2 : h % 4 = 2 := by omega
    have hρh : ρ h = 3 / 4 := by simp [ρ, h0, h2]
    have hc : ((h : ℂ) - (((b : ℝ) / 8 : ℝ) : ℂ)) = (((4 * m + 2 : ℝ) - b / 8 : ℝ) : ℂ) := by
      simp [hh]
    have hz : w + (((4 * m + 2 : ℝ) - b / 8 : ℝ) : ℂ) * I ∈
        Metric.closedBall ((h : ℂ) * I) (ρ h) := by
      rw [hρh, Metric.mem_closedBall, dist_eq] at *
      convert hw using 2
      rw [← hc]; ring
    have := hp h hS _ hz
    simp only [τ, h0, h2, ite_false, ite_true] at this
    rwa [hc, add_sub_cancel_right] at this
  · set h : ℤ := 4 * j with hh
    have hS : h ∈ S := by
      simp only [S, Finset.mem_union, Finset.mem_image, Finset.mem_Ico]
      left; right; exact ⟨j, ⟨hj1, by rw [pow_succ] at hj2; omega⟩, rfl⟩
    have h0 : h ≠ 0 := by omega
    have h2 : ¬ h % 4 = 2 := by omega
    have := hp h hS ((h : ℂ) * I) (Metric.mem_closedBall_self (hρ h))
    simp only [τ, h0, h2, ite_false] at this
    convert this using 3
    simp [hh]
  · set h : ℤ := -(4 * j) with hh
    have hS : h ∈ S := by
      simp only [S, Finset.mem_union, Finset.mem_image, Finset.mem_Ico]
      right; exact ⟨j, ⟨hj1, by rw [pow_succ] at hj2; omega⟩, rfl⟩
    have h0 : h ≠ 0 := by omega
    have h2 : ¬ h % 4 = 2 := by omega
    have := hp h hS ((h : ℂ) * I) (Metric.mem_closedBall_self (hρ h))
    simp only [τ, h0, h2, ite_false] at this
    convert this using 3
    simp [hh]

open Complex in
/-- Geometric tail of the error budget. -/
private theorem Printed.recurrentCompact_geom_tail (N : ℕ) :
    HasSum (fun k : ℕ ↦ ((1 : ℝ) / 2) ^ (k + N + 2)) ((1 / 2) ^ (N + 1)) := by
  have h := (hasSum_geometric_of_lt_one (r := (1 : ℝ) / 2) (by norm_num) (by norm_num)).mul_left
    ((1 / 2) ^ (N + 2))
  convert h using 1
  · funext k; rw [← pow_add]; ring_nf
  · rw [pow_succ, pow_succ, pow_succ]; norm_num; ring

open Complex in
/-- The stage discs increase. -/
private theorem Printed.recurrentCompact_ball_mono {N n : ℕ} (h : N ≤ n) :
    Metric.closedBall (0 : ℂ) (4 * 2 ^ N - 2) ⊆ Metric.closedBall 0 (4 * 2 ^ n - 2) := by
  apply Metric.closedBall_subset_closedBall
  have : (2 : ℝ) ^ N ≤ 2 ^ n := pow_le_pow_right₀ (by norm_num) h
  linarith

open Complex in
/-- The telescoping series converges on the stage discs, with explicit tail. -/
private theorem Printed.recurrentCompact_tail_bound (P : ℕ → Polynomial ℂ)
    (hP : ∀ n, ∀ z ∈ Metric.closedBall (0 : ℂ) (4 * 2 ^ n - 2),
      ‖(P n).eval z - (P (n + 1)).eval z‖ < (1 / 2) ^ (n + 2))
    (N : ℕ) (z : ℂ) (hz : z ∈ Metric.closedBall (0 : ℂ) (4 * 2 ^ N - 2)) :
    Summable (fun n ↦ (P (n + 1)).eval z - (P n).eval z) ∧
    ‖(∑' n, ((P (n + 1)).eval z - (P n).eval z)) - ((P N).eval z - (P 0).eval z)‖ ≤
      (1 / 2) ^ (N + 1) := by
  set d : ℕ → ℂ := fun n ↦ (P (n + 1)).eval z - (P n).eval z
  have hb : ∀ k, ‖d (k + N)‖ ≤ (1 / 2) ^ (k + N + 2) := by
    intro k
    have := hP (k + N) z (Printed.recurrentCompact_ball_mono (by omega) hz)
    simp only [d]
    rw [norm_sub_rev]; exact this.le
  have hs' : Summable (fun k ↦ d (k + N)) :=
    (Printed.recurrentCompact_geom_tail N).summable.of_norm_bounded hb
  have hs : Summable d := (summable_nat_add_iff N).mp hs'
  refine ⟨hs, ?_⟩
  have e1 := hs.sum_add_tsum_nat_add N
  have e2 : ∑ i ∈ Finset.range N, d i = (P N).eval z - (P 0).eval z :=
    Finset.sum_range_sub (fun i ↦ (P i).eval z) N
  change ‖(∑' n, d n) - _‖ ≤ _
  rw [← e1, e2, add_sub_cancel_left]
  exact tsum_of_norm_bounded (Printed.recurrentCompact_geom_tail N) hb

open Complex in
/-- Every point lies in some stage disc. -/
private theorem Printed.recurrentCompact_exists_ball (z : ℂ) : ∃ N : ℕ, ‖z‖ < 4 * 2 ^ N - 2 := by
  obtain ⟨N, hN⟩ := pow_unbounded_of_one_lt (‖z‖ + 2) (by norm_num : (1 : ℝ) < 2)
  exact ⟨N, by linarith [norm_nonneg z]⟩

open Complex in
/-- The limit of the construction is entire. -/
private theorem Printed.recurrentCompact_tsum_differentiable (P : ℕ → Polynomial ℂ)
    (hP : ∀ n, ∀ z ∈ Metric.closedBall (0 : ℂ) (4 * 2 ^ n - 2),
      ‖(P n).eval z - (P (n + 1)).eval z‖ < (1 / 2) ^ (n + 2)) :
    Differentiable ℂ (fun z ↦ ∑' n, ((P (n + 1)).eval z - (P n).eval z)) := by
  intro z0
  obtain ⟨N, hN⟩ := Printed.recurrentCompact_exists_ball z0
  set U := Metric.ball (0 : ℂ) (4 * 2 ^ N - 2)
  have hU : IsOpen U := Metric.isOpen_ball
  have hz0 : z0 ∈ U := by simpa [U] using hN
  have hd : DifferentiableOn ℂ (fun w ↦ (P N).eval w - (P 0).eval w +
      ∑' k, ((P (k + N + 1)).eval w - (P (k + N)).eval w)) U := by
    refine ((P N).differentiable.sub (P 0).differentiable).differentiableOn.add ?_
    refine differentiableOn_tsum_of_summable_norm (Printed.recurrentCompact_geom_tail N).summable
      (fun k ↦ ((P (k + N + 1)).differentiable.sub (P (k + N)).differentiable).differentiableOn)
      hU fun k w hw ↦ ?_
    have := hP (k + N) w
      (Printed.recurrentCompact_ball_mono (by omega) (Metric.ball_subset_closedBall hw))
    rw [norm_sub_rev]; exact this.le
  refine (hd.differentiableAt (hU.mem_nhds hz0)).congr_of_eventuallyEq ?_
  filter_upwards [hU.mem_nhds hz0] with w hw
  have hs := (Printed.recurrentCompact_tail_bound P hP N w (Metric.ball_subset_closedBall hw)).1
  have e1 := hs.sum_add_tsum_nat_add N
  have e2 : ∑ i ∈ Finset.range N, ((P (i + 1)).eval w - (P i).eval w) =
      (P N).eval w - (P 0).eval w := Finset.sum_range_sub (fun i ↦ (P i).eval w) N
  rw [← e1, e2]

open Complex in
/-- The density ratio is at most one. -/
private theorem Printed.recurrentCompact_dens_ratio_le_one (X : Set ℝ) :
    ∀ᶠ T : ℝ in atTop, volume.real (Icc (-T) T ∩ X) / (2 * T) ≤ 1 := by
  filter_upwards [eventually_gt_atTop 0] with T hT
  rw [div_le_one (by positivity)]
  refine (measureReal_mono inter_subset_left measure_Icc_lt_top.ne).trans ?_
  rw [Real.volume_real_Icc_of_le (by linarith)]
  linarith

open Complex in
/-- A bounded set has upper density at most zero. -/
private theorem Printed.recurrentCompact_dens_bounded (X : Set ℝ) (hX : X ⊆ Icc (-6) 6) :
    upperDensity X ≤ 0 := by
  have hv : Tendsto (fun T : ℝ ↦ 6 / T) atTop (𝓝 0) :=
    tendsto_const_nhds.div_atTop tendsto_id
  have hge : ∀ᶠ T : ℝ in atTop, 0 ≤ volume.real (Icc (-T) T ∩ X) / (2 * T) := by
    filter_upwards [eventually_ge_atTop 0] with T hT
    exact div_nonneg measureReal_nonneg (by positivity)
  have hle : ∀ᶠ T : ℝ in atTop, volume.real (Icc (-T) T ∩ X) / (2 * T) ≤ 6 / T := by
    filter_upwards [eventually_gt_atTop 0] with T hT
    rw [div_le_div_iff₀ (by positivity) hT]
    have : volume.real (Icc (-T) T ∩ X) ≤ 12 := by
      refine (measureReal_mono (inter_subset_right.trans hX) measure_Icc_lt_top.ne).trans ?_
      rw [Real.volume_real_Icc_of_le (by norm_num)]; norm_num
    nlinarith
  unfold upperDensity
  rw [← hv.limsup_eq]
  exact limsup_le_limsup hle (isCoboundedUnder_le_of_eventually_le _ hge) hv.isBoundedUnder_le

open Complex in
/-- Return intervals in every dyadic block give positive upper density. -/
private theorem Printed.recurrentCompact_dens_pos (X : Set ℝ) (b : ℤ) {δ : ℝ} (hδ : 0 < δ)
    (hδ1 : δ < 1)
    (H : ∀ N : ℕ, ∃ n ≥ N, ∀ m : ℕ, 2 ^ n ≤ m → m + 1 < 2 ^ (n + 1) →
      Icc ((4 * m + 2 - b / 8 : ℝ) - δ) ((4 * m + 2 - b / 8 : ℝ) + δ) ⊆ X) :
    0 < upperDensity X := by
  set c : ℝ := δ / (2 * (8 + |(b : ℝ)|)) with hc
  have hc0 : 0 < c := by positivity
  refine hc0.trans_le (le_limsup_of_frequently_le ?_
    (isBoundedUnder_of_eventually_le (Printed.recurrentCompact_dens_ratio_le_one X)))
  rw [frequently_atTop]
  intro T0
  obtain ⟨N, hN⟩ := pow_unbounded_of_one_lt T0 (by norm_num : (1 : ℝ) < 2)
  obtain ⟨n, hn, hX⟩ := H (N + 1)
  have hA : (2 : ℝ) ^ N ≤ 2 ^ n := pow_le_pow_right₀ (by norm_num) (by omega)
  have hA2 : (2 : ℕ) ≤ 2 ^ n := by
    calc 2 = 2 ^ 1 := by norm_num
      _ ≤ 2 ^ n := Nat.pow_le_pow_right (by norm_num) (by omega)
  set A : ℝ := 2 ^ n with hAdef
  have hA2r : (2 : ℝ) ≤ A := by rw [hAdef]; exact_mod_cast hA2
  set T : ℝ := 8 * A + |(b : ℝ)| with hT
  have hT0 : 0 < T := by positivity
  refine ⟨T, by linarith [abs_nonneg (b : ℝ)], ?_⟩
  set s : Finset ℕ := Finset.Ico (2 ^ n) (2 ^ (n + 1) - 1)
  let I : ℕ → Set ℝ := fun m ↦ Icc ((4 * m + 2 - b / 8 : ℝ) - δ) ((4 * m + 2 - b / 8 : ℝ) + δ)
  have hbabs : (b : ℝ) / 8 ≤ |(b : ℝ)| ∧ -|(b : ℝ)| ≤ (b : ℝ) / 8 := by
    constructor <;> cases abs_cases (b : ℝ) <;> linarith
  have hsub : (⋃ m ∈ s, I m) ⊆ Icc (-T) T ∩ X := by
    intro x hx
    simp only [mem_iUnion] at hx
    obtain ⟨m, hm, hx⟩ := hx
    simp only [s, Finset.mem_Ico] at hm
    have hm1 : (2 : ℝ) ^ n ≤ m := by exact_mod_cast hm.1
    have hm2 : (m : ℝ) + 2 ≤ 2 * 2 ^ n := by
      have : m + 2 ≤ 2 * 2 ^ n := by rw [pow_succ] at hm; omega
      exact_mod_cast this
    refine ⟨⟨?_, ?_⟩, hX m hm.1 (by rw [pow_succ] at hm ⊢; omega) hx⟩
    · linarith [hx.1, hbabs.1]
    · linarith [hx.2, hbabs.2]
  have hdisj : PairwiseDisjoint (↑s) I := by
    intro m _ m' _ hne
    refine Set.disjoint_left.mpr fun x hx hx' ↦ ?_
    have : m + 1 ≤ m' ∨ m' + 1 ≤ m := by omega
    rcases this with h | h
    · have : (m : ℝ) + 1 ≤ m' := by exact_mod_cast h
      linarith [hx.2, hx'.1]
    · have : (m' : ℝ) + 1 ≤ m := by exact_mod_cast h
      linarith [hx.1, hx'.2]
  have hvol : volume.real (⋃ m ∈ s, I m) = s.card * (2 * δ) := by
    rw [measureReal_biUnion_finset hdisj (fun m _ ↦ measurableSet_Icc)
      (fun m _ ↦ measure_Icc_lt_top.ne)]
    rw [Finset.sum_congr rfl (fun m _ ↦ Real.volume_real_Icc_of_le (by linarith))]
    have e : ∀ m ∈ s, (4 * (m : ℝ) + 2 - b / 8 + δ - (4 * (m : ℝ) + 2 - b / 8 - δ)) = 2 * δ :=
      fun m _ ↦ by ring
    rw [Finset.sum_congr rfl e, Finset.sum_const, nsmul_eq_mul]
  have hcard : A ≤ 2 * (s.card : ℝ) := by
    have : 2 ^ n ≤ 2 * s.card := by
      simp only [s, Nat.card_Ico]; rw [pow_succ]; omega
    rw [hAdef]; exact_mod_cast this
  have hmono : volume.real (⋃ m ∈ s, I m) ≤ volume.real (Icc (-T) T ∩ X) :=
    measureReal_mono hsub ((measure_mono inter_subset_left).trans_lt measure_Icc_lt_top).ne
  rw [le_div_iff₀ (by positivity)]
  have key : c * (2 * T) ≤ δ * A := by
    rw [hc, div_mul_eq_mul_div, div_le_iff₀ (by positivity)]
    have : |(b : ℝ)| ≤ |(b : ℝ)| * A := le_mul_of_one_le_right (abs_nonneg _) (by linarith)
    nlinarith
  nlinarith

open Complex in
/-- The disc schedule grows at most linearly. -/
private theorem Printed.recurrentCompact_sch_bound (n : ℕ) :
    |(((Nat.unpair n).1 : ℤ) - (Nat.unpair n).2 : ℤ)| ≤ n := by
  have h1 := Nat.unpair_left_le n
  have h2 := Nat.unpair_right_le n
  rw [abs_le]; constructor <;> omega

open Complex in
/-- The disc schedule visits every index infinitely often. -/
private theorem Printed.recurrentCompact_sch_freq (b : ℤ) (N : ℕ) :
    ∃ n ≥ N, (((Nat.unpair n).1 : ℤ) - (Nat.unpair n).2 : ℤ) = b := by
  refine ⟨Nat.pair (b + (N + b.natAbs : ℕ)).toNat (N + b.natAbs), ?_, ?_⟩
  · exact le_trans (by omega) (Nat.right_le_pair _ _)
  · rw [Nat.unpair_pair]; simp only
    omega

open Complex in
/-- Norm of a point on the imaginary axis. -/
private theorem Printed.recurrentCompact_norm_ofReal_mul_I (x : ℝ) : ‖(x : ℂ) * I‖ = |x| := by
  rw [norm_mul, Complex.norm_I, mul_one, Complex.norm_real, Real.norm_eq_abs]

open scoped ENNReal NNReal in
/-- Extended norm as `ENNReal.ofReal`. -/
private theorem Printed.recurrentCompact_enn_nnnorm (v : ℂ) :
    ((‖v‖₊ : ℝ≥0) : ℝ≥0∞) = ENNReal.ofReal ‖v‖ := by
  rw [← ENNReal.ofReal_coe_nnreal, coe_nnNorm]

open Complex in
open scoped ENNReal NNReal in
/-- Paper: Lemma B.5.3.4(2), p. 633. In the strip `|Re z| < 1/2` take the
segment `K = [-2i, 2i]`. Construct an entire function of norm less than one on
`K` and greater than three at every `4ji` for nonzero integer `j`.
Start with polynomial approximations to zero on `K` and four at `±4i`.
Cycle through the rational closed discs strictly inside the strip. At stage
`L = 2^n`, approximate the preceding polynomial on the square of half-side
`4L + 1` and copy its values from the scheduled disc of center `c` to its vertical
translates by `i (4m + 2 - Im c)` for `L ≤ m < 2L`. Their centers have height
`4m + 2` and their radii are less than one half. Schedule each disc infinitely often
after it fits in the old square. Approximate four at `±4ji` for `L < j ≤ 2L`. The union of the
square, new discs, and new marks has connected complement, so Runge approximation
allows summable errors of total less than one. For each disc strictly inside a scheduled
disc, the copy errors tend to zero and continuity gives intervals of good shifts of fixed
positive width.
These intervals give positive upper density along its blocks. Every shift of
`K` by imaginary height of absolute value at least six meets a mark, so its
return times for tolerance two have upper density zero. -/
theorem Printed.stronglyRecurrentOn_compact_of_closedBall_false :
    ¬ Printed.stronglyRecurrentOn_compact_of_closedBall := by
  intro hpr
  classical
  choose next hnext using Printed.recurrentCompact_stage_exists
  let sch : ℕ → ℤ := fun n ↦ ((Nat.unpair n).1 : ℤ) - (Nat.unpair n).2
  let P : ℕ → Polynomial ℂ := fun n ↦ Nat.rec 0 (fun k q ↦ next k (sch k) q) n
  have hP0 : P 0 = 0 := rfl
  have hPs : ∀ n, P (n + 1) = next n (sch n) (P n) := fun n ↦ rfl
  have h1 : ∀ n, ∀ z ∈ Metric.closedBall (0 : ℂ) (4 * 2 ^ n - 2),
      ‖(P n).eval z - (P (n + 1)).eval z‖ < (1 / 2) ^ (n + 2) := fun n ↦ by
    rw [hPs]; exact (hnext n (sch n) (P n)).1
  have h2 := fun n ↦ (hnext n (sch n) (P n)).2.1
  have h3 := fun n ↦ (hnext n (sch n) (P n)).2.2
  simp only [← hPs] at h2 h3
  set f : ℂ → ℂ := fun z ↦ ∑' n, ((P (n + 1)).eval z - (P n).eval z) with hfdef
  have hf : Differentiable ℂ f := Printed.recurrentCompact_tsum_differentiable P h1
  have hfN : ∀ N, ∀ z ∈ Metric.closedBall (0 : ℂ) (4 * 2 ^ N - 2),
      ‖f z - (P N).eval z‖ ≤ (1 / 2) ^ (N + 1) := by
    intro N z hz
    have := (Printed.recurrentCompact_tail_bound P h1 N z hz).2
    rwa [hP0, Polynomial.eval_zero, sub_zero] at this
  -- the compact segment
  set K : Set ℂ := (fun s : ℝ ↦ (s : ℂ) * I) '' Icc (-2) 2 with hKdef
  have hKc : IsCompact K := isCompact_Icc.image (by fun_prop)
  have hKs : K ⊆ verticalStrip (-1 / 2) (1 / 2) := by
    rintro _ ⟨s, _, rfl⟩
    simp only [verticalStrip, mem_preimage, mul_re, ofReal_re, I_re, mul_zero, ofReal_im, I_im,
      mul_one, sub_self, mem_Ioo]
    norm_num
  have hfK : ∀ z ∈ K, ‖f z‖ < 1 / 2 := by
    rintro _ ⟨s, hs, rfl⟩
    have hz0 : (s : ℂ) * I ∈ Metric.closedBall (0 : ℂ) (4 * 2 ^ 0 - 2) := by
      rw [Metric.mem_closedBall, dist_zero_right, Printed.recurrentCompact_norm_ofReal_mul_I,
        abs_le]
      norm_num; exact hs
    have a := hfN 1 _ (Printed.recurrentCompact_ball_mono (by norm_num) hz0)
    have b := h1 0 _ hz0
    rw [hP0, Polynomial.eval_zero, zero_sub, norm_neg] at b
    have : ‖f ((s : ℂ) * I)‖ ≤ ‖f ((s : ℂ) * I) - (P 1).eval ((s : ℂ) * I)‖ +
        ‖(P 1).eval ((s : ℂ) * I)‖ := norm_le_norm_sub_add _ _
    norm_num at a b
    linarith
  have hmark : ∀ j : ℤ, j ≠ 0 → 7 / 2 < ‖f (((4 * j : ℝ) : ℂ) * I)‖ := by
    intro j hj
    set k := j.natAbs with hk
    have hk0 : k ≠ 0 := by omega
    set n := Nat.log 2 k
    have hn1 : 2 ^ n ≤ k := Nat.pow_log_le_self 2 hk0
    have hn2 : k < 2 ^ (n + 1) := Nat.lt_pow_succ_log_self (by norm_num) k
    have hball : ∀ x : ℝ, |x| = 4 * k → ((x : ℂ) * I) ∈
        Metric.closedBall (0 : ℂ) (4 * 2 ^ (n + 1) - 2) := by
      intro x hx
      rw [Metric.mem_closedBall, dist_zero_right, Printed.recurrentCompact_norm_ofReal_mul_I, hx]
      have : (k : ℝ) + 1 ≤ 2 ^ (n + 1) := by exact_mod_cast hn2
      linarith
    have hsmall : ((1 : ℝ) / 2) ^ (n + 2) ≤ 1 / 4 := by
      calc ((1 : ℝ) / 2) ^ (n + 2) ≤ (1 / 2) ^ 2 :=
            pow_le_pow_of_le_one (by norm_num) (by norm_num) (by omega)
        _ = 1 / 4 := by norm_num
    have hj' : (4 * j : ℝ) = 4 * k ∨ (4 * j : ℝ) = -(4 * k) := by
      rcases Int.natAbs_eq j with h | h
      · left; have : (j : ℝ) = (k : ℝ) := by rw [← Int.cast_natCast, ← h]
        rw [this]
      · right; have : (j : ℝ) = -(k : ℝ) := by rw [← Int.cast_natCast, ← Int.cast_neg, ← h]
        rw [this]; ring
    have hgen : ∀ x : ℝ, |x| = 4 * k → ‖4 - (P (n + 1)).eval ((x : ℂ) * I)‖ < (1 / 2) ^ (n + 2) →
        7 / 2 < ‖f ((x : ℂ) * I)‖ := by
      intro x hx hlt
      have a := hfN (n + 1) _ (hball x hx)
      have : (4 : ℝ) ≤ ‖f ((x : ℂ) * I)‖ + ‖f ((x : ℂ) * I) - (P (n + 1)).eval ((x : ℂ) * I)‖ +
          ‖4 - (P (n + 1)).eval ((x : ℂ) * I)‖ := by
        have e : f ((x : ℂ) * I) - (f ((x : ℂ) * I) - (P (n + 1)).eval ((x : ℂ) * I)) +
            (4 - (P (n + 1)).eval ((x : ℂ) * I)) = 4 := by ring
        calc (4 : ℝ) = ‖f ((x : ℂ) * I) - (f ((x : ℂ) * I) - (P (n + 1)).eval ((x : ℂ) * I)) +
            (4 - (P (n + 1)).eval ((x : ℂ) * I))‖ := by rw [e]; norm_num
          _ ≤ _ := (norm_add_le _ _).trans (add_le_add (norm_sub_le _ _) le_rfl)
      have : ((1 : ℝ) / 2) ^ (n + 1 + 1) ≤ 1 / 4 := hsmall
      linarith
    rcases hj' with h | h
    · rw [h]
      exact hgen _ (by rw [abs_of_nonneg (by positivity)]) (by
        have := (h3 n k hn1 hn2).1; push_cast at this ⊢; exact this)
    · rw [h]
      exact hgen _ (by rw [abs_neg, abs_of_nonneg (by positivity)]) (by
        have := (h3 n k hn1 hn2).2; push_cast at this ⊢; exact this)
  -- failure on K
  have hnot : ¬ StronglyRecurrentOn f K := by
    intro hsr
    have hpos := hsr 2 two_pos
    have hsub : verticalReturnTimes f K 2 ⊆ Icc (-6) 6 := by
      intro t ht
      by_contra hout
      have h6 : 6 < |t| := by
        rw [mem_Icc, not_and_or, not_le, not_le] at hout
        rcases hout with h | h
        · rw [abs_of_neg (by linarith)]; linarith
        · rw [abs_of_pos (by linarith)]; exact h
      set j : ℤ := round (t / 4)
      have hj := abs_sub_round (t / 4)
      have hj0 : j ≠ 0 := by
        intro h0
        rw [show round (t / 4) = j from rfl, h0, Int.cast_zero, sub_zero, abs_div,
          abs_of_pos (by norm_num : (0 : ℝ) < 4)] at hj
        linarith
      have hzK : ((4 * j - t : ℝ) : ℂ) * I ∈ K := by
        refine ⟨4 * j - t, ?_, rfl⟩
        rw [abs_le] at hj
        constructor <;> linarith [hj.1, hj.2]
      have hm := hmark j hj0
      have hz := hfK _ hzK
      have hshift : ((4 * j - t : ℝ) : ℂ) * I + (t : ℂ) * I = ((4 * j : ℝ) : ℂ) * I := by
        push_cast; ring
      have hle : (‖f (((4 * j - t : ℝ) : ℂ) * I + (t : ℂ) * I) - f (((4 * j - t : ℝ) : ℂ) * I)‖₊ :
          ℝ≥0∞) ≤ ⨆ z : K, (‖f ((z : ℂ) + (t : ℂ) * I) - f z‖₊ : ℝ≥0∞) :=
        le_iSup (fun z : K ↦ (‖f ((z : ℂ) + (t : ℂ) * I) - f z‖₊ : ℝ≥0∞)) ⟨_, hzK⟩
      have ht' : (⨆ z : K, (‖f ((z : ℂ) + (t : ℂ) * I) - f z‖₊ : ℝ≥0∞)) < ENNReal.ofReal 2 := ht
      rw [hshift, Printed.recurrentCompact_enn_nnnorm] at hle
      have hlow : 2 < ‖f (((4 * j : ℝ) : ℂ) * I) - f (((4 * j - t : ℝ) : ℂ) * I)‖ := by
        have := norm_sub_norm_le (f (((4 * j : ℝ) : ℂ) * I)) (f (((4 * j - t : ℝ) : ℂ) * I))
        linarith
      have := (ENNReal.ofReal_lt_ofReal_iff (by linarith)).mpr hlow
      exact absurd (this.trans_le (hle.trans ht'.le)) (lt_irrefl _)
    exact absurd (Printed.recurrentCompact_dens_bounded _ hsub) (not_le.mpr hpos)
  apply hnot
  refine hpr (-1 / 2) (1 / 2) (by norm_num) f hf.differentiableOn ?_ K hKc hKs
  -- recurrence on discs
  intro z r hr hB ε hε
  have hzr : |z.re| + r < 1 / 2 := by
    have hp := hB (show z + (r : ℂ) ∈ Metric.closedBall z r by
      rw [Metric.mem_closedBall, dist_eq, add_sub_cancel_left, Complex.norm_real,
        Real.norm_eq_abs, abs_of_nonneg hr])
    have hm := hB (show z - (r : ℂ) ∈ Metric.closedBall z r by
      rw [Metric.mem_closedBall, dist_eq, sub_sub_cancel_left, norm_neg, Complex.norm_real,
        Real.norm_eq_abs, abs_of_nonneg hr])
    simp only [verticalStrip, mem_preimage, add_re, sub_re, ofReal_re, mem_Ioo] at hp hm
    cases abs_cases z.re <;> linarith
  set b : ℤ := ⌊8 * z.im⌋ with hbdef
  have hb1 : (b : ℝ) ≤ 8 * z.im := Int.floor_le _
  have hb2 : 8 * z.im < b + 1 := Int.lt_floor_add_one _
  set c : ℂ := (((b : ℝ) / 8 : ℝ) : ℂ) * I with hc
  set D : Set ℂ := Metric.closedBall c (3 / 4)
  have hzc : ‖z - c‖ ≤ |z.re| + 1 / 8 := by
    refine (Complex.norm_le_abs_re_add_abs_im _).trans ?_
    have e1 : (z - c).re = z.re := by simp [hc]
    have e2 : (z - c).im = z.im - b / 8 := by simp [hc]
    rw [e1, e2]
    have : |z.im - b / 8| ≤ 1 / 8 := by rw [abs_le]; constructor <;> linarith
    linarith
  have hBD : ∀ w ∈ Metric.closedBall z r, ∀ s : ℝ, |s| ≤ 1 / 8 → w + (s : ℂ) * I ∈ D := by
    intro w hw s hs
    rw [Metric.mem_closedBall, dist_eq] at hw ⊢
    have : ‖w + (s : ℂ) * I - c‖ ≤ ‖w - z‖ + ‖z - c‖ + ‖(s : ℂ) * I‖ := by
      have e : w + (s : ℂ) * I - c = (w - z) + (z - c) + (s : ℂ) * I := by ring
      rw [e]; exact norm_add₃_le
    rw [Printed.recurrentCompact_norm_ofReal_mul_I] at this
    linarith
  have huc := (isCompact_closedBall c (3 / 4)).uniformContinuousOn_of_continuous
    hf.continuous.continuousOn
  obtain ⟨δ0, hδ0, hδ0'⟩ := Metric.uniformContinuousOn_iff.mp huc (ε / 4) (by positivity)
  set δ : ℝ := min δ0 (1 / 8) / 2 with hδ
  have hδpos : 0 < δ := by positivity
  have hδ1 : δ ≤ 1 / 16 := by
    have := min_le_right δ0 (1 / 8); rw [hδ]; linarith
  have hδ2 : δ < δ0 := by
    have := min_le_left δ0 (1 / 8); rw [hδ]; linarith
  have hcopy : ∀ n, 1 ≤ n → sch n = b → ∀ m : ℕ, 2 ^ n ≤ m → m + 1 < 2 ^ (n + 1) →
      ∀ w ∈ D, ‖f (w + (((4 * m + 2 : ℝ) - b / 8 : ℝ) : ℂ) * I) - f w‖ ≤ (1 / 2) ^ n := by
    intro n hn hsch m hm1 hm2 w hw
    have hbn : |(b : ℝ)| ≤ n := by
      have hsb : |sch n| ≤ (n : ℤ) := Printed.recurrentCompact_sch_bound n
      rw [hsch] at hsb; exact_mod_cast hsb
    have hn2 : (n : ℝ) ≤ 2 ^ n := by exact_mod_cast (Nat.lt_two_pow_self).le
    have hwc : ‖w - c‖ ≤ 3 / 4 := by rwa [Metric.mem_closedBall, dist_eq] at hw
    have hcn : ‖c‖ = |(b : ℝ)| / 8 := by
      rw [hc, Printed.recurrentCompact_norm_ofReal_mul_I, abs_div,
        abs_of_pos (by norm_num : (0 : ℝ) < 8)]
    have hwn : w ∈ Metric.closedBall (0 : ℂ) (4 * 2 ^ n - 2) := by
      rw [Metric.mem_closedBall, dist_zero_right]
      have : ‖w‖ ≤ ‖w - c‖ + ‖c‖ := norm_le_norm_sub_add _ _
      have : (1 : ℝ) ≤ 2 ^ n := one_le_pow₀ (by norm_num)
      linarith
    set w' := w + (((4 * m + 2 : ℝ) - b / 8 : ℝ) : ℂ) * I
    have hw' : w' - (((4 * m + 2 : ℝ) : ℝ) : ℂ) * I = w - c := by
      simp only [w', hc]; push_cast; ring
    have hwt : w' ∈ Metric.closedBall (0 : ℂ) (4 * 2 ^ (n + 1) - 2) := by
      rw [Metric.mem_closedBall, dist_zero_right]
      have : ‖w'‖ ≤ ‖w' - (((4 * m + 2 : ℝ) : ℝ) : ℂ) * I‖ +
          ‖(((4 * m + 2 : ℝ) : ℝ) : ℂ) * I‖ := norm_le_norm_sub_add _ _
      rw [hw', Printed.recurrentCompact_norm_ofReal_mul_I, abs_of_nonneg (by positivity)] at this
      have : (m : ℝ) + 2 ≤ 2 ^ (n + 1) := by
        have : m + 2 ≤ 2 ^ (n + 1) := by omega
        exact_mod_cast this
      linarith
    have e1 := hfN n w hwn
    have e2 := hfN (n + 1) w' hwt
    have e3 := h2 n m hm1 hm2 w (by rw [hsch]; exact hw)
    rw [hsch] at e3
    have : ‖f w' - f w‖ ≤ ‖f w' - (P (n + 1)).eval w'‖ + ‖(P n).eval w - (P (n + 1)).eval w'‖ +
        ‖f w - (P n).eval w‖ := by
      have e : f w' - f w = (f w' - (P (n + 1)).eval w') - ((P n).eval w - (P (n + 1)).eval w') -
          (f w - (P n).eval w) := by ring
      rw [e]
      exact (norm_sub_le _ _).trans (add_le_add (norm_sub_le _ _) le_rfl)
    have hpow : ((1 : ℝ) / 2) ^ n = (1 / 2) ^ (n + 1 + 1) + (1 / 2) ^ (n + 2) +
        (1 / 2) ^ (n + 1) := by ring
    rw [hpow]
    linarith
  obtain ⟨N1, hN1⟩ := exists_pow_lt_of_lt_one (show 0 < ε / 4 by positivity)
    (show (1 : ℝ) / 2 < 1 by norm_num)
  refine Printed.recurrentCompact_dens_pos _ b hδpos (by linarith) fun N ↦ ?_
  obtain ⟨n, hn, hsch⟩ := Printed.recurrentCompact_sch_freq b (max N (max N1 1))
  refine ⟨n, le_trans (le_max_left _ _) hn, fun m hm1 hm2 t ht ↦ ?_⟩
  have hnN1 : ((1 : ℝ) / 2) ^ n ≤ ε / 4 :=
    (pow_le_pow_of_le_one (by norm_num) (by norm_num)
      (le_trans (le_trans (le_max_left _ _) (le_max_right _ _)) hn)).trans hN1.le
  have hn1 : 1 ≤ n := le_trans (le_trans (le_max_right _ _) (le_max_right _ _)) hn
  set tm : ℝ := (4 * m + 2 : ℝ) - b / 8
  set s : ℝ := t - tm
  have hs : |s| ≤ δ := by rw [abs_le]; constructor <;> linarith [ht.1, ht.2]
  change (⨆ w : Metric.closedBall z r,
    (‖f ((w : ℂ) + (t : ℂ) * I) - f w‖₊ : ℝ≥0∞)) < ENNReal.ofReal ε
  refine lt_of_le_of_lt (iSup_le fun w ↦ ?_ : _ ≤ ENNReal.ofReal (ε / 2))
    ((ENNReal.ofReal_lt_ofReal_iff hε).mpr (by linarith))
  rw [Printed.recurrentCompact_enn_nnnorm]
  refine ENNReal.ofReal_le_ofReal ?_
  have hw1 : (w : ℂ) + (s : ℂ) * I ∈ D := hBD w w.2 s (by linarith)
  have hw0 : (w : ℂ) ∈ D := by simpa using hBD w w.2 0 (by norm_num)
  have hcp := hcopy n hn1 hsch m hm1 hm2 _ hw1
  have he : (w : ℂ) + (s : ℂ) * I + ((tm : ℝ) : ℂ) * I = (w : ℂ) + (t : ℂ) * I := by
    simp only [s]; push_cast; ring
  rw [he] at hcp
  have huc' := hδ0' _ hw1 _ hw0 (by
    rw [dist_eq, add_sub_cancel_left, Printed.recurrentCompact_norm_ofReal_mul_I]; linarith)
  rw [dist_eq] at huc'
  have : ‖f ((w : ℂ) + (t : ℂ) * I) - f w‖ ≤ ‖f ((w : ℂ) + (t : ℂ) * I) -
      f ((w : ℂ) + (s : ℂ) * I)‖ + ‖f ((w : ℂ) + (s : ℂ) * I) - f w‖ :=
    norm_sub_le_norm_sub_add_norm_sub _ _ _
  linarith

end RiemannMasullo
