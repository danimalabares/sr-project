# GN2 — testing a possible determinantal smoothing of SR(M)

Goal: build a flat family with special fibre the Stanley–Reisner scheme
of Grünbaum's 8-vertex 3-sphere, `I_SR` (16 cubic monomials in
`x1..x8`), and smooth generic fibre — the Gulliksen–Negård determinantal
Calabi–Yau threefold in `P^7` (3×3 minors of a 4×4 matrix of linear
forms).

This directory investigates whether `SR(M)` can be realised as a
degeneration of the determinantal CY3. No such degeneration or smoothing
has been constructed or proved to exist.

## What was established (all computational, reproducible)

1. **Necessary numerical invariants match.** (`03_compare_invariants.m2`)
   `I_SR`, the given circulant determinantal ideal, and a generic
   determinantal ideal ALL have
   - codim 4, degree 20,
   - Hilbert numerator `1 + 4T + 10T^2 + 4T^3 + T^4`,
   - the self-dual Gulliksen–Negård Betti table `1, 16, 30, 16, 1`
     (arithmetically Gorenstein).
   Thus these invariants do not rule out a flat degeneration GN ⇝ SR(M).
   Their agreement does not prove that one exists, that `SR(M)` is
   smoothable, or that the two schemes lie on the same Hilbert component.

2. **The given circulant matrix is NOT a weight degeneration to I_SR.**
   (`01_match_and_weight.py`) Although 15 of 16 SR monomials appear as a
   term of some minor, only **8** can be the simultaneous ω-leading terms
   of their minors, and `f1 = x6x7x8` is structurally unreachable
   (`x6,x7,x8` live in only 2 rows of that matrix). This is exactly the
   "perfect pairing" wall hit earlier — it genuinely does not exist for
   this matrix.

3. **A generic determinantal ideal is NOT a weight degeneration to I_SR.**
   (`06_initial_ideal_LP.py`) In degree 3 the 16 SR monomials ARE a
   basis-transversal of the minor space `W` (the 16×16 SR-block is
   invertible), but the reduced basis is dense (all 1664 other monomials
   appear), so the separating-weight LP is infeasible. No single weight
   makes the SR monomials the leading terms.

4. **No exact single-monomial determinantal presentation.**
   (`07`,`08`) The 4×4 0/1 patterns with every 3×3 permanent = 1 (unique
   transversal ⇒ each minor a single monomial) are exactly 72, all
   8-cell, all 6-regular like the SR hypergraph — but NONE is isomorphic
   to the SR hypergraph. So I_SR is not the ideal of minors of a
   {0, x_i}-matrix.

5. **I_SR is (very likely) not exactly linear-determinantal at all.**
   (`09_solve_exact_presentation.py`) Optimising the matrix entries so
   that every minor lies in `span(SR)` drives the non-SR coefficient
   mass to ~0 easily (across many random starts), but the SR-rank then
   caps at **≤ 4** — the 16 minors collapse into a rank-4 subspace, never
   spanning all of `(I_SR)_3`. This numerical search found no exact
   presentation of the tested kind; it does not show that `I_SR` is a
   flat limit or lies on the boundary of the determinantal locus.

6. **Rigorous obstruction + Lean proof.** (`10_obstruction_certificate.py`,
   `PROOF.md`) The "no Gröbner degeneration" fact is now a theorem with an
   exact rational **Gordan certificate**: because each variable lies in
   exactly 6 of the 16 SR generators (and 15 of the 40 faces),
   `∑_{a,i}(e(m_a) − e(x_i^3)) = 0`, which makes the separation system
   infeasible. This proves the **generic/smooth** GN CY3 has no coordinate
   Gröbner degeneration to SR(M) (and the face-certificate kills the given
   circulant matrix). The finite core is formally verified in Lean 4 +
   Mathlib: `../cotangent/sr_t1/SrT1/GroebnerObstruction.lean`, theorem
   `no_separating_weight` (compiles, exit 0). A search of 1122 rank-16
   matrices (`11_special_matrix_search.py`) finds **zero** escapes across
   all sparsity levels — evidence for a universal non-Gröbner statement,
   though the fully general claim is left as a conjecture (see `PROOF.md`).

## Current conclusion

It is **not known from these computations whether `SR(M)` is smoothable**,
whether it is a degeneration of the determinantal CY3, or whether it lies
on the determinantal component of the Hilbert scheme.

What is known here is negative and method-specific: the tested
coordinate/weight Gröbner routes fail, the restricted exact
determinantal searches found no presentation, and the current
order-by-order candidate is not flat. These facts do not imply one
another and do not rule out a different flat smoothing.

## Recommended next experiment

Test whether there exists a 1-parameter matrix family `A(t)` whose minor
ideal has flat limit exactly `I_SR` at `t=0`:

- parametrise `A(t) = A_* + t·B`, with `A_*` a special boundary matrix;
- require the flat limit `(minors(A(t)) : t^∞)|_{t=0} = I_SR`
  (the limit the user's saturation computes — but now solve for the
  coefficients that make it land on I_SR rather than overshoot);
- investigate whether any directions in `T^1(SR)` (dim 53) arise as
  limits of determinantal deformations. Their existence is not known.

## Files

- `gn_common.py` — minors, SR data, weight LP.
- `01_match_and_weight.py` — minor↔SR matching + separating-weight LP.
- `02_design_matrix.py` — diagonal-order pattern design (negative).
- `03_compare_invariants.m2` — Betti/Hilbert comparison (writes
  `cache/03_invariants.log`).
- `05_random_pattern_search.py` — single-variable pattern search.
- `06_initial_ideal_LP.py` — exact degree-3 initial-ideal LP test.
- `07_find_exact_matrix.py`, `08_label_and_match.py` — permanent-1
  patterns + SR-hypergraph matching.
- `09_solve_exact_presentation.py` — numeric search for an exact
  determinantal presentation (shows the rank-≤4 cap).
