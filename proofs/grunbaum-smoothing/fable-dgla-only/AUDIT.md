# Audit: every former L∞-dependent step and its strict dg Lie replacement

Date: 2026-08-27.
Scope: `proofs/grunbaum-smoothing/fable-dgla-only/`, produced without
modifying the frozen `referee-packet/`, `audits/tate-stage/`, `completion/`,
`snapshots/`, or the earlier `dgla-only/` attempt.

## Repository state at audit start

```text
workspace=/Users/daniel/github/sr-project
branch=restructure
HEAD=866e9f186a65485a3a71eb3554c33c840a757612
baseline=9c0fc0e8da6699bd7fe30d9940b4637222686472   (ancestor of HEAD; tree diff empty)
working_tree: only untracked proofs/grunbaum-smoothing/dgla-only/ (left untouched)
```

The requested path `~/github/danimalabares/sr-project` does not exist here;
the same repository lives at `~/github/sr-project` (branch and baseline
match), and all work was done there.  No repository instruction files
(`CLAUDE.md`, `AGENTS.md`) exist in this tree.

## Verdict

The smoothing theorem is provable — and is proved in
[PROOF_DGLA.tex](PROOF_DGLA.tex) — with a strict dg Lie algebra only.
L∞-machinery is **not necessary** for this theorem: every step where the
frozen proof used a transferred structure is replaced by an argument at the
chain level of the strict algebra `Der_S(P,P)_0`, and the replacement is
strictly stronger (it produces the sixteen embedded cubics literally in the
fixed coordinates, which the transferred argument recovered only through a
hull-presentation comparison).

## Where L∞ entered the frozen proof, and what replaces it

The frozen `referee-packet/PROOF.tex` uses L∞-algebras in §2.1 and
Proposition `prop:arc`.  Item by item:

| # | Former L∞-dependent step (frozen PROOF.tex) | Strict replacement (this directory) | Status |
|---|---|---|---|
| 1 | Transfer of the tangent dg Lie algebra `g` to its cohomology `H` as a minimal L∞-algebra with operations `ℓ_n` of every arity (§2.1, eq. 2.2–2.3) | No transfer at all. All work happens in the strict complete filtered dg Lie algebra `s·Der_S(P,P)_0[[s]]` itself; cohomology enters only as the target of rank computations. | Directly proved (PROOF_DGLA §§2–3, 6). |
| 2 | Curvature `κ(t)=Σ (1/n!) ℓ_n(t,…,t)` on the minimal model | Ordinary curvature `F(γ)=∂γ+½[γ,γ]` of an actual degree-one element. | Directly proved (PROOF_DGLA eq. 6.1). |
| 3 | Curved Bianchi identity `d_t κ(t)=0` derived from the L∞ identities (eq. 2.4) | Strict Bianchi identity `∂F(γ)+[γ,F(γ)]=0`, proved from the graded Leibniz and Jacobi axioms in four lines. | Directly proved (PROOF_DGLA Lem. 6.1; DG_LIE_INDUCTION Lem. 2). |
| 4 | Comparison of minimal-hull presentations: the operator `B_G(t)=d_{φ(t)}∘U(t)^{-1}` and the discussion of the unknown matrix `U(t)` (§2.1) | Eliminated. No hull, no completed base, no presentation matrix `U(t)` exists in the strict proof. The only basis change is the **constant** 30×30 matrix `U` with `Q_0U=R_0`, `det U=1`, verified exactly, used to write the differential on the `f_j` (PROOF_DGLA eq. 4.3–4.4). | Eliminated + verified computation. |
| 5 | All-orders arc `t(s)∈T^1_0(A)[[s]]` with curvature killed order by order via `ℓ_2(y,r_N)=0` and the m-ary order bookkeeping `(N−1)+(m−1)≥N+1` (Prop. `prop:arc`) | Fixed-two-jet extension lemma in the strict algebra: obstruction coefficient is a cocycle (Bianchi at order `s^N`), its class lies in `ker(ad_a)` (Bianchi at order `s^(N+1)`), exactness supplies a **closed** `v` and a cochain `w` with `r_N+[a,v]=∂w`, and the correction `s^(N−1)v − s^N w` kills `r_N` exactly. All signs and orders displayed. | Directly proved (DG_LIE_INDUCTION Lem. 3; PROOF_DGLA Lem. 6.2). |
| 6 | Implicit passage "arc in `T^1[[s]]` ⇒ compatible flat families" via the miniversal family pullback | Direct realization: an MC element *is* a square-zero Tate differential; its `H_0` is the embedded family; flatness proved degreewise from acyclicity plus the local flatness criterion. No deformation-functor formalism at all. | Directly proved (PROOF_DGLA Prop. 3.1). |
| 7 | (In `COMPLETION.md`, the consolidation layer) Hinich's derived deformation-control theorem, used for the "graded classical Maurer–Cartan bridge" (its Lemma 3.1) | Not used. Both directions of the bridge that the proof actually needs are constructed by hand: MC ⇒ family is Prop. 3.1; the one family that must become an MC element (the certified `R_4` family) is lifted explicitly in PROOF_DGLA §4, with the extension over all Tate generators supplied by the filtered cycle-lifting lemma and the certified completeness of the low Tate stages. | Eliminated + directly proved. |

Additionally, the packaged computations (`versalDeformation`, `CT^1`,
`CT^2`) are exact commutative-algebra routines; they involve no homotopy
transfer.  Their outputs are used only as matrices whose asserted identities
are re-verified (`F^[3]Q^[3]=0`, completeness of `Q_0`, homogeneity,
`first order = T1*y`, byte-identity of the two-jet).

## Disposition of the historical foundations gaps

The terminology-and-foundations audit (`../audits/terminology-and-foundations.md`)
recorded two foundational gaps and the conditional "M1"/`U(0)` objection.
All three are discharged by this write-up:

1. *Low Tate-stage completeness* (its gap 1): supplied by the independent
   Tate-stage audit, replayed here — the two unbounded module equalities
   `ker D_1 = im D_2`, `ker D_2 = im [D_3 Z]` enter PROOF_DGLA precisely as
   the hypotheses of the cycle-lifting and extension lemmas.
2. *The finite package lift vs. a hull truncation* (its gap 2): moot — no
   deformation hull appears.  The finite package tuple is converted
   directly into a square-zero Tate differential, and the induction starts
   from that differential; no comparison of the package family with a hull
   presentation is needed or made.
3. *M1 / `U(0)`*: moot for the same reason — the only basis change in the
   proof is the constant, determinant-one syzygy-basis matrix `U` with
   `Q_0U = R_0`, verified exactly; no assertion `U(0)=I` about a
   completed-hull presentation occurs, because no such presentation is
   used.  The class-level pairing that M1 asked for is replaced by the
   chain-level identity `primary = −J·Dq_y`, computed exactly.

The unsupported phrase "André–Quillen bracket" does not occur: the only
operation used is the graded commutator of derivations of `P` and the map
it induces on cohomology.

## Is L∞ genuinely necessary here? — No, with proof

The only mathematical service the L∞ structure performed in the frozen proof
was to encode, on the 53-dimensional space `H^1`, the obstruction to
extending an arc order by order.  The strict proof shows this encoding is
dispensable, for a structural reason:

1. the obstruction at order `s^N` is the coefficient `r_N` of the curvature
   of an honest degree-one element of the strict algebra, and the strict
   Bianchi identity gives both `∂r_N=0` and `[a,r_N]∈B^3` with no reference
   to higher operations;
2. killing `[r_N]` requires only a *closed* degree-one correction `v` (one
   order lower) and a boundary correction `w`; both exist by the certified
   exactness at `H^2` — a statement about the binary bracket only;
3. convergence is `s`-adic in the complete filtered algebra; no minimal
   model is needed because nothing is ever projected to cohomology.

The transferred `ℓ_n` (n ≥ 3) never had independent computational input:
no value of any higher operation was ever computed in the frozen packet.
Their role was purely organizational, and the strict induction organizes
the same estimates directly.  Hence the L∞ formalism was a convenience,
not a necessity, and the strict proof is complete without it.

## The critical bridges, hostile review

### 1. Maurer–Cartan correspondence

**Attack:** the Macaulay2 output is a tuple of matrices; calling it a
Maurer–Cartan element assumes the correspondence being proved.

**Answer:** PROOF_DGLA §4 never invokes a correspondence.  It *defines* a
derivation `D` on the Tate algebra by `D(e_i)=F^[3]_i`,
`D(f_j)=Σ(Q^[3]U)_{ij}e_i`, proves `D²=0` on generators from the exactly
verified identity `F^[3]Q^[3]=0` and `Q_0U=R_0`, and extends `D` over every
later Tate generator by the filtered cycle-lifting lemma, whose hypotheses
at homological degrees 3 and 4 are precisely the two certified module
equalities of the Tate-stage audit.  `ᾱ=D−d` then satisfies the MC equation
because `D²=0`.  Weight-zero of `ᾱ` is not assumed: homogeneity of every
family entry (x-degree 3) and relation entry (x-degree 1) is a new exact
check in `verify_fable_dgla.m2` (the prior repository material asserted it
without a dedicated check).

**Attack:** the controller could be wrong — the package tangent space is
53-dimensional but `H^1(Der_S(P,P)_0)` is not.

**Answer:** correct, and accounted for: the relative `H^1` has dimension
109 (verified), the absolute 53, difference 56 = the coordinate Jacobian
image (verified).  The proof never identifies them; the exactness statement
is proved for the relative controller by an explicit chain-level transfer
(PROOF_DGLA Prop. 5.5), using that the two algebras literally agree in
cohomological degrees ≥ 1.

**Attack:** the script's cocycle θ and the actual linear coefficient `a`
of the constructed differential might represent different classes, so the
computed adjoint maps might be irrelevant to the induction.

**Answer:** both have the *same values* `(T1·y)_i` on the `e_i`, literally
as polynomials (verified for `a` by `verify_fable_dgla.m2`, for θ by the
frozen script's construction).  A degree-one cochain in `Der(P,A)_0` is
determined by its e-values, so `a−θ` maps to the zero cochain; injectivity
of `H^1(g)→H^1(Der(P,A)_0)` (the derivation quasi-isomorphism, proved from
semifreeness of `Ω_{P/k}`) gives `a−θ=∂ξ`, and `ad_a=ad_θ` on all relevant
cohomology by a two-line chain-level computation.  No invariance principle
for transferred structures is invoked.

### 2. `H^3` and the 136 cycles

**Attack:** rank 12 was computed in `C^3/im(δ2)`, not in `H^3`; and the
136 degree-three generators might be mistaken for an `H^3` basis.

**Answer:** the proof claims neither.  The 136 columns certify exactly
`ker D_2 = im [D_3 Z]` — completeness of the degree-3 Tate stage — and are
never called cohomology classes.  The 27 commutator columns are proved to
be *globally closed* derivations (extension lemma over all later Tate
generators, whose positive-degree cycle hypothesis is Tate acyclicity, and
whose first nontrivial case for degree-1 derivations is the certified
`ker D_1 = im D_2`).  For already-closed columns, the natural map
`H^3 = ker δ³/im δ² → C³/im δ²` is injective, so their rank 12 in the
quotient is their rank in genuine `H^3`.  No total dimension of `H^3` is
claimed or used anywhere.

**Attack:** exactness at `H^2` is inferred from `rank Dq_y = 15`.

**Answer:** it is not.  Four independent exact computations combine:
(i) the 27 transported classes are closed, independent mod boundaries, and
exhaust the weight-zero cocycles mod boundaries (so they are an actual
`H^2` basis — spanning is checked, not assumed);
(ii) the secondary map has rank 12 on that basis;
(iii) the primary commutator matrix equals `−J·Dq_y` exactly and has rank
15; (iv) the composite of the two computed matrices is zero.
Then `dim ker = 27−12 = 15 = dim im` upgrades the inclusion (iv) to
equality.  `rank Dq_y = 15` alone would prove nothing of the kind.

### 3. Flatness

**Attack:** square-zero perturbations produce derived/dg objects; classical
flatness of `H_0` is an extra claim.

**Answer:** proved directly, twice (over each `R_n` and over `R`).  Over
`R_n`: the perturbed complex is acyclic in positive degrees by induction on
`n` via the exact sequence of complexes
`0 → (P,d) → P⊗R_n → P⊗R_{n−1} → 0` (no spectral sequence needed); in each
internal weight it is then a finite free resolution of `(B_n)_j`, reduction
mod `s` returns the Tate resolution, so `Tor_1^{R_n}(k,(B_n)_j)=0`, and the
local flatness criterion (proved inline in the Artinian case; Stacks Tag
00MK verified verbatim for the general statement) gives freeness.  Over
`R`: each `B_j` is finitely generated and `s`-torsion-free (via freeness of
all its truncations plus Krull intersection), hence free over the DVR.

### 4. Algebraization

**Attack:** a formal compatible family need not be algebraic.

**Answer:** there is nothing to algebraize: `α_∞` preserves weight, so
`F_i = D_∞(e_i)` lies in the finite free module `Q[[s]]⊗S_3`, i.e. is a
polynomial in `x` with power-series coefficients, and
`X = Proj(R[x]/(F_i))` is *by construction* a projective scheme over `R`
whose reductions are the truncated families.  Stacks Tag 0899 (statement
verified verbatim against the Stacks Project; hypotheses — complete
Noetherian base, separated finite-type ambient, cartesian system of closed
subschemes, proper special member — all checked) is recorded only as an
optional independent route in a footnote and is not a dependency.

### 5. Smoothness

**Attack:** the 280 certificates are statements about a truncated ideal in
a polynomial ring, not about the family; and the Jacobian-rank dichotomy
(`singular ⇔ a 4-plane in the kernel`) silently assumes the generic fibre
is equidimensional of dimension 3.

**Answer:** both points are addressed head-on.

*Equidimensionality*: proved self-containedly (new in this write-up —
the prior material delegated it to the opening step of Stacks Tag 0E7T,
whose full statement carries a Fitting-ideal hypothesis that was never
matched to the incidence formulation).  The route here: graded Betti
numbers can only drop from the special to the generic fibre (universal
coefficients over the DVR applied to a lifted graded free resolution — all
syzygies of the flat `B` are `R`-flat), so
`pd B_K ≤ pd_S A = 8 − depth A = 4` (Auslander–Buchsbaum, with
`depth A = 4` from Reisner), whence `depth B_K ≥ 4 = dim B_K` (Hilbert
functions are constant in the flat family), so the generic fibre's
coordinate ring is Cohen–Macaulay, hence unmixed; all components of the
geometric generic fibre have dimension exactly 3, and this is stable under
the base change to the algebraic closure because Betti numbers and Hilbert
functions are.

*From memberships to smoothness*: the certificates prove exactly
`s² ∈ (80 truncated incidence generators) + (s³)` on each of the 280
charts, as polynomial identities.  A hypothetical singular closed point of
the geometric generic fibre yields, by the Jacobian dichotomy (now
justified), a point-plus-4-plane pair over a finite extension `K'`;
properness of `P^7` and `Gr(4,7)` extends both over the complete DVR `R'`
(integral closure of `Q[[s]]` in `K'` — a complete DVR by classical
ramification theory), with a unit projective coordinate and a unit Plücker
coordinate selecting one of the 280 chart pairs with integral coordinates.
Because every equation and every partial derivative of the actual family
differs from its truncation by `s³·(integral)`, evaluating the certified
identity at the incidence point gives `s² = s³·c` in `R'`, which is
impossible for valuation reasons.  The certificates therefore force
smoothness for *every* continuation with the printed two-jet — which is
exactly why preserving the two-jet (and nothing more) in the induction
suffices.

### 6. What is *not* claimed

- No dimension for `H^3` or intrinsic `T^3`.
- No preservation of the full `R_4` element modulo `s^4`: the first
  correction `s³v` may change the `s³` coefficient.  Preserving it would
  need `[r_4]=0` in `H^2`, which exactness does not give and the theorem
  does not need (DG_LIE_INDUCTION Rem. 5).
- No smoothness of the total space, no Calabi–Yau or irreducibility claim
  for the generic fibre.

## Computational integrity

All four canonical packages were replayed on 2026-08-27 from a fresh
temporary copy (frozen trees untouched); see [REPRODUCE.md](REPRODUCE.md)
and [STATUS.md](STATUS.md) for outputs.  The new script
`verify_fable_dgla.m2` passed all assertions, including the two new
homogeneity checks.
