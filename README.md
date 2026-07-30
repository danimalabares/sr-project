# Search for a smoothing of SR variety of Grünbaum-Shreedharan's sphere

In a [1967 paper](https://doi.org/10.1016/S0021-9800(67)80055-3), Grünbaum and Sreedharan
discovered a triangulation 
$\mathcal{M}$ of the 3-sphere
with interesting combinatorial properties.
The Stanley-Reisner variety
$SR(\mathcal{M})$ associated
to $\mathcal{M}$ is a union of linear
subspaces in $\mathbb{P}^7$, and is highly
singular. We look for a smoothing of
$SR(\mathcal{M})$,
that is, a flat family whose singular
fibre is $SR(\mathcal{M})$
and whose general fibre is a smooth variety.

It is not known whether such a smoothing
exists. So far, we have found:

* A projective variety [studied by Gulliksen–Negård](https://zbmath.org/?q=an%3A0238.13015)
whose Betti numbers match identically with
those of $SR(\mathcal{M})$.
We could prove that these two varieties
are not deformation-equivalent via
Gröbner deformations. They could still
be so via another method.

* The dimension of the space $T^1$ of first-order
deformations of $SR(\mathcal{M})$,
which is 53. This has been confirmed
with two methods: using a result by
[Christophersen-Altmann](https://doi.org/10.1007/s00229-004-0496-3) where 
such dimension is computed using the
combinatorial structure of the underlying
simplicial complex; and by direct
computation of the general first-order
deformation space considering syzygy
constraints.

* The dimension of the second-order deformation space
$T^2$, which is 12, and a set of 30
quadratic obstruction equations.

* Several formal families which lift up
to high orders; and a few flat families, 
but none with smooth general fibre.


# Repository map

```text
sr-project/
├── README.md
├── journal.md
├── lean/
├── old-code/
│   ├── GN2/
│   ├── cotangent/
│   └── more-lifting/
├── rl/
│   ├── README.md
│   ├── sr_environment.sage
│   ├── search/
│   ├── tests/
│   └── runs/
└── serendipity/
    ├── README.md
    ├── data/
    └── y8-y20-branch/
```

* `rl/` is the current workspace---you
can find a more detailed explanation of
the mathematics and computations there.
The directory's name comes from the motivation of
constructing a Reinforcement Learning
machine which would explore efficiently the
spaces of deformations, which have been
found to be computationally unmanageable. As
of 30/7/2026, I have constructed the basic
mathematical functions, and I'm ready
to implement a statistical method
which would make the machine ``learn''.

* `serendipity/` records a few
flat families found by serendipity
during the search, along with the computations
which show that their general fibres are
singular.

* `old-code` captures the essential results
from the repository where I used to work
before July 2027:

- `old-code/GN2/` contains my attempts
to deform $SR(\mathcal{M})$
to Gulliksen–Negård's variety. 
I tried to use initial ideals,
homogenization forms and Gröbner fans
(see [Eisenbud, *Commutative Algebra: with a View Toward
Algebraic Geometry*, Theorem 15.17](https://doi.org/10.1007/978-1-4612-5350-1)).
My own attempts failed since
the computations are too heavy.
Later, AI claimed to have produced
a Lean-certified proof that this method
cannot possibly work, documented in
`lean/`.

- `old-code/cotangent/` contains the initial
computations of the first and second
order deformation spaces, obstructions,
and lifts. In particular, we found
a set of first-order directions which
lift formally up to order 30, but
never managed to find a family from these
formal lifts. The current work in `rl/`
continues the search in this spirit.

- `old-code/more-lifting/` is just like
`old-code/cotangent`. (To do: merge these
two directories).

* `lean/` contains at least two Lean 4
certificates: the failure of GN-to-$SR(\mathcal{M})$
deformation-equivalence explained above,
and the confirmation that
$\dim T^1 = 53$ but by syzygy computations
and using Christopher-Altmann combinatorial
formula. Note: these files/results are
preliminary and need a more careful analysis.

* `journal.md` is the working research journal.


# Current computational picture

**Status:** `SR(M)` has not been
proved smoothable nor
non-smoothable. The following claims
have been found using AI and would be
verified more thoroughly upon a conclusive
answer to our problem.

- $dim T^1 = 53$ and $dim T^2 = 12$.

- Generic first-order directions are
obstructed at second order.

- The raw calculation produces 27 quadratic
obstruction equations.

- A sparse branch lifts formally through
 order 30, but the resulting naive cubic
family is not flat: we found torsion
witnesses.

- Generic points of all 27 quadratic
components meet higher-order obstructions; a
smoothing direction, if present, must lie on
a smaller special locus.

- The determinantal Gulliksen–Negård
Calabi–Yau has matching numerical
invariants, but the tested coordinate
Gröbner-degeneration route to 
$SR(\mathcal{M})$ is
obstructed. A finite Gordan certificate is
included, together with its Lean
formalization.

## Software

The scripts use SageMath, Macaulay2, Python
3 with NumPy/SciPy/SymPy, and Lean 4 with
Mathlib.
