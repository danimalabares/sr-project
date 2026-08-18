# A smoothing of the Grünbaum Stanley--Reisner variety

In a [1967 paper](https://doi.org/10.1016/S0021-9800(67)80055-3), Grünbaum and Sreedharan
discovered a triangulation 
$\mathcal{M}$ of the 3-sphere
with interesting combinatorial properties.
The Stanley-Reisner variety
$SR(\mathcal{M})$ is a union of linear
subspaces in $\mathbb{P}^7$, and is highly
singular. We asked whether $SR(\mathcal{M})$ is smoothable: does it occur as
the special fibre of a flat projective family whose geometric generic fibre
is smooth?

## Answer: yes

The certificates in [`proofs/`](proofs/) construct such a family over
$\operatorname{Spec}\mathbf Q[[s]]$. Consequently the Grünbaum
Stanley--Reisner variety is smoothable in characteristic zero, and in
particular over $\mathbf C$.

The proof has three parts.

1. Exact cotangent-cohomology calculations give

   \[
   \dim T^1_0=53,\qquad \dim T^2_0=27,\qquad \dim T^3_0=24.
   \]

   At one explicit rational tangent direction $y$, the quadratic Kuranishi
   map satisfies $q(y)=0$ and $\operatorname{rank}Dq_y=15$. A semi-free
   commutative DG-algebra computation gives

   \[
   \operatorname{rank}([y,-]:T^2_0\to T^3_0)=12,
   \qquad [y,-]Dq_y=0.
   \]

   Hence $\ker[y,-]=\operatorname{im}Dq_y$. The curved Bianchi identity then
   kills every successive obstruction and extends the prescribed two-jet to
   a formal arc to all orders over $\mathbf Q$. See
   [`proofs/all-ones-versal-arc/`](proofs/all-ones-versal-arc/).

2. The exact rational two-jet already forces smoothness of the geometric
   generic fibre, independently of every coefficient of order $s^3$ and
   higher. On each of the $8\cdot35$ affine projective/Grassmann charts, an
   exact module calculation over $\mathbf Q$ proves

   \[
   s^2\in(F_i,J^{\mathsf T}K,s^3),
   \]

   where $K$ is the universal four-plane in the kernel of the affine
   Jacobian. A hypothetical singular generic point extends over a finite DVR
   extension with integral projective and Grassmann coordinates; evaluating
   this identity would give $s^2=s^3c$, a valuation contradiction. See
   [`proofs/rational-two-jet-smoothness/`](proofs/rational-two-jet-smoothness/).

3. The formal embedded deformation is defined over $\mathbf Q$. Grothendieck
   existence for the proper scheme
   $\mathbf P^7_{\mathbf Q[[s]]}$
   [algebraizes its compatible formal ideal
   sheaves](https://stacks.math.columbia.edu/tag/0899), giving a projective
   flat scheme over $\operatorname{Spec}\mathbf Q[[s]]$. Equivalently, after
   base change to $\mathbf C$, this is the effectivity criterion in
   Altmann--Christophersen: $L=\mathcal O_{SR(\mathcal M)}(1)$ is very ample,
   $H^1(SR(\mathcal M),L)=0$ by their Theorem 2.2, and
   [Theorem 3.1(v)](https://arxiv.org/html/0901.2502v1#S3.Thmtheorem1)
   makes every formal deformation of $(SR(\mathcal M),L)$ effective.

The central computations can be replayed from the repository root with
Macaulay2 1.20 and SageMath 10.7:

```sh
M2 --script proofs/all-ones-versal-arc/export_base_QQ.m2
M2 --script proofs/all-ones-versal-arc/export_t1_QQ.m2
M2 --script proofs/all-ones-versal-arc/export_rational_two_jet.m2
sage proofs/all-ones-versal-arc/transport_coordinates.sage
sage proofs/all-ones-versal-arc/check_prescribed_two_jet.sage
M2 --script proofs/all-ones-versal-arc/compute_aq_bracket.m2
python3 proofs/rational-two-jet-smoothness/verify_grassmann_all.py
```

## Historical context

The search first produced several directions that lifted to high finite order
and several explicit flat families whose general fibres turned out to be
singular. These negative and exploratory calculations remain in `rl/`,
`serendipity/`, and `old-code/`; the proof above uses a different rational
direction and an intrinsic all-orders obstruction argument.

The repository is still being reorganized for a more transparent
computational flow. The directory `rl/` contains the friendliest introductory
explanations and coding exercises.

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
├── proofs/
│   ├── all-ones-versal-arc/
│   └── rational-two-jet-smoothness/
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

* `proofs/` contains the exact characteristic-zero smoothing certificates:
the all-orders obstruction calculation and the exhaustive two-jet
singular-incidence verification.

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
