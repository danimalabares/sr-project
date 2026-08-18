# All-ones versal-base arc

This directory gives an exact finite-order calculation for the tangent
direction

\[
y=(1,\ldots,1)\in T^1
\]

of the Stanley--Reisner deformation problem.  The arc calculation is over
\(\mathbf F_{32003}\); the coordinate transport, tangent-space checks, and a
second finite Bianchi lift are over \(\mathbf Q\).  Parameter and equation
indices in the reports are one-based.

## Reproduce

From the repository root, using Macaulay2 1.20 and SageMath:

```sh
M2 --script proofs/all-ones-versal-arc/export_base.m2
sage proofs/all-ones-versal-arc/verify_arc.sage
M2 --script proofs/all-ones-versal-arc/export_base_QQ.m2
M2 --script proofs/all-ones-versal-arc/export_t1_QQ.m2
M2 --script proofs/all-ones-versal-arc/export_rational_two_jet.m2
sage proofs/all-ones-versal-arc/transport_coordinates.sage
sage proofs/all-ones-versal-arc/check_prescribed_two_jet.sage
M2 --script proofs/all-ones-versal-arc/check_rational_direction.m2
M2 --script proofs/all-ones-versal-arc/check_tangent_dimensions.m2
M2 --script proofs/all-ones-versal-arc/compute_aq_bracket.m2
M2 --script proofs/all-ones-versal-arc/lift_bianchi.m2
M2 --script proofs/all-ones-versal-arc/lift_bianchi_QQ.m2
```

The first command uses `VersalDeformations` with `SmartLift=>false` to export
the 27 homogeneous base equations in degrees 2, 3, 4, and 5.  The second
command parses that export and performs exact polynomial and linear algebra.
It keeps every kernel parameter at each recursive step; it never interprets
failure of a chosen particular lift as an intrinsic obstruction.

## What the degree-five calculation proves

Put

\[
t(s)=s y+v_2s^2+v_3s^3+v_4s^4+\cdots .
\]

If \(g_2\) is the quadratic base term and
\(A=Dg_2|_y\), then `verify_arc.sage` certifies

- `rank(A) = 15`, `dim ker(A) = 38`, and `dim coker(A) = 12`;
- the order-3, order-4, and order-5 cokernel compatibility polynomials vanish
  identically while all 38 fresh kernel variables are retained; and
- consequently every lift through order 4 of this tangent direction extends
  through order 5.

One especially sparse exact arc modulo \(s^6\) has \(v_2=0\),

```text
v3:  1:1, 11:2, 16:1, 26:-1
v4:  1:1, 2:-4, 5:-3, 11:-5, 12:-5, 16:3, 17:3,
     18:-5, 20:-3, 26:1, 29:4, 36:-2, 37:5, 40:-5
```

and all 27 exported base equations vanish after substitution modulo \(s^6\).
The signed integers above denote their residue classes modulo 32003.

The checked-in certificates contain the nonsingular 15-by-15 minor used for
the exact splitting and the complete symbolic coefficient vectors.  The
generated base export is not checked in; each newly generated certificate
contains its SHA-256 digest.

This all-ones finite-field calculation is not by itself a characteristic-zero
formal arc, an algebraization, or a smoothing.  The independent rational
direction and its all-orders argument are treated below so those distinctions
remain visible.

## Bianchi calculation and rational direction

The historical deterministic \(T^1\) coordinates differ from Macaulay2's
`CT^1` coordinates by a permutation.  `transport_coordinates.sage`
reconstructs both complements in the common 1664-dimensional raw correction
space over \(\mathbf Q\), proves that permutation exactly, and transports the
rational generic top-component point before it is used.  The independent
`check_rational_direction.m2` computation then proves

```text
q(y) = 0
rank Dq_y = 15
number of linear syzygies = 24
rank S(y) = 12
ker S(y) = image Dq_y
```

over \(\mathbf Q\).

`check_prescribed_two_jet.sage` compares the deterministic historical
second-order lift with Macaulay2's canonical lift at this rational direction.
After centered lifting from \(\mathbf F_{32003}\) to \(\mathbf Q\), their 16
first-order cubics agree exactly.  Their second-order cubics differ only by a
coordinate derivation: the induced coefficient in the 53-dimensional
versal-base complement is

```text
v2 = (0,...,0).
```

The exact cubic base coefficient also vanishes at this two-jet.  Thus the
historical prescribed two-jet reaches order three and is the same versal-base
two-jet as the canonical one, up to an infinitesimal coordinate change.

`compute_aq_bracket.m2` computes the intrinsic André--Quillen tangent-Lie
operation at the transported rational direction over \(\mathbf Q\).  It
certifies

```text
rank [y,-] = 12
rank Dq_y = 15
[y,-] composed with Dq_y = 0
ker [y,-] = image Dq_y
```

The primary DG-algebra commutator is checked to equal \(-Dq_y\) in the
actual `VersalDeformations` coordinates.  The curved Bianchi identity then
shows that every successive residual of a partial arc lies in
`image(Dq_y)`, so it can be killed by the next base coefficient.  Since the
prescribed two-jet above has `v2=0` and zero cubic residual, it extends to a
formal base arc to all orders over \(\mathbf Q\).  See
[AQ_BRACKET.md](AQ_BRACKET.md) for the chain model and its Tate-extension
lemma, and [BIANCHI.md](BIANCHI.md) for the induction.

As an independent finite-order cross-check, `lift_bianchi.m2` recursively
lifts all 24 linear syzygies through every exported base term.  It verifies
the Bianchi identities through total degree 6 exactly over
\(\mathbf F_{32003}\).  `export_base_QQ.m2` and `lift_bianchi_QQ.m2`
independently reproduce the same finite lift over \(\mathbf Q\).  The
characteristic-zero export has the same SHA-256 digest and the four lifted
matrices have the same nonzero-entry counts.

Both degree-five exports are nonterminal: their last homogeneous base term is
nonzero and `VersalDeformations` reports that `HighestOrder` was reached.
Thus neither finite calculation is a syzygy of a known complete polynomial
base.  Polynomial termination is unnecessary for the all-orders proof,
which instead uses the intrinsic fixed-direction bracket.  In particular,
the finite syzygy lift is corroborating evidence and is not itself presented
as the all-orders argument.
