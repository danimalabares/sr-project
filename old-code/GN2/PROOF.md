# SR(M) is not a Gröbner degeneration of the determinantal CY3

This note records what is **rigorously proved** (with exact, machine-checked
certificates) versus what is **strong evidence**, about whether the
Gulliksen–Negård determinantal CY3 can be degenerated to SR(M) by a weight
(a coordinate Gröbner degeneration, the "twisted-cubic" method).

Notation. `S = Q[x_1,...,x_8]`. `I_SR` is the Stanley–Reisner ideal of
Grünbaum's 8-vertex 3-sphere M: 16 squarefree cubic monomials
`m_1,...,m_16`, the minimal non-faces. For a `4x4` matrix `A` of linear
forms, `I_A = <3x3 minors of A>` (16 cubics). `e(x^u) = u ∈ Z^8` is the
exponent vector; `𝟙 = (1,...,1)`. A weight `ω ∈ R^8` acts by `ω·u`.

## Reduction to a degree-3 separation problem

`I_A` is generated in degree 3 and `(I_A)_3 = W :=` span of the 16 minors
(generically `dim W = 16`). Likewise `(I_SR)_3 =` span of `m_1,...,m_16`,
also 16-dimensional. Hence:

> If `in_ω(I_A) = I_SR` then `in_ω(W) = (I_SR)_3`.

Suppose the `16x16` submatrix of `W` on the SR-monomial columns is
invertible (true for generic `A` — `03/06` give explicit nonzero
determinants). Then `W` has a unique reduced basis
`g_a = m_a + Σ_{m' ∉ SR} c_{a,m'} m'`, and `in_ω(W) = (I_SR)_3` holds iff
each `m_a` is the strict `ω`-leading term of `g_a`, i.e.

>  (∗)   for every `a` and every non-SR monomial `m'` with `c_{a,m'} ≠ 0`:
>            ω · ( e(m_a) − e(m') ) > 0.

## The combinatorial heart: SR is "centrally balanced"

The complex M is **vertex-regular for SR**: each variable lies in exactly
**6** of the 16 SR generators, and in exactly **15** of the 40 faces
(squarefree non-SR cubics). (Verified in `10_obstruction_certificate.py`.)
Therefore

```
   Σ_{a=1..16} e(m_a) = 6·𝟙 ,   Σ over faces e(face) = 15·𝟙 ,
   Σ_{i=1..8} e(x_i^3) = 3·𝟙 .
```

Two consequences — explicit **Gordan certificates** (a positive
combination of the constraint vectors of (∗) that sums to 0, forcing
`0 > 0`):

- **Cube certificate** (`λ = 1` on the 16·8 pairs `(m_a, x_i^3)`):
  ```
  Σ_{a,i} ( e(m_a) − e(x_i^3) ) = 8·(6·𝟙) − 16·(3·𝟙) = 48·𝟙 − 48·𝟙 = 0.
  ```
- **Face certificate** (`λ = 1` on the 16·40 pairs `(m_a, face)`):
  ```
  Σ_{a,f} ( e(m_a) − e(f) ) = 40·(6·𝟙) − 16·(15·𝟙) = 240·𝟙 − 240·𝟙 = 0.
  ```

Both identities are verified exactly over `Q` in
`10_obstruction_certificate.py`.

## Theorem (proved)

**(a)** For a Zariski-generic `4x4` matrix `A` of linear forms, the
reduced basis has full support — in particular every cube `x_i^3` occurs
in every `g_a` (verified: all 8 cube-coefficients nonzero in all 16 `g_a`).
The cube certificate then makes (∗) infeasible. Hence **no weight `ω`
satisfies `in_ω(I_A) = I_SR`**. In particular the **smooth GN CY3 does not
Gröbner-degenerate to SR(M)**.

**(b)** For any `A` whose minors are supported on squarefree cubics and
whose reduced basis contains all 40 faces (e.g. the given circulant matrix
of `stanley-reisner.tex`), the face certificate makes (∗) infeasible.
Same conclusion.

*Proof.* In each case the listed certificate is a positive rational
combination `Σ λ_k d_k = 0` of the constraint vectors `d_k = e(m_a)−e(m')`
of (∗). If some `ω` satisfied (∗), then `0 = ω·(Σ λ_k d_k) = Σ λ_k (ω·d_k)
> 0` (sum of strictly positive terms with positive weights), a
contradiction. ∎

## Strong evidence (not yet a theorem): non-toric in general

`11_special_matrix_search.py` samples 1122 matrices with a rank-16
SR-block across six sparsity levels (including heavily sparsified
entries). **None** has an `ω`-separable reduced support — the smallest
non-SR support found is 85 monomials and still surrounds the SR centroid
`(3/8,...,3/8)`. So even special/sparse matrices do not escape.

This strongly suggests the universal statement:

> **Conjecture.** No `4x4` matrix of linear forms (smooth or not)
> Gröbner-degenerates to SR(M); equivalently SR(M) is not an initial
> ideal of any such `I_A`. If a determinantal smoothing exists, it cannot
> be obtained by this coordinate initial-degeneration method.

A proof of the conjecture would need the universal claim "rank-16
SR-block ⟹ reduced support contains `(3/8,...,3/8)`", which should follow
from the GN linear syzygies among the minors; not done here.

## Why this matters

The twisted-cubic toy example worked precisely because SR(o-o-o-o) **is**
an initial ideal of the twisted cubic. The Grünbaum case is genuinely
different: SR(M)'s central balance (every variable in exactly 6 of 16
non-faces) makes it un-separable, so the gfan/perfect-pairing search was
doomed from the start. This says nothing about whether a smoothing exists;
it only restricts how a hypothetical determinantal smoothing could arise.
