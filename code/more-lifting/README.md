# Higher-order lifting experiments

This directory studies possible deformations of `SR(M)` beyond the
quadratic obstruction calculation in `../cotangent/order2`.

The scripts test points on the 27-component quadratic obstruction cone,
attempt to lift them to higher order, and examine whether the resulting
families are flat. The main computational observations so far are:

- generic points on 26 components fail to lift at order 3;
- a generic point on the remaining top component reaches order 3 but
  fails at order 4;
- a special sparse branch lifts formally through order 30;
- the cubic family obtained from that branch is not flat: `t`-saturation
  changes the special fibre;
- later scripts probe smaller loci and possible repairs of this flatness
  defect, but no smoothing has been constructed.

The files are numbered in experimental order:

- `01`–`04`: quadratic cone, expected dimensions, and existing branch;
- `05`–`12`: higher-order lifting and the order-4 obstruction wall;
- `13`–`25`: torsion, saturation, and attempted flatness repairs;
- `26`–`29`: searches in wider first-order directions.

Most Sage scripts use checkpoint data from `../cotangent/part-1.pkl` and
`../cotangent/order2/cache/`. Run them from this directory with
`HOME=/tmp sage <script>.sage`. Macaulay2 files use
`M2 --script <script>.m2`.

These are exploratory computations. In particular, they do not prove
that `SR(M)` is smoothable or that it lies on a determinantal Hilbert
component.
