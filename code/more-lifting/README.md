# more-lifting

This directory studies the abstract versal
deformation base of `SR(M)` beyond the GN2
non-Groebner obstruction.

Computed here:

- `01_versal_base_structure.m2` analyzes the 27 quadratic obstruction equations in the 53 `T^1` coordinates.
- `02_hodge_of_smoothing.m2` computes the basic determinantal CY3 data in Macaulay2 and compares the expected smooth-side deformation dimension with the quadratic obstruction cone.
- `03_probe_order3_on_quadratic_samples.sage` connects the existing higher-order lifting data from `code/cotangent/order2/` back to the 53 `T^1` coordinates and probes order-3 lifting on representative sample points of the quadratic cone.
- `04_candidate_branch_flatness_diagnostics.sage` summarizes the constructive status of the known QQ cubic branch using the cached flatness-inspection data from `code/cotangent/order2/`.
- `05_top_component_generic_lifts.sage` samples genuinely generic points on the unique 38-dimensional top quadratic component and tests how far they lift order-by-order over `GF(32003)`.
- `06_order4_locus.sage` samples one generic point on each of the `27` irreducible product components of the quadratic cone and tests lifting through order `4`.
- `07_extract_top_order4_obstruction.sage` extracts an explicit left-kernel compatibility witness for the generic order-4 failure on the top component, and compares it with the saved sparse order-30 branch.
- `08_probe_top_obstruction_support.sage` tests whether the sparse `07` witness support persists across several generic top-component points.
- `09_wall_determinant_oracle.sage` turns the stable 8-row support into an explicit `8 x 8` determinant oracle for the local order-4 wall equation.
- `10_test_sparse_branch_wall.sage` evaluates the `09` determinant oracle on the saved sparse order-30 formal branch.
- `11_probe_rank_drop_locus.sage` tests whether the saved branch's rank-drop behavior persists on the same sparse support and on nearby sparse supports.
- `12_sparse_slice_higher_order.sage` tests whether generic points on the exact 7-coordinate sparse slice lift beyond order `4`.
- `13_sparse_slice_flatness_samples.sage` builds cubic family ideals for the saved branch and random sparse-slice points over `GF(32003)`, then tests `t`-torsion and saturated special fibers.
- `14_sparse_slice_torsion_witnesses.sage` records the actual `t`-torsion witnesses and saturation layers for the sparse-slice cubic family ideals.
- `15_test_colon_witness_repairs.sage` tests direct repairs by adding the stable colon/saturation witnesses as extra family generators.
- `16_legal_torsion_repair_targets.sage` classifies which torsion-layer monomials lie in the SR(M) ideal and therefore can be legal special-fiber repair terms.
- `17_constrained_saturation_repair.sage` iteratively adds only legal elements from `J:t` and verifies that this legal closure still gets stuck at the illegal layer-3 witnesses.
- `18_random_lifted_legal_repairs.sage` tests a first lifted repair ansatz with legal constant terms and random `t`-corrections; this ansatz still leaves the same four extra saturated special-fiber equations.
- `19_sample_lift_kernel_representatives.sage` goes back to the lifting step and samples alternative order-2/order-3 representatives by randomizing the linear-system column order; the generator corrections do not change, and the same flatness defect remains.
- `20_layer3_lifted_legal_attack.sage` tests the first illegal layer directly: after adding lifted legal witnesses `h_i=m_i+tq_i`, it checks whether `t*x1*x3*x4*x7` and `t*x1*x3*x4^2` are still forced by the enlarged ideal.
- `21_saturate_saved_lifted_legal_hit.sage` takes the deterministic successful trial from `20`, records the actual `q_i`, then computes the full `t`-saturation and saturated special fiber.
- `22_compare_lifted_legal_subansatz.sage` compares raw, individual, grouped, and full lifted legal corrections using the same saved `q_i`, measuring the first-colon explosion and illegal special-fiber remainders.
- `23_minimal_layer2_lift_search.sage` keeps `m1,m2,m3` raw and searches sparse singleton corrections for only `m4,m5`, using monomials from the successful `q4,q5` supports.
- `24_saturate_best_layer2_pair.sage` saturates the best sparse layer-2 pair found by `23`.
- `25_parametric_best_layer2_pair.sage` tests the two-parameter ansatz
  `q4=a*x0*x1*x3*x7`, `q5=b*x1*x3^2*x4` on a deterministic finite-field grid.
- `26_wider_branch_search.sage` opens the search beyond the exact sparse
  slice by turning on extra coordinates inside the top quadratic component,
  then testing order-4 liftability and `t`-saturated special fibers.
- `27_y20_line_probe.sage` probes the one-parameter line obtained by adding
  a nonzero `y20` coefficient to the sparse branch.
- `28_y20_plus_one_probe.sage` fixes `y20=37` and adds one further
  `T^1` coordinate at a time, searching for a second drop in the
  saturated-special-fiber defect.
- `29_y8_y20_grid_probe.sage` isolates the successful `y8,y20`
  enrichment and tests a coefficient grid in both coordinates.

Rerun from this directory:

```bash
M2 --script 01_versal_base_structure.m2
M2 --script 02_hodge_of_smoothing.m2
HOME=/tmp sage 03_probe_order3_on_quadratic_samples.sage
HOME=/tmp sage 04_candidate_branch_flatness_diagnostics.sage
HOME=/tmp sage 05_top_component_generic_lifts.sage
HOME=/tmp sage 06_order4_locus.sage
HOME=/tmp sage 07_extract_top_order4_obstruction.sage
HOME=/tmp sage 08_probe_top_obstruction_support.sage
HOME=/tmp sage 09_wall_determinant_oracle.sage
HOME=/tmp sage 10_test_sparse_branch_wall.sage
HOME=/tmp sage 11_probe_rank_drop_locus.sage
HOME=/tmp sage 12_sparse_slice_higher_order.sage
HOME=/tmp sage 13_sparse_slice_flatness_samples.sage
HOME=/tmp sage 14_sparse_slice_torsion_witnesses.sage
HOME=/tmp sage 15_test_colon_witness_repairs.sage
HOME=/tmp sage 16_legal_torsion_repair_targets.sage
HOME=/tmp sage 17_constrained_saturation_repair.sage
HOME=/tmp sage 18_random_lifted_legal_repairs.sage
HOME=/tmp sage 19_sample_lift_kernel_representatives.sage
HOME=/tmp sage 20_layer3_lifted_legal_attack.sage
HOME=/tmp sage 21_saturate_saved_lifted_legal_hit.sage
HOME=/tmp sage 22_compare_lifted_legal_subansatz.sage
HOME=/tmp sage 23_minimal_layer2_lift_search.sage
HOME=/tmp sage 24_saturate_best_layer2_pair.sage
HOME=/tmp sage 25_parametric_best_layer2_pair.sage
HOME=/tmp sage 26_wider_branch_search.sage
HOME=/tmp sage 27_y20_line_probe.sage
HOME=/tmp sage 28_y20_plus_one_probe.sage
HOME=/tmp sage 29_y8_y20_grid_probe.sage
```

Logs:

- `cache/01_versal_base_structure.log`
- `cache/02_hodge_of_smoothing.log`
- `cache/03_probe_order3_on_quadratic_samples.log`
- `cache/04_candidate_branch_flatness_diagnostics.log`
- `cache/05_top_component_generic_lifts.log`
- `cache/06_order4_locus.log`
- `cache/07_extract_top_order4_obstruction.log`
- `cache/08_probe_top_obstruction_support.log`
- `cache/09_wall_determinant_oracle.log`
- `cache/10_test_sparse_branch_wall.log`
- `cache/11_probe_rank_drop_locus.log`
- `cache/12_sparse_slice_higher_order.log`
- `cache/13_sparse_slice_flatness_samples.log`
- `cache/14_sparse_slice_torsion_witnesses.log`
- `cache/15_test_colon_witness_repairs.log`
- `cache/16_legal_torsion_repair_targets.log`
- `cache/17_constrained_saturation_repair.log`
- `cache/18_random_lifted_legal_repairs.log`
- `cache/19_sample_lift_kernel_representatives.log`
- `cache/20_layer3_lifted_legal_attack.log`
- `cache/21_saturate_saved_lifted_legal_hit.log`
- `cache/22_compare_lifted_legal_subansatz.log`
- `cache/23_minimal_layer2_lift_search.log`
- `cache/24_saturate_best_layer2_pair.log`
- `cache/25_parametric_best_layer2_pair.log`
- `cache/26_wider_branch_search.log`
- `cache/27_y20_line_probe.log`
- `cache/28_y20_plus_one_probe.log`
- `cache/29_y8_y20_grid_probe.log`

## Dani-understandable meaning of `06`

The 27 quadratic components are the first big
list of possible directions in which a
smoothing could start.  Passing the quadratic
equations means a direction is plausible to
second order, but it does not yet mean it
comes from an actual family.

The `06_order4_locus.sage` experiment picked
one generic point on each of these 27
components and asked a stricter question: can
this direction be continued to order 3 and
then order 4?

What happened:

- all 27 sampled directions pass the
- quadratic test and lift to order `2`; 26 of
- the 27 generic directions fail already at
- order `3`; the remaining top component
- `(0,0,0)` reaches order `3` but fails at
- order
  `4`;
- the failure is always rank-gap one, so at
- the first failing order there is
  exactly one extra condition missing.

So this does **not** disprove the CY3.  It
says something more precise: a smoothing, if
it exists, is not generic on any of the 27
quadratic components.  It must lie on a
smaller, more special locus inside them.
This fits the known sparse branch, which
lifts formally to order `30`.

The next useful computation is therefore to
extract the actual rank-gap-one equation,
starting on the top component `(0,0,0)`, and
check whether the known order-30 branch lies
on its zero locus.

The first version of this extraction is
`07_extract_top_order4_obstruction.sage`. At
the same generic top-component point used in
`06`, it finds an explicit left-kernel
certificate

```text lambda * A = 0,   lambda * b = 1 ```

for the failed order-4 system `A x = b`.
This `lambda` is very sparse: only `8`
nonzero entries among `9898` rows.  The same
script checks the saved sparse branch from
the order-30 formal lift, using its saved
lower-order corrections, and that branch
**does** pass the order-4 rank test.

So the situation is now:

- generic top-component direction: obstructed
- at order `4`; known sparse branch: not
- obstructed at order `4`, and known to lift
  formally to order `30`;
- next step: interpolate/globalize the sparse
- `lambda`-certificate into an
  actual equation on the top-component
parameters.

The follow-up
`08_probe_top_obstruction_support.sage`
checks whether the same sparse witness
support is stable, rather than just an
artifact of one sample.  On five
deterministic generic samples of the top
component, the full left-kernel witness
always has the same support:

```text [138, 139, 142, 143, 144, 146, 150,
157] ```

Moreover, using exactly this fixed 8-row
support from the first sample produces a
valid witness at all five samples.  This
means the next interpolation target is
genuinely small: the 8-row subsystem indexed
by this fixed support.

The next script,
`09_wall_determinant_oracle.sage`, makes this
even more concrete.  On the fixed rows

```text [138, 139, 142, 143, 144, 146, 150,
157] ```

the coefficient matrix has rank `7` at
generic top-component points.  The script
chooses stable pivot columns

```text [1696, 1699, 1701, 1702, 1723, 1725,
1726] ```

and forms the `8 x 8` determinant

```text det([A_fixed_rows,pivot_columns |
b_fixed_rows]). ```

This determinant is nonzero on all eight
tested generic samples, exactly as expected
for obstructed generic points.  The local
order-4 wall equation is therefore this
determinant set equal to zero.

Finally, `10_test_sparse_branch_wall.sage`
evaluates this determinant on the saved
sparse order-30 branch.  The generic sanity
check has nonzero determinant `6123`, while
the saved sparse branch has

```text saved wall determinant = 0 saved
pivot coefficient rank = 1 saved order 4
lifts = True ```

So the saved sparse branch really does lie on
the determinant wall.  In fact it lies on a
more degenerate part of the chosen chart,
where the generic pivot rank drops from `7`
to `1`.

The follow-up `11_probe_rank_drop_locus.sage`
asks whether this is just one special
coefficient choice or a whole sparse-support
phenomenon.  It finds:

- every tested random point on the exact
- support
  `{y0,y2,y3,y19,y33,y34,y41}` passes the
quadratic equations, lifts through order `4`,
has wall determinant `0`, and has pivot rank
`1`;
- some two-coordinate enlargements of this
- support fail already quadratically; among
- the two-coordinate enlargements that pass
- the quadratic equations,
  some lift through order `4`, but one tested
point has wall determinant `0` and still
fails at order `4`.

So the exact 7-coordinate sparse support
looks like a real order-4-compatible linear
slice.  The wall determinant is necessary but
not sufficient once we move off that slice.

The higher-order check
`12_sparse_slice_higher_order.sage` then
tests the same exact sparse slice through
order `10`.  The saved branch and five random
points on the sparse support all reach order
`10`.  In every case the solver finds the
same pattern:

```text G1 nonzero, G2 nonzero, G3 nonzero,
G4 = G5 = ... = G10 = 0, A1 nonzero, A2 = A3
= ... = A9 = 0. ```

So the cubic formal pattern is not just
attached to the saved point.  It appears
generic on the 7-coordinate sparse slice, at
least through order `10`.

The flatness sample
`13_sparse_slice_flatness_samples.sage` then
tests the actual cubic family ideal for the
saved point and two random sparse-slice
points over `GF(32003)`.  All three have the
same defect:

```text J:(t) == J: False saturation steps
used = 4 K0 == I: False extra K0 generators
modulo I = x1*x3*x4*x7, x1*x3*x4^2,
x1*x3^2*x7^2, x1^2*x4^3. ```

So the sparse slice gives a robust formal
cubic pattern, but the naive generator ideal
still has the same
`t`-torsion/saturated-special-fiber defect
generically on that slice.

The torsion-witness script
`14_sparse_slice_torsion_witnesses.sage`
shows the defect is completely stable between
the saved branch and a random sparse-slice
point.  The first colon has three monomial
witnesses:

```text x0*x2*x3*x7, x0*x2*x3*x4,
x2^2*x3^3*x7^2. ```

The saturation layers then introduce:

```text layer 2: x2*x3^2*x7, x0*x1*x4^2 layer
3: x1*x3*x4*x7, x1*x3*x4^2 layer 4:
x1*x3^2*x7^2, x1^2*x4^3 ```

The final four are exactly the extra
special-fiber equations.  This gives a
concrete repair target: the missing
family-ideal structure must kill the first
torsion witnesses without letting the later
layer-3/layer-4 monomials become extra
equations in the special fiber.

The direct repair test
`15_test_colon_witness_repairs.sage` tries
adding the stable witnesses as extra
generators:

- adding the layer-1 witnesses removes the
- first layer but shifts the torsion
  to layer 2;
- adding layer 1 plus layer 2 shifts the
- torsion to layer 3; adding all layers makes
- `J:(t)==J` true, but only because the four
- bad
  special-fiber equations have been added
outright.

Thus the naive colon-witness repair does
**not** produce a flat family with special
fiber exactly `I`.  It confirms the tension:
killing the torsion by adding these visible
witnesses also kills the desired special
fiber.

The follow-up
`16_legal_torsion_repair_targets.sage`
separates the legal and illegal special-fiber
repair terms.  The first two layers are in
`I`:

```text x0*x2*x3*x7, x0*x2*x3*x4,
x2^2*x3^3*x7^2, x2*x3^2*x7, x0*x1*x4^2. ```

But the next two layers are not in `I`:

```text x1*x3*x4*x7, x1*x3*x4^2,
x1*x3^2*x7^2, x1^2*x4^3. ```

So the saturated central fiber is not allowed
if the goal is a smooth variety degenerating
to exactly `SR(M)`.

The constrained repair
`17_constrained_saturation_repair.sage` then
adds only actual elements from `J:t` whose
`t=0` specialization lies in `I`.  It adds
four legal generators and then stops, because
the next colon witnesses are exactly the
illegal layer-3 monomials:

```text x1*x3*x4*x7, x1*x3*x4^2. ```

Saturating after this legal closure still
produces the same four bad extras.

Finally,
`18_random_lifted_legal_repairs.sage` tests a
first non-monomial repair ansatz.  It adds
four generators with legal constant terms:

```text layer1 + t*(linear combination of
layer2), layer2 + t*(linear combination of
layer3). ```

On 24 random coefficient choices for the
saved branch and 24 for a random sparse-slice
branch, every trial preserves the raw `t=0`
ideal but still has `J:(t) != J` and the same
four extra equations after saturation.  Thus
this small lifted-repair ansatz is also too
small.

The next attempted escape was to go back one
level and vary the lift representative
itself.  Full right-kernel extraction for the
order-3 linear system was too expensive, so
`19_sample_lift_kernel_representatives.sage`
uses a cheaper proxy: solve the
underdetermined order-2 and order-3 systems
after randomly permuting the
generator-correction columns.  If the
generator part had accessible solver-level
freedom, this would usually change `G2` or
`G3`.  In four samples it did not:

```text delta from saved: G2 nnz 0, G3 nnz 0
```

Every sampled representative had the same
flatness failure and the same four bad
saturated special-fiber equations.  This does
not prove the full affine kernel has no
useful direction, but it does show that the
generator corrections selected by the lifting
equations are rigid under this practical
probe.

Conclusions so far:

- The 27 quadrics split into three disjoint
- 12-variable blocks plus 17 free variables.
- Each 12-variable block has dimension `7`,
- degree `6`, and exactly `3` minimal primes,
- with dimensions `7, 6, 6`. Therefore the
- quadratic obstruction cone is `V_A x V_B x
- V_C x A^17`, with `27` product components.
- Their dimensions are:
  `35` (8 components), `36` (12 components),
`37` (6 components), `38` (1 component).
- For the smooth degree-20 Gulliksen-Negard
- Calabi-Yau threefold in `P^7`, the expected
- smoothing-component dimension is
- `h^1(T_X)=h^{2,1}=33`.
  The Macaulay2 part here verifies the
degree-20 / Betti / Hilbert data; the
Hodge-number input `rho=1`, `c3=-64` is taken
from Bertin's degree-20 GN example
(`arXiv:math/0701511`), giving `h^{2,1}=33`.
- Hence no irreducible component of the
- quadratic cone has the expected smoothing
- dimension `33`. The known higher-order
- branch from
- `code/cotangent/order2/cache/formal_lift_to_order30.sobj`
- projects to a very sparse first-order
- direction in the `y`-coordinates:
  support `{0,2,3,19,33,34,41}`. So it uses
only two coordinates in block `A`, one in
block `B`, one in block `C`, and three free
coordinates.
- A first cubic-order probe on the known
- branch plus six sparse sample points on the
- quadratic cone found:
  all seven tested directions lift to order
`3`. So cubic terms do not yet visibly cut
away these representative sparse directions.
- By contrast, three deterministic generic
- samples on the unique top-dimensional
- quadratic component
  `V_A^(0) x V_B^(0) x V_C^(0) x A^17` all
lift to order `3` but fail at order `4`, with
rank jump `rank_A = 6879`, `rank_B = 6880`.
So the order-30 formal branch is not generic
on that 38-dimensional component; it lies on
a more special higher-order-compatible locus.
- A full one-sample sweep of all `27`
- quadratic product components found no
- generic order-4 survivor.
  The unique top component `(0,0,0)` lifts to
order `3` and fails at order `4`; every other
sampled component lifts to order `2` and
fails already at order `3`. The rank gap is
consistently `1` at the first failing order.
- The order-4 failure on the generic top
- component has an explicit sparse
  left-kernel witness: `lambda` has `8`
nonzero entries and satisfies `lambda*A = 0`,
`lambda*b = 1`. The saved sparse order-30
branch passes the same order-4 rank test when
its saved lower-order corrections are used.
- The same 8-row witness support
  `[138,139,142,143,144,146,150,157]`
persists across five generic samples of the
top component, and that fixed support gives a
valid witness at every tested sample.
- The fixed support can be converted into a
- determinant oracle:
  using pivot columns
`[1696,1699,1701,1702,1723,1725,1726]`, the
local wall equation is
`det([A_fixed_rows,pivot_columns |
b_fixed_rows]) = 0`. This determinant is
nonzero on eight tested generic top-component
samples.
- The saved sparse order-30 branch lies on
- this wall:
  the same determinant is `0`, the saved
order-4 system is compatible, and the pivot
coefficient rank drops from generic rank `7`
to `1`.
- The rank-one behavior is not unique to the
- saved coefficients:
  eight random points on the same
7-coordinate sparse support all lift through
order `4` with pivot rank `1`. Near-sparse
perturbations are mixed, so the wall
determinant alone is not a full order-4
criterion away from this sparse slice.
- The same sparse slice also survives
- higher-order testing:
  the saved branch and five random
sparse-slice points all lift through order
`10`, with no corrections beyond the cubic
generator terms and first syzygy correction.
- The naive cubic generator ideal has the
- same flatness defect generically on
  the sparse slice as at the saved branch:
after `t`-saturation the special fiber
becomes `I` plus the same four extra
equations.
- The `t`-torsion chain causing that defect
- is stable on the sparse slice:
  first colon witnesses are `x0*x2*x3*x7`,
`x0*x2*x3*x4`, `x2^2*x3^3*x7^2`, and
saturation propagates to the same four extra
special-fiber monomials.
- Directly adding the stable colon/saturation
- witnesses does not repair the
  family: partial additions merely shift the
torsion later, while adding all layers makes
`t` a nonzerodivisor only after permanently
adding the four unwanted special-fiber
equations.
- The first illegal layer is not forced if
- the legal witnesses are lifted
  instead of added raw.  In
`20_layer3_lifted_legal_attack.sage`, the raw
legal baseline has `t*x1*x3*x4*x7` and
`t*x1*x3*x4^2` in the repaired ideal, but
random lifted legal witnesses with degree-4
standard-monomial `t`-corrections make both
membership tests fail while preserving the
raw special fiber.
- Saturating the deterministic lifted-legal
- hit from `20` does not repair the
  family.  In
`21_saturate_saved_lifted_legal_hit.sage`,
`J':t != J'`; full saturation takes six colon
steps, and the saturated special fiber is
still strictly larger than `I`.  The first
illegal monomials reappear among many
special-fiber extras, including
`x1*x3*x4*x7`, `x1*x3*x4^2`, `x1*x3^2*x7^2`,
and `x1^2*x4^3`.
- The subansatz comparison in
- `22_compare_lifted_legal_subansatz.sage`
- shows
  where the first-colon explosion starts.
Raw legal cleaning has only two first-colon
witnesses, both illegal.  Lifting `m4` kills
the `t*u2` membership test, lifting `m5`
kills the `t*u1` membership test, and lifting
`m4,m5` kills both, but already creates `215`
first-colon witnesses.  Lifting `m1,m2` does
not kill either named membership test and
increases the witness count to `130`; lifting
all five creates `1058` witnesses.
- The minimal layer-2 search in
- `23_minimal_layer2_lift_search.sage` finds
- a
  much smaller focused correction.  Keeping
`m1,m2,m3` raw and taking `q4 = x0*x1*x3*x7`
and `q5 = x1*x3^2*x4` kills both `t*u1` and
`t*u2` while producing only `8` first-colon
witnesses, `4` of which have illegal
special-fiber remainders.  This is the best
candidate found so far for a controlled
layer-2 correction.
- Saturating this best sparse pair in
- `24_saturate_best_layer2_pair.sage`
  still fails.  The colon chain is small and
terminates after three layers with witness
counts `8,7,3`, but the saturated special
fiber is not `I`. It contains seven illegal
extras: `x1*x3*x4*x7`, `x0*x1*x3*x7`,
`x1*x3*x4^2`, `x1*x3^2*x4`, `x1*x3^2*x7^2`,
`x1*x3^3*x7`, and `x1^2*x4^3`.
- The two-parameter test in
- `25_parametric_best_layer2_pair.sage` found
- no
  coefficient rescue on a 64-point
deterministic grid over `GF(32003)`. Every
tested nonzero pair `(a,b)` has the same
behavior: `t*u1` and `t*u2` are not in the
repaired ideal, saturation layers have counts
`8,7,3`, the saturated ideal is
`t`-saturated, and the saturated special
fiber still has the same seven illegal
extras.
- Constructively, the known QQ cubic family
- is not yet a genuine smoothing family:
  the naive ideal `J=(F_1(t),...,F_16(t))`
has `t`-torsion, and after `t`-saturation its
special fiber becomes `K_0 = I + (extra
equations)` rather than exactly `I`.
- More precisely, the saturated special fiber
- still contains all 16 shifted SR
- generators, but also four extra equations
  `x1^2*x4^3`, `x1*x3^2*x7^2`, `x1*x3*x4^2`,
`x1*x3*x4*x7`, and the degree drops from `20`
to `16`.

Remaining gap:

- This is not yet a proof that no smoothing
- exists. A genuine `33`-dimensional
- smoothing component could still sit as a
- proper subvariety of one of the `35`-`38`
- dimensional quadratic components, cut out
- by higher-order equations whose first
- nonzero terms are cubic or higher. The
- order-3/order-4 probes are still not a
- proof against smoothing: they test generic
- points of the quadratic components.
  A smoothing component could still sit
inside a proper higher-codimension locus, as
the known long formal branch does.
- On the constructive side, the next exact
- repair task is to change the family ideal,
- not just its truncated generators: remove
- the `t`-torsion without creating those four
- extra special-fiber equations after
- saturation. On the constructive side, the
- next exact task is to repair the family
- ideal
  on the sparse slice, not merely find more
formal generator corrections: we need to
remove the common `t`-torsion without adding
the four recurring extra special-fiber
equations.
- After `20`, the next focused test is not
- the raw layer-3 membership anymore:
  it is whether the lifted legal witnesses
merely postpone torsion to a later layer or
can actually improve the saturated special
fiber.
- After `21`, this particular lifted-legal
- hit should be counted as a no-go:
  it avoids the first layer-3 membership test
but only postpones/complicates the torsion
chain.
- After `22`, the useful local target is the
- layer-2 correction pair
  `m4,m5`; the layer-1 lifts `m1,m2` look
like noise for the named obstruction and
should be excluded from the next focused
ansatz.
- After `23`, the next exact test is to
- saturate the best sparse pair
  `q4=x0*x1*x3*x7`, `q5=x1*x3^2*x4` and
compare its special fiber with `I`.
- After `24`, the sparse-pair repair should
- be treated as a controlled no-go:
  it reduces the torsion explosion
dramatically, but saturation still forces a
small illegal special-fiber ideal.
- After `25`, coefficient scaling in the
- two-monomial ansatz is not a useful
  escape route; the next meaningful
enlargement would need new monomial
directions, not just rescaling `x0*x1*x3*x7`
and `x1*x3^2*x4`.

# July 6, 2026: 2-parameter ansatz for lifting

Summary of total progress + today's work:

First-order deformation space understood:
  T^1 dimension known.

Obstruction space partly understood:
  T^2 dimension known, quadratic obstruction data exists.

One promising formal branch found:
  lifts to high order.

But honest flatness fails:
  torsion cleaning changes the special fiber.

Simple repair attempts:
  tested and failed in controlled ways.

Next serious frontier:
  leave the tiny one-parameter sparse branch
  or impose symbolic conditions on a wider
  ansatz.


Next session: deformation branch checkpoint

Today we clarified the flatness failure of
the sparse one-parameter branch.

The original formal lift gives an ideal
\(J=(F_1(t),\dots,F_{16}(t))\) with correct
raw special fiber: \[ J+(t)=I+(t). \]

But it is not flat: torsion-cleaning
\(J:t^\infty\) changes the central fiber.

We tested simple repairs by adding legal
torsion witnesses. Raw cleaning breaks at
layer 3. Lifted corrections can hide the
first bad witnesses, but full saturation
still forces illegal special-fiber equations.

Best controlled repair so far:
\[
h_4=m_4+tq_4,\qquad h_5=m_5+tq_5.
\]

It reduces the torsion explosion, but the
saturated special fiber still contains seven
illegal extras. Scaling the two correction
monomials by parameters \(a,b\) did not
change the outcome.

Conclusion: the sparse branch is not repaired
by the small layer-2 ansätze tested today.

Next session should start by deciding between
two routes:

1. widen the ansatz using more
   \(T^1\)-directions, or  
2. turn the sparse-branch failure into a
   clean no-go statement for this branch.

The key question is now:

> Is the flatness failure intrinsic to this
> sparse one-parameter branch, or just an
> artifact of too small a repair ansatz?

# July 7, 2026: wider branch search

We chose the second route: open up the
first-order direction rather than keep
repairing only the tiny sparse branch.

The new script
`26_wider_branch_search.sage` stays inside
the intrinsic `T^1`/obstruction computation.
It does not use GN data.  It samples
controlled directions in the top quadratic
component by starting from the sparse support

```text
{y0,y2,y3,y19,y33,y34,y41}
```

and turning on extra A/B/C/free coordinates.

Result:

- `14` of `17` tested wider candidates lift
  through order `4`;
- three wider candidates fail at order `4`
  with rank gap one:
  `A_u2_A_v0_B_tail`,
  `C_q0_C_p0_C_f`, and `wider_top_patch`;
- all `14` order-4 survivors still have
  `J:(t) != J` and saturated special fiber
  strictly larger than `I`;
- most one-coordinate widenings reproduce
  the same four illegal extras as the sparse
  branch;
- the most interesting survivor is
  `B_w1`, with support
  `{y0,y2,y3,y19,y20,y33,y34,y41}`.
  Its saturated special fiber has only three
  visible extra generators modulo `I`, namely
  linear combinations of the old bad terms
  involving `x1*x3*x4*x7`,
  `x1*x3*x4^2`, and `x1^2*x4^3`.

So widening the direction definitely creates
new formal order-4 branches.  It does not
yet produce a flat family, but `B_w1` is a
better local target than the original sparse
anchor because the visible saturated
special-fiber defect is smaller.

Next useful computation: follow the
one-parameter `B_w1` widening symbolically,
or at least on a coefficient grid, to test
whether the missing fourth extra was killed
for structural reasons and whether some
coefficient choice can also eliminate the
remaining three extras.

# July 7, 2026: y20-line probe

The follow-up script
`27_y20_line_probe.sage` tests the line

```text
{y0,y2,y3,y19,y33,y34,y41} + c*y20
```

for

```text
c = 0, 1, 2, 3, 5, 7, 11, 13, 17, 19,
    23, 29, 37, 53, 101, -1
```

over `GF(32003)`.

Result:

- every tested value, including `c=0`, lifts
  through order `4`;
- `c=0` is the original sparse anchor and
  has the usual four visible extra
  saturated-special-fiber generators;
- every tested nonzero `c` has exactly three
  visible extra generators modulo `I`;
- no tested coefficient gives `J:(t)=J` or
  saturated special fiber exactly `I`.

So the improvement from adding `y20` is
structural for this sampled line: nonzero
`y20` consistently removes one of the four
old visible extras, but the remaining three
extras persist across the grid.

Next useful computation: enrich the
`y20`-line by adding one more coordinate and
look for a second structural drop in the
extra-generator count.

# July 7, 2026: y20 plus one-coordinate probe

The next intrinsic search script is
`28_y20_plus_one_probe.sage`.  It fixes the
improved line at

```text
y20 = 37
```

and then tries to add one more `T^1`
coordinate at a time.  The coefficient grid
for the added coordinate is

```text
1, 2, 3, 5, 7, 11, -1
```

over `GF(32003)`.

Important implementation detail: the full
grid is used for the quadratic filter, but
the expensive order-4/saturation stage first
tests one representative coefficient per
surviving coordinate.  This keeps the search
finite: the raw grid had `315` possible
one-coordinate additions, of which `238`
passed the quadratic equations, across `34`
different added coordinates.

Order-4 representative results:

- `34` coordinates survived the quadratic
  filter;
- `28` representative directions lifted
  through order `4`;
- six representative directions failed at
  order `4`:
  `y14`, `y28`, `y30`, `y38`, `y45`, `y47`;
- the previous `y20` line had `3` visible
  extra saturated-special-fiber generators;
- most added coordinates still have `3` or
  more extras;
- `y17=1` improves to `2` visible extras,
  but fails when rerun to order `5`;
- the major hit is

```text
{y0,y2,y3,y8,y19,y20,y33,y34,y41}
```

with coefficients inherited from the script
(`y20=37`, `y8=1`).  It has:

```text
J:(t) = J
(J:t^infinity)+(t) = I+(t)
extra generators modulo I = 0
```

for the constructed family ideal.  It also
reruns formally through order `6`; the
generator corrections satisfy

```text
G1 nonzero, G2 nonzero, G3 nonzero,
G4 = G5 = G6 = 0.
```

The order-6 family ideal was checked again
and still has

```text
J:(t) = J,  K0 = I,  extra count = 0.
```

This is a genuine computational candidate
for an intrinsic smoothing direction.  It is
not yet a proof: the search used finite-field
arithmetic and a representative coefficient
for each added coordinate.  The next task is
to isolate this `y8,y20` branch, test a
coefficient grid in both `y8` and `y20`, and
then replay the best hit over another prime
or over `QQ`.

# July 7, 2026: y8,y20 grid probe

The follow-up script
`29_y8_y20_grid_probe.sage` isolates the
branch found by `28`:

```text
{y0,y2,y3,y8,y19,y20,y33,y34,y41}.
```

It keeps the original sparse coefficients,
turns on both `y8` and `y20`, and tests the
grid

```text
y8  in {1,2,3,5,7,11,-1}
y20 in {1,2,3,5,7,11,37,-1}
```

over `GF(32003)`.

Result:

- all `56` coefficient pairs satisfy the
  quadratic obstruction equations;
- all `56` coefficient pairs lift through
  order `4`;
- every order-4 family ideal tested has

```text
J:(t) = J,
(J:t^infinity)+(t) = I+(t),
extra generators modulo I = 0.
```

The first four zero-extra hits were rerun to
order `6`, namely

```text
(y8,y20) = (1,1), (2,1), (3,1), (5,1).
```

All four still lift through order `6`, with

```text
G1 nonzero, G2 nonzero, G3 nonzero,
G4 = G5 = G6 = 0,
J:(t) = J,
K0 = I,
extra count = 0.
```

Dani interpretation: the old sparse branch
was a formal curve whose family ideal picked
up hidden `t`-torsion; after saturation the
central fiber got extra equations, so it was
not a smoothing.  Adding `y20` killed one
visible bad equation.  Adding `y8` as well
appears to kill the whole visible
saturation defect on this finite-field grid.
So `y8,y20` is not just a cosmetic
enrichment of the sparse line; it is now the
main intrinsic smoothing candidate produced
by these computations.

This is still a search result, not a proof.
It does not use GN data, but it is finite
field evidence and uses the implemented
lifting/saturation tests.  The next branch
strategy should be:

1. replay the `y8,y20` branch over a second
   prime to check that this is not an
   accidental `GF(32003)` phenomenon;
2. try a small `QQ` replay for a simple pair
   such as `(y8,y20)=(1,1)`;
3. if those agree, extract the actual
   truncated family equations and turn the
   finite-order computation into a symbolic
   or certifiable flatness argument.
