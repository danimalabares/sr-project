# Stanley–Reisner deformation computations

This is a focused snapshot of computations for the deformation theory of
the Stanley–Reisner scheme `SR(M)` associated with Grünbaum and Sreedharan's
8-vertex triangulated 3-sphere, denoted `M`.

The objective of the project is to construct a smoothing of this
Stanley–Reisner variety, that is, a flat family whose special fibre is `SR(M)` and
whose general fibre is smooth. By a result in Stanley–Reisner theory, such
a smooth general fibre would be a Calabi–Yau (threefold) since `M` is a triangulation
of the 3-sphere.

## The two approaches in this repository

There are two separate deformation attempts:

1. **Gröbner deformation attempt — `code/GN2/`.** This directory tries to
   obtain `SR(M)` as a coordinate/weight Gröbner degeneration of a
   Gulliksen–Negård determinantal CY3. This is the approach for which
   ChatGPT produced the failure proof: the included Gordan certificate
   proves that the generic determinantal matrix, as well as the specific
   circulant matrix tested here, cannot Gröbner-degenerate to `SR(M)` by
   the proposed weight method. The stronger statement covering every
   possible special matrix remains conjectural.

2. **Order-by-order lifting attempts — `code/cotangent/` and
   `code/more-lifting/`.** These directories compute first- and
   higher-order deformations directly, starting with `T^1`, `T^2`, and
   the quadratic obstruction equations. They include the sparse formal
   lift and the subsequent flatness tests. The candidate family found by
   this route is not flat, and no smoothing has been constructed.

## Reinforcement learning preliminary setup

(Human written.) 
I intend to implement a RL machine
that would explore the space of deformation
directions. Here's a preliminary setup:

- The sample space is a vector
  (eta1, eta2,...., etaN) where the i-th
  entry is i-th order correction of one
  of the original generators of the
  varietie's ideal. I have to choose a
  suitable N and also a finite subset
  of possible values for choosing the eta's.

- The reward criterion should be the
  dimension of certain torsion module
  which measures flatness failure (so
  far all my attempts have failed)

- I need to set up the statistical method
  that would allow the machine to make
  better and better choices for the next
  action as it gathers more data.

## Current computational picture

**Important status:** `SR(M)` has not been proved smoothable, has not been
proved to be a degeneration of the determinantal CY3, and has not been
shown to lie on its Hilbert-scheme component. Matching numerical invariants
are only necessary evidence, not a construction or proof.

- `dim T^1 = 53` and `dim T^2 = 12`.
- Generic first-order directions are obstructed at second order.
- The raw calculation produces 27 quadratic obstruction equations.
- A sparse branch lifts formally through order 30, but the resulting naive
  cubic family is not flat: `t`-saturation changes its special fibre.
- Generic points of all 27 quadratic components meet higher-order
  obstructions; a smoothing direction, if present, must lie on a smaller
  special locus.
- The determinantal Gulliksen–Negård Calabi–Yau has matching numerical
  invariants, but the tested coordinate Gröbner-degeneration route to
  `SR(M)` is obstructed. A finite Gordan certificate is included, together
  with its Lean formalization.

These are computational findings and working conclusions, not a finished
paper. See the notes inside each directory for the precise status and
limitations of each claim.

## Repository map

- `code/GN2/`: the failed ChatGPT-developed Gröbner deformation attempt,
  including the determinantal comparison and Gordan failure certificate.
- `code/cotangent/`: the initial lifting attempt: `T^1`, `T^2`, obstruction
  quadrics, formal lifts, and the flatness failure. The small cached data
  files are retained because the later scripts use them as reproducible
  checkpoints.
- `code/more-lifting/`: continuation of the lifting attempt through
  higher-order obstruction and flatness experiments.
- `lean/`: Lean 4 checks for the finite combinatorial certificates. Build
  artifacts are intentionally excluded.

Generated Sage `.sage.py` translations, logs, archives, editor settings,
talks, journals, and unrelated research projects are intentionally omitted.

## Software

The scripts use SageMath, Macaulay2, Python 3 with NumPy/SciPy/SymPy, and
Lean 4 with Mathlib.

There is no single one-command pipeline yet. Start with the README files in
the code directories; the numbered filenames record the experimental
sequence.

## Quick independent checks

From the repository root:

```bash
python3 code/cotangent/verify_M.py
python3 code/cotangent/compute_T1_AC.py
python3 code/GN2/10_obstruction_certificate.py
```

Some longer Sage scripts consume the included cached checkpoints rather than
recomputing every earlier stage.
