#!/bin/bash
set -euo pipefail

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$ROOT"
export LC_ALL=C
export LANG=C

if [ -e verification/FAILED_CLASS.m2 ]; then
  echo "Refusing to hide an existing failure witness: verification/FAILED_CLASS.m2" >&2
  exit 2
fi

python3 code/check_environment.py > verification/environment_check.txt
cmp -s verification/environment.txt verification/environment_check.txt

python3 code/prepare_inputs.py \
  --input data/tate_candidate.tsv \
  --provenance data/provenance.json \
  --m2-output verification/generated_input.m2 \
  --singular-output data/tate_input.sing \
  > verification/input_validation.txt

M2 --no-preload --no-randomize --no-readline --no-threads --no-time --no-tty \
  --silent --stop -q code/verify_tate_stage.m2 \
  > verification/macaulay2_full.txt 2>&1
cmp -s verification/m2_lifts.generated.m2 data/m2_lift_certificate.m2
M2 --no-preload --no-randomize --no-readline --no-threads --no-time --no-tty \
  --silent --stop -q code/check_m2_certificate.m2 \
  > verification/macaulay2_retained.txt 2>&1

Singular --quiet --no-rc --no-shell --no-stdlib --random=0 --no-tty \
  --cpus=1 --threads=1 --flint-threads=1 code/verify_tate_stage.sing \
  > verification/singular_summary.txt 2>&1
cmp -s verification/singular_lifts.generated.dump \
  data/singular_lift_certificate.dump
Singular --quiet --no-rc --no-shell --no-stdlib --random=0 --no-tty \
  --cpus=1 --threads=1 --flint-threads=1 \
  -u data/singular_lift_certificate.dump \
  -c 'getdump(system("--user-option"));' \
  code/check_singular_certificate.sing \
  > verification/singular_retained.txt 2>&1

python3 code/check_results.py
shasum -a 256 -c MANIFEST.sha256
echo "TATE_STAGE_AUDIT_REPLAY_CERTIFIED"
