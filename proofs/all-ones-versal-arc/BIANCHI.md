# Bianchi identity and the all-orders rational arc

This note combines the formal characteristic-zero Bianchi identity with the
exact tangent-Lie bracket calculation for the Grünbaum sphere.

## Formal theorem

Let a complete filtered minimal \(L_\infty[1]\)-algebra \(H\) over a
characteristic-zero field control the graded deformation problem.  Put

\[
V=H^1,\qquad W=H^2,\qquad Z=H^3.
\]

For transferred brackets \(Q_n\), define the Kuranishi map and the twisted
differential on obstruction classes by

\[
\kappa(t)=\sum_{n\geq2}\frac{1}{n!}Q_n(t^n),\qquad
B(t)w=\sum_{n\geq0}\frac{1}{n!}Q_{n+1}(t^n,w).
\]

The identity \(Q^2=0\), after twisting by \(t\), gives the curved Bianchi
identity

\[
B(t)\kappa(t)=0.
\]

Minimality gives \(B(0)=0\).  Its linear term is
\(B_1(t)w=Q_2(t,w)\), while
\(\kappa_2(t)=Q_2(t,t)/2\).  Hence the rows of \(B_1\) are linear syzygies of
the quadratic Kuranishi term.  Equivalently their space is the image of

\[
\beta:(H^3)^\vee\longrightarrow (H^1)^\vee\otimes(H^2)^\vee,
\qquad
\beta=(Q_2|_{H^1\otimes H^2})^\vee.
\]

Changing from a minimal-model Kuranishi vector to another minimal tuple of
versal-base equations changes source coordinates formally and multiplies the
equation vector by an invertible formal matrix.  It therefore transports the
Bianchi matrix and does not change the rank of its linear row space.

## Exact data for this ring

For \(A=S/I\) and \(M=I/I^2\), cotangent transitivity gives

\[
T^i_{A/k}\cong\operatorname{Ext}^{i-1}_A(M,A),\qquad i\geq2.
\]

`check_tangent_dimensions.m2` proves over \(\mathbf Q\) that

\[
\dim T^2_0=27,\qquad \dim T^3_0=24.
\]

The quadratic term has exactly 24 minimal linear syzygies.  The script
`lift_bianchi.m2` lifts all of them against every currently exported base
term.  If

\[
g=g_2+g_3+g_4+g_5
\]

then it constructs matrices \(S_k\), homogeneous of degree \(k\), such that

\[
\sum_{d+k=N}g_dS_k=0
\]

for total degrees \(N=3,4,5,6\).  The exact identities are checked
independently over both \(\mathbf Q\) and \(\mathbf F_{32003}\), not inferred
from numerical sampling.  The two degree-five exports are byte-for-byte
identical, and the coefficient matrices have respectively 96, 30, 118, and
179 nonzero entries over both fields.  Both exports are nonterminal
`SmartLift=>false` computations, so these identities apply only through total
degree 6.

At both the all-ones direction and the transported rational generic
direction, the same scripts certify

\[
q(y)=0,\qquad \operatorname{rank}Dq_y=15,
\qquad \operatorname{rank}S_1(y)=12,
\qquad S_1(y)Dq_y=0.
\]

Thus

\[
\ker S_1(y)=\operatorname{im}Dq_y.
\]

The historical and Macaulay2 \(T^1\) coordinates are not identical:
`transport_coordinates.sage` proves that they differ by the explicit
permutation recorded in `certificates/t1_transport_QQ.txt`.  In particular,
it transports the rational point before any rank calculation.

## The fixed-direction bracket certificate

The global injectivity of \(\beta\) is not needed for the chosen rational
direction.  `compute_aq_bracket.m2` constructs the first three stages of a
semi-free commutative DG algebra resolution and computes the intrinsic map

\[
\operatorname{ad}_y=Q_2(y,-):T^2_0\longrightarrow T^3_0
\]

over \(\mathbf Q\).  It proves exactly that

\[
\operatorname{rank}\operatorname{ad}_y=12,
\qquad \operatorname{rank}Dq_y=15,
\qquad \operatorname{ad}_yDq_y=0.
\]

The script also reconstructs the primary commutator directly on the DG
algebra and verifies that, in the actual `VersalDeformations` obstruction
coordinates, its class is \(-Dq_y\).  This checks the coordinate transport
and graded-Jacobi identity rather than inferring them from dimensions.  Since
\(\dim T^2_0=27\), the ranks give

\[
\ker\operatorname{ad}_y=\operatorname{im}Dq_y.
\]

Only the first three stages of the Tate model need to be materialized.  The
degree-one and degree-two derivations used in the bracket extend inductively
to the full acyclic resolution: on each new generator the required value is a
primitive of a positive-degree cycle.  Thus their computed commutator is a
genuine \(T^3\) cocycle.  The construction and this extension lemma are
spelled out in [AQ_BRACKET.md](AQ_BRACKET.md).

## All-orders induction

Suppose a partial base arc satisfies

\[
g(t(s))=r_Ns^N+O(s^{N+1}).
\]

The curved \(L_\infty\) identity gives
\(Q_1^{t(s)}(g(t(s)))=0\).  Its coefficient of \(s^{N+1}\) is
\(\operatorname{ad}_y(r_N)\), because all lower curvature coefficients
vanish.  Hence the exact kernel--image equality gives
\(r_N\in\operatorname{im}Dq_y\), so one may choose the next arc coefficient
\(v_{N-1}\) with

\[
Dq_yv_{N-1}=-r_N.
\]

`check_prescribed_two_jet.sage` proves that the transported rational direction
has \(q(y)=0\), that the prescribed second-order lift induces \(v_2=0\), and
that its cubic base coefficient vanishes.  It therefore supplies the initial
partial arc to which the induction applies.  The result is a formal
characteristic-zero versal-base arc extending that two-jet to every order.

This argument does not require a complete polynomial export of the Kuranishi
map or the stronger global statement `rank(beta)=24`.  Dimension equality
alone would not have sufficed; the decisive input is the directly computed
fixed-direction André--Quillen bracket.  Ordinary Yoneda multiplication on
\(\operatorname{Ext}_A(I/I^2,A)\) is not this bracket.
