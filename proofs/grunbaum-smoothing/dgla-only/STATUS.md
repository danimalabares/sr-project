# Final status

Date: 2026-08-26

## Verdict

**Proved, subject to the explicitly identified computer-assisted inputs.**

The Grünbaum Stanley–Reisner threefold occurs as the special fibre of a flat
projective scheme over `Spec(Q[[s]])` with smooth geometric generic fibre.
The proof in [PROOF_DGLA.tex](PROOF_DGLA.tex) uses only:

- a Tate resolution;
- the strict relative dg Lie algebra `Der_S(P,P)_0`;
- its differential and graded commutator;
- the ordinary Maurer–Cartan equation;
- elementary obstruction theory with the strict Bianchi identity;
- exact commutative-algebra computations;
- the classical flatness, Tate-resolution, Reisner, and algebraization facts
  cited with their hypotheses checked.

No transferred structure, higher bracket, or minimal higher-operation model
appears in either proof TeX source.

There is no missing implication needed for the smoothing theorem. The first
stronger unsupported implication would be preservation of the full starting
element over `R_4`; the strict induction only preserves its reduction modulo
`s^3`. Preserving all of `R_4` would additionally require the leading
order-four obstruction class `[r_4]` itself to vanish in `H^2`. The 280
smoothness certificates need only the preserved reduction modulo `s^3`.

## Deliverables

- [PROOF_DGLA.tex](PROOF_DGLA.tex): complete standalone strict proof.
- [PROOF_DGLA.pdf](PROOF_DGLA.pdf): compiled proof.
- [DG_LIE_INDUCTION.tex](DG_LIE_INDUCTION.tex): standalone abstract induction
  lemma with signs, indices, convergence, and the initial `s^4` case.
- [DG_LIE_INDUCTION.pdf](DG_LIE_INDUCTION.pdf): compiled induction note.
- [AUDIT.md](AUDIT.md): replacement map for every former higher-operation
  step and hostile review of the critical bridges.
- [REPRODUCE.md](REPRODUCE.md): exact commands and portability notes.
- [verify.sh](verify.sh): non-mutating full replay wrapper.
- [verify_relative_controller.m2](verify_relative_controller.m2): new exact
  relative/absolute tangent and starting-class check.
- [verification/controller_QQ.txt](verification/controller_QQ.txt): its
  deterministic certificate.

## Repository state

At audit start:

```text
workspace=/Users/daniel/github/sr-project
branch=restructure
HEAD=866e9f186a65485a3a71eb3554c33c840a757612
baseline=9c0fc0e8da6699bd7fe30d9940b4637222686472
baseline_is_ancestor=true
tree_diff_baseline_to_HEAD=empty
working_tree=clean
```

The two commits after the baseline are an update and its revert. The requested
`~/github/danimalabares/sr-project` path is absent in this environment; work
was performed in the workspace path supplied above.

The frozen referee packet, Tate-stage audit, completion certificate, and
snapshot were not modified. Full replays ran from temporary copies.

## Reproduction results

All proof-critical calculations were rerun on 2026-08-26 with the pinned
executables.

The new one-command wrapper was also exercised end to end and finished with

```text
DGLA_ONLY_FULL_REPLAY_VERIFIED
```

It replays from a retained temporary copy and supplies closed standard input
so the pinned Singular version probe terminates even when the wrapper is
launched from an interactive terminal.

### Complete frozen referee replay: passed

The full `referee-packet/verify.sh` replay ran with four incidence workers and
finished with:

```text
proved 280/280
VERIFIED: every exact computation, PROOF.pdf, and manifest entry passed.
```

It recomputed the rational formal data, the strict bracket, every incidence
chart, the frozen PDF, and all manifest hashes. Runtime was approximately
10 minutes 29 seconds.

The strict bracket output included:

```text
Jacobi composite rank=0
primary minus Dq rank=15
primary plus Dq rank=0
ad_y composed primary-bracket rank=0
primary self bracket at y zero=true
rank commutator columns modulo delta2=12
rank Dq_y=15
```

The regenerated bracket certificate was byte-identical to the frozen file.

### Complete Tate-stage replay: passed

Both full homogeneous syzygy computations and both retained-certificate
checks passed, ending with:

```text
TATE_STAGE_AUDIT_REPLAY_CERTIFIED
```

Runtime was approximately 6 minutes 44 seconds. The one-time provenance
extractor was also rerun: it produced shapes `16x30` and `150x136`, its raw
candidate was byte-identical to the audited input, and both had SHA-256

```text
9e0691837d69ba2027cca1fef52e0598dcd83f0bc65e2c88379061bce9caa396
```

### Complete starting-`R_4` replay: passed

The completion replay verified `F^[3]Q^[3]=0`, the complete 30-column special
syzygy matrix, and byte equality with the frozen two-jet. It ended with:

```text
starting_deformation_flatness_inputs_verified=true
starting_two_jet_matches_frozen_input=true
```

The universal two-jet SHA-256 is

```text
40e64e61674b6a4e61f1ea6822dc79327bf4ba397285f84ed8738c4c18cd1795
```

### New local strict checks: passed

The local verifier reports:

```text
relative_H1_dimension=109
coordinate_boundary_image_dimension=56
absolute_H1_dimension=53
relative_minus_coordinate_equals_absolute=true
starting_mc_linear_e_values_equal_T1_y=true
strict_source_scan_passed=true
relative_controller_certificate_passed=true
DGLA_ONLY_LOCAL_VERIFIED
```

Both TeX sources compile with pdfTeX/latexmk and have no undefined control
sequence, citation, or reference warning in their final logs.

## Critical conclusions

### Controller

The fixed-coordinate controller is `Der_S(P,P)_0`. It is not correct to call
its `H^1` 53-dimensional; the exact value is 109. The absolute controller has
53-dimensional `H^1`, and the 56 extra relative classes are coordinate
directions that bracket to boundaries. Since the complexes are identical in
positive cohomological degrees, the computed exactness transfers rigorously
to the relative controller.

### Actual starting MC element

The matrices are not treated as cohomology classes. A differential is defined
on `e` and `f` by the verified family and relation matrices. A proved
filtered-cycle lemma extends it over all 136 `g` generators and every later
Tate generator. The resulting `D-d` is an actual element of
`MC(Der_S(P,P)_0 tensor (s)/(s^4))`, and the new exact check identifies its
linear `e`-values with `T1*y`.

### `H^3`

The 136 cycles span the relevant homological degree-two group modulo
decomposable boundaries; they do not purport to span `H^3`. Global extension
of the computed derivations proves that the 12 commutator columns are genuine
`H^3` cocycles. No total dimension of `H^3` is assumed.

### Flatness and algebraization

The perturbed Tate complex is a degreewise free resolution by the finite
`s`-filtration spectral sequence, so Tag 00MK gives classical flatness. At all
orders the sixteen equations are literally `D_infinity(e_i)` in the fixed
coordinates. Their fixed `x`-degree makes them elements of `Q[[s]][x]`, so
their Proj is an explicit algebraization; Tag 0899 supplies an independent
effectivity route.

### Smoothness

The 280 certificates prove exact truncated incidence memberships, not
smoothness in isolation. Projective/Grassmannian properness, the relative
dimension-three Jacobian criterion, and the extension-DVR valuation argument
turn those memberships into smoothness of the geometric generic fibre for
every continuation with the prescribed two-jet.

## Remaining dependencies

There is no unresolved mathematical lemma internal to the strict proof. Its
remaining dependencies are transparent and reproducible:

1. the exact Macaulay2 and Singular computations in the frozen and audited
   packets;
2. Avramov’s Tate-resolution and derivation-complex results;
3. Reisner’s criterion;
4. Stacks Tags 00MK, 0899, and 0E7T with the hypotheses listed in the proof;
5. ordinary commutative algebra facts used explicitly (Nakayama, Krull
   intersection, torsion-free modules over a DVR are flat).

The former Hinich hull-comparison citation is not a dependency of this proof.
