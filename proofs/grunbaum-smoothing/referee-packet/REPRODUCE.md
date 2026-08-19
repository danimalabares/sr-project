# Reproducing the proof

Run the complete replay from the packet root with one command:

```sh
./verify.sh
```

The default uses four concurrent Macaulay2 incidence workers. On a machine
with less memory, use:

```sh
JOBS=1 ./verify.sh
```

The replay is exact and offline. It does not download anything and does not
look outside this directory except for the named system executables and their
installed package sources.

## Audited environment

The supplied packet was built and replayed with:

- macOS 12.7.6 (build 21H1320), Darwin 21.6.0, x86_64;
- Macaulay2 1.20, full build description
  `version-1.20-6-a156a3cd4-dirty`, compiled 2022-05-14 with clang 13.1.6;
- Macaulay2 launcher SHA-256
  `a768799d25c404f5cd33ef445c37c7c83a28ca86b6d3124ac5a8d6997fe8dfbe`;
- Macaulay2 binary SHA-256
  `c6f0c89e69d18334031c78217ddb6b383d5a729bde32aeb5f70ee2da0eec9b6c`;
- `VersalDeformations` 3.0, source SHA-256
  `3363126cce0237f2c3a7ab8a8438372c5adcf83a6fb5be1fb84e7cea9bd61c3a`;
- `DGAlgebras` 1.1.0, source SHA-256
  `72adff5eb889703562b7cedfce10c93490fda171f5f9dd90a998eb69b7d433b0`;
- Python 3.13.7, standard library only;
- latexmk 4.79;
- pdfTeX 3.141592653-2.6-1.40.25, TeX Live 2023.

`code/check_environment.py` verifies these versions and hashes before any
mathematics runs. The strict binary checks are intentional because the bracket
script uses private interfaces of `DGAlgebras`. A different Macaulay2 1.20
build may be mathematically equivalent but is not the audited exact replay.

No SageMath, NumPy, SciPy, SymPy, Lean, network service, database, or external
data file is used.

## What `verify.sh` does

In order, it performs:

```sh
python3 code/check_environment.py
python3 code/verify_combinatorics.py
M2 --script code/verify_formal_data.m2 --no-randomize
M2 --script code/verify_aq_bracket.m2 --no-randomize
python3 code/verify_all_incidence.py --jobs 4
python3 code/check_results.py
latexmk -norc -pdf -interaction=nonstopmode -halt-on-error PROOF.tex
latexmk -norc -c PROOF.tex
shasum -a 256 -c MANIFEST.sha256
```

`M2 --script` implies quiet startup without a user initialization file. The
`--no-randomize` option appears after the script filename, as required by
Macaulay2 1.20, and every Macaulay2 script also fixes the random seed. The miniversal calls explicitly
set `DefParam=>t` and disable `SmartLift`; no configurable package default is
silently relied upon.

Expected wall time on the audited machine is approximately:

- combinatorics and degree-three versal data: under 15 seconds;
- intrinsic bracket: 3–4 minutes;
- 280 incidence charts plus one retained-lift check: about 6 minutes with
  four workers;
- LaTeX and hash validation: under 10 seconds.

The incidence stage has an 1800-second timeout per chart. Progress is printed
every 20 completed chart pairs.

## Inputs and regenerated outputs

There are only two data files:

- `data/grunbaum_facets.txt` is the human-readable 20-facet definition of the
  special complex;
- `data/universal_2jet_QQ.txt` is the exact 16-row rational family two-jet.

The latter is not trusted as an opaque cache. Every replay overwrites it from
the displayed ideal and rational direction using
`code/verify_formal_data.m2`, then checks its SHA-256 digest before using it in
the incidence calculation.

The deterministic semantic outputs are:

- `verification/environment.txt`;
- `verification/combinatorics_QQ.txt`;
- `verification/formal_data_QQ.txt`;
- `verification/aq_bracket_QQ.txt`;
- `verification/incidence_all_QQ.txt`;
- `verification/replay_summary.txt`.

`PROOF.pdf` is rebuilt with a fixed `SOURCE_DATE_EPOCH`; auxiliary TeX files
are removed after a successful build. `MANIFEST.sha256` covers every packet
file except the manifest itself.

## Fresh-directory replay

To reproduce the release-style test:

```sh
tmpdir="$(mktemp -d)"
tar -xzf grunbaum-smoothing-referee.tar.gz -C "$tmpdir"
cd "$tmpdir/grunbaum-smoothing-referee"
JOBS=4 ./verify.sh
```

The release test was performed from such a fresh extraction. In addition, a
filesystem sandbox explicitly denied reads from the source checkout while
the full replay and PDF build ran, verifying that no undeclared parent-tree
dependency remained.

## Reading a failure

- An environment failure means the executable or package source is not the
  audited version; it is not evidence against the mathematics.
- Exit status 2 from an individual incidence chart means the configured
  degree limit was inconclusive. The driver automatically retries degree
  eight and fails the whole replay if membership is still not proved.
- A failed assertion in a Macaulay2 script identifies an exact algebraic
  equality or rank that did not reproduce.
- A manifest failure after all computations means a supposedly deterministic
  packet output changed and should be investigated before relying on it.
