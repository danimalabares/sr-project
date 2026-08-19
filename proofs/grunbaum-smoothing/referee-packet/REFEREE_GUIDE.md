# Referee guide

This packet proves that the projective Stanley–Reisner scheme defined by the
sixteen cubics in `PROOF.tex`, equation (1.1), has a flat projective smoothing
over `Q[[s]]`. Nothing outside this directory is an input.

## Logical dependency graph

The proof has the following dependency order.

1. **C0 — special fibre.** `data/grunbaum_facets.txt` and
   `code/verify_combinatorics.py` prove that the displayed ideal is the face
   ideal of the 20-facet complex, that it is pure of dimension three, and that
   Reisner’s criterion holds over `Q`. Consequence: the special fibre is a
   pure Cohen–Macaulay threefold.

2. **C1 — initial versal data.** `code/verify_formal_data.m2`, using only the
   displayed ideal and 53-vector, computes `dim T1_0 = 53`,
   `dim T2_0 = 27`, `q(y)=0`, `rank Dq_y=15`, and vanishing cubic residual at
   `t=sy`. It regenerates the exact sixteen-row two-jet in `data/`.

3. **C2 — intrinsic fixed-direction bracket.**
   `code/verify_aq_bracket.m2` builds three stages of a Tate resolution,
   transports the `T2` basis by an invertible constant matrix, checks closure,
   and computes 27 commutators. The Tate-extension lemma in `PROOF.tex`
   promotes them to genuine intrinsic André–Quillen `T3` cocycles. Exact
   module reduction gives bracket rank 12. The same script aligns the
   obstruction coordinates by checking that the primary commutator is
   `-Dq_y` and that `ad_y Dq_y=0`. Since `15+12=27`, this proves
   `ker(ad_y)=im(Dq_y)`.

4. **T1 — all-orders formal arc.** This is theoretical, not a finite-order
   extrapolation. In the ordinary unshifted `L_infinity` convention, the
   curved Bianchi identity sends every order-`N` residual to
   `ker(ad_y)`. C2 places it in `im(Dq_y)`, so the next base coefficient kills
   it. C1 supplies the initial residual `O(s^4)` without changing the
   two-jet. Consequence: a compatible formal embedded deformation exists at
   every order.

5. **T1b — cubic equation bridge.** Degreewise flatness makes every graded
   piece of the completed quotient finite free over `Q[[s]]`. The degree-three
   kernel is therefore free of rank 16; the sixteen miniversal equations are
   a basis by Nakayama, and a second degreewise Nakayama argument shows that
   they generate the whole formal ideal. Consequence: the formal arc really
   has the sixteen all-orders cubic equations used by the Jacobian argument.

6. **C3 — exhaustive two-jet incidence certificate.** The two-jet regenerated
   by C1 is the sole data input to `code/verify_incidence_chart.m2`.
   `code/verify_all_incidence.py` proves `s^2` membership on all
   `8 * binomial(7,4) = 280` projective/Grassmann chart pairs. Consequence:
   every all-orders continuation with that two-jet has smooth geometric
   generic fibre, by the DVR argument.

7. **T2 — algebraization and flatness.** Grothendieck algebraization applies
   to the compatible closed subschemes of projective 7-space over `Q[[s]]`.
   Flatness is then proved stalkwise from flatness modulo every `s^n`, Krull
   intersection, and the equivalence “torsion-free = flat” over a DVR.

The main theorem is `C0 + C1 + C2 + T1 + T1b + C3 + T2`. The generic-smoothness
calculation does not assume that the formal deformation terminates as a
polynomial in `s`.

## Most vulnerable steps

### 1. Intrinsic bracket versus a truncated commutator

This is the most delicate point. A commutator on only three stages of a DG
algebra is not automatically an André–Quillen class. The proof closes the gap
as follows:

- the full Tate resolution is a cofibrant commutative DG-algebra resolution;
- `Der(P,P) -> Der(P,A)` computes the intrinsic tangent Lie algebra;
- each degree-one or degree-two partial derivation extends over every later
  Tate generator because the required right-hand side is a positive-degree
  cycle and therefore a boundary;
- the primitive has lower generator degree and can be chosen in the same
  internal grading;
- the global commutator is closed, so rank in `C3/im(delta2)` is rank in
  intrinsic `T3` on the computed span.

Inspect `PROOF.tex`, the Tate-extension lemma and the fixed-direction
exactness proposition, together with assertions in
`code/verify_aq_bracket.m2` around `relationChange`, `delta1`, `delta2`, and
`bracketMap`.

The packet deliberately makes **no assertion about the total dimension of
intrinsic `T3`**. In particular, it does not identify it with
`Ext^2_A(I/I^2,A)`.

### 2. Bianchi induction and conventions

All operations use the ordinary cohomological convention
`degree(ell_n)=2-n`. The Maurer–Cartan variable is in `H^1`, curvature in
`H^2`, and the Bianchi value in `H^3`. For a residual `r_N s^N`, the
coefficient of `s^(N+1)` is `ell_2(y,r_N)`. Adding
`v_(N-1) s^(N-1)` changes the order-`N` residual by `Dq_y(v_(N-1))` and higher
brackets only at order `N+1` or later. These indices should be checked
carefully in the all-orders-arc proposition.

The bridge from a transferred minimal model to the Macaulay2 miniversal
coordinates is explicit in the proof. If `G(t) = U(t) kappa(phi(t))`, its
transported Bianchi operator is
`B_G(t) = d_(phi(t)) composed with U(t)^(-1)`, so `B_G(t)G(t)=0`; its term
linear in `t` is the intrinsic bracket after the linear tangent/obstruction
basis changes. The constant relation-basis transport and primary-commutator
comparison in C2 verify those linear identifications in the package
coordinates used by the induction.

### 3. Why 280 charts are exhaustive

A singular point on a pure three-dimensional fibre in affine 7-space has
Jacobian rank at most three, hence a four-plane in `ker(J^T)`. Eight standard
charts cover projective 7-space and 35 standard Plücker charts cover
`Gr(4,7)`. After finite extension, properness extends both points over a DVR;
primitive scaling makes one projective coordinate and one Plücker coordinate
units. Therefore one of the 280 integral chart pairs applies. This is proved,
not inferred from a sample, in Proposition 3.2.

### 4. Meaning of the truncated membership

For each of 80 incidence generators, the three module columns encode
multiplication by every element of `B[s]/(s^3)`. Thus a zero module remainder
is exactly `s^2 in (incidence generators, s^3)`. A partial Gröbner basis is
conclusive only when the remainder is zero; the driver treats every nonzero
remainder as inconclusive and retries at degree eight. A retained change
matrix is checked on chart `(1,1)`.

The mathematical DVR step retains the membership coefficients. Replacing a
truncated generator `q` by an arbitrary continuation `q+s^3 r` changes only
the integral coefficient of the `s^3` term. Evaluation gives
`s^2=s^3 c`, contradicting valuation.

### 5. Grothendieck existence does not itself prove flatness

The proof applies Tag 0899 to the compatible *closed subschemes* (equivalently
to their coherent quotient sheaves and maps), obtaining a closed subscheme of
projective space. It then separately proves that multiplication by `s` is
injective on every special stalk. This distinction is essential.

## Computational accountability

| Claim | Source | Input | Output certificate |
|---|---|---|---|
| Facets, nonfaces, CM | `code/verify_combinatorics.py` | `data/grunbaum_facets.txt` | `verification/combinatorics_QQ.txt` |
| Initial direction and two-jet | `code/verify_formal_data.m2` | ideal and explicit vector in source | `verification/formal_data_QQ.txt` |
| AQ bracket and exactness | `code/verify_aq_bracket.m2` | same ideal and vector | `verification/aq_bracket_QQ.txt` |
| 280 memberships | two incidence scripts | regenerated `data/universal_2jet_QQ.txt` | `verification/incidence_all_QQ.txt` |

All polynomial, matrix, homology, and Gröbner calculations are exact over
`Q`. There is no floating-point or probabilistic step. `./verify.sh` checks
the audited executable/package hashes before running them.

## Remaining weaknesses and scope limits

- The 280 exact coefficient identities are recomputed, not stored
  individually. A zero exact Gröbner remainder is a mathematical membership
  proof, but a referee wishing to inspect every coefficient must rerun the
  roughly six-minute computation. Only one full change-matrix identity is
  retained during the replay as an implementation cross-check.
- The bracket script uses private/debug interfaces of `DGAlgebras`; this is
  why the exact Macaulay2 executable and package-source hashes are enforced.
- The all-orders step relies on standard characteristic-zero formal-moduli
  theory and uniqueness of miniversal hull presentations. The finite
  computation verifies the required jets and intrinsic linear bracket; it
  does not print infinitely many arc coefficients.
- The packet proves a smoothing over the complete DVR `Q[[s]]`. It does not
  claim an explicit polynomial family over an open subset of the affine
  line.

None of these scope limits changes the logical conclusion of the theorem.
