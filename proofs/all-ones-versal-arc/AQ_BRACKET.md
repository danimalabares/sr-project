# The intrinsic André--Quillen bracket at the rational direction

> **Corrected status.**  This computation does not prove
> \(\dim T^3_0=24\): the number 24 is
> \(\dim\operatorname{Ext}^2_A(I/I^2,A)_0\), which need not equal intrinsic
> \(T^3_0\) for this non-lci quotient.  The rank-12 claim becomes intrinsic
> after the independent Tate-stage completeness certificate used in
> [`../grunbaum-smoothing/COMPLETION.md`](../grunbaum-smoothing/COMPLETION.md).

`compute_aq_bracket.m2` computes the tangent-Lie operation

\[
  \operatorname{ad}_y=[y,-]:T^2_0(A)\longrightarrow T^3_0(A)
\]

over \(\mathbf Q\), for the transported rational point used in the smoothing
calculation.  It does not use Yoneda multiplication.

## Chain model

Starting with the 16 cubic generators of the Stanley--Reisner ideal, the
script constructs the first three stages of a semi-free commutative DG
algebra resolution.  They have

\[
16\quad\text{degree-one generators},\qquad
30\quad\text{degree-two generators},
\]

and 136 degree-three generators (16 of internal degree 5 and 120 of internal
degree 6).  The package's 30-generator syzygy basis and the acyclic-closure
basis are related by an explicitly solved invertible matrix; every \(T^2\)
cocycle is transported by its transpose before brackets are taken.

A degree-one cocycle \(\theta\) representing \(y\) is lifted through the
degree-three generators.  Each of the 27 basis cocycles \(\eta\) of \(T^2_0\)
is lifted through the same stage.  The script then evaluates the graded
commutator

\[
 [\theta,\eta](g)=\theta(\eta(g))-\eta(\theta(g))
\]

on every degree-three generator \(g\), and quotients by the complete image of
the degree-two coboundary map.

## Why these are genuine \(T^3\) cocycles

The three-stage model can be continued to a full acyclic Tate resolution
\(E_\infty\).  Suppose a degree-\(p\) derivation is closed on all generators
of degree below \(n\).  For a new generator \(z\) of degree \(n\), the closure
condition prescribes

\[
 d(\theta z)=\pm\theta(dz).
\]

The right side is a cycle of homological degree \(n-p-1\).  For \(p=1,2\)
and \(n\ge4\), this degree is positive, so acyclicity makes it a boundary.
Thus the partial derivations used by the script extend inductively, without
changing their values on the first three stages, to closed derivations of
\(E_\infty\).  Their commutator is closed.  Therefore its displayed values on
the 136 degree-three generators lie in the kernel of the next cochain
differential, even though that very large next matrix need not be built.

It follows that the natural map

\[
 T^3_0=\ker(\delta_3)/\operatorname{im}(\delta_2)
 \hookrightarrow C^3_0/\operatorname{im}(\delta_2)
\]

is injective on the computed classes.  Rank in the cokernel used by the
script is therefore their rank in \(T^3_0\).

## Exact result and cross-checks

The computation, together with that Tate-stage certificate, proves

\[
 \operatorname{rank}[y,-]=12.
\]

Independently, `VersalDeformations` gives the quadratic Kuranishi map \(q\)
and the script verifies

\[
 q(y)=0,\qquad \operatorname{rank}Dq_y=15,
 \qquad [y,-]\circ Dq_y=0.
\]

It also reconstructs the primary commutator \([y,v]\) directly from the DG
algebra and verifies that its class is exactly \(-Dq_y(v)\) in the
`VersalDeformations` obstruction coordinates.  Hence the last zero is the
intrinsic graded Jacobi identity in the actual coordinate systems, not a
dimension inference.  Since \(15+12=27=\dim T^2_0\),

\[
 \ker [y,-]=\operatorname{im}Dq_y.
\]

This exactness is the all-orders input needed in the Bianchi induction.
