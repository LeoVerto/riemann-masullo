module

public import RiemannMasullo.Ch06_LocalGlobal.Sec2
public import RiemannMasullo.Ch05_ThetaZSpaces.Sec5
public import RiemannMasullo.AppB_AnalyticNT.Sec5
public import RiemannMasullo.AppB_AnalyticNT.Sec6
public import RiemannMasullo.AppB_AnalyticNT.Sec3
public import RiemannMasullo.ForMathlib.NumberTheory.NumberField.Completion.FinitePlace

/-! # Local and global converse theorems

Masullo, §6.3, pp. 302–310. Finite sets in the S-local notation specify the
finite places. The S-local Euler product always includes all infinite places.
-/

@[expose] public noncomputable section

open Filter Function IsDedekindDomain MeasureTheory NumberField Set Topology
open scoped NNReal NumberField.AdeleRing

namespace RiemannMasullo

set_option quotPrecheck false
set_option maxSynthPendingDepth 8

variable {F : Type*} [Field F] [NumberField F]

local notation "V" => HeightOneSpectrum (𝓞 F)
local notation "C𝔽" => IdeleClassGroup (𝓞 F) F
local notation "U" => PontryaginDual C𝔽
local notation "C₁" => (ideleClassNorm F).ker
local notation "χ₀(" χ ")" => ideleClassNormTwist χ 0
local notation "χ₁(" χ ")" => (χ : U).comp
  (⟨(ideleClassNorm F).ker.subtype, continuous_subtype_val⟩ : C₁ →ₜ* C𝔽)
local notation "normChartₛ(" χ ")" => quasiCharacterNormTwist (sIdeleQuotientNorm F _)
  (isProperMap_sIdeleQuotientNorm F _).continuous
  ((⟨Circle.coeHom, continuous_subtype_val⟩ : Circle →ₜ* ℂ).comp χ)
local notation "q(" v ")" => (Ideal.absNorm (HeightOneSpectrum.asIdeal v))
local notation "halfPlane" => Complex.re ⁻¹' Ioi (1 : ℝ)

-- Equation (6.3.1.1) uses `ideleClassNormTwist` from §3.2.

/-- At a place where a Hecke character is unramified, its value on a local unit is the value on
a given uniformizer raised to the valuation exponent, and the norm is the same power of the
norm of the uniformizer. -/
private theorem unramifiedHeckeCharacter_existsUnique_phase_local
    (c : HeckeCharacter (𝓞 F) F) (v : HeightOneSpectrum (𝓞 F))
    (hc : c.IsUnramifiedAt v) (π : (v.adicCompletion F)ˣ)
    (hπ : Valued.v.IsUniformizer π.val) (x : (v.adicCompletion F)ˣ) :
    ∃ n : ℤ, finitePlaceRestriction F v c x = finitePlaceRestriction F v c π ^ n ∧
      ‖(x : v.adicCompletion F)‖ = ‖(π : v.adicCompletion F)‖ ^ n := by
  have hval : Valued.v (π : v.adicCompletion F) = WithZero.exp (-1 : ℤ) := hπ.trans
    (congrArg Units.val (Valuation.IsRankOneDiscrete.generator_eq_exp_neg_one_of_surjective
      (v.valuedAdicCompletion_surjective F)))
  have hx0 : Valued.v (x : v.adicCompletion F) ≠ 0 := (Valuation.ne_zero_iff _).mpr x.ne_zero
  set k := WithZero.log (Valued.v (x : v.adicCompletion F))
  let y : (v.adicCompletion F)ˣ := x * π ^ k
  have hv : Valued.v (y : v.adicCompletion F) = 1 := by
    rw [Units.val_mul, Units.val_zpow_eq_zpow_val, map_mul, map_zpow₀, hval,
      ← WithZero.exp_zsmul]
    conv_lhs => rw [← WithZero.exp_log hx0]
    rw [← WithZero.exp_add]
    simp [k]
  have hxy : x = y * π ^ (-k) := by simp [y]
  have hy : finitePlaceRestriction F v c y = 1 := by
    have := hc.restrict_apply_eq_one (y : v.adicCompletion F) hv
    rw [HeckeCharacter.restrict, MulChar.ofUnitHom_coe] at this
    exact this
  refine ⟨-k, ?_, ?_⟩
  · rw [hxy, map_mul, map_zpow, hy, one_mul]
  · have hn : ‖(y : v.adicCompletion F)‖ = 1 := by
      rw [FinitePlace.norm_def, hv, map_one, NNReal.coe_one]
    rw [hxy, Units.val_mul, norm_mul, hn, one_mul, Units.val_zpow_eq_zpow_val, norm_zpow]

/-- Paper: Equations (6.3.1.2)–(6.3.1.3), p. 303.
At an unramified place a uniformizer determines a unique local phase in the chosen
half-open period. Every norm twist of the local character is then the indicated norm power.
Deviation: The phase is specified by exponentiating the logarithm identity with the
chosen period. The logarithm is of the uniformizer value. -/
theorem unramifiedHeckeCharacter_existsUnique_phase (χ : U) (v : V)
    (hχ : χ₀(χ).IsUnramifiedAt v) (π : (v.adicCompletion F)ˣ)
    (_hπ : Valued.v.IsUniformizer π.val) :
    ∃! t : ℝ, t ∈ Ico 0 (2 * Real.pi / Real.log (q(v) : ℝ)) ∧
      finitePlaceRestriction F v χ₀(χ) π = (q(v) : ℂ) ^ (-(t : ℂ) * Complex.I) ∧
      ∀ (s : ℂ) (x : (v.adicCompletion F)ˣ),
        finitePlaceRestriction F v (ideleClassNormTwist χ s) x =
          ((‖x.val‖ : ℝ) : ℂ) ^ (s + (t : ℂ) * Complex.I) := by
  set q : ℕ := Ideal.absNorm v.asIdeal with hqdef
  have hq1 : 1 < (q : ℝ) := by exact_mod_cast HeightOneSpectrum.one_lt_absNorm v
  have hq0 : (q : ℂ) ≠ 0 := by exact_mod_cast (zero_lt_one.trans hq1).ne'
  set ℓ := Real.log (q : ℝ) with hℓdef
  have hℓ : 0 < ℓ := Real.log_pos hq1
  have hP : 0 < 2 * Real.pi / ℓ := div_pos Real.two_pi_pos hℓ
  set a := finitePlaceRestriction F v (ideleClassNormTwist χ 0) π with hadef
  have htwist (s : ℂ) (x : (v.adicCompletion F)ˣ) :
      finitePlaceRestriction F v (ideleClassNormTwist χ s) x =
        (χ (IdeleClassGroup.ofAdicCompletion (𝓞 F) F v x) : ℂ) *
          ((‖x.val‖ : ℝ) : ℂ) ^ s := by
    change (χ (IdeleClassGroup.ofAdicCompletion (𝓞 F) F v x) : ℂ) *
      (((ideleClassNorm F (IdeleClassGroup.ofAdicCompletion (𝓞 F) F v x) : ℝ≥0) : ℝ) : ℂ) ^ s =
        _
    rw [ideleClassNorm_ofAdicCompletion]
    rfl
  have hχ0 (x : (v.adicCompletion F)ˣ) : finitePlaceRestriction F v (ideleClassNormTwist χ 0) x =
      (χ (IdeleClassGroup.ofAdicCompletion (𝓞 F) F v x) : ℂ) := by
    rw [htwist, Complex.cpow_zero, mul_one]
  have ha1 : ‖a‖ = 1 := by rw [hadef, hχ0]; exact Circle.norm_coe _
  have hlog : Complex.log (q : ℂ) = (ℓ : ℂ) := by rw [hℓdef, Complex.natCast_log]
  have hcpow (t : ℝ) : (q : ℂ) ^ (-(t : ℂ) * Complex.I) =
      Complex.exp (((-t * ℓ : ℝ) : ℂ) * Complex.I) := by
    rw [Complex.cpow_def_of_ne_zero hq0, hlog]
    congr 1
    push_cast
    ring
  -- existence of the phase
  set t₀ : ℝ := -Complex.arg a / ℓ
  set t : ℝ := toIcoMod hP 0 t₀
  have ht : t ∈ Ico 0 (2 * Real.pi / ℓ) := by simpa using toIcoMod_mem_Ico hP 0 t₀
  have hta : a = (q : ℂ) ^ (-(t : ℂ) * Complex.I) := by
    rw [hcpow]
    have hm := toIcoMod_add_toIcoDiv_zsmul hP 0 t₀
    set m := toIcoDiv hP 0 t₀
    have : -t * ℓ = Complex.arg a + (m : ℝ) * (2 * Real.pi) := by
      have h1 : t = t₀ - m * (2 * Real.pi / ℓ) := by rw [zsmul_eq_mul] at hm; linarith
      rw [h1]
      simp only [t₀]
      field_simp
      ring
    rw [this]
    push_cast
    rw [add_mul, Complex.exp_add, show (m : ℂ) * (2 * Real.pi) * Complex.I =
      m * (2 * Real.pi * Complex.I) by ring, Complex.exp_int_mul_two_pi_mul_I, mul_one]
    conv_lhs => rw [← Complex.norm_mul_exp_arg_mul_I a, ha1]
    simp
  refine ⟨t, ⟨ht, hta, fun s x ↦ ?_⟩, ?_⟩
  · obtain ⟨n, hn, hnorm⟩ := unramifiedHeckeCharacter_existsUnique_phase_local _ v hχ π _hπ x
    rw [norm_uniformizer_adicCompletion v _ _hπ] at hnorm
    rw [htwist, ← hχ0, hn]
    have hr : (0 : ℝ) < ((q : ℝ)⁻¹) ^ n := zpow_pos (inv_pos.mpr (zero_lt_one.trans hq1)) n
    rw [hnorm, Complex.cpow_add _ _ (by exact_mod_cast hr.ne'), mul_comm (_ ^ s)]
    congr 1
    rw [← hadef, hta, hcpow, ← Complex.exp_int_mul, ← hqdef,
      Complex.cpow_def_of_ne_zero (by exact_mod_cast hr.ne'),
      ← Complex.ofReal_log hr.le, Real.log_zpow, Real.log_inv]
    congr 1
    push_cast
    rw [hlog]
    ring
  · rintro t' ⟨ht', hta', -⟩
    rw [hta, hcpow, hcpow, Complex.exp_eq_exp_iff_exists_int] at hta'
    obtain ⟨n, hn⟩ := hta'
    have h2 : (t' - t) * ℓ = n * (2 * Real.pi) := by
      have := congrArg Complex.im hn
      simp at this
      linarith
    have hd : t' - t = n * (2 * Real.pi / ℓ) := by field_simp; linarith
    have hlt : (n : ℝ) * (2 * Real.pi / ℓ) < 1 * (2 * Real.pi / ℓ) := by
      rw [← hd]; linarith [ht.1, ht'.2]
    have hgt : (-1 : ℝ) * (2 * Real.pi / ℓ) < n * (2 * Real.pi / ℓ) := by
      rw [← hd]; linarith [ht.2, ht'.1]
    have h1 : (n : ℝ) < 1 := lt_of_mul_lt_mul_right hlt hP.le
    have h3 : (-1 : ℝ) < n := lt_of_mul_lt_mul_right hgt hP.le
    have : n = 0 := by
      have : n < 1 := by exact_mod_cast h1
      have : -1 < n := by exact_mod_cast h3
      omega
    subst this
    simp at hd
    linarith


/-- Paper: Equation (6.3.1.4), p. 303.
The reciprocal of the unramified Euler factor is the geometric denominator with
the local phase. Inversion expresses the formula through its poles. -/
theorem finiteHeckeEulerFactor_inv_eq_phase (χ : U) (v : V)
    (hχ : χ₀(χ).IsUnramifiedAt v) (t : ℝ)
    (ht : χ₀(χ).localValue v = (q(v) : ℂ) ^ (-(t : ℂ) * Complex.I)) (s : ℂ) :
    (finiteHeckeEulerFactor χ v s)⁻¹ = 1 - (q(v) : ℂ) ^ (-s - (t : ℂ) * Complex.I) := by
  classical
  have hq : (q(v) : ℂ) ≠ 0 := by
    exact_mod_cast (zero_lt_one.trans (HeightOneSpectrum.one_lt_absNorm v)).ne'
  rw [finiteHeckeEulerFactor, ite_eq_left hχ, inv_inv, ht, ← Complex.cpow_add _ _ hq]
  ring_nf

-- The ramified and infinite factors are already given by `finiteHeckeEulerFactor`,
-- `realHeckeCharacter_parameters`, `complexHeckeCharacter_parameters` and `heckeGammaFactor`.
-- In Terminology 6.3.1.1 the descent is `sIdeleRestriction` from §3.1 and the
-- product (6.3.1.5) is `sLocalHeckeL` from §3.3.

/-- Paper: Terminology 6.3.1.1, p. 303.
The S-local Hecke L-function and the local functional-equation factor have the
same poles with the same orders.
Deviation: This local comparison applies to every unitary character of the S-idèle quotient. -/
theorem sLocalHeckeL_poleOrder_eq (S : Finset V) (χ : PontryaginDual (SIdeleQuotient F S))
    (s : ℂ) :
    min 0 (meromorphicOrderAt (fun z ↦ sLocalHeckeL (normChartₛ(χ) z)) s) =
      min 0 (meromorphicOrderAt (fun z ↦ sLocalRhoFactor (normChartₛ(χ) z)) s) := by
  sorry

/-- Paper: Terminology 6.3.1.1, p. 303.
The completed Hecke L-function on the norm chart is the meromorphic continuation
of the Euler product of §3.2. -/
abbrev continuedCompletedHeckeL (χ : U) : ℂ → ℂ :=
  (completedHeckeL_exists_continuation χ).choose

/-- Paper: Terminology 6.3.1.1, p. 303.
The continuation is in meromorphic normal form and recovers the completed Euler
product on the half-plane of absolute convergence. -/
theorem continuedCompletedHeckeL_spec (χ : U) :
    MeromorphicNFOn (continuedCompletedHeckeL χ) univ ∧
      ∀ s : halfPlane, continuedCompletedHeckeL χ s = completedHeckeL χ s :=
  (completedHeckeL_exists_continuation χ).choose_spec

/-- Paper: Equation (6.3.1.6), p. 303.
The product outside S divides the completed Hecke L-function by the S-local factor.
Deviation: Normal form fills in removable singularities of the quotient. Restriction and
this product are defined for every S outside which the character is unramified. -/
def heckeEulerProductOutside (S : Finset V) (χ : U)
    (hχ : χ₀(χ) ∈ unramifiedOutside F S) : ℂ → ℂ :=
  let twist := quasiCharacterNormTwist (sIdeleQuotientNorm F S)
    (isProperMap_sIdeleQuotientNorm F S).continuous (sIdeleRestriction F S ⟨χ₀(χ), hχ⟩)
  toMeromorphicNFOn
    (fun s ↦ continuedCompletedHeckeL χ s / sLocalHeckeL (twist s)) univ

/-- Paper: Equation (6.3.1.6), p. 303.
The outside product equals the finite continuation with the finite factors in S removed,
as used in Appendix B.6. -/
theorem heckeEulerProductOutside_eq_finite (S : Finset V) (χ : U)
    (hχ : χ₀(χ) ∈ unramifiedOutside F S) (L : ℂ → ℂ)
    (_hL : MeromorphicNFOn L univ) (_hSeries : ∀ s : halfPlane, L s = finiteHeckeL χ s) :
    heckeEulerProductOutside S χ hχ = toMeromorphicNFOn
      (fun s ↦ reciprocalPartialHeckeEulerProduct χ S s * L s) univ := by
  sorry

section GlobalConverse

local notation "ℬ" => SchwartzBruhat (Multiplicative 𝔸[F])
local notation "P" => adelePolarSubspace F
local notation "Θ(" ω ")" => GlobalHomogeneousThetaSpace F ω
local notation "K(" ω ")" => LinearMap.ker (homogeneousAdelicThetaLinearMap F ω)
local notation "Z(" f ", " χ ", " s ")" => globalIdelicZFunction f (ideleClassNormTwist χ s)
local notation "B" => SchwartzBergman (univ : Set ℝ)
local notation "bergmanIdeal(" G ")" =>
  {φ : B | ∃ u : ℂ → ℂ, Differentiable ℂ u ∧ ∀ s, φ.val s = (G : ℂ → ℂ) s * u s}
local notation "shift(" t ")" => ((t : ℝ) : ℂ) * Complex.I
local notation "polePolynomial(" t ")" => (fun s : ℂ ↦ (s + shift(t)) * (1 - s - shift(t)))
local notation "regularizedL(" χ ", " t ")" =>
  toMeromorphicNFOn (fun s ↦ polePolynomial(t) s * continuedCompletedHeckeL χ s) univ
local notation "zeroAdele" => Multiplicative.ofAdd (0 : 𝔸[F])
local notation "mass" => ((normOneIdeleClassTamagawaMeasure F univ).toReal : ℂ)

/-- Paper: Theorem 6.3.2.1(2), p. 304, following equation (6.3.2.6).
Integrating the homogeneous theta representative over the full class group
multiplies its component Mellin transform by the norm-one class mass.
Deviation: The component Mellin transform in (5.2.3.14) uses the norm-section
integral with dt/t. Dividing the displayed full class integral by the mass gives
that transform on its half-plane of absolute convergence. The same convention
applies after (6.3.2.22). -/
theorem homogeneousTheta_classMellin_eq_mass_mul (χ : U) (f : ℬ) (s : halfPlane) :
    let c := ideleClassNormTwist χ (s : ℂ)
    let integrand := fun g : C𝔽 ↦ homogeneousAdelicTheta χ₁(χ) f g * c g
    Integrable integrand (ideleClassTamagawaMeasure F) ∧
      (∫ g, integrand g ∂ideleClassTamagawaMeasure F) = mass * Z(f, χ, (s : ℂ)) := by
  sorry

-- Equation (6.3.2.1) is `adelePolarSubspace`. Equation (6.3.2.2) is
-- `globalThetaPolarValues_fst_translate` and `globalThetaPolarValues_snd_translate`.
-- TODO(paper-gap): The identities following (6.3.2.2) lose the Gaussian values.
-- Use `globalThetaPolarValues_eq_eigendistributions` from §5.5.

/-- Paper: Theorem 6.3.2.1(1), p. 304, equation (6.3.2.3).
On a nontrivial norm-one component the global Mellin transform is a closed
topological embedding with range the completed Hecke principal ideal in the
Schwartz–Bergman space. -/
theorem globalConverse_nontrivial (χ : U) (_hχ : χ₁(χ) ≠ 1) :
    ∃ ZB : Θ(χ₁(χ)) →L[ℂ] B, IsClosedEmbedding ZB ∧
      (∀ (f : ℬ) s, (ZB ((K(χ₁(χ))).mkQ f)).val s = Z(f, χ, s)) ∧
      Set.range ZB = bergmanIdeal(continuedCompletedHeckeL χ) := by
  sorry

/-- Paper: Theorem 6.3.2.1(1)–(2), p. 304.
A unitary character trivial on the norm-one subgroup has a unique real
norm-twist parameter. -/
theorem globalConverse_existsUnique_normTwist (χ : U) (_hχ : χ₁(χ) = 1) :
    ∃! t : ℝ, χ₀(χ) = ideleClassNormTwist (1 : U) (shift(t)) := by
  have hTriv (g : C𝔽) (hg : ideleClassNorm F g = 1) : χ g = 1 :=
    DFunLike.congr_fun _hχ ⟨g, hg⟩
  let q : IdeleGroup (𝓞 F) F →ₜ* C𝔽 := ⟨QuotientGroup.mk' _, continuous_quotient_mk'⟩
  let σ : ℝ≥0ˣ →ₜ* C𝔽 := q.comp
    ⟨canonicalIdeleNormSection F, canonicalIdeleNormSection_continuous F⟩
  have hσ : RightInverse σ (ideleClassNorm F) := canonicalIdeleNormSection_rightInverse F
  let j : Circle →ₜ* ℂ := ⟨Circle.coeHom, continuous_subtype_val⟩
  obtain ⟨z, ⟨hzre, hz⟩, huniq⟩ :=
    existsUnique_unitaryComplexPower (j.comp (χ.comp σ)) (fun r ↦ Circle.norm_coe _)
  have hval (ψ : U) (s : ℂ) (g : C𝔽) : ideleClassNormTwist ψ s g =
      (ψ g : ℂ) * (((ideleClassNorm F g : ℝ≥0) : ℝ) : ℂ) ^ s := rfl
  have hzI : z = shift(z.im) := by
    apply Complex.ext <;> simp [hzre]
  have hχg (g : C𝔽) : (χ g : ℂ) = (((ideleClassNorm F g : ℝ≥0) : ℝ) : ℂ) ^ z := by
    have hn : ideleClassNorm F (g * (σ (ideleClassNorm F g))⁻¹) = 1 := by
      rw [map_mul, map_inv, hσ _, mul_inv_cancel]
    have hg : g = (g * (σ (ideleClassNorm F g))⁻¹) * σ (ideleClassNorm F g) := by group
    conv_lhs => rw [hg, map_mul, hTriv _ hn, one_mul]
    exact hz (ideleClassNorm F g)
  refine ⟨z.im, ?_, fun t ht ↦ ?_⟩
  · ext g
    rw [hval, hval, Complex.cpow_zero, mul_one, PontryaginDual.one_apply, Circle.coe_one, one_mul,
      ← hzI]
    exact hχg g
  · have := huniq (shift(t)) ⟨by simp, fun r ↦ ?_⟩
    · rw [← this]; simp
    have h := DFunLike.congr_fun ht (σ r)
    rw [hval, hval, Complex.cpow_zero, mul_one, PontryaginDual.one_apply, Circle.coe_one,
      one_mul, hσ r] at h
    exact h


/-- Paper: Theorem 6.3.2.1(1), p. 304, equation (6.3.2.4).
On tests with both polar values zero the Mellin transform is relatively open,
with closed range generated by the pole-cancelled completed Hecke L-function.
Its kernel is the restriction of the trivial homogeneous theta kernel.
Deviation: Normal form supplies the regularized generator's values at the two poles. -/
theorem globalConverse_normTwist (χ : U) (t : ℝ)
    (_hχ : χ₀(χ) = ideleClassNormTwist (1 : U) (shift(t))) :
    ∃ ZB : P →L[ℂ] B, IsOpenMap ZB.rangeRestrict ∧ IsClosed (Set.range ZB) ∧
      (∀ (f : P) s, (ZB f).val s = Z(f.val, χ, s)) ∧
      Set.range ZB = bergmanIdeal(regularizedL(χ, t)) ∧
      ZB.ker = (K(1)).comap (P).subtype := by
  sorry

/-- Paper: Theorem 6.3.2.1(2), p. 304, equation (6.3.2.5).
The ordinary pole-free theta space is the topological quotient of the polar
test subspace by the restriction of the ordinary theta kernel. -/
abbrev GlobalPolarFreeThetaSpace (F : Type*) [Field F] [NumberField F] :=
  (adelePolarSubspace F) ⧸ (LinearMap.ker (adelicThetaLinearMap F)).comap (adelePolarSubspace F).subtype

/-- In a quotient of a submodule by the pullback of a kernel, two classes agree exactly when
the linear map agrees on their representatives. Stated for abstract modules, so that it
elaborates without unfolding the Schwartz–Bruhat instances. -/
private theorem globalPolarFreeThetaSpace_mk_eq_iff_quotient {R M N : Type*} [CommRing R]
    [AddCommGroup M] [Module R M] [AddCommGroup N] [Module R N] (Q : Submodule R M)
    (θ : M →ₗ[R] N) (f g : Q) :
    (Submodule.Quotient.mk f : Q ⧸ (LinearMap.ker θ).comap Q.subtype) =
        Submodule.Quotient.mk g ↔
      θ f = θ g := by
  rw [Submodule.Quotient.eq, Submodule.mem_comap, LinearMap.mem_ker, map_sub,
    Submodule.subtype_apply, Submodule.subtype_apply, map_sub, sub_eq_zero]

/-- Paper: Theorem 6.3.2.1(2), p. 304, equation (6.3.2.5).
Two pole-free tests give the same quotient class exactly when their ordinary
theta functions agree. -/
theorem globalPolarFreeThetaSpace_mk_eq_iff (f g : P) :
    (Submodule.Quotient.mk f : GlobalPolarFreeThetaSpace F) = Submodule.Quotient.mk g ↔
      adelicThetaLinearMap F f.val = adelicThetaLinearMap F g.val := by
  exact globalPolarFreeThetaSpace_mk_eq_iff_quotient (adelePolarSubspace F)
    (adelicThetaLinearMap F) f g

/-- Paper: Theorem 6.3.2.1(2), p. 304, equation (6.3.2.5).
The pole-free theta quotient is represented by the image of the polar test
subspace in the homogeneous theta space. The natural quotient topology is
identified with the subspace topology by the open quotient assertions below. -/
def globalPolarFreeThetaSubmodule (ω : PontryaginDual C₁) : Submodule ℂ Θ(ω) :=
  (P).map (K(ω)).mkQ

/-- Paper: Theorem 6.3.2.1(2), p. 304, equation (6.3.2.5).
A homogeneous class belongs to the pole-free subspace exactly when it has
a representative with both polar values zero. -/
theorem mem_globalPolarFreeThetaSubmodule (ω : PontryaginDual C₁) (x : Θ(ω)) :
    x ∈ globalPolarFreeThetaSubmodule ω ↔
      ∃ f : ℬ, f zeroAdele = 0 ∧ adeleSchwartzFourier f zeroAdele = 0 ∧ (K(ω)).mkQ f = x := by
  simp only [globalPolarFreeThetaSubmodule, Submodule.mem_map, mem_adelePolarSubspace, and_assoc]

-- Helpers for `globalConverse_nontrivial_exact`. The first four repeat private lemmas of
-- Ch05 §5 (`globalTheta_unitTranslate_apply`, `homogeneousTheta_unitTranslate`,
-- `adeleSchwartzFourier_zero_unitTranslate`). The main argument: for a norm-one idele `u`
-- with `ω [u] ≠ 1`, `(1 - ω [u])⁻¹ • (τᵤ b - ω [u] • b)` lies in the homogeneous theta
-- kernel and has the polar values of `b`; subtracting such correctors gives a continuous
-- retraction of the test space onto the polar subspace that preserves the theta class.
-- Elaboration note: `obtain` from `DFunLike.ne_iff.mp` or `QuotientGroup.mk_surjective`
-- inside the main statement ran for over ten minutes, hence the explicit helpers.

/-- Global theta of a unit translate is theta at the inversely translated idele class. -/
private theorem globalConverse_nontrivial_exact_theta_translate (g : IdeleGroup (𝓞 F) F)
    (f : ℬ) (a : C𝔽) :
    adelicTheta (schwartzBruhatUnitTranslate g f) a =
      adelicTheta f ((QuotientGroup.mk g)⁻¹ * a) := by
  induction a using QuotientGroup.induction_on with | H x => ?_
  change _ = adelicTheta f (QuotientGroup.mk (g⁻¹ * x))
  rw [adelicTheta_mk (schwartzBruhatUnitTranslate g f) x, adelicTheta_mk f (g⁻¹ * x)]
  exact tsum_congr fun t ↦ congrArg (fun y ↦ f (Multiplicative.ofAdd y))
    (mul_left_comm g.inv (algebraMap F 𝔸[F] (t : F)) x.val)

private theorem globalConverse_nontrivial_exact_homTheta_translate (ω : PontryaginDual C₁)
    (g : C₁) (u : IdeleGroup (𝓞 F) F) (hu : QuotientGroup.mk u = g.val) (f : ℬ) :
    homogeneousAdelicThetaLinearMap F ω (schwartzBruhatUnitTranslate u f) =
      (ω g : ℂ) • homogeneousAdelicThetaLinearMap F ω f := by
  refine ContinuousMap.ext fun x ↦ ?_
  refine Eq.trans ?_ ((homogeneousAdelicTheta_homogeneous ω f g x).trans
    ((ContinuousMap.smul_apply (ω g : ℂ) (homogeneousAdelicThetaLinearMap F ω f) x).trans
      (smul_eq_mul _ _)).symm)
  change homogeneousAdelicTheta ω (schwartzBruhatUnitTranslate u f) x =
    homogeneousAdelicTheta ω f (g.val⁻¹ * x)
  refine congrArg (MeasureTheory.integral _) (funext fun h ↦ ?_)
  refine congrArg (· * (ω h : ℂ))
    ((globalConverse_nontrivial_exact_theta_translate u f _).trans ?_)
  rw [hu, mul_left_comm]

private theorem globalConverse_nontrivial_exact_fourier_integral (u : IdeleGroup (𝓞 F) F)
    (k : 𝔸[F] → ℂ) :
    ∫ x, k ((↑u⁻¹ : 𝔸[F]) * x) ∂additiveTamagawaMeasure F =
      (((ideleNorm F u).val : ℝ) : ℂ) * ∫ x, k x ∂additiveTamagawaMeasure F := by
  let : MeasurableSpace 𝔸[F] := borel _
  have : BorelSpace 𝔸[F] := ⟨rfl⟩
  have hH : (additiveTamagawaMeasure F).IsAddHaarMeasure :=
    (additiveTamagawaMeasure_existsUnique F).exists.choose_spec.1
  let d : 𝔸[F] ≃ₜ 𝔸[F] := Homeomorph.smul (u⁻¹ : IdeleGroup (𝓞 F) F)
  have hset (s : Set 𝔸[F]) :
      d ⁻¹' s = (fun a : 𝔸[F] ↦ (u : 𝔸[F]) * a) '' s := by
    ext y
    constructor
    · intro hy
      exact ⟨(↑u⁻¹ : 𝔸[F]) * y, hy, Units.mul_inv_cancel_left u y⟩
    · rintro ⟨a, ha, rfl⟩
      change (↑u⁻¹ : 𝔸[F]) * ((u : 𝔸[F]) * a) ∈ s
      rwa [Units.inv_mul_cancel_left]
  have hmap : (additiveTamagawaMeasure F).map d =
      ((ideleNorm F u).val : ENNReal) • additiveTamagawaMeasure F := by
    refine Measure.ext fun s hs ↦ ?_
    rw [Measure.map_apply d.continuous.measurable hs, hset s]
    exact adeleHaar_mul_image F (additiveTamagawaMeasure F) u s hs
  have h1 : ∫ x, k (d.toMeasurableEquiv x) ∂additiveTamagawaMeasure F =
      ∫ y, k y ∂((additiveTamagawaMeasure F).map d.toMeasurableEquiv) :=
    (integral_map_equiv d.toMeasurableEquiv k).symm
  have h2 : ((additiveTamagawaMeasure F).map d.toMeasurableEquiv) =
      ((ideleNorm F u).val : ENNReal) • additiveTamagawaMeasure F := hmap
  rw [h2, integral_smul_measure, ENNReal.coe_toReal, Complex.real_smul] at h1
  exact h1

private theorem globalConverse_nontrivial_exact_fourier_translate (u : IdeleGroup (𝓞 F) F)
    (f : ℬ) :
    adeleSchwartzFourier (schwartzBruhatUnitTranslate u f) zeroAdele =
      (((ideleNorm F u).val : ℝ) : ℂ) * adeleSchwartzFourier f zeroAdele := by
  have hA := (adeleSchwartzFourier_apply_zero (schwartzBruhatUnitTranslate u f)).2
  have hB := (adeleSchwartzFourier_apply_zero f).2
  have hI := globalConverse_nontrivial_exact_fourier_integral u
    (fun z : 𝔸[F] ↦ f (Multiplicative.ofAdd z))
  exact hA.trans (hI.trans (congrArg _ hB.symm))

private theorem globalConverse_nontrivial_exact_openQuotient {E : Type*}
    [AddCommGroup E] [Module ℂ E] [TopologicalSpace E] [IsTopologicalAddGroup E]
    (K Q : Submodule ℂ E) (T : E → Q) (hT : Continuous T)
    (hTQ : ∀ p : Q, T p = p) (hK : ∀ f, (T f : E) - f ∈ K) :
    IsOpenQuotientMap (K.mkQ.comp Q.subtype) := by
  have hmk (f : E) : K.mkQ (T f : E) = K.mkQ f := (Submodule.Quotient.eq K).mpr (hK f)
  have hq := K.isOpenQuotientMap_mkQ
  refine ⟨fun x ↦ ?_, hq.continuous.comp continuous_subtype_val, fun W hU ↦ ?_⟩
  · obtain ⟨f, rfl⟩ := K.mkQ_surjective x
    exact ⟨T f, hmk f⟩
  · have himg : (K.mkQ.comp Q.subtype) '' W = K.mkQ '' (T ⁻¹' W) := by
      ext x
      constructor
      · rintro ⟨p, hp, rfl⟩
        refine ⟨p, ?_, rfl⟩
        change T p ∈ W
        rwa [hTQ p]
      · rintro ⟨f, hf, rfl⟩
        exact ⟨T f, hf, hmk f⟩
    rw [himg]
    exact hq.isOpenMap _ (hU.preimage hT)

private theorem globalConverse_nontrivial_exact_one_sub_ne {G : Type*} [Monoid G]
    [TopologicalSpace G] (ω : PontryaginDual G) (c : G) (h : ω c ≠ (1 : PontryaginDual G) c) :
    (1 : ℂ) - (ω c : ℂ) ≠ 0 := by
  rw [PontryaginDual.one_apply] at h
  intro h'
  exact h (Circle.ext (by rw [Circle.coe_one]; linear_combination -h'))

private theorem globalConverse_nontrivial_exact_norm_eq_one (u : IdeleGroup (𝓞 F) F)
    (c : IdeleClassGroup (𝓞 F) F) (hc : ideleClassNorm F c = 1)
    (hu : (QuotientGroup.mk u : IdeleClassGroup (𝓞 F) F) = c) : ideleNorm F u = 1 := by
  rw [← hc, ← hu]
  rfl

private theorem globalConverse_nontrivial_exact_of_polar {E : Type*}
    [AddCommGroup E] [Module ℂ E] [TopologicalSpace E] [IsTopologicalAddGroup E]
    [ContinuousSMul ℂ E] (K Q : Submodule ℂ E) (pv : E →ₗ[ℂ] ℂ × ℂ) (hpv : Continuous pv)
    (hQ : ∀ f, f ∈ Q ↔ pv f = 0) (k₁ k₂ : E) (hk₁ : k₁ ∈ K) (hk₂ : k₂ ∈ K)
    (h₁ : pv k₁ = (1, 0)) (h₂ : pv k₂ = (0, 1)) :
    IsOpenQuotientMap (K.mkQ.comp Q.subtype) := by
  let T₀ : E → E := fun f ↦ f - (pv f).1 • k₁ - (pv f).2 • k₂
  have hT₀Q (f : E) : T₀ f ∈ Q := by
    rw [hQ]
    simp only [T₀, map_sub, map_smul, h₁, h₂]
    ext <;> simp
  have hT₀c : Continuous T₀ :=
    (continuous_id.sub ((continuous_fst.comp hpv).smul continuous_const)).sub
      ((continuous_snd.comp hpv).smul continuous_const)
  refine globalConverse_nontrivial_exact_openQuotient K Q (fun f ↦ ⟨T₀ f, hT₀Q f⟩)
    (hT₀c.subtype_mk _) (fun p ↦ Subtype.ext ?_) (fun f ↦ ?_)
  · have hp : pv p = 0 := (hQ p).mp p.2
    change (p : E) - (pv p).1 • k₁ - (pv p).2 • k₂ = p
    rw [hp]
    simp
  · change (f - (pv f).1 • k₁ - (pv f).2 • k₂) - f ∈ K
    rw [show f - (pv f).1 • k₁ - (pv f).2 • k₂ - f = -((pv f).1 • k₁ + (pv f).2 • k₂) by abel]
    exact K.neg_mem (K.add_mem (K.smul_mem _ hk₁) (K.smul_mem _ hk₂))

private theorem globalConverse_nontrivial_exact_corrector {E M : Type*}
    [AddCommGroup E] [Module ℂ E] [AddCommGroup M] [Module ℂ M]
    (θ : E →ₗ[ℂ] M) (pv : E →ₗ[ℂ] ℂ × ℂ) (w : ℂ) (hw : (1 : ℂ) - w ≠ 0) (b τb : E)
    (hθ : θ τb = w • θ b) (hpv : pv τb = pv b) :
    (1 - w)⁻¹ • (τb - w • b) ∈ LinearMap.ker θ ∧ pv ((1 - w)⁻¹ • (τb - w • b)) = pv b := by
  constructor
  · rw [LinearMap.mem_ker, map_smul, map_sub, map_smul, hθ, sub_self, smul_zero]
  · rw [map_smul, map_sub, map_smul, hpv,
      show pv b - w • pv b = (1 - w) • pv b by rw [sub_smul, one_smul], smul_smul,
      inv_mul_cancel₀ hw, one_smul]

private theorem globalConverse_nontrivial_exact_polar_translate (u : IdeleGroup (𝓞 F) F)
    (hnorm : ideleNorm F u = 1) (b : ℬ) :
    adelePolarValues (F := F) (schwartzBruhatUnitTranslate u b) = adelePolarValues (F := F) b := by
  refine Prod.ext ?_ ?_
  · change schwartzBruhatUnitTranslate u b zeroAdele = b zeroAdele
    rw [schwartzBruhatUnitTranslate_apply, mul_zero]
  · change adeleSchwartzFourier (schwartzBruhatUnitTranslate u b) zeroAdele =
      adeleSchwartzFourier b zeroAdele
    rw [globalConverse_nontrivial_exact_fourier_translate, hnorm]
    simp

private theorem globalConverse_nontrivial_exact_exists_lift (c : IdeleClassGroup (𝓞 F) F)
    (hc : ideleClassNorm F c = 1) :
    ∃ u : IdeleGroup (𝓞 F) F,
      (QuotientGroup.mk u : IdeleClassGroup (𝓞 F) F) = c ∧ ideleNorm F u = 1 := by
  obtain ⟨u, hu⟩ := QuotientGroup.mk_surjective c
  exact ⟨u, hu, globalConverse_nontrivial_exact_norm_eq_one u c hc hu⟩

set_option linter.all false in
private theorem globalConverse_nontrivial_exact_core (ω : PontryaginDual C₁) (c : C₁)
    (hw : (1 : ℂ) - (ω c : ℂ) ≠ 0) (u : IdeleGroup (𝓞 F) F)
    (hu : (QuotientGroup.mk u : IdeleClassGroup (𝓞 F) F) = c.val) (hnorm : ideleNorm F u = 1)
    (b₁ b₂ : ℬ) (hb₁ : adelePolarValues (F := F) b₁ = (1, 0))
    (hb₂ : adelePolarValues (F := F) b₂ = (0, 1)) :
    IsOpenQuotientMap ((K(ω)).mkQ.comp (P).subtype) := by
  have hθ (b : ℬ) := globalConverse_nontrivial_exact_homTheta_translate ω c u hu b
  have hτ (b : ℬ) := globalConverse_nontrivial_exact_polar_translate u hnorm b
  have e₁ := globalConverse_nontrivial_exact_corrector
    (homogeneousAdelicThetaLinearMap F ω) (adelePolarValues (F := F)) (ω c : ℂ) hw b₁ _ (hθ b₁) (hτ b₁)
  have e₂ := globalConverse_nontrivial_exact_corrector
    (homogeneousAdelicThetaLinearMap F ω) (adelePolarValues (F := F)) (ω c : ℂ) hw b₂ _ (hθ b₂) (hτ b₂)
  let : ContinuousSMul ℂ ℬ := (PolynormableSpace.withSeminorms ℂ ℬ).continuousSMul
  exact globalConverse_nontrivial_exact_of_polar (K(ω)) P (adelePolarValues (F := F))
    (adelePolarValues_continuous (F := F)) (fun f ↦ Iff.rfl) _ _ e₁.1 e₂.1
    (e₁.2.trans hb₁) (e₂.2.trans hb₂)

-- TODO(paper-gap): The codomain in (6.3.2.5) is zero on a nontrivial norm-one
-- component. The map (6.3.2.6) is identically zero there.

set_option linter.all false in
/-- Paper: Theorem 6.3.2.1(2), p. 304, equations (6.3.2.5) and (6.3.2.7).
On a nontrivial norm-one component the polar test subspace maps openly and
surjectively onto the full homogeneous theta space. In Mellin coordinates
the inclusion becomes the identity of the range in (6.3.2.3).
Deviation: The terminal residue space is zero on this component, as in (6.3.2.7). -/
theorem globalConverse_nontrivial_exact (ω : PontryaginDual C₁) (_hω : ω ≠ 1) :
    IsOpenQuotientMap ((K(ω)).mkQ.comp (P).subtype) := by
  have h2 : ∃ c : C₁, ω c ≠ (1 : PontryaginDual C₁) c := DFunLike.ne_iff.mp _hω
  have hl := globalConverse_nontrivial_exact_exists_lift h2.choose.val h2.choose.prop
  have e₁ := adelePolarValues_surjective (F := F) (1, 0)
  have e₂ := adelePolarValues_surjective (F := F) (0, 1)
  exact globalConverse_nontrivial_exact_core ω h2.choose
    (globalConverse_nontrivial_exact_one_sub_ne ω _ h2.choose_spec) hl.choose hl.choose_spec.1
    hl.choose_spec.2 e₁.choose e₂.choose e₁.choose_spec e₂.choose_spec

/-- Paper: Theorem 6.3.2.1(2), p. 304, equations (6.3.2.5)–(6.3.2.6).
The signed polar evaluations descend to a continuous residue map on the trivial
norm-one quotient. Its kernel is the pole-free theta subspace with its quotient
topology, and the residue map is open and surjective. -/
theorem globalConverse_normTwist_exact :
    ∃ R : Θ(1) →L[ℂ] ℂ × ℂ,
      (∀ f : ℬ, R ((K(1)).mkQ f) = (-mass * f zeroAdele,
        mass * adeleSchwartzFourier f zeroAdele)) ∧
      R.ker = globalPolarFreeThetaSubmodule (F := F) 1 ∧ IsOpenQuotientMap R ∧
      IsOpenQuotientMap (((K(1)).mkQ.comp (P).subtype).rangeRestrict) := by
  sorry

-- TODO(paper-gap): In (6.3.2.8), the middle ideal contains functions with
-- poles, so intersection with the entire Schwartz–Bergman space kills both
-- residues. The first pole-cancelling factor must be s + it₀.

/-- Paper: Theorem 6.3.2.1(2), pp. 304–305, equation (6.3.2.8).
The Mellin chart identifies the trivial norm-one quotient with the meromorphic
Mellin image and its pole-free subspace with the kernel of the two residues.
A function on the punctured chart is in the middle term exactly when multiplying
by the pole polynomial extends it to the pole-cancelled Schwartz–Bergman ideal.
Deviation: The middle term uses the Mellin image with the stated quotient
topology. Its elements are represented by their values away from the two
possible poles. The growth test is on the polynomial multiple, which extends
across both poles. The left term uses the pole-cancelled generator and the
Schwartz–Bergman subspace topology of (6.3.2.4). -/
theorem globalConverse_normTwist_meromorphic_exact (χ : U) (t : ℝ)
    (_hχ : χ₀(χ) = ideleClassNormTwist (1 : U) (shift(t))) :
    let regular := ({-shift(t), 1 - shift(t)} : Set ℂ)ᶜ
    let polarFree := globalPolarFreeThetaSubmodule (F := F) 1
    ∃ (ZB : P →L[ℂ] B) (M : Θ(1) →ₗ[ℂ] regular → ℂ) (R : M.range →ₗ[ℂ] ℂ × ℂ),
      letI : TopologicalSpace M.range := TopologicalSpace.coinduced M.rangeRestrict inferInstance
      IsHomeomorph M.rangeRestrict ∧
      (∀ (f : ℬ) (s : regular), M ((K(1)).mkQ f) s = Z(f, χ, s.val)) ∧
      (∀ (f : P) s, (ZB f).val s = Z(f.val, χ, s)) ∧
      Set.range ZB = bergmanIdeal(regularizedL(χ, t)) ∧
      (∀ h : regular → ℂ, h ∈ M.range ↔
        ∃ b : B, b ∈ bergmanIdeal(regularizedL(χ, t)) ∧
          ∀ s : regular, b.val s.val = polePolynomial(t) s.val * h s) ∧
      (∀ (φ : M.range) (g : ℂ → ℂ), Meromorphic g → (∀ s : regular, g s.val = φ.val s) →
        R φ = (complexResidue g (-shift(t)), complexResidue g (1 - shift(t)))) ∧
      R.ker = polarFree.map M.rangeRestrict ∧ IsOpenQuotientMap R ∧
      IsClosedEmbedding (M.rangeRestrict.comp polarFree.subtype) ∧
      ∃ e : polarFree ≃L[ℂ] ZB.range, ∀ (x : polarFree) (s : regular),
        M x.val s = (e x).val.val s := by
  sorry

-- TODO(paper-gap): The argument on pp. 305–306 glues one-sided pole-cancelled
-- products using an unweighted difference. The two cancellation factors in
-- (6.3.2.11) differ even after applying the global functional equation.
-- TODO(paper-gap): The formula on p. 307 for global insertion omits the outside
-- integer-unit masses. See `weilIdentity_unramifiedOutside_meromorphic`.
-- Include the primes of the different in S for the unweighted local/global
-- Fourier comparison in (6.3.2.13): outside integer indicators must be self-dual.
-- The zero condition after (6.3.2.15) must allow higher multiplicities.
-- At F = ℚ, multiplying the Mellin transform of the Gaussian by s(1-s) gives
-- a pole-free test in (6.3.2.14) whose ψ is Γℝ(s), meromorphic at the trivial
-- zeros of the finite zeta function. The entire quotient here is ψ / Γℝ.
-- The final display on p. 309 yields a pole-polynomial multiple of a transform.
-- To obtain a polar-free test one must realize that multiplier on the test.
-- TODO(paper-gap): The inverse multiplier on p. 308 can have poles on Re s = 0
-- after Euler-factor removal and at trivial zeros of the finite L-function even
-- without any removal. Equations (6.3.2.16)–(6.3.2.17) substitute L_S for L_outside.

section PrincipalValue

local notation "PV(" S ")" => adelePrincipalValue F S
local notation "pvMorphism(" S ", " ω ")" => (K(ω)).mkQ.comp (PV(S))
local notation "pvTheta(" S ", " ω ")" => (pvMorphism(S, ω)).range
local notation "pvPolar(" S ")" => (P).map (PV(S))
local notation "removal(" χ ", " S ")" => reciprocalPartialHeckeEulerProduct χ S

/-- Paper: Theorem 6.3.2.2(1), pp. 309–310, equation (6.3.2.19).
On a nontrivial norm-one component, the principal-value image embeds as the
closed Schwartz–Bergman subspace divisible by the completed Hecke L-function
times the reciprocals of the removed Euler factors. The ramified factors are one. -/
theorem globalPrincipalValueConverse_nontrivial (S : Finset V) (χ : U) (_hχ : χ₁(χ) ≠ 1) :
    ∃ ZB : pvTheta(S, χ₁(χ)) →L[ℂ] B, IsClosedEmbedding ZB ∧
      (∀ (f : ℬ) s, (ZB ((pvMorphism(S, χ₁(χ))).rangeRestrict f)).val s = Z(PV(S) f, χ, s)) ∧
      Set.range ZB = bergmanIdeal(fun s ↦ removal(χ, S) s * continuedCompletedHeckeL χ s) := by
  sorry

-- TODO(paper-gap): Equation (6.3.2.20) uses the unshifted zeta generator and
-- omits the Schwartz–Bergman intersection. Even for S empty and trivial χ,
-- the entire multiple with multiplier exp(s^4) is not Schwartz on a vertical line.

/-- Paper: Theorem 6.3.2.2(1), pp. 309–310, equation (6.3.2.20).
On the principal-value image of the polar test space the Mellin map is open
onto a closed range. Its kernel is the principal-value image of the restricted
trivial homogeneous theta kernel.
Deviation: The generator uses the same norm-twist shift and cancellation as
(6.3.2.4), with the removed Euler factors. Divisibility is tested within the
Schwartz–Bergman space. -/
theorem globalPrincipalValueConverse_normTwist (S : Finset V) (χ : U) (t : ℝ)
    (_hχ : χ₀(χ) = ideleClassNormTwist (1 : U) (shift(t))) :
    ∃ ZB : pvPolar(S) →L[ℂ] B, IsOpenMap ZB.rangeRestrict ∧ IsClosed (Set.range ZB) ∧
      (∀ (f : pvPolar(S)) s, (ZB f).val s = Z(f.val, χ, s)) ∧
      Set.range ZB = bergmanIdeal(fun s ↦ removal(χ, S) s * regularizedL(χ, t) s) ∧
      ZB.ker = (((K(1) ⊓ (P)).map (PV(S))).comap (pvPolar(S)).subtype) := by
  sorry

-- TODO(paper-gap): In (6.3.2.21) the terminal space must be zero on a nontrivial
-- component, as in (6.3.2.23). In a pure norm-twist component with a nonempty
-- removal set, the first residue vanishes on the entire principal-value image.

/-- Paper: Theorem 6.3.2.2(2), p. 310, equations (6.3.2.21) and (6.3.2.23).
On a nontrivial norm-one component, principal values of polar-free tests already
give the full homogeneous principal-value image with its subspace topology.
The inclusion corresponds to the identity on the range in (6.3.2.19).
Deviation: The terminal residue space is zero, as in (6.3.2.23). -/
theorem globalPrincipalValueConverse_nontrivial_exact (S : Finset V)
    (ω : PontryaginDual C₁) (_hω : ω ≠ 1) :
    IsOpenQuotientMap ((pvMorphism(S, ω)).rangeRestrict.comp (P).subtype) := by
  sorry

-- TODO(paper-gap): The powers in (6.3.2.22) drop the local phases when
-- evaluating at the two shifted poles. The factors are 1 - 1 and 1 - qᵥ⁻¹
-- on a pure norm-twist component.

/-- Paper: Theorem 6.3.2.2(2), p. 310, equation (6.3.2.22).
The residues of a principal-value transform are the signed polar evaluations
times the reciprocal partial Euler product at the respective poles.
Deviation: The multipliers are evaluated in the norm-twist chart, retaining
the local phases. -/
theorem globalPrincipalValueConverse_normTwist_residues (S : Finset V) (χ : U) (t : ℝ)
    (_hχ : χ₀(χ) = ideleClassNormTwist (1 : U) (shift(t))) (f : ℬ) :
    (complexResidue (fun s ↦ Z(PV(S) f, χ, s)) (-shift(t)),
      complexResidue (fun s ↦ Z(PV(S) f, χ, s)) (1 - shift(t))) =
      (removal(χ, S) (-shift(t)) * (-mass * f zeroAdele),
        removal(χ, S) (1 - shift(t)) * (mass * adeleSchwartzFourier f zeroAdele)) := by
  sorry

-- TODO(paper-gap): Equations (6.3.2.24)–(6.3.2.26) repeat the shift and entire
-- middle-term errors of (6.3.2.8). Even with those corrected, at F = ℚ, χ = 1
-- and S₀ = {2}, the factor 1 - 2⁻ˢ cancels the pole at zero, so the residues
-- cannot map onto ℂ × ℂ. The divided residues below recover the two coordinates.

/-- Paper: Theorem 6.3.2.2, pp. 309–310.
Principal value multiplies the component Mellin transform by the reciprocal
Euler product, as an identity of meromorphic functions.
Deviation: Pointwise products are compared off a discrete set to allow for cancellation. -/
theorem globalPrincipalValueConverse_mellin (S : Finset V) (χ : U) (f : ℬ) :
    (fun s ↦ Z(PV(S) f, χ, s)) =ᶠ[codiscrete ℂ] (fun s ↦ removal(χ, S) s * Z(f, χ, s)) := by
  sorry

/-- Paper: Theorem 6.3.2.2(2), p. 310, equations (6.3.2.21)–(6.3.2.26).
On the principal-value theta image the two original residue coordinates are
recovered by dividing its Mellin transform by the known Euler multiplier.
Their common kernel is the principal-value image of the pole-free tests.
Deviation: Ordinary residues of the principal-value transform are given above.
For nonempty S its first ordinary residue vanishes identically. Division on
the punctured germs recovers the coefficient lost to that cancellation. -/
theorem globalPrincipalValueConverse_normTwist_divided_exact (S : Finset V) (χ : U) (t : ℝ)
    (_hχ : χ₀(χ) = ideleClassNormTwist (1 : U) (shift(t))) :
    let q := (pvMorphism(S, (1 : PontryaginDual C₁))).rangeRestrict
    ∃ R : pvTheta(S, (1 : PontryaginDual C₁)) →L[ℂ] ℂ × ℂ,
      (∀ f : ℬ,
        let h := fun s ↦ Z(PV(S) f, χ, s) / removal(χ, S) s
        R (q f) = (complexResidue h (-shift(t)), complexResidue h (1 - shift(t)))) ∧
      (∀ f : ℬ, R (q f) = (-mass * f zeroAdele, mass * adeleSchwartzFourier f zeroAdele)) ∧
      R.ker = (P).map q ∧ IsOpenQuotientMap R ∧
      IsOpenQuotientMap (q.comp (P).subtype).rangeRestrict := by
  sorry

end PrincipalValue

end GlobalConverse

end RiemannMasullo
