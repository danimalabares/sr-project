# In search of a smoothing 

In a [1967 paper](https://doi.org/10.1016/S0021-9800(67)80055-3), Grünbaum and Sreedharan
discovered a triangulation 
$\mathcal{M}$ of the 3-sphere
with interesting combinatorial properties.
The Stanley-Reisner variety
$SR(\mathcal{M})$ is a union of linear
subspaces in $\mathbb{P}^7$, and is highly
singular. We look for a smoothing of
$SR(\mathcal{M})$,
that is, a flat family whose special 
fibre is $SR(\mathcal{M})$
and whose general fibre is a smooth variety.

It is not known whether such a smoothing
exists. The current state of the project
may be summarized as follows:

* Preliminary computations show
the dimension of the space $T^1$ of first-order
deformations of $SR(\mathcal{M})$
is 53. This has been observed via 
two methods: using a formula by
[Altmann–Christophersen, *Deforming Stanley–Reisner
schemes*](https://doi.org/10.1007/s00208-010-0490-x) 
which relies on the
combinatorial structure of the underlying
simplicial complex; and by direct
computation considering syzygy
constraints.

* Preliminary computations show
the dimension of the obstruction space
$T^2$ is 12 and that there are
27 quadratic obstruction conditions.

* We found several deformation directions
which lift up to high orders (up to 30); and
a few flat families, but none which has been
shown to have smooth general fibre.

* There exists a smooth projective variety
 [studied by
Gulliksen–Negård](https://zbmath.org/?q=an%3A0238.13015)
whose graded  Betti table matches
identically with that of $SR(\mathcal{M})$.
We have not managed to prove whether they
are deformation-equivalent.


**Note.** This repository is currently being
restructured for a more transparent
computational flow and easier reading.
Currently, the directory `rl/` contains the
friendliest explanations and even some
coding exercises.

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

* `rl/` is the current workspace.
The directory's name comes from the
motivation of constructing a reinforcement
learning machine to explore the deformation
space, which has been found to be
computationally unmanageable. As of
30/7/2026, I have constructed the basic
mathematical functions; the next step is to
implement a statistical method which would
make the machine ``learn''.

* `serendipity/` records a few
flat families found 
during the search (one of them
by serendipity), along with the
corresponding 
smoothness tests.

* `old-code` captures the essential results
from the repository where I used to work
before July 2026:

  - `old-code/GN2/` contains my attempts
    to deform $SR(\mathcal{M})$
    to Gulliksen–Negård's variety. 
    I tried to use initial ideals,
    homogenization forms and Gröbner fans
    (see [Eisenbud, *Commutative Algebra: with a View Toward
    Algebraic Geometry*, Theorem 15.17](https://doi.org/10.1007/978-1-4612-5350-1)).
    My attempts failed because
    the computations are too heavy.

  - `old-code/cotangent/` contains the initial
    computations of the first-order
    deformation space $T^1$, the obstruction
    space $T^2$, and higher-order lifts.
    In particular, we found
    a set of first-order directions which
    lift up to order 30, but
    never managed to find a family from these
    finite-order lifts. The current work in `rl/`
    continues the search in this spirit.

  - `old-code/more-lifting/` is just like
    `old-code/cotangent`. (To do: merge these
    two directories).

* `lean/` contains preliminary Lean
certificates on some of the above results.
I need to check the details of these files.

* `journal.md` is the working research journal.


## Software

The scripts use SageMath, Macaulay2, Python
3 with NumPy/SciPy/SymPy, and Lean 4 with
Mathlib. I work with ChatGPT Pro, both in
the online version and local Codex terminal
sessions.
