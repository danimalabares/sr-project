# Reproducing the strict dg Lie proof

Run commands from
`proofs/grunbaum-smoothing/dgla-only/`.

## One-command replay

```sh
./verify.sh --all
```

This performs the new controller check, compiles both TeX documents, and
replays all three canonical computational packages from a fresh temporary
copy. The frozen originals are never written. The final lines are

```text
DGLA_ONLY_FULL_REPLAY_VERIFIED
temporary_replay_copy=/.../grunbaum-dgla-replay....
```

The temporary copy is deliberately retained for inspection. The wrapper
requires `python3.13`, then creates a temporary `python3` shim because the
frozen referee and Tate wrappers hard-code the generic executable name while
their environment checks require Python 3.13.7. This repairs the local PATH
portability issue without changing a frozen byte. The completion manifest
also covers `../COMPLETION.md`, so the wrapper copies that file at the exact
relative path expected by the original script.

The wrapper also gives each frozen replay `/dev/null` as standard input. This
makes the command safe to launch from an interactive terminal: on the pinned
Singular build, the frozen `Singular --version` environment probe can
otherwise print its banner and wait for terminal EOF. This is an orchestration
repair in the new wrapper only; no frozen script or certificate is changed.

Set the incidence worker count when memory is constrained:

```sh
JOBS=1 ./verify.sh --all
```

Expected runtime on the audited machine is roughly 15–25 minutes. The Tate
syzygy replay and the 280 incidence charts dominate.

## New proof checks only

```sh
./verify.sh --local
```

This runs:

```sh
M2 --script verify_relative_controller.m2 --no-randomize
python3.13 check_local.py
latexmk -norc -pdf -interaction=nonstopmode -halt-on-error PROOF_DGLA.tex
latexmk -norc -pdf -interaction=nonstopmode -halt-on-error DG_LIE_INDUCTION.tex
```

The controller calculation verifies, with graded shifts retained,

```text
relative_H1_dimension=109
coordinate_boundary_image_dimension=56
absolute_H1_dimension=53
relative_minus_coordinate_equals_absolute=true
starting_mc_linear_e_values_equal_T1_y=true
```

`check_local.py` also rejects the superseded higher-operation constructs in
the two proof sources and requires the ordinary Maurer–Cartan and strict
Bianchi formulas.

## Canonical replays separately

The following commands describe the mathematical checks. To preserve the
frozen trees, run them in copies as `verify.sh --all` does.

### Frozen referee packet

```sh
cd ../referee-packet
PATH=/path/to/python3.13-shim:$PATH JOBS=4 ./verify.sh
```

Expected final line:

```text
VERIFIED: every exact computation, PROOF.pdf, and manifest entry passed.
```

This recomputes:

- the special-fibre combinatorics and all Reisner links;
- `dim T^1_0=53`, `dim T^2_0=27`, the rational direction, and its two-jet;
- the strict derivation commutators, their ranks 15 and 12, and the zero
  composite;
- all 280 truncated singular-incidence memberships;
- the frozen PDF and every manifest digest.

### Complete low Tate stage

```sh
cd ../audits/tate-stage
PATH=/path/to/python3.13-shim:$PATH ./verify.sh
```

Expected final line:

```text
TATE_STAGE_AUDIT_REPLAY_CERTIFIED
```

Macaulay2 and Singular independently prove

```text
ker(D1) = image(D2)
ker(D2) = image([D3 Z])
```

as full graded polynomial modules, not finite-degree rank tests.

### Starting `R_4` deformation

The manifest refers to `../COMPLETION.md`; retain the original relative
layout:

```sh
cd ../completion
./verify.sh
```

Expected semantic lines include:

```text
starting_deformation_flatness_inputs_verified=true
starting_two_jet_matches_frozen_input=true
```

This verifies `F^[3] Q^[3]=0`, completeness of the special first syzygies,
and byte equality with the incidence two-jet.

## Lightweight integrity checks

These do not replace the complete replays:

```sh
(cd ../referee-packet && python3.13 code/check_results.py)
(cd ../referee-packet && shasum -a 256 -c MANIFEST.sha256)
(cd ../audits/tate-stage && python3.13 code/check_results.py)
(cd ../audits/tate-stage && shasum -a 256 -c MANIFEST.sha256)
(cd ../completion && python3.13 check_results.py)
(cd ../completion && shasum -a 256 -c MANIFEST.sha256)
```

The last completion-manifest command must be run in the repository layout so
that `../COMPLETION.md` exists.

## Environment

The frozen environment check pins:

- Macaulay2 1.20 and exact launcher/binary hashes;
- `VersalDeformations` 3.0 and `DGAlgebras` 1.1.0 source hashes;
- Singular 4.4.1 for the Tate audit;
- Python 3.13.7;
- latexmk 4.79 and pdfTeX from TeX Live 2023.

No network access, SageMath, numerical arithmetic, or unlisted data source is
used by these replays.
