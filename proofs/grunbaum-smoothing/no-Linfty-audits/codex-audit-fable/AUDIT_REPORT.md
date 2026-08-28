# Hostile audit of `fable-dgla-only`

Date: 2026-08-27

Auditor: Codex, independent audit requested in this repository

Target: `proofs/grunbaum-smoothing/fable-dgla-only/`

## Verdict

**VALID AFTER MINOR EXPOSITIONAL CORRECTIONS**

The target genuinely constructs, using only a strict dg Lie algebra, a flat
projective family over `Spec Q[[s]]` whose special fibre is the
Grünbaum--Sreedharan Stanley--Reisner scheme and whose geometric generic fibre
is smooth.  I found no failed exact computation, sign error, circular
certificate, missing low Tate generator, misuse of the 136 cycles as an
`H^3` basis, or gap in the repaired weight, equidimensionality, or chart-change
arguments that invalidates that theorem.

The verdict is not unqualified because several assertions are stronger than
their printed proofs:

1. The first exact proof gap occurs in `PROOF_DGLA.tex:444-499`.  The
   proposition says that *all* realization statements, including positive
   acyclicity, hold over `R=Q[[s]]`, but the over-`R` paragraph proves only the
   compatibility of `H_0` with the finite quotients.  This is repairable:
   weight preservation makes every relevant source and target for a fixed
   Tate generator finite-dimensional over `Q`; a cycle over `R` can then be
   killed by compatible coefficient-by-coefficient lifts, using
   `H_i(P,d)=0` at each step and completeness of a finite free `R`-module.
   The main theorem only invokes finite-quotient acyclicity at
   `PROOF_DGLA.tex:1031-1045`, so the omitted paragraph does not damage the
   family or its flatness.
2. `PROOF_DGLA.tex:1128-1130` passes from pure three-dimensional projective
   components to three-dimensional local rings at closed points without
   naming the needed dimension formula.  Purity alone is insufficient in
   arbitrary Noetherian schemes.  Here the assertion is correct because the
   scheme is of finite type over a field: [Stacks Lemma 33.20.3, Tag
   0A21](https://stacks.math.columbia.edu/tag/0A21) says that at a closed point
   the local dimension is the maximum dimension of the components through the
   point.  One sentence invoking that fact repairs the Jacobian threshold used
   at `PROOF_DGLA.tex:1154-1158`.
3. The universal strengthening in `PROOF_DGLA.tex:1205-1207`--smoothness for
   *every* flat projective family with the same printed two-jet--is not proved
   by the displayed argument.  That argument imports the Cohen--Macaulay and
   equidimensional conclusion of Proposition 8.2, which was established for
   the particular graded-coordinate family using its degreewise freeness.
   Delete the universal sentence, add degreewise freeness/equidimensionality
   as hypotheses, or supply a separate fibrewise-Cohen--Macaulay theorem.
   The constructed family already has the required hypotheses.
4. The final phrase “smoothable in characteristic zero” at
   `PROOF_DGLA.tex:109-110` is established in the formal-DVR sense by the
   theorem as stated.  The target does **not** spread the family to a curve or
   a base of finite type over `Q`.  If “smoothable” is defined to require such
   a base, add a standard Noetherian-approximation/spreading-out argument; the
   optional Tag 0899 discussion at `PROOF_DGLA.tex:1020-1027` algebraizes over
   `Spec Q[[s]]`, not over a finite-type `Q`-base.
5. `verify.sh:33-38` does not force a clean TeX rebuild.  Because the target
   contains generated auxiliary files and PDFs and the whole directory is
   copied with timestamps preserved, `latexmk` may say “nothing to do.”  I
   separately forced both documents to rebuild successfully.  Add `-g` or
   omit generated build products from the temporary source tree.

The first item is the first logical omission in source order.  Its effect is
limited to an unnecessarily strong clause of the realization proposition;
the minimal repair is the weightwise compatible-boundary argument just
described.  No modification of the target was made during this audit.

## Independence and repository state

At the beginning of the audit I recorded:

```text
workspace=/Users/daniel/github/sr-project
branch=restructure
HEAD=866e9f186a65485a3a71eb3554c33c840a757612
working tree:
?? proofs/grunbaum-smoothing/dgla-only/
?? proofs/grunbaum-smoothing/fable-dgla-only/
```

I read the repository instructions and the permitted canonical material.  I
did not read `proofs/grunbaum-smoothing/dgla-only/`, the target's existing
`AUDIT.md`, or any other audit under `no-Linfty-audits/`.  I did not inspect
another agent's output or process state.  All persistent audit output is in
this directory.  Replays and compilation occurred only in fresh directories
under `/private/tmp` or the system temporary directory.  No reset, commit, or
push was performed, and no target or canonical file was changed.

The target itself was untracked at audit start.  That fact prevents a Git tree
comparison against `HEAD`; integrity was instead checked against the frozen
manifests, byte comparisons, and explicit source hashes supplied by the
canonical packets.

## 1. Exact theorem actually proved

### Identification of the special fibre

The target defines the 20 facets and the 16 cubic nonfaces at
`PROOF_DGLA.tex:73-98`.  The facet list agrees exactly with Complex M in Table
4 of Grünbaum--Sreedharan, *An enumeration of simplicial 4-polytopes with 8
vertices* (J. Combinatorial Theory 2 (1967), 437--465), and the paper's
subsequent diagram identifies the corresponding complex.  I checked the
scanned [primary source](https://www.math.ucdavis.edu/~deloera/MISC/LA-BIBLIO/trunk/Grunbaum1.pdf)
rather than inferring the name from the repository.

The frozen exact combinatorics script independently enumerates 97 faces,
checks purity of dimension three, derives exactly the 16 inclusion-minimal
nonfaces, and computes every rational link homology group used by Reisner's
criterion.  The logical translation in `PROOF_DGLA.tex:118-127` is correct:
`A=Q[x_1,...,x_8]/I` has dimension four and is Cohen--Macaulay.

### Scope of the theorem

The theorem at `PROOF_DGLA.tex:100-110` proves the existence of 16 elements

```text
F_i in Q[[s]][x_1,...,x_8]_3
```

whose reductions modulo `s^3` equal the frozen two-jet, such that

```text
Proj(Q[[s]][x]/(F_1,...,F_16)) -> Spec Q[[s]]
```

is projective and flat, has special fibre `Proj(S/I)`, and has smooth fibre
after extension from `Q((s))` to its algebraic closure.  These conclusions are
all established.

The proof correctly disclaims smoothness of the total space, irreducibility of
the generic fibre, a trivial canonical bundle, and identification with a named
smooth threefold at `PROOF_DGLA.tex:113-116`.  It also correctly disclaims
preservation of the full `R_4` Maurer--Cartan element at
`PROOF_DGLA.tex:955-962`.  The unsupported universal strengthening and the
finite-type-base distinction are the two scope qualifications listed above.

## 2. The strict controller

### Relative versus absolute derivations

The controller requested in the audit is

```text
Der_S(P,P)_0.
```

The target calls it `h`, not `g`; its notation is

```text
g = Der_Q(P,P)_0,    h = Der_S(P,P)_0
```

at `PROOF_DGLA.tex:269-285`.  This is only a notation difference.  The target
uses the relative algebra for the actual fixed-coordinate deformation and the
absolute algebra only to import the package's quotient tangent calculation.

A cohomological degree-`p` derivation lowers homological degree by `p`, while
the differential lowers homological degree by one; the internal weight is
separate and is preserved (`PROOF_DGLA.tex:130-150`).  These conventions make
`partial=[d,-]` degree `+1`, and the bracket signs are standard.

For `p>=1`, a derivation sends `P_0=S` to negative homological degree and
therefore vanishes on `S`.  Thus the equality of cochain groups
`h^p=g^p`, not merely a quasi-isomorphism, is proved at
`PROOF_DGLA.tex:287-305`.  It follows correctly that `H^q` agrees for
`q>=2`, while `H^1(h)->H^1(g)` is only surjective.

### Resolution and derivation cohomology

The staged Tate construction at `PROOF_DGLA.tex:182-230` is valid.  The
canonical low-stage audit proves the full polynomial-module identities

```text
ker D1 = image D2
ker D2 = image [D3 Z]
```

over `Q[x]`, not ranks in selected degrees (`PROOF_DGLA.tex:233-251`).  Its
Macaulay2 and Singular paths reconstruct the signed decomposable differential
independently, compute complete syzygy modules, and prove both containments by
exact lifts.  Provenance extraction of `F,R,Z` was repeated and byte-identical
to the canonical sparse input.  This is sufficient to continue the displayed
low segment to a full Tate resolution with no missing generators in degrees
two or three.

The quasi-isomorphism

```text
Der(P,P) -> Der(P,A)
```

at `PROOF_DGLA.tex:326-361` is not assumed deformation folklore.  The target
proves acyclicity of the kernel using the filtration of Kähler differentials,
surjective inverse-limit transitions, and exactness of products of complexes
of vector spaces.  The same proof applies relatively.  I found no failure in
the inverse-limit or weight-zero passage.

The low cochain groups are consequently

```text
C^1 = (A_3)^16,
C^2 = (A_4)^30,
C^3 = (A_5)^16 + (A_6)^120,
```

with the relative complex lacking only the absolute degree-zero coordinate
fields (`PROOF_DGLA.tex:313-324`).  The identifications with
`Hom_S(I,A)_0`, its Jacobian quotient, and `T^2_0` are proved at
`PROOF_DGLA.tex:364-398` using the *complete* first-syzygy matrix.

### Independent dimension reconstruction

`check_controller_complex.py` in this directory parses only the canonical
sparse `F,R,Z` input, reduces monomials combinatorially modulo the monomial
Stanley--Reisner ideal, and builds all three weight-zero differentials over
exact `QQ`.  It does not load `VersalDeformations` or `DGAlgebras`.  It found:

```text
dim A_1,...,A_6 = 8,36,104,232,440,748
dim C^0,C^1,C^2,C^3 = 64,1664,6960,96800
rank delta_0,delta_1,delta_2 = 56,1555,5378
dim H^1(relative) = 1664-1555 = 109
dim H^1(absolute) = 109-56 = 53
dim H^2 = 6960-1555-5378 = 27
```

It also verifies `delta_1 delta_0=0` and `delta_2 delta_1=0`.  This independently confirms the
controller dimensions asserted at `PROOF_DGLA.tex:401-410` and rules out a
package-coordinate explanation for the `109/53` discrepancy.

### Filtration and completeness

The actual complete strict dg Lie algebra is

```text
s h[[s]] = product_{j>=1} s^j h,
F^r = s^r h[[s]].
```

The filtration is separated and complete, and brackets add orders
(`PROOF_DGLA.tex:416-428`).  This is an ordinary completed dg Lie algebra; no
operation beyond the differential and binary commutator occurs.

## 3. Maurer--Cartan realization

For an odd derivation `alpha`, the calculation

```text
(d+alpha)^2 = partial(alpha) + 1/2[alpha,alpha]
```

at `PROOF_DGLA.tex:450-456` has the correct sign and proves literal
square-zero, not an analogy with a deformation functor.  Relative derivations
fix `S`, so `D=d+alpha` is `R_n[x]`-linear.  Its degree-zero boundary ideal is
generated by the 16 values `D(e_i)`, which are cubics specializing to the 16
Stanley--Reisner generators (`PROOF_DGLA.tex:468-472`).

For every Artinian quotient `R_n`, the short exact filtration by
`s^{n-1}` and the long exact homology sequence prove positive acyclicity
(`PROOF_DGLA.tex:458-466`).  Fixed weight pieces are finite free complexes;
the exact Tor calculation and the Artinian local flatness criterion prove
each `(B_n)_j` free of rank `dim_Q A_j` (`PROOF_DGLA.tex:474-494`).  This is
sufficient Tate acyclicity and flatness for the embedded deformations used
later.  The omitted all-orders positive-acyclicity paragraph is the first
minor correction described in the verdict.

## 4. From the certified `R_4` family to Maurer--Cartan

The local and completion scripts compute over `Q[s]/(s^4)`, not over a
floating or sampled ring.  They check directly

```text
F^[3] Q^[3] = 0,
```

the vanishing of the specialized quadratic and cubic base equations, and the
completeness of all 30 special first syzygies
(`PROOF_DGLA.tex:552-578`; `verify_fable_dgla.m2:48-76`;
`completion/verify_starting_jet.m2:27-56`).  They also check every family entry
is cubic and every relation entry is linear in the projective variables
(`verify_fable_dgla.m2:78-88`).  Thus the weight-zero assertion is certified,
not inferred from an ungraded package run.

The constant change-of-relations matrix satisfies `Q_0 U=R_0`, has rank 30,
determinant exactly one, and constant entries
(`PROOF_DGLA.tex:588-595`; `referee-packet/code/verify_aq_bracket.m2:90-111`).
With this orientation,

```text
D(e)=F^[3],        D(f)=Q^[3] U e
```

gives `D^2(e)=0` by relative linearity and `D^2(f)=F^[3]Q^[3]U=0`
(`PROOF_DGLA.tex:597-628`).

The filtered cycle-lifting lemma at `PROOF_DGLA.tex:513-533` has the correct
power of `s` and sign.  For degree-three generators its hypothesis is exactly
`ker D1=image D2`; for degree four it is exactly
`ker D2=image[D3 Z]`; later cases use the continuing Tate construction
(`PROOF_DGLA.tex:630-645`).  Therefore the square-zero differential extends
to *every* later generator, not merely the 16 `e` and 30 `f` generators.
The resulting `alpha_bar=D-d` is a genuine element of
`MC(h tensor (s)/(s^4))`, and its `H_0` is the required flat graded `R_4`
quotient (`PROOF_DGLA.tex:647-655`).

The reduction modulo `s^3` is compared byte-for-byte with the frozen
two-jet; its SHA-256 is
`40e64e61674b6a4e61f1ea6822dc79327bf4ba397285f84ed8738c4c18cd1795`.
The first-order coefficient is checked entrywise to equal `T1*y`, so the
chain-level linear coefficient used by the induction is tied to the exact
package direction.

## 5. The 27 classes and exactness at `H^2`

The source of `referee-packet/code/verify_aq_bracket.m2` was inspected in
full.  The following checks are logically distinct and exact:

- It transports the 27 package `T^2` columns through `U^T`, checks
  `delta_2 T2=0`, proves all 27 independent modulo `image delta_1`, and then
  computes that the degree-zero kernel remaining after quotienting by both
  boundaries and the 27 columns is zero
  (`verify_aq_bracket.m2:169-189`).  This is a spanning proof, not acceptance
  of an expected dimension.
- It constructs the degree-three commutators from solved chain-level values
  and obtains rank 12 in `C^3/image delta_2`
  (`verify_aq_bracket.m2:142-189`).
- It recomputes the Jacobian of the 27 quadratic base equations at `y` and
  obtains rank 15 (`verify_aq_bracket.m2:195-214`).
- It constructs all 53 primary commutators directly from relation lifts,
  proves `primary = -T2*Dq_y` modulo boundaries, proves the composite with
  the secondary commutator matrix is zero, and separately checks the Jacobi
  composite and self-bracket (`verify_aq_bracket.m2:216-247`).

There is no rank-only inference: the zero composite is checked before
`27-12=15` is used.  The target's dimension argument at
`PROOF_DGLA.tex:787-806` therefore proves exactness at the 27-dimensional
middle term.

The script closes `theta` and each `eta_j` through the displayed `g` stage.
The two Tate-stage equalities and later acyclicity extend them over the full
resolution (`PROOF_DGLA.tex:662-693`).  Their commutators are consequently
genuine closed degree-three derivations.  For already-closed columns, the map

```text
H^3 -> C^3 / image delta_2
```

is injective, so the computed rank 12 is a rank in genuine `H^3`, without
knowing the dimension of `H^3` (`PROOF_DGLA.tex:695-706`).

The 136 columns are different objects: they are degree-two *Tate cycles*
whose killing generators produce the correct `C^3` domain.  They are neither
declared independent nor used as `H^3` classes (`PROOF_DGLA.tex:254-266` and
`:709-713`).

Finally, the actual coefficient `a` and the script's `theta` have identical
`e`-values.  The proven derivation quasi-isomorphism makes their difference
an absolute boundary; bracketing with relative positive-degree cocycles moves
that difference by a relative boundary (`PROOF_DGLA.tex:740-767`).  The
surjection `H^1(relative)->H^1(absolute)` and equality in degrees two and
three then transfer exactness correctly (`PROOF_DGLA.tex:808-826`).

## 6. Strict Bianchi induction

I re-derived the companion argument directly from

```text
F(gamma)=partial gamma + 1/2[gamma,gamma].
```

For odd `gamma`,

```text
partial[gamma,gamma] = -2[gamma,partial gamma]
```

and the graded Jacobi identity gives
`[gamma,[gamma,gamma]]=0` in characteristic zero.  Thus

```text
partial F(gamma)+[gamma,F(gamma)]=0
```

with the signs printed at `PROOF_DGLA.tex:850-865` and
`DG_LIE_INDUCTION.tex:79-113`.

Writing the curvature as

```text
s^N r_N + s^(N+1) r_(N+1) + ...,
```

the coefficient of `s^N` is `partial r_N=0`; the coefficient of `s^(N+1)`
is `partial r_(N+1)+[a,r_N]=0`.  Hence the obstruction is a class in
`ker(ad_a:H^2->H^3)` (`PROOF_DGLA.tex:891-901`).  Exactness supplies a closed
`v` and a `w` satisfying

```text
r_N+[a,v]=partial w.
```

The correction

```text
delta = s^(N-1) v - s^N w
```

changes the `s^N` curvature coefficient by
`[a,v]-partial w=-r_N`.  Its square starts at `s^(2N-2)`, which is at least
`s^(N+2)` for `N>=4` (`PROOF_DGLA.tex:903-926`).  Every index and sign is
consistent.

For the initial truncated element,

```text
r_4=[a_1,a_3]+1/2[a_2,a_2],
r_5=[a_2,a_3],
r_6=1/2[a_3,a_3],
```

exactly as at `PROOF_DGLA.tex:942-952`.  The first correction is
`s^3 v-s^4 w`.  Consequently the `s` and `s^2` coefficients are preserved,
but the `s^3` coefficient need not be.  The target states this sharp limit
correctly at `PROOF_DGLA.tex:955-962` and
`DG_LIE_INDUCTION.tex:270-288`.

Corrections begin in successively higher filtration.  Every coefficient
stabilizes, curvature coefficients are finite expressions in stabilized
coefficients, and separated completeness gives a genuine Maurer--Cartan
limit (`PROOF_DGLA.tex:928-939`).  No transferred bracket, ternary operation,
minimal `L_infinity` model, or deformation-functor equivalence occurs.

## 7. Convergence and the actual family

Weight preservation is crucial and is used correctly.  For each `e_i`, every
coefficient of `alpha_infinity(e_i)` lies in the finite-dimensional space
`S_3`.  Therefore

```text
F_i in Q[[s]] tensor_Q S_3 = Q[[s]][x]_3
```

is a polynomial in the eight projective variables, with formal power-series
coefficients in `s`; it is not a power series in the `x_i`
(`PROOF_DGLA.tex:982-998`).  The same weightwise finiteness makes the formal
derivation itself well-defined on each Tate generator; this should be stated
when `D_infinity` is introduced at `PROOF_DGLA.tex:975`.

The quotient by 16 such cubics is a finitely presented graded algebra over
`Q[[s]]`, and its Proj is an actual projective scheme of finite presentation
over `Spec Q[[s]]`, not merely a compatible sequence of infinitesimal schemes
(`PROOF_DGLA.tex:1001-1029`).  The proof of degreewise freeness over the DVR
uses all finite Maurer--Cartan reductions, Krull intersection, and
torsion-freeness (`PROOF_DGLA.tex:1031-1045`); chart localization then proves
scheme-theoretic flatness (`PROOF_DGLA.tex:1046-1048`).

These distinctions must remain explicit:

- `F_i` is polynomial in `x`;
- its finitely many coefficients may be arbitrary elements of `Q[[s]]`;
- it need not be polynomial in `s`;
- the scheme is algebraic and finitely presented over `Spec Q[[s]]`;
- no family over a finite-type `Q`-base is constructed in the target.

## 8. What the 280 certificates prove, and the geometry around them

### Exact computational content

For each of 8 projective charts and 35 standard charts of `Gr(4,7)`, the
incidence checker forms 16 dehomogenized two-jet equations and the 64 entries
of the `16 x 7` Jacobian times a `7 x 4` Grassmann-chart matrix: exactly 80
polynomials.  In `Q[z,a][s]/(s^3)`, multiplication of each
`q=q_0+s q_1+s^2 q_2` by arbitrary truncated coefficients is encoded by the
three columns `q,sq,s^2q`, hence a `3 x 240` module matrix.  Reducing
`(0,0,1)^T` to zero proves exactly

```text
s^2 in (q_1,...,q_80)+(s^3).
```

It is not merely a scalar ideal test in the wrong ring.  The driver checks all
280 distinct pairs, uses degree bound six for 277 and eight for precisely
`(2,7)`, `(6,12)`, `(8,16)`, and rechecks a retained explicit lift.  The full
fresh replay returned `proved 280/280 chart pairs`.

The certificates do **not** prove smoothness, equidimensionality, or anything
about the unknown coefficients at order `s^3` and above.  The target states
this limitation accurately at `PROOF_DGLA.tex:1195-1199`.

### Cohen--Macaulayness and equidimensionality

The special Stanley--Reisner ring has depth and dimension four.  A finite
graded free `R[x]` resolution of `B` remains a resolution on both fibres
because its syzygies are `R`-flat.  After tensoring with `R[x]/(x)`, universal
coefficients over the DVR injects special-fibre homology and proves generic
Betti numbers are no larger (`PROOF_DGLA.tex:1060-1088`).  Thus generic
projective dimension is at most four.  The constant Hilbert function gives
dimension four, and Auslander--Buchsbaum gives depth four, including after
arbitrary field extension (`PROOF_DGLA.tex:1099-1117`).

For this standard graded quotient, Cohen--Macaulayness at the irrelevant
maximal ideal and localization imply global Cohen--Macaulayness.  Unmixedness
then makes every minimal homogeneous component dimension four and every Proj
component dimension three (`PROOF_DGLA.tex:1119-1127`).  This is a valid
replacement for the previously fragile Fitting-ideal citation.  The only
correction needed is to name the finite-type dimension formula at closed
points, as noted above.

### Jacobian and chart coverage

The target proves that each Proj chart is cut out by exactly the 16
dehomogenized cubics, not merely by their saturation
(`PROOF_DGLA.tex:1147-1153`).  At a closed geometric generic point the local
dimension is three; the tangent dimension is `7-rank J`.  The point is
singular exactly when `rank J<=3`, equivalently when the kernel contains a
four-plane (`PROOF_DGLA.tex:1140-1158`).  The 8 projective and 35 Grassmann
charts therefore cover every possible singular incidence.

### Extension DVR and repaired chart change

A hypothetical geometric singular point descends to a closed point over a
finite extension `K'/Q((s))`.  In characteristic zero the extension is
separable; completeness/Henselianity gives a unique extension valuation, so
the integral closure `R'` is a finite complete DVR with positive `v'(s)`
([Stacks, Section 15.113 and Remark 15.113.6, Tag
0EXQ](https://stacks.math.columbia.edu/tag/0EXQ)).
Properness extends both the projective point and the Grassmannian point
(`PROOF_DGLA.tex:1210-1227`).

The original affine coordinate need not remain a unit.  The repaired argument
at `PROOF_DGLA.tex:1229-1248` correctly selects a unit projective coordinate
`x_(v0)`, observes that the generic point lies in both old and new charts,
uses the intrinsic tangent space to reselect a four-plane in
`ker J_(v0)`, and then selects a unit Pluecker coordinate.  This yields
integral coordinates in one of the exact 280 chart pairs.  There is no hidden
assumption that the original chart survives specialization.

Evaluating a lifted membership identity is legitimate.  The actual equations
and their Jacobian entries differ from the printed two-jet incidence
generators by `s^3` times integral power-series coefficients; differentiation
and multiplication by the integral Grassmann matrix preserve that factor
(`PROOF_DGLA.tex:1250-1269`).  All actual incidence generators vanish, so the
identity gives

```text
s^2=s^3 c,  c in R'.
```

The valuation equation `2v'(s)=3v'(s)+v'(c)` is impossible.  Hence no closed
geometric generic point is singular (`PROOF_DGLA.tex:1270-1276`).  Over the
algebraically closed characteristic-zero field, regularity and smoothness
agree ([Stacks, Section 10.140, Tag
00TQ](https://stacks.math.columbia.edu/tag/00TQ)); a non-smooth finite-type
locus would contain a closed point.  The geometric generic fibre is therefore
smooth.

## Computational replay and falsification checks

The complete target wrapper was run from a newly made outer temporary copy,
with the target copied without its excluded `AUDIT.md`.  The wrapper then made
its own fresh copies of each canonical packet.  The replay passed:

```text
relative H1 dimension=109
coordinate-boundary image dimension=56
absolute H1 dimension=53
family and relation corrections weight-homogeneous=true
starting MC linear e-values equal T1*y=true
two jet matches frozen input=true

T1 degree-zero dimension=53
T2 degree-zero dimension=27
rank commutator columns modulo delta2=12
rank Dq_y=15
primary plus Dq rank=0
ad_y composed primary-bracket rank=0
Jacobi composite rank=0
primary self bracket at y zero=true
proved 280/280 chart pairs

TATE_STAGE_AUDIT_REPLAY_CERTIFIED
starting_deformation_flatness_inputs_verified=true
starting_two_jet_matches_frozen_input=true
FABLE_DGLA_FULL_REPLAY_VERIFIED
```

The low Tate stage was recomputed in both Macaulay2 and Singular with complete,
unbounded syzygy calculations.  The incidence run used exact `QQ` arithmetic.
No computation used floating point.

I inspected each verification layer rather than accepting the final strings:

- `check_fable.py` is only a source-contract and certificate-consistency
  checker; it proves no mathematics by itself.
- `verify_fable_dgla.m2` does direct `FQ=0`, degree, tangent, and byte checks,
  but the independent controller script was needed to avoid relying solely on
  package conventions.
- the bracket script proves spanning and the two ranks on the correct cochain
  quotients and has direct primary-bracket and zero-composite cross-checks;
- the Tate audit certifies modules, not finite degree samples;
- the 280 script certifies truncated ideal membership, not smoothness;
- the geometric conclusion comes only after the separately audited DVR and
  equidimensionality arguments.

The local TeX phase initially did no work because copied build products were
new enough.  I then ran `latexmk -g` on both TeX sources in the temporary copy.
Both rebuilt successfully with no undefined control sequence or reference.
Only layout/hyperref warnings remained.

As a supplementary stress test, I requested `VERIFY_LIFT=1` for the hard
degree-eight pair `(2,7)`.  It continued without error or result far beyond the
ordinary chart runtime and was interrupted; that incomplete run is not counted
as evidence in either direction.  The evidence used here is the completed
280/280 exact normal-form replay and the driver's completed retained-lift
check.  `REPRODUCE.md` gives the ordinary retained-pair explicit-lift command.

Environment used:

```text
Macaulay2 1.20
VersalDeformations 3.0
DGAlgebras 1.1.0
Singular 4.4.1
Python 3.13.7
SageMath 10.7
latexmk 4.79 / TeX Live 2023
```

## Final assessment

The strict dg-Lie proof is real, not a relabeling of transferred
`L_infinity` operations.  Its decisive inputs are a genuine Tate resolution,
ordinary derivations and commutators, a chain-level `R_4` differential, exact
rank and zero-composite computations, and the strict Bianchi identity.  The
constructed `Q[[s]]` family and smooth geometric generic fibre survive hostile
checking.

The requested minimal edits are expository: prove the over-`R` clause
weightwise, cite the finite-type dimension formula at closed points, remove or
qualify the universal-family sentence, distinguish a formal-DVR smoothing
from spreading out over a finite-type base, and force TeX rebuilding in the
wrapper.  None requires changing the target family, adding an `L_infinity`
operation, or repairing a failed obstruction calculation.
