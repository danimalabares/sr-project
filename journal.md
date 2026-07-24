# July 23, 2026

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

# July 24, 2026

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

## Deformations of CY literature review (AI-written)

