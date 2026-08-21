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

The proof and exact certificates in [`proofs/`](proofs/) construct such a
family over $\operatorname{Spec}\mathbf Q[[s]]$. Consequently the Grünbaum
Stanley--Reisner variety is smoothable in characteristic zero, and in
particular over $\mathbf C$.

The proof has three parts.

1. Exact cotangent-cohomology calculations give

   \[
   \dim T^1_0=53,\qquad \dim T^2_0=27.
   \]

   At one explicit rational tangent direction $y$, the quadratic Kuranishi
   map satisfies $q(y)=0$ and $\operatorname{rank}Dq_y=15$. A certified
   initial segment of a Tate resolution and the graded commutator of its
   derivations give

   \[
   T^1_0\xrightarrow{[y,-]}T^2_0\xrightarrow{[y,-]}T^3_0,
   \qquad \operatorname{rank}=15,12,
   \]

   with the sequence exact at $T^2_0$. The package output first gives an
   actual flat deformation over $\mathbf Q[s]/(s^4)$. A direct
   Maurer--Cartan Bianchi induction then kills every successive obstruction,
   starting in order $s^4$ and therefore preserving the prescribed equations
   modulo $s^3$. See the audited
   [`completion proof`](proofs/grunbaum-smoothing/COMPLETION.md).

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

3. The completed graded algebra is degreewise free over $\mathbf Q[[s]]$.
   Lifting the eight degree-one coordinates and applying Nakayama's lemma
   gives sixteen honest cubics in
   $\mathbf Q[[s]][x_1,\ldots,x_8]$, literally equal to the certified
   two-jet modulo $s^3$, and these cubics generate the full ideal. Their
   Proj is therefore the required projective flat family. No separate
   identification of package equations with a completed miniversal hull is
   assumed.

The audited proof computations can be replayed from the repository root with
the pinned tools documented in each directory (the first two replays are
substantially more expensive):

```sh
(cd proofs/grunbaum-smoothing/referee-packet && ./verify.sh)
(cd proofs/grunbaum-smoothing/audits/tate-stage && ./verify.sh)
(cd proofs/grunbaum-smoothing/completion && ./verify.sh)
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
│   ├── grunbaum-smoothing/
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

* `proofs/` contains the exact characteristic-zero smoothing proof and
certificates: the certified tangent-DG-Lie calculation, the fixed-two-jet
all-orders argument, and the exhaustive singular-incidence verification.

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
