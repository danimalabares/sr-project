# July 23, 2026 (first day)

First day of work after XXII EDG conference.
Starting today, I'll try to set up
a RL machine for my SR project.

The basic workflow is:

1. The machine proposes a deformation
direction y.

2. The code tests how good it is:
does it lift and to what order,
how badly does it fail flatness?

3. The machine remembers the best directions
and proposes similar ones.

Today I started implementing steps 1 and 2.
I created a function that picks a
deformation direction $y \in T^1$ and 
computes the deformed polynomials induced
from $y$. Next steps: lift to order 2
and check flatness.

# July 24, 2026 (literature)

## Unicamp group literature review (AI-written)

### 1. The pure-mathematics entrance

[Asymptotically Z-stable bundles over
projective
surfaces](https://arxiv.org/abs/2604.20264)

The paper studies vector bundles through
extensions, stability conditions, projective
surfaces, blow-ups and moduli-type
questions.

It is not directly about Stanley–Reisner
deformation theory, but its language of
extensions, stability and moduli is
relatively close to my mathematical world.

### 2. The machine entrance

[Machine learning Sasakian and G2 topology
on contact Calabi–Yau
7-manifolds](https://arxiv.org/abs/2310.03064)

They begin with exact algebraic-geometric
objects, compute invariants, encounter
Gröbner-basis bottlenecks, and use machine
learning to predict patterns and accelerate
computations.

The relevant model for my project is:

exact algebraic object → expensive invariant
→ learn computational structure → verify
exactly.

This is probably the most useful Sá Earp
paper for designing the SR experiment.

### 3. Tomás Silva’s RL work

[A semicontinuous relaxation of Saito’s
criterion and freeness as angular
minimization](https://arxiv.org/abs/2604.02995)

This is Tomás Silva’s paper, not Sá Earp’s.
Nevertheless, it may be the closest
conceptual model for my RL machine: it turns
a binary algebraic condition into a graded
numerical reward and uses reinforcement
learning to construct line arrangements.

### Reading order

1. Read the ML Sasakian/G2 paper to
   understand how their group connects
machine learning with exact geometry.

2. Read the Z-stable bundles paper
   selectively to understand Sá Earp’s
underlying pure mathematics.

3. Study Tomás’s freeness/RL paper when
   deciding what the agent, actions and
reward should be in the SR project.

## Deformations literature review (AI-written)

### Computational deformation theory

[Nathan Ilten,
*VersalDeformations*](https://arxiv.org/abs/1107.2416)

Explains the computational passage:

T¹ → obstruction equations → higher-order
corrections → local Hilbert scheme.

[Jan Stevens,
*Computing versal
deformations*](https://eudml.org/doc/226690)

Explains how versal deformation spaces
can be computed by extending infinitesimal
deformations order by order.

[Jan Stevens,
*Computing Versal Deformations of
Singularities with Hauser’s
Algorithm*](https://link.springer.com/chapter/10.1007/978-3-642-39131-6_6)

Presents an alternative algorithm which
does not construct the deformation by
extending it one order at a time.

### SR and toric smoothings

[Ingrid Fausk,
*Pfaffian Calabi–Yau Threefolds,
Stanley–Reisner Schemes and Mirror
Symmetry*](https://arxiv.org/abs/1205.4871)

The closest geometric precedent: smoothing
SR schemes of triangulated 3-spheres into
Calabi–Yau threefolds.

[Klaus Altmann,
*The Versal Deformation of an Isolated
Toric Gorenstein
Singularity*](https://arxiv.org/abs/alg-geom/9403004)

Shows how combinatorial data can describe
versal components and genuine flat
families.

### The wider smoothing problem

[Gert-Martin Greuel,
*Deformation and Smoothing of
Singularities*](https://arxiv.org/abs/1903.03661)

A general survey of smoothability and
smoothing components.

[Friedman–Laza,
*Deformations of Calabi–Yau Varieties
with k-Liminal
Singularities*](https://www.cambridge.org/core/journals/forum-of-mathematics-sigma/article/deformations-of-calabiyau-varieties-with-kliminal-singularities/49D80A37510C84DB1797253A76250EC9)

Places smoothing inside the wider question
of which singular Calabi–Yau varieties
occur on the boundaries of moduli spaces.

If my SR scheme smooths to the
Gulliksen–Negård threefold, it gives an
explicit combinatorial boundary point of
the GN Hilbert-scheme component.

The stronger goal is to locate and
understand this smoothing component inside
the 53-dimensional deformation space.

# July 25, 2026 (serendipity)

Serendipity. While writing Step 5 of my
RL machine, which would test for flatness
of a given order-three-liftable deformation
direction, we found by chance in the
example computations a flat family!

Unfortunately the general fibre is still
far from smooth.

# July 29, 2026 (sampling and testing functions)

Now we're one step away from writing
the actual learning algorithm!
Up to this point I have configured 

- the elementary mathematical functions that
deal with the linear algebra (the
deformation directions as vectors,
obstruction vector spaces, etc.) in
`sr_environment.sage`

- (today) the elementary sampling functions
`random_h_search.sage`,
`random_q_search.sage` and
`evaluate_candidate.sage`,
which explore the vector spaces and
store the result of the lifting/flatness
tests for the given deformation directions.

Next up: design a way for the machine
to iterate this process intelligently.

# August 10 (restructuring)

I'm checking that my past computations are
correct before continuing. This means
restructuring the repository. So far, we
re-wrote the scripts which compute the
dimensions of T^1 (both via AC formula and
direct syzygy computations) and T^1 (via AC
formula). Actually, there was a mistake: by
a convention established in the AC paper
which we did not consider before, we
discovered that dim T_{0}^2 = 27 and not 12
as we thought.

At this point I also created `foundations/`
for the basic combinatorial data script
`M_FACETS.py` and the basic algebra
and syzygy computations `part-1.sage`.

The T^1 and T^2 scripts lie in
`deformation-basics`.
