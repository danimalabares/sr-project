# The historical $y_8,y_{20}$ branch

This independent project reconstructs the old
$y_8,y_{20}$ flat branch over
$\mathrm{GF}(32003)$. The historical
computation tested a grid of 56 coefficient
pairs. Four pairs were additionally lifted
through order 6.

The scripts here first recover and freeze the
exact representatives selected by the old
solver, then verify their flatness and test
whether a nonzero fibre is smooth. No
smoothness conclusion should be recorded
until those tests finish.

Run from the repository root:

```sh
sage serendipity/y8-y20-branch/reconstruct_families.sage
sage serendipity/y8-y20-branch/verify_flatness.sage
sage serendipity/y8-y20-branch/test_known_pairs.sage
```

The last command reuses and validates the
frozen smoothness caches. Pass
`--recompute-smoothness` only to deliberately
repeat the expensive Jacobian calculations.
