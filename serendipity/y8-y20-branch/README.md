# The historical $y_8,y_{20}$ branch

This independent project reconstructs the old
$y_8,y_{20}$ flat branch over
$K=\mathrm{GF}(32003)$. The historical
computation tested a grid of 56 coefficient
pairs. Four pairs were additionally lifted
through order 6 and frozen in `data/`.

For every reconstructed pair, the exact colon
calculation gives

```text
J:t = J.
```

Thus multiplication by $t$ is injective on the
homogeneous coordinate ring. After localizing
the base at $t=0$, this is a torsion-free module
over the DVR $K[t]_{(t)}$, hence a flat module.
The special fibre is the Grünbaum
Stanley--Reisner scheme.

All 56 families also contain the same projective
section

```text
p = [0:0:0:0:0:0:1:0].
```

Direct symbolic substitution in $K[t]$ shows
that every generator vanishes at $p$ and that
all 128 entries of the $16\mathbin{\times}8$
$x$-Jacobian vanish there. The generic fibre
has projective dimension 3 by flatness, while
its embedded tangent space at $p$ is all of
$\mathbf P^7$. Therefore the geometric generic
fibre of every one of these 56 families is
singular. None of them is a smoothing over
$\mathrm{GF}(32003)$.

Run from the repository root:

```sh
sage serendipity/y8-y20-branch/reconstruct_families.sage
sage serendipity/y8-y20-branch/verify_flatness.sage
sage serendipity/y8-y20-branch/verify_singular_section.sage
sage serendipity/y8-y20-branch/test_known_pairs.sage
```

The fast singular-section command independently
recomputes flatness for the four frozen pairs
and proves generic singularity without an
expensive minors-and-saturation calculation.
To bypass the saved 56-pair Boolean audit and
independently reconstruct and verify the whole
historical grid, run:

```sh
sage serendipity/y8-y20-branch/verify_singular_section.sage \
  --all-56 --workers 4
```

The last command above, `test_known_pairs.sage`,
retains the older Jacobian-minors test at
$t=1$. By default it checks the metadata in the
frozen smoothness caches; pass
`--recompute-smoothness` to repeat the expensive
minors-and-saturation calculations.

This result eliminates these 56 finite-field
candidates only. It does not prove that the
Grünbaum Stanley--Reisner variety has no
smoothing in another deformation direction,
and a computation over $\mathrm{GF}(32003)$ by
itself does not settle smoothability in
characteristic zero.
