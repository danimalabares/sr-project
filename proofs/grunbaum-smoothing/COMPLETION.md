# Completion of the Grünbaum smoothing proof

## Status

The frozen referee packet is not, by itself, a complete proof.  The audit in
[`audits/terminology-and-foundations.md`](audits/terminology-and-foundations.md)
correctly identified two gaps.  The low Tate-stage gap was subsequently closed
by [`audits/tate-stage/`](audits/tate-stage/).  This note closes the remaining
gap without identifying the finite `VersalDeformations` output with a chosen
system of equations for a completed miniversal hull.

The key point is to use an **actual finite flat deformation as the starting
lift**.  A direct Maurer--Cartan argument starts from its representative over
\(\mathbb Q[s]/(s^4)\), changes only coefficients of order \(s^3\) and
higher, and therefore preserves the printed family modulo \(s^3\).  A final
presentation argument recovers the same eight projective coordinates and the
same sixteen cubic two-jets literally, not merely up to an unspecified
hull-coordinate change.

Throughout, put \(k=\mathbb Q\), \(S=k[x_1,\ldots,x_8]\), \(A=S/I\), and

\[
 R_n=k[s]/(s^n),\qquad R=k[[s]].
\]

Thus the printed two-jet is a family over \(R_3\), while the finite starting
deformation is over \(R_4\).

## 1. Audited inputs

The proof uses the following exact results.

1. The special ring \(A\) is the pure Cohen--Macaulay Stanley--Reisner ring
   of the displayed 20-facet three-sphere.  This is checked by
   [`referee-packet/code/verify_combinatorics.py`](referee-packet/code/verify_combinatorics.py).
2. In internal degree zero,

   \[
   \dim T^1(A)=53,\qquad \dim T^2(A)=27.
   \]

   For the displayed rational tangent vector \(y\), the package calculation
   gives a homogeneous deformation through order three and its quadratic and
   cubic base equations vanish at \(y\).  Its reduction over \(R_3\) is the
   sixteen-row file
   [`referee-packet/data/universal_2jet_QQ.txt`](referee-packet/data/universal_2jet_QQ.txt).
3. Let \(P\to A\) be a full internally graded Tate resolution and put

   \[
   \mathfrak g=\operatorname{Der}_k(P,P)_0,
   \qquad \partial=[d,-].
   \]

   Here the subscript means internal weight zero; cohomological degree \(p\)
   derivations lower Tate homological degree by \(p\).  The operation used
   below is precisely the bracket on \(H^*(\mathfrak g)\) induced by the
   graded commutator of derivations.  No separate operation called an
   “André--Quillen bracket” is assumed.

   If \(a\in Z^1(\mathfrak g)\) represents \(y\), the exact computation in
   [`referee-packet/code/verify_aq_bracket.m2`](referee-packet/code/verify_aq_bracket.m2),
   together with the independent completeness certificate in
   [`audits/tate-stage/MATHEMATICAL_CERTIFICATE.md`](audits/tate-stage/MATHEMATICAL_CERTIFICATE.md),
   proves

   \[
   \ker\!\left([y,-]:H^2(\mathfrak g)\longrightarrow
                     H^3(\mathfrak g)\right)
   =
   \operatorname{im}\!\left([y,-]:H^1(\mathfrak g)\longrightarrow
                     H^2(\mathfrak g)\right).                 \tag{1.1}
   \]

   Concretely, the two maps have ranks \(12\) and \(15\), respectively,
   inside a 27-dimensional middle space, and their composite is zero.  The
   Tate-stage certificate is what makes the twelve computed target classes
   genuine classes in \(H^3(\mathfrak g)\).
4. For every one of the 280 projective/Grassmann charts, the exact incidence
   computation proves

   \[
   s^2\in(F_i^{(2)},(J^{(2)})^{\mathsf T}K,s^3).              \tag{1.2}
   \]

   This is the exhaustive characteristic-zero calculation in the frozen
   packet; no finite-field-to-characteristic-zero inference is used.

## 2. The package output is an actual flat starting deformation

Write \(F_0,F_1,F_2,F_3\) and \(Q_0,Q_1,Q_2,Q_3\) for the family and
first-relation matrices returned by `versalDeformation` with
`HighestOrder=>3`.  After substituting \(t_i=s y_i\), let

\[
 F^{[3]}=\sum_{i=0}^3F_i,
 \qquad Q^{[3]}=\sum_{i=0}^3Q_i
\]

over \(R_4[x_1,\ldots,x_8]\).  The new exact check
[`completion/verify_starting_jet.m2`](completion/verify_starting_jet.m2)
proves

\[
 F^{[3]}Q^{[3]}=0,                                            \tag{2.1}
\]

that \(Q_0\) is the complete 30-column first-syzygy matrix of \(F_0\), and
that reduction of \(F^{[3]}\) modulo \(s^3\) is exactly the frozen printed
two-jet.

Let

\[
 A_4=R_4[x_1,\ldots,x_8]/(F^{[3]}).
\]

This algebra is flat over \(R_4\).  Indeed, fix an internal degree \(d\) and
consider the finite free \(R_4\)-module presentation

\[
 (R_4[x](-3)^{16})_d\xrightarrow{F^{[3]}}
 (R_4[x])_d\longrightarrow (A_4)_d\longrightarrow0.          \tag{2.2}
\]

Let \(K_d\) be the kernel of the first map in (2.2), and let
\(\overline F_d\) be its reduction modulo \(s\).  Every relation in
\(\ker\overline F_d\) is an \(S\)-linear combination of the columns of
\(Q_0\).  Equation (2.1) lifts those columns to elements of \(K_d\).
Consequently the natural reduction map is onto:

\[
 \ker\overline F_d
 =\operatorname{im}\!\left(
 K_d\otimes_{R_4}k\longrightarrow
 (R_4[x](-3)^{16})_d\otimes_{R_4}k\right).                  \tag{2.3}
\]

Extend (2.2) on the left to a free resolution.  After tensoring with \(k\),
the first homology of that resolution is the quotient of
\(\ker\overline F_d\) by the image in (2.3), and hence is zero.  Therefore
\(\operatorname{Tor}^{R_4}_1(k,(A_4)_d)=0\).  The
[local criterion for flatness](https://stacks.math.columbia.edu/tag/00MK)
over the Artinian local ring \(R_4\) makes \((A_4)_d\) flat, hence free.
This holds in every degree, so \(A_4\) is a flat graded deformation of \(A\).
Its reduction

\[
 A_3=A_4/s^3A_4                                             \tag{2.4}
\]

is literally the printed cubic two-jet.

## 3. The graded classical Maurer--Cartan bridge

We record explicitly the comparison needed below.

**Lemma 3.1 (graded classical control).**  For every \(n\), a marked graded
flat deformation of \(A\) over \(R_n\) determines, functorially up to gauge,
a Maurer--Cartan element

\[
 \alpha\in \mathfrak g^1\otimes(s)/(s^n).
\]

Conversely, such an element determines a marked graded flat deformation.
These constructions commute with \(R_n\to R_m\), and their tangent
identification is

\[
 H^1(\mathfrak g)=T^1_0(A).
\]

**Proof.**  Reverse the Tate homological grading, so that \(P\) and \(A\)
are nonpositively graded commutative DG algebras.  Hinich's
[Theorem 2.1.2](https://arxiv.org/pdf/math/9904145) applies to the
commutative operad in characteristic zero and identifies the derived
deformation functor with the nerve of the tangent DG Lie algebra
\(\operatorname{Der}_k(P,P)\).  Sections 4.1 and 4.2.2 give the object-level
construction: after a graded identification of the underlying cofibrant
algebra with \(R_n\otimes P\), the deformation differential is
\(1\otimes d+\alpha\); the equation that its square is zero is precisely

\[
 \partial\alpha+\tfrac12[\alpha,\alpha]=0.                   \tag{3.1}
\]

The internal grading is not discarded here.  Apply the same construction in
the symmetric monoidal category of internally \(\mathbb Z\)-graded chain
complexes.  Equivalently, perform every free lift and every graded
identification weight by weight.  A homogeneous deformation differential has
weight zero, its changes of homogeneous trivialization have weight zero, and
the construction restricts exactly to
\(\operatorname{Der}_k(P,P)_0\).  Thus no averaging of Maurer--Cartan
elements is being used.

Finally, \(\Omega_{P/k}\) is cofibrant as a DG \(P\)-module.  Applying
\(\operatorname{Hom}_P(\Omega_{P/k},-)\) to \(P\to A\) gives a
quasi-isomorphism

\[
 \operatorname{Der}_k(P,P)_0\longrightarrow
 \operatorname{Der}_k(P,A)_0.
\]

Its cohomology is the internally degree-zero tangent cohomology of \(A\),
which proves the tangent identification asserted in the lemma.

For completeness, this derived statement has the required classical-flat
meaning in the present situation.  Given \(\alpha\), filter

\[
 (R_n\otimes P,\,1\otimes d+\alpha)
\]

by powers of \(s\).  Its associated-graded differential is \(d\), so the
finite-filtration spectral sequence has

\[
 E_1=H(P)\otimes_k\operatorname{gr}(R_n)
    =A\otimes_k\operatorname{gr}(R_n)
\]

in Tate homological degree zero and is zero in positive homological degrees.
It follows that the perturbed complex is still exact in positive homological
degrees.  Put \(B=H_0(R_n\otimes P,1\otimes d+\alpha)\).  In each internal
degree the perturbed complex is now a free \(R_n\)-resolution of \(B_d\).
Tensoring that resolution with \(k\) recovers \(P_d\), whence

\[
 \operatorname{Tor}^{R_n}_i(B_d,k)=H_i(P_d)=0\qquad(i>0).
\]

The local Artinian flatness criterion makes the finite module \(B_d\) free.
Hence a Maurer--Cartan element gives a classical graded flat algebra, not
merely a derived object.  Conversely, a graded flat algebra deformation,
equipped with a cofibrant resolution, is an object of Hinich's deformation
groupoid and therefore has such a Maurer--Cartan representative.
Quasi-isomorphisms between these resolutions induce isomorphisms on their
degree-zero homology, so the marking of the classical deformation is
retained.  All constructions are compatible with base change.  ∎

Apply Lemma 3.1 to \(A_4\).  Choose a representative

\[
 \bar\alpha\in\operatorname{MC}
   (\mathfrak g\otimes(s)/(s^4)).                              \tag{3.2}
\]

Its linear coefficient is a cocycle whose cohomology class is the computed
tangent vector \(y\): the first family correction is exactly `T1*y` in the
ordered basis used by both computations.  A simultaneous sign change in the
control convention would replace \(y\) by \(-y\), which leaves (1.1)
unchanged.

## 4. A relative fixed-jet Maurer--Cartan lemma

The following direct DG-Lie argument is the all-orders step.  In particular,
it does not assume that a finite package tuple is the truncation of a chosen
completed hull presentation.

**Lemma 4.1 (fixed two-jet extension).**  Let \((\mathfrak h,\partial,[-,-])\)
be a DG Lie algebra over a characteristic-zero field.  Suppose
\(\bar\alpha\in\operatorname{MC}(\mathfrak h\otimes(s)/(s^4))\), and let
\(a\in Z^1(\mathfrak h)\) be its linear coefficient.  If

\[
 \ker([a,-]:H^2\mathfrak h\to H^3\mathfrak h)
 =\operatorname{im}([a,-]:H^1\mathfrak h\to H^2\mathfrak h), \tag{4.1}
\]

then there is \(\alpha_\infty\in\operatorname{MC}(\mathfrak h[[s]])\)
whose reduction modulo \(s^3\) equals that of \(\bar\alpha\).

**Proof.**  Lift \(\bar\alpha\) arbitrarily to a series \(\gamma\).  Its
curvature

\[
 \Phi(\gamma)=\partial\gamma+\tfrac12[\gamma,\gamma]
\]

is \(O(s^4)\).  Suppose inductively that

\[
 \Phi(\gamma)=s^Nr_N+s^{N+1}r_{N+1}+O(s^{N+2}),\qquad N\ge4. \tag{4.2}
\]

The strict DG-Lie Bianchi identity

\[
 \partial\Phi(\gamma)+[\gamma,\Phi(\gamma)]=0                \tag{4.3}
\]

gives \(\partial r_N=0\) in order \(s^N\), and in order \(s^{N+1}\) gives

\[
 \partial r_{N+1}+[a,r_N]=0.
\]

Thus \([a,r_N]\) is exact, so \([r_N]\) lies in the kernel in (4.1).
Choose
\(v\in Z^1(\mathfrak h)\) such that

\[
 [r_N]+[a,v]=0\quad\text{in }H^2(\mathfrak h).
\]

Choose \(w\in\mathfrak h^1\) with

\[
 r_N+[a,v]=\partial w.                                       \tag{4.4}
\]

Replace

\[
 \gamma\quad\text{by}\quad
 \gamma+s^{N-1}v-s^Nw.                                      \tag{4.5}
\]

The order-\(s^N\) curvature changes by
\([a,v]-\partial w\), so (4.4) kills it.  Every other new term has order at
least \(N+1\): \(v\) is closed, the part of \(\gamma-sa\) has order at
least two, and the quadratic expression in the correction has order at least
\(2N-2\).  Hence the new curvature is \(O(s^{N+1})\).

Iterating (4.5) converges coefficientwise in \(\mathfrak h[[s]]\).  Since
the first correction, for \(N=4\), begins with \(s^3\), the limit is
unchanged modulo \(s^3\).  Its curvature lies in every power of \((s)\), so
it is zero.  ∎

Apply Lemma 4.1 to \(\mathfrak h=\mathfrak g\), using (1.1) and (3.2).  We
obtain a formal Maurer--Cartan element \(\alpha_\infty\) whose associated
compatible flat graded deformation \(\widehat A\) satisfies a marked
isomorphism

\[
 \widehat A/s^3\widehat A\cong A_3.                          \tag{4.6}
\]

This is the missing preservation statement: the induction uses the actual
flat \(R_4\)-deformation as its starting lift and fixes its \(R_3\)-reduction,
which is the printed two-jet.

## 5. Recovering the literal embedded equations

It remains to turn the marked isomorphism (4.6) into the same equations in
the same projective coordinates.

Each graded piece \(\widehat A_d\) is a finite free \(R\)-module, being the
inverse limit of its compatible free reductions.  Through (4.6), lift the
eight classes of \(x_1,\ldots,x_8\) to \(\widehat A_1\).  They give a graded
map

\[
 \pi:R[x_1,\ldots,x_8]\longrightarrow\widehat A.             \tag{5.1}
\]

It is surjective in every degree by Nakayama, because its special-fibre map
is \(S\to A\).  Put \(J=\ker\pi\).  Since each \(\widehat A_d\) is free,
base change in

\[
 0\longrightarrow J_d\longrightarrow R[x]_d
 \longrightarrow\widehat A_d\longrightarrow0
\]

is exact.  In particular,

\[
 J/s^3J=\ker\bigl(R_3[x]\to A_3\bigr).                       \tag{5.2}
\]

Let \(F_0^{(2)},\ldots,F_{15}^{(2)}\) be the exact printed cubics over
\(R_3\).  By (5.2), lift them to cubics \(F_i\in J_3\).  The module \(J_3\)
is finite free: it is the kernel of a surjection between finite free
\(R\)-modules, and that surjection splits.  Its special fibre is \(I_3\),
which has dimension 16 with basis the distinct minimal cubic nonfaces.
Thus \(J_3\) has rank 16, and Nakayama makes the sixteen \(F_i\) an
\(R\)-basis of \(J_3\).
For every \(d\ge3\), the degree-\(d\) part of

\[
 J/(F_0,\ldots,F_{15})
\]

is a finite \(R\)-module whose reduction modulo \(s\) is zero, because the
special ideal \(I\) is generated by those cubics.  Nakayama makes it zero.
For \(d<3\), the same argument applied to \(J_d\) gives \(J_d=0\).  Hence

\[
 J=(F_0,\ldots,F_{15}),\qquad
 F_i=F_i^{(2)}+s^3H_i(s,x),                                  \tag{5.3}
\]

where \(H_i\in R[x_1,\ldots,x_8]\) is homogeneous of degree three in the
\(x\)'s.  Because there are only finitely many degree-three monomials, these
are honest elements of \(R[x]\), not merely elements of an additional
completion in the \(x\)-variables.

Consequently

\[
 X=\operatorname{Proj}R[x_1,\ldots,x_8]/(F_0,\ldots,F_{15})  \tag{5.4}
\]

is projective over \(R\) and has special fibre \(X_0\).  It is flat as well.
Its graded coordinate ring
\(B=\widehat A=\bigoplus_d\widehat A_d\) is a direct sum of free
\(R\)-modules.  On each standard projective chart, \((B_{x_i})_0\) is the
degree-zero direct summand of the flat localization \(B_{x_i}\), hence is
flat over \(R\).  These charts cover \(X\).  This direct construction also
makes a separate appeal to Grothendieck existence unnecessary.

## 6. Smoothness of the geometric generic fibre

Equations (5.3) put (5.4) exactly within the scope of the 280 memberships
(1.2).  The argument is recalled to make the final dependency explicit.

The special fibre is Cohen--Macaulay and equidimensional of dimension three.
For a proper flat family over \(R\), the Cohen--Macaulay fibre criterion and
constancy of relative dimension therefore make \(X\to\operatorname{Spec}R\)
a Cohen--Macaulay morphism of relative dimension three; this is also the
opening step of the Stacks Project's
[smoothing lemma](https://stacks.math.columbia.edu/tag/0E7T).  Thus at a
singular point of the generic fibre the affine Jacobian has rank at most
three, and its transpose has a kernel containing a four-plane.

If the geometric generic fibre had such a singular point, it would be defined
after a finite extension of \(k((s))\).  Properness of projective space and
of \(\operatorname{Gr}(4,7)\) extends the point and a four-plane in the
kernel of its affine Jacobian over an extension DVR.  Some projective
coordinate and some Plücker coordinate are units, so one of the 280 affine
chart pairs contains integral coordinates for this incidence point.

On that chart, (1.2) is a polynomial identity

\[
 s^2=\sum_j c_jq_j+s^3c_0.
\]

Replacing each truncated incidence generator by the corresponding generator
for (5.3) changes it only by \(s^3\) times an integral series.  Evaluation at
the incidence point therefore gives

\[
 s^2=s^3c
\]

in the extension DVR.  This contradicts its positive valuation of \(s\).
Thus the geometric generic fibre is smooth.

We have proved:

**Smoothing theorem.**  The Grünbaum Stanley--Reisner threefold is the
special fibre of a flat projective scheme over
\(\operatorname{Spec}\mathbb Q[[s]]\) whose geometric generic fibre is
smooth.  In particular it is smoothable in characteristic zero.

## 7. What this repairs

This argument discharges the surviving items in the foundations audit as
follows.

- **Finite package output versus an all-orders object:** Section 2 certifies
  an actual flat deformation over \(R_4\); Lemma 4.1 uses it as a starting
  lift and retains its \(R_3\)-reduction.
- **Graded and classical deformation theory:** Lemma 3.1 restricts the
  tangent DG Lie algebra to internal weight zero and proves classical
  flatness of the Maurer--Cartan output.
- **Absolute versus embedded deformation:** Section 5 constructs the fixed
  polynomial presentation from the graded flat algebra.
- **Preservation of the printed two-jet:** the induction starts at order
  four and is unchanged modulo \(s^3\); (5.2)--(5.3) then recover the printed
  cubics literally.
- **The constant obstruction-basis matrix \(U(0)\):** no completed-hull
  equation comparison is used, so no assertion that \(U(0)=I\), or even a
  choice of \(U(t)\), is needed.
