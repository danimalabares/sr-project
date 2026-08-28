# Strict dg Lie replacement audit

## Verdict

The smoothing proof can be completed with a strict dg Lie algebra. There is
no mathematical need here for transferred higher operations. The replacement
is not terminological: it starts with an actual square-zero perturbation of a
Tate differential over `R_4`, performs the obstruction induction on that
strict differential, and reads the sixteen embedded cubics directly from the
differentials of the first Tate generators.

The exact theorem supported is:

> The Grünbaum Stanley–Reisner threefold is the special fibre of a flat
> projective scheme over `Spec(Q[[s]])` whose geometric generic fibre is
> smooth.

The data do not prove that the total space is smooth, that the generic fibre
is Calabi–Yau, or that it is a particular known threefold.

## Repository state and protected scope

At the start of this audit:

- requested branch: `restructure`;
- actual branch: `restructure`;
- review baseline: `9c0fc0e8da6699bd7fe30d9940b4637222686472`;
- actual HEAD: `866e9f186a65485a3a71eb3554c33c840a757612`;
- working tree: clean, including untracked files;
- the baseline is an ancestor of HEAD;
- `git diff 9c0fc0e8..HEAD` is empty. The two later commits are an update and
  its revert;
- the requested path `~/github/danimalabares/sr-project` does not exist in
  this environment. The workspace supplied by the environment is
  `/Users/daniel/github/sr-project`;
- no `AGENTS.md`, `CLAUDE.md`, or other repository instruction file exists
  in this tree.

No file in `referee-packet/`, `audits/tate-stage/`, `completion/`, or the
frozen snapshot was modified. Replays that write deterministic outputs were
run from temporary copies.

## The correct controller

Let `P -> A` be a full internally graded Tate resolution over
`S=Q[x_1,...,x_8]`. There are two relevant strict dg Lie algebras:

\[
  \mathfrak g=\operatorname{Der}_{\mathbf Q}(P,P)_0,
  \qquad
  \mathfrak h=\operatorname{Der}_{S}(P,P)_0.
\]

The fixed-coordinate embedded controller is `h`, because its degree-zero
gauge transformations fix `S`. The absolute algebra `g` permits coordinate
changes and is the one whose computed `H^1` has dimension 53.

For every cohomological degree `p >= 1`, the two derivation spaces are
literally equal: a derivation lowering nonnegative Tate homological degree by
`p` must vanish on `P_0=S`. Therefore

\[
 H^1(\mathfrak h)\twoheadrightarrow H^1(\mathfrak g),
 \qquad H^q(\mathfrak h)\cong H^q(\mathfrak g)\quad(q\ge2).
\]

The new exact check [verify_relative_controller.m2](verify_relative_controller.m2)
finds

\[
 \dim H^1(\mathfrak h)=109,
 \quad \dim\operatorname{im}(\text{coordinate boundaries})=56,
 \quad \dim H^1(\mathfrak g)=53.
\]

This prevents a serious false identification: the relative tangent space is
not the 53-dimensional package tangent space. It does not obstruct the
induction. If `a` is the fixed relative cocycle and an extra relative class
becomes the absolute boundary `partial xi`, then

\[
 [a,\partial\xi]=-\partial[a,\xi].
\]

The right side is a relative boundary because `[a,xi]` has positive degree.
Thus the images of `ad_a` from relative and absolute `H^1` coincide, while
their `H^2` and `H^3` are already identical.

## Replacement of every former higher-operation step

| Former dependency | Strict replacement | Status |
| --- | --- | --- |
| Transfer of the tangent dg Lie algebra to cohomology | No transfer. Work on `Der_S(P,P)_0` itself. | Directly proved in `PROOF_DGLA.tex` §2. |
| Curvature on a minimal model | `F(alpha)=partial alpha + 1/2[alpha,alpha]` on the strict derivation algebra. | Directly proved. |
| A completed miniversal hull and an unspecified comparison matrix `U(t)` | Construct `D=d+alpha_bar` on the same Tate algebra from the verified matrices `F^[3]`, `Q^[3]`, and the constant relation-basis change. | Directly proved in §3. No completed-hull comparison is used. |
| Treating the package two-jet as a cohomological point | First prove `F^[3]Q^[3]=0`, then set `D(e)=F^[3]`, `D(f)=Q^[3]U e`, and extend `D` generator by generator. | Verified computation plus direct Tate induction. |
| Curved Bianchi identity for transferred operations | The strict identity `partial F(alpha)+[alpha,F(alpha)]=0`. | Directly proved from the dg Lie axioms. |
| Killing a minimal-model obstruction by changing a tangent coefficient | Choose an actual closed derivation `v`, then a cochain `w` with `r_N+[a,v]=partial w`, and replace `gamma` by `gamma+s^(N-1)v-s^Nw`. | Directly proved with signs and orders in both TeX files. |
| Pullback of a formal miniversal family | Take `H_0(P[[s]],d+alpha_infty)` and, more concretely, the quotient by the sixteen elements `(d+alpha_infty)(e_i)`. | Directly proved. |
| Recovering fixed coordinates after an absolute deformation | Use the relative controller from the outset. Its MC differential fixes `S`, so the equations are literal in the original eight variables. | Directly proved. |
| Abstract algebraization of an unspecified formal ideal | The sixteen differentials of the `e_i` are cubics in `Q[[s]][x]`; their Proj is the algebraization. Tag 0899 gives an independent effectivity route with all hypotheses checked. | Directly proved plus an exact external theorem. |

The frozen proof’s transferred curvature argument is therefore entirely
replaced, not renamed.

## The `R_4` object is an actual truncated MC element

The starting calculation verifies over `R_4=Q[s]/(s^4)` that

\[
 F^{[3]}Q^{[3]}=0,
\]

that the special `Q_0` is the full thirty-column first-syzygy matrix, and
that reduction modulo `s^3` is byte-identical to the frozen two-jet. See
[verify_starting_jet.m2](../completion/verify_starting_jet.m2) and its
[certificate](../completion/verification/starting_jet_QQ.txt).

The direct bridge is:

1. Let `U` be the determinant-one constant matrix carrying the package
   syzygy basis to the audited Tate `f`-basis.
2. Define `D(e_i)=F_i^[3]` and `D(f)=Q^[3]U e`. The verified matrix identity
   gives `D^2=0` on `e` and `f`.
3. For a later Tate generator `z` of homological degree `q>=3`, lift `d(z)`
   to a `D`-cycle one coefficient of `s` at a time. At each step the defect is
   a `d`-cycle in degree `q-2>0`, so it has a homogeneous primitive among
   earlier generators.
4. The complete `f`-stage handles `q=3`, the independently certified
   136-generator stage handles `q=4`, and the ordinary Tate construction
   handles every later `q`.
5. Then `alpha_bar=D-d` is literally in
   `MC(Der_S(P,P)_0 tensor (s)/(s^4))`.

This does not infer a Maurer–Cartan representative from a Macaulay2 class or
from a deformation-functor slogan.

## Flatness and literal equations

For any relative MC element, `D=d+alpha` fixes `S`, and

\[
 H_0(P_R,D)=R[x_1,\ldots,x_8]/(D(e_1),\ldots,D(e_{16})).
\]

The right side uses the original projective coordinates. Internal weight zero
makes all sixteen entries cubic. Filtering the Tate complex by powers of `s`
has associated graded differential `d`; its `E_1` page is
`A tensor gr(R)` in homological degree zero and zero in positive degrees.
The perturbed complex is therefore a degreewise free resolution. Reduction
to `Q` recovers `P`, so `Tor_1` vanishes and Stacks Tag 00MK gives classical
flatness degree by degree.

For the formal solution, the first correction begins at `s^3`. Hence

\[
 D_\infty(e_i)=F_i^{(2)}+s^3H_i(s,x),
\]

with the exact printed `F_i^(2)`. This is stronger and cleaner than recovering
coordinates through an unspecified isomorphism of hulls.

## The `H^3` issue and the 136 cycles

The 136 columns are not asserted to span `H^3`. Their exact certified role is

\[
 D_2Z=0,
 \qquad
 \ker D_2=\operatorname{im}[D_3\;Z].
\]

Thus their classes span `ker(D_2)/im(D_3)`, the remaining homological
degree-two homology of the partial Tate algebra after decomposable
degree-three boundaries. This proves that the 136 `g_a` kill all of that
homology and that no additional generators of homological degree at most
three are missing. The full two-system certificate is
[MATHEMATICAL_CERTIFICATE.md](../audits/tate-stage/MATHEMATICAL_CERTIFICATE.md).

The degree-one and degree-two derivations used by the bracket script are
closed through every `g_a`. They extend over all later Tate generators because
the required right-hand side is a positive-degree cycle and hence a boundary.
Their strict commutators are consequently global degree-three cocycles. Only
for those already-global cocycles do we use the injection

\[
 H^3\hookrightarrow C^3/\operatorname{im}(\delta_2).
\]

Therefore the rank 12 computed in that quotient is a genuine `H^3` rank. No
claim about `dim H^3` is made.

The 53 degree-one tangent representatives used for the primary bracket are
also global cocycles, rather than merely truncated matrices.  The script
checks them through the `f`-stage; on each `g_a`, their next closure defect is
a degree-one cycle, and the certified equality
`ker(D1)=image(D2)` supplies a primitive.  The ordinary positive-homology
Tate induction then extends them over every later generator without changing
the values used in the primary computation.

## Exactness is not inferred from `rank Dq_y=15`

The frozen strict script does all of the following:

- [lines 175–185](../referee-packet/code/verify_aq_bracket.m2#L175) prove
  that the 27 transported columns are a complete `H^2_0` basis;
- [lines 142–189](../referee-packet/code/verify_aq_bracket.m2#L142) compute
  the 27 secondary strict commutators and their genuine rank 12;
- [lines 216–247](../referee-packet/code/verify_aq_bracket.m2#L216) compute
  all 53 primary strict commutators;
- it proves the exact matrix identity `primaryMap = -T2onF * Dq_y`;
- it directly proves that the secondary map composed with the primary map is
  zero.

The primary image has dimension 15, while the secondary kernel has dimension
`27-12=15`; the directly checked inclusion is therefore equality. This is
the exactness used by the strict induction.

There is one further representative-level comparison.  The linear
coefficient `a` of the constructed `R_4` differential and the script's
cocycle `theta` both represent `y` in absolute `H^1`, so
`a-theta=partial xi` for an absolute degree-zero derivation `xi`.  For every
closed relative positive-degree derivation `z`,

\[
 [a-\theta,z]=[\partial\xi,z]=\partial[\xi,z].
\]

The cochain `[xi,z]` has positive degree and is therefore relative.  Hence
the adjoint maps calculated with `theta` are exactly the cohomology maps
induced by the actual coefficient `a`; this closes the chain-level bridge
without invoking an abstract invariance claim.

## Initial order, signs, and what is preserved

With cohomological degree `p` lowering Tate homological degree by `p`,

\[
 \partial\theta=d\theta-(-1)^p\theta d.
\]

The frozen script uses the corresponding minus sign for closing degree-one
derivations, the plus sign for degree two, the bracket
`theta eta - eta theta` in degrees `(1,2)`, and the symmetric signed
commutator `theta psi + psi theta` in degrees `(1,1)`.

If the curvature begins `s^N r_N+s^(N+1)r_(N+1)`, strict Bianchi gives

\[
 \partial r_N=0,
 \qquad \partial r_{N+1}+[a,r_N]=0.
\]

After exactness supplies a closed `v` and a cochain `w` with
`r_N+[a,v]=partial w`, the correction

\[
 s^{N-1}v-s^Nw
\]

kills `r_N`. At the initial `N=4` step this is `s^3v-s^4w`, so the `s` and
`s^2` coefficients remain fixed.

The formal solution need not equal the starting MC element modulo `s^4`.
Preserving that entire element would require the stronger condition
`[r_4]=0` in `H^2`; the current exactness only makes `[r_4]` an
`ad_a`-image. The theorem needs only preservation modulo `s^3`.

## Incidence certificates and their exact meaning

For each of eight projective charts and 35 Grassmann charts, the frozen code
proves

\[
 s^2\in(F_i^{(2)},(J^{(2)})^{\mathsf T}K,s^3).
\]

It represents the 80 incidence generators over the truncated `s`-ring by a
`3 x 240` module matrix. A zero exact remainder proves membership. The output
records 277 charts at degree limit 6 and precisely `(2,7)`, `(6,12)`, and
`(8,16)` at degree limit 8.

These are incidence memberships, not standalone smoothness assertions. The
geometric conclusion also uses:

- flatness and relative dimension three;
- the Cohen–Macaulay equidimensional special fibre;
- the Jacobian rank criterion;
- properness of projective space and `Gr(4,7)` to extend a hypothetical
  singular point and kernel four-plane over an extension DVR;
- a unit projective and Plücker coordinate to select one of the 280 charts;
- the valuation contradiction `s^2=s^3c`.

## Reference audit

The completed strict proof does not use Hinich’s deformation-control theorem.
The citation in `COMPLETION.md` to Theorem 2.1.2 of the linked arXiv version is
accurate, and §§4.1 and 4.2.2 there give the object-level differential
perturbation.  What is not stated verbatim is the internally graded,
fixed-`S`, classical embedded specialization needed here. The direct Tate
lift proves that specialization and makes the abstract control theorem
unnecessary for this proof.

The external results retained in `PROOF_DGLA.tex` are:

- Avramov, *Infinite Free Resolutions*, Proposition 6.1.4, for existence of a
  Tate resolution, and Corollary 6.2.4 for the derivation-complex
  quasi-isomorphism;
- Reisner’s criterion, with all links checked computationally;
- Stacks Tag 00MK, whose finite/local/Noetherian hypotheses are verified for
  every graded piece;
- Stacks Tag 0899 as an optional second algebraization route, with complete
  Noetherian base, separated finite-type ambient scheme, cartesian formal
  system, and proper special member;
- Stacks Tag 0E7T for the Cohen–Macaulay/relative-dimension smoothing setup.

## Hostile self-review

### Maurer–Cartan correspondence

Potential attack: a package family is being called an MC element without a
chain-level lift.

Answer: `D` is defined on `e` and `f` by explicit verified matrices, and on
every later generator by a written coefficientwise cycle-lifting proof.
`D^2=0` is the MC equation. Its degree-zero boundaries are exactly the
sixteen cubics. No cohomology-class shortcut remains.

Potential attack: the absolute controller moves coordinates.

Answer: the proof uses the relative controller. The absolute complex enters
only to interpret the already-computed exactness, and the positive-degree
comparison is proved explicitly. The 109/53 distinction is independently
checked.

### `H^3`

Potential attack: 136 degree-three generators are being mistaken for 136
`H^3` classes.

Answer: the proof says neither. The 136 differentials span the degree-two
homology modulo decomposable boundaries. Global extension proves that the 12
commutator columns satisfy the uncomputed outgoing `C^3 -> C^4` condition.
Only then is their quotient rank interpreted in `H^3`.

### Flatness

Potential attack: square-zero of a perturbed differential produces a derived
object, not a flat classical algebra.

Answer: the finite `s`-filtration proves positive acyclicity, giving a free
resolution of `H_0` in each internal degree. `Tor_1=0` and Tag 00MK prove
classical flatness. The all-orders algebra is separately shown torsion-free
degree by degree.

### Algebraization

Potential attack: a compatible formal ideal need not be an algebraic family.

Answer: each equation has fixed `x`-degree three and therefore finitely many
`x`-monomials with coefficients in `Q[[s]]`; it lies in `Q[[s]][x]` itself.
Its Proj is an explicit projective algebraization. Tag 0899 is also applicable
with its hypotheses listed.

### Smoothness

Potential attack: the 280 calculations merely inspect charts of a truncated
family.

Answer: projective and Grassmannian properness makes the charts exhaustive
over an extension DVR, and every higher correction is divisible by `s^3`,
including its Jacobian derivatives. Evaluation turns the certified membership
into an impossible valuation equality. This proves smoothness of the
geometric generic fibre for every continuation with the fixed two-jet.

### Remaining limitation

There is no missing implication needed for the smoothing theorem. The first
stronger statement not proved by the induction is preservation of the full
`R_4` MC element; its minimal additional hypothesis would be
`[r_4]=0 in H^2`. That stronger statement is unnecessary because all 280
smoothness certificates depend only on the reduction modulo `s^3`.
