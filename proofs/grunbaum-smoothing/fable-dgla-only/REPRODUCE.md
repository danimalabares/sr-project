# Reproducing the strict dg Lie proof (fable-dgla-only)

Run all commands from `proofs/grunbaum-smoothing/fable-dgla-only/`.

## One-command replay

```sh
./verify.sh --all
```

This runs the new exact checks, compiles both proof documents, scans their
logs, and then replays the three canonical frozen packages from a fresh
temporary copy.  The frozen trees are never written.  Expected final lines:

```text
FABLE_DGLA_FULL_REPLAY_VERIFIED
temporary_replay_copy=/.../grunbaum-fable-replay.XXXXXX
```

Expected runtime is roughly 15–25 minutes; the Tate syzygy replay and the
280 incidence charts dominate.  Set `JOBS=1` if memory is constrained.

Portability repairs live entirely in the new wrapper (no frozen byte is
changed):

- the frozen wrappers hard-code `python3` while their environment checks
  require Python 3.13.7, so the wrapper puts a temporary `python3` shim to
  the pinned `python3.13` on `PATH`;
- the frozen `Singular --version` probe can wait for terminal EOF on the
  pinned build, so each frozen replay receives `/dev/null` as stdin;
- the completion manifest covers `../COMPLETION.md`, so the wrapper copies
  that file at the expected relative path.

## New proof checks only

```sh
./verify.sh --local
```

runs, in order:

```sh
M2 --script verify_fable_dgla.m2 --no-randomize
python3.13 check_fable.py
latexmk -norc -pdf -interaction=nonstopmode -halt-on-error PROOF_DGLA.tex
latexmk -norc -pdf -interaction=nonstopmode -halt-on-error DG_LIE_INDUCTION.tex
```

and fails if any TeX log contains an undefined control sequence or
reference.  Expected M2 certificate
(`verification/fable_dgla_QQ.txt`):

```text
field=QQ
VersalDeformations_version=3.0
relative_H1_dimension=109
coordinate_boundary_image_dimension=56
absolute_H1_dimension=53
relative_minus_coordinate_equals_absolute=true
T2_degree_zero_dimension=27
base_equations_vanish_at_y_through_order_three=true
specialized_family_times_relations_zero=true
complete_special_first_syzygies=30
family_corrections_homogeneous_x_degree_3=true
relation_corrections_homogeneous_x_degree_1=true
starting_mc_linear_e_values_equal_T1_y=true
two_jet_matches_frozen_input=true
```

The two homogeneity lines are new to this directory: they verify the
weight-zero property of the truncated Maurer–Cartan element (every family
correction is a cubic in `x`, every relation correction linear in `x`),
which the proof uses and which no earlier script asserted.

`check_fable.py` also rejects any occurrence of the superseded
higher-operation constructs in the two proof sources and requires the
ordinary Maurer–Cartan and strict Bianchi formulas to be present.

## What each canonical replay proves

### Frozen referee packet (`../referee-packet/verify.sh`)

Final line:

```text
VERIFIED: every exact computation, PROOF.pdf, and manifest entry passed.
```

Used by this proof for: the special-fibre combinatorics and Reisner links;
`dim T^1_0 = 53`, `dim T^2_0 = 27`; the constant relation-basis matrix `U`
with `Q_0 U = R_0`, `det U = 1`; closure of the 27 transported classes,
their completeness as an `H^2` basis, the secondary commutator rank 12
modulo all degree-three coboundaries, the primary commutator identity
`primary = −J·Dq_y` with rank 15, the directly computed zero composite; and
all 280 incidence memberships (`proved 280/280 chart pairs`).

### Low Tate-stage audit (`../audits/tate-stage/verify.sh`)

Final line:

```text
TATE_STAGE_AUDIT_REPLAY_CERTIFIED
```

Macaulay2 and Singular independently prove the unbounded graded module
equalities `ker(D1) = image(D2)` and `ker(D2) = image([D3 Z])`.  These are
the hypotheses of the cycle-lifting and derivation-extension lemmas at
homological degrees 3 and 4.

### Starting `R_4` deformation (`../completion/verify.sh`)

Semantic lines:

```text
starting_deformation_flatness_inputs_verified=true
starting_two_jet_matches_frozen_input=true
```

Verifies `F^[3] Q^[3] = 0` over `QQ[s]/(s^4)`, completeness of the thirty
special first syzygies, and byte identity of the reduction mod `s^3` with
the frozen incidence input
(SHA-256 `40e64e61674b6a4e61f1ea6822dc79327bf4ba397285f84ed8738c4c18cd1795`).

## Lightweight integrity checks

```sh
(cd ../referee-packet && shasum -a 256 -c MANIFEST.sha256)
(cd ../audits/tate-stage && shasum -a 256 -c MANIFEST.sha256)
(cd ../completion && shasum -a 256 -c MANIFEST.sha256)
```

(The completion manifest must be checked from the repository layout so that
`../COMPLETION.md` exists.)

## Environment

Pinned by the frozen environment certificate: Macaulay2 1.20,
`VersalDeformations` 3.0, `DGAlgebras` 1.1.0, Singular 4.4.1,
Python 3.13.7, latexmk 4.79 with pdfTeX (TeX Live 2023).  No network access
or floating-point arithmetic is used by any replay.

## External references checked for this write-up

- Stacks Tag 00MK (local criterion of flatness) — statement verified
  against the Stacks Project on 2026-08-27; also re-proved inline in the
  Artinian case actually used.
- Stacks Tag 0899 (algebraization of compatible proper closed subschemes)
  — statement verified 2026-08-27; used only as an optional footnote route.
- Stacks Tag 0E7T was checked and deliberately **not** used: its full
  statement carries a Fitting-ideal hypothesis that the incidence
  certificates do not literally instantiate; the proof replaces the
  CM/equidimensionality step it would have supplied with a self-contained
  Betti-semicontinuity argument (PROOF_DGLA §8.1).
