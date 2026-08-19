# Mathematical certificate

## Certified complex

Let

\[
S=\mathbb Q[x_1,\ldots,x_8]
\]

with its standard internal grading and graded reverse lexicographic order.  The
frozen sparse input records polynomial matrices `F`, `R`, and `Z`.  A format
checker translates that single canonical term list mechanically to both
Macaulay2 and Singular syntax.

Use the homogeneous free modules

\[
E_0=S,\qquad E_1=S(-3)^{16},
\]

\[
E_2=S(-4)^{30}\oplus S(-6)^{120},\qquad
E_3^{\mathrm{dec}}=S(-7)^{480}\oplus S(-9)^{560},
\]

and

\[
G_3=S(-5)^{16}\oplus S(-6)^{120}.
\]

The ordered basis of `E1` is `e_1,...,e_16`.  The ordered basis of `E2` is
first `f_1,...,f_30`, then the 120 products `e_i e_j` in lexicographic order
with `i<j`.  The ordered basis of `E3dec` is first the 480 products `e_i f_a`
with `i` outer and `a` inner, then the 560 products `e_i e_j e_k` with
`i<j<k`.  The basis of `G3` is `g_1,...,g_136`, with internal degree 5 for
the first 16 elements and degree 6 for the remaining 120.

The maps are

\[
D_1:E_1\longrightarrow E_0,\quad
D_2:E_2\longrightarrow E_1,\quad
D_3:E_3^{\mathrm{dec}}\longrightarrow E_2,\quad
Z:G_3\longrightarrow E_2,
\]

and `B=[D3 Z]`.  Here `D1(e_i)=F_i`; the `f` block of `D2` is `R`, so

\[
D_2(f_a)=\sum_i R_{ia}e_i,
\qquad
D_2(e_i e_j)=F_i e_j-F_j e_i.
\]

The map `D3` is reconstructed independently from the signed Leibniz rule:

\[
d(e_i f_a)=F_i f_a-e_i d(f_a),
\]

\[
d(e_i e_j e_k)=F_i e_j e_k-F_j e_i e_k+F_k e_i e_j.
\]

The columns of `Z` are the frozen candidate differentials `d(g_b)` in the
displayed basis of `E2`.  Thus the shapes of `D1`, `D2`, `D3`, `Z`, and `B`
are respectively `1x16`, `16x150`, `150x1040`, `150x136`, and `150x1176`.
Both CAS scripts check every source and target shift and every nonzero entry's
homogeneous degree.

## Exact module certificates

Both systems first verify the exact polynomial-matrix identities over
`QQ`

\[
D_1D_2=0,\qquad D_2D_3=0,\qquad D_2Z=0.
\]

Macaulay2 then computes the full, unbounded homogeneous syzygy matrices

\[
K_1=\operatorname{syz}(D_1),\qquad
K_2=\operatorname{syz}(D_2),
\]

with 30 and 136 columns.  It retains homogeneous polynomial lift matrices
satisfying

\[
D_2Q_1=K_1,\qquad K_1P_1=D_2,
\]

\[
BQ_2=K_2,\qquad K_2P_2=B.
\]

Because `im(K1)=ker(D1)` and `im(K2)=ker(D2)` by the full syzygy
computations, these two-sided identities certify both containments in

\[
\ker D_1=\operatorname{im}D_2,
\qquad
\ker D_2=\operatorname{im}B
          =\operatorname{im}[D_3\;Z].
\]

The retained Macaulay2 certificate contains exact polynomial entries and
source shifts—not ranks, Hilbert functions, or a finite-degree truncation.
Its checker reconstructs the maps and multiplies the matrices again.  The
full syzygy computation remains a required part of every replay: retained
lift identities alone would not establish that a displayed `K_i` generates
the entire kernel.

Singular independently constructs the same maps from the canonical sparse
input and computes its own full `syz(D1)` and `syz(D2)`.  Its Gröbner-dependent
generating sets have 31 and 141 columns; their nonminimality does not affect
the generated modules.  Singular retains exact lifts `L1,L2` satisfying

\[
D_2L_1=K_1^{\mathrm{Sing}},\qquad
BL_2=K_2^{\mathrm{Sing}}.
\]

Together with the three zero composites, those identities independently
give the same two module equalities.  A second Singular script reloads the
ASCII dump and multiplies all chain and lift identities again.  Neither
certification path loads `DGAlgebras` or calls `killCycles`; both use public
core exact-arithmetic operations.  As with Macaulay2, the retained Singular
identities are an integrity/reload check; fullness of its displayed kernels
comes from the fresh `syz` computations that precede the byte comparison in
every complete replay.

## Why this is the missing Tate-stage hypothesis

The first equality says that adjoining the 30 generators `f_a` kills all
homology in homological degree 1.  The second says that the decomposable
degree-3 boundaries together with the 136 displayed `d(g_b)` kill every
cycle in homological degree 2.  Consequently no additional generators are
missing in homological degrees 2 or 3, and the displayed DG algebra is a
genuine initial segment of a Tate resolution.  A full resolution can continue
by adjoining generators in homological degree at least 4.

This is essential to the source proof's extension lemma.  If either equality
failed, completing the resolution would require extra low-degree generators.
Those generators would change the degree-2 or degree-3 derivation cochain
modules, their boundary map, and hence the quotient in which the source
proof reduced its commutator columns.  A calculation on only the displayed
generators would then not certify intrinsic Andre-Quillen `T^3` classes.

## Consequence for the commutator classes

Let `P` be a full Tate resolution continuing this certified initial segment.
The source computation solves the closure equations for its degree-1
derivation `theta` and degree-2 derivations `eta_j` on every displayed
`e_i,f_a,g_b`.  A closed derivation `vartheta` of degree `p=1` or `2` extends
inductively over every later Tate generator `z` of homological degree `n>=4`.
Closedness prescribes

\[
d(\vartheta z)=(-1)^p\vartheta(dz).
\]

The right side is a cycle of homological degree `n-p-1`, which is positive.
Acyclicity of the full Tate resolution makes it a boundary.  Its primitive
has lower generator degree and can be chosen in the required internal degree,
so the induction changes none of the already computed values.

Thus the source proof's `theta` and `eta_j` extend to globally closed
derivations, and their graded commutators are globally closed degree-3
derivations.  Since the target algebra is concentrated in homological degree
zero, the degree-3 cochain component is determined by values on degree-3
Tate generators, and its boundaries are exactly `im(delta_2)`.  Therefore

\[
T^3_0(A)=\ker(\delta_3)/\operatorname{im}(\delta_2)
\longrightarrow C^3_0/\operatorname{im}(\delta_2)
\]

is injective.  Independence of the source proof's closed commutator columns
in the quotient on the right is therefore independence of genuine intrinsic
Andre-Quillen `T^3_0` classes, rather than an artifact of a truncated DG
algebra.  This audit supplies the low-stage exactness premise of that
argument; it does not rerun the source proof's closure, commutator, or rank
calculations.

## Scope

This certificate proves the two low-stage module equalities for the exact
frozen `F,R,Z` data and checks them independently in Macaulay2 and Singular.
Provenance ties those data to the pinned construction in the referee packet;
the one-time extraction is not itself treated as an independent
certification path.

It does not assert that the finite displayed DG algebra is a full resolution,
compute `H_3`, determine the total dimension of intrinsic `T^3_0`, recompute
the 27 commutators or their rank 12, verify
`ker(ad_y)=im(Dq_y)`, rerun the miniversal or incidence calculations, or
independently prove the smoothing theorem.
