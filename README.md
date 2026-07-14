# Stanley–Reisner deformation computations

This is a focused snapshot of computations for the deformation theory of
the Stanley–Reisner scheme `SR(M)` associated with Grünbaum and Sreedharan's
8-vertex triangulated 3-sphere.

## Current computational picture

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

- `code/cotangent/`: `T^1`, `T^2`, obstruction quadrics, formal lifts, and
  the flatness failure. The small cached data files are retained because the
  later scripts use them as reproducible checkpoints.
- `code/more-lifting/`: higher-order obstruction and flatness experiments.
- `code/GN2/`: determinantal comparison and non-Gröbner obstruction.
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
