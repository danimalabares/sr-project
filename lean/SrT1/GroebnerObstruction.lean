import Mathlib

/-!
# Gröbner-degeneration obstruction for SR(M): the finite Gordan certificate

This file formalises the finite combinatorial core of the proof that the
Gulliksen–Negård determinantal CY3 does not admit a coordinate Gröbner
degeneration to the Stanley–Reisner scheme `SR(M)` of Grünbaum's
8-vertex 3-sphere.

The algebraic-geometry reduction (initial ideals, determinantal ideals,
flatness) is NOT formalised here — Mathlib has no Gröbner/initial-ideal
theory in usable form. What IS formalised is the exact statement on which
the whole argument rests:

  There is no weight `ω : Fin 8 → ℚ` making every Stanley–Reisner
  exponent vector `m a` strictly `ω`-heavier than every "pure cube"
  exponent vector `3·e i`.

Equivalently the system `(∗)` of strict inequalities is infeasible. The
proof is a Gordan certificate: the constant weights `λ ≡ 1` on the
`16 × 8` difference vectors `m a − 3 e i` sum to `0`, so a positive
combination of strictly-positive quantities would be `0`. This uses the
combinatorial fact that each variable lies in exactly six of the sixteen
SR generators (so `∑ a, m a = (6,…,6)`).
-/

namespace GroebnerObstruction

open Finset

/-- The 16 Stanley–Reisner exponent vectors of Grünbaum's sphere
(the minimal non-faces), as integer vectors in `Fin 8 → ℤ`. -/
def m : Fin 16 → (Fin 8 → ℤ) :=
  ![ ![0, 0, 0, 0, 0, 1, 1, 1],   -- f1  = x6 x7 x8
     ![0, 0, 0, 1, 0, 1, 0, 1],   -- f2  = x4 x6 x8
     ![0, 0, 1, 0, 0, 0, 1, 1],   -- f3  = x3 x7 x8
     ![0, 0, 1, 0, 1, 0, 1, 0],   -- f4  = x3 x5 x7
     ![0, 0, 1, 1, 0, 0, 0, 1],   -- f5  = x3 x4 x8
     ![0, 1, 0, 0, 0, 0, 1, 1],   -- f6  = x2 x7 x8
     ![0, 1, 0, 0, 1, 0, 1, 0],   -- f7  = x2 x5 x7
     ![0, 1, 0, 0, 1, 1, 0, 0],   -- f8  = x2 x5 x6
     ![0, 1, 0, 1, 0, 0, 1, 0],   -- f9  = x2 x4 x7
     ![0, 1, 0, 1, 0, 1, 0, 0],   -- f10 = x2 x4 x6
     ![1, 0, 0, 1, 0, 1, 0, 0],   -- f11 = x1 x4 x6
     ![1, 0, 0, 1, 1, 0, 0, 0],   -- f12 = x1 x4 x5
     ![1, 0, 1, 0, 0, 0, 0, 1],   -- f13 = x1 x3 x8
     ![1, 0, 1, 0, 0, 1, 0, 0],   -- f14 = x1 x3 x6
     ![1, 0, 1, 0, 1, 0, 0, 0],   -- f15 = x1 x3 x5
     ![1, 1, 0, 0, 1, 0, 0, 0] ]  -- f16 = x1 x2 x5

/-- The 8 "pure cube" exponent vectors `3·e i` (the monomials `x_i^3`),
which are non-faces, hence not in `I_SR`. -/
def cube : Fin 8 → (Fin 8 → ℤ) := fun i => fun j => if i = j then 3 else 0

/-- The `16 × 8` difference vectors of the constraint system `(∗)`. -/
def d (p : Fin 16 × Fin 8) : Fin 8 → ℤ := m p.1 - cube p.2

/-- A rational weight applied to an integer exponent vector. -/
def dotq (ω : Fin 8 → ℚ) (v : Fin 8 → ℤ) : ℚ := ∑ i, ω i * (v i : ℚ)

lemma dotq_add (ω : Fin 8 → ℚ) (v w : Fin 8 → ℤ) :
    dotq ω (v + w) = dotq ω v + dotq ω w := by
  simp only [dotq, Pi.add_apply, Int.cast_add, mul_add, Finset.sum_add_distrib]

lemma dotq_zero (ω : Fin 8 → ℚ) : dotq ω 0 = 0 := by
  simp [dotq]

/-- Linearity of `dotq ω` over a finite sum of integer vectors. -/
lemma dotq_sum {ι : Type*} (ω : Fin 8 → ℚ) (s : Finset ι) (f : ι → Fin 8 → ℤ) :
    dotq ω (∑ p ∈ s, f p) = ∑ p ∈ s, dotq ω (f p) := by
  classical
  induction s using Finset.induction_on with
  | empty => simp [dotq_zero]
  | @insert a s h ih =>
      rw [Finset.sum_insert h, Finset.sum_insert h, dotq_add, ih]

/-- **Gordan certificate.** The difference vectors sum to zero:
`∑_{a,i} (m a − 3 e i) = 0`. This encodes that each variable lies in
exactly six of the sixteen SR generators. -/
lemma sum_d_eq_zero : (∑ p : Fin 16 × Fin 8, d p) = 0 := by
  native_decide

/-- **Main lemma (infeasibility of the separation system `(∗)`).**
There is no weight `ω` making every SR exponent vector strictly heavier
than every pure cube. -/
theorem no_separating_weight :
    ¬ ∃ ω : Fin 8 → ℚ, ∀ p : Fin 16 × Fin 8, 0 < dotq ω (d p) := by
  rintro ⟨ω, h⟩
  -- the positive combination of the strict inequalities is zero
  have key : (∑ p : Fin 16 × Fin 8, dotq ω (d p)) = 0 := by
    rw [← dotq_sum, sum_d_eq_zero, dotq_zero]
  have pos : 0 < ∑ p : Fin 16 × Fin 8, dotq ω (d p) :=
    Finset.sum_pos (fun p _ => h p) Finset.univ_nonempty
  exact absurd key (ne_of_gt pos)

end GroebnerObstruction
