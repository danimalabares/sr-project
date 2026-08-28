# Reproducing this audit

Run from:

```sh
cd /Users/daniel/github/sr-project
```

The commands below write only to a newly created temporary directory or this
audit directory.  They do not write to the target or canonical packets.

## 1. Record repository state

```sh
pwd
git branch --show-current
git rev-parse HEAD
git status --short
```

State observed before this audit created any output:

```text
/Users/daniel/github/sr-project
restructure
866e9f186a65485a3a71eb3554c33c840a757612
?? proofs/grunbaum-smoothing/dgla-only/
?? proofs/grunbaum-smoothing/fable-dgla-only/
```

## 2. Make a genuinely fresh permitted replay tree

The target contains an excluded pre-existing `AUDIT.md`; the copy command
deliberately omits it.

```sh
audit_tmp=$(mktemp -d /private/tmp/codex-fable-audit.XXXXXX)
audit_parent="$audit_tmp/grunbaum-smoothing"
mkdir -p "$audit_parent/audits"

rsync -a --exclude AUDIT.md \
  proofs/grunbaum-smoothing/fable-dgla-only/ \
  "$audit_parent/fable-dgla-only/"
cp -p proofs/grunbaum-smoothing/COMPLETION.md "$audit_parent/COMPLETION.md"
cp -pR proofs/grunbaum-smoothing/completion "$audit_parent/completion"
cp -pR proofs/grunbaum-smoothing/referee-packet "$audit_parent/referee-packet"
cp -pR proofs/grunbaum-smoothing/audits/tate-stage \
  "$audit_parent/audits/tate-stage"
```

The variable names are task-specific and do not repurpose shell configuration
variables.

## 3. Complete exact replay

```sh
cd "$audit_parent/fable-dgla-only"
JOBS=4 ./verify.sh --all
```

The 2026-08-27 audit replay completed with these decisive lines:

```text
relative H1 dimension=109
coordinate-boundary image dimension=56
absolute H1 dimension=53
family and relation corrections weight-homogeneous=true
starting MC linear e-values equal T1*y=true
two jet matches frozen input=true

T1 degree-zero dimension=53
T2 degree-zero dimension=27
rank commutator columns modulo delta2=12
rank Dq_y=15
primary plus Dq rank=0
ad_y composed primary-bracket rank=0
Jacobi composite rank=0
primary self bracket at y zero=true
proved 280/280 chart pairs

TATE_STAGE_AUDIT_REPLAY_CERTIFIED
starting_deformation_flatness_inputs_verified=true
starting_two_jet_matches_frozen_input=true
FABLE_DGLA_FULL_REPLAY_VERIFIED
```

The outer copy used in this audit was
`/private/tmp/codex-fable-audit.yrvwxL`; the target wrapper reported its own
nested canonical replay at
`/var/folders/k3/0vv6p5kd29z430w37hl5yvz00000gn/T/grunbaum-fable-replay.iXCnaC`.
These paths are evidence locations from this run, not prerequisites.

## 4. Force the TeX rebuild

The ordinary target wrapper can reuse copied generated products.  Force both
documents in the temporary tree:

```sh
cd "$audit_parent/fable-dgla-only"
latexmk -g -norc -pdf -interaction=nonstopmode -halt-on-error PROOF_DGLA.tex
latexmk -g -norc -pdf -interaction=nonstopmode -halt-on-error DG_LIE_INDUCTION.tex
rg -n \
  'Undefined control sequence|LaTeX Warning: Reference .* undefined|There were undefined references' \
  PROOF_DGLA.log DG_LIE_INDUCTION.log
```

Both forced builds passed.  The final `rg` produced no matches.  The logs had
only non-fatal layout/hyperref warnings.

## 5. Independent controller reconstruction

This check reads the canonical sparse Tate data and uses Sage's exact rational
matrix arithmetic.  It does not load either Macaulay2 deformation package.

```sh
cd /Users/daniel/github/sr-project
DOT_SAGE=/private/tmp/codex-fable-sage-cache \
  sage -python \
  proofs/grunbaum-smoothing/no-Linfty-audits/codex-audit-fable/check_controller_complex.py
```

Expected output:

```text
dim_A_1=8
dim_A_2=36
dim_A_3=104
dim_A_4=232
dim_A_5=440
dim_A_6=748
C0_absolute_dimension=64
C1_dimension=1664
C2_dimension=6960
C3_dimension=96800
rank_delta0=56
rank_delta1=1555
rank_delta2=5378
complex_composites_zero=true
relative_H1_dimension=109
absolute_H1_dimension=53
H2_dimension=27
controller_complex_independent_check=passed
```

If `DOT_SAGE` is omitted in a restricted environment, Sage may try to create a
cache below the user's home directory; that filesystem failure is unrelated to
the mathematics.

## 6. Replay critical packets separately

These commands are useful when isolating a failure.  Run them in the fresh
tree, not in the canonical source directories.

```sh
cd "$audit_parent/referee-packet"
JOBS=4 ./verify.sh </dev/null

cd "$audit_parent/audits/tate-stage"
./verify.sh </dev/null

cd "$audit_parent/completion"
./verify.sh </dev/null

cd "$audit_parent/fable-dgla-only"
M2 --script verify_fable_dgla.m2 --no-randomize
python3.13 check_fable.py
```

The first command runs all 280 incidence charts.  The second performs fresh,
complete syzygy-module computations in both Macaulay2 and Singular.  The
third checks the direct `R_4` presentation identity.  The last two regenerate
the controller, homogeneity, tangent, and two-jet checks.

## 7. Inspect one incidence encoding with an explicit lift

The normal batch run checks Gröbner remainder zero for every chart and reloads
one retained lift.  A direct explicit-lift check can be requested for the
standard retained pair:

```sh
cd "$audit_parent/referee-packet"
env X_CHART=1 GRASSMANN_CHART=1 DEGREE_LIMIT=6 VERIFY_LIFT=1 \
  M2 --script code/verify_incidence_chart.m2
```

The relevant source translation to inspect is:

```text
80 incidence polynomials
3 columns per polynomial: q, s*q, s^2*q
3 x 240 exact QQ[z,a]-module matrix
target column (0,0,1)^T
```

Remainder zero is therefore the truncated-ring identity
`s^2 in (q_1,...,q_80)+(s^3)`, not a smoothness statement by itself.

## 8. Environment

Observed commands and versions:

```sh
M2 --version
Singular --version
python3.13 --version
sage --version
latexmk -v
```

```text
Macaulay2 1.20
VersalDeformations 3.0
DGAlgebras 1.1.0
Singular 4.4.1
Python 3.13.7
SageMath 10.7
latexmk 4.79 / TeX Live 2023
```

All mathematical calculations are over exact rational or polynomial rings;
no numerical tolerance or floating-point rank is involved.

## 9. What a passing replay does not establish by itself

A final success string is insufficient unless the source translations are
also audited.  In particular:

- `check_fable.py` is a static contract checker;
- `F^[3]Q^[3]=0` must be connected to a differential on every Tate generator;
- the 136 `d(g)` columns certify a Tate-stage kernel, not 136 `H^3` classes;
- the ranks 12 and 15 prove exactness only together with closure, spanning,
  and the zero composite;
- the 280 normal forms prove truncated polynomial identities, not
  equidimensionality or smoothness;
- smoothness requires the separate projective extension, chart-change,
  Jacobian-dimension, and DVR valuation arguments.

Those logical translations are supplied in `AUDIT_REPORT.md` and itemized in
`CLAIM_LEDGER.md`.
