#!/usr/bin/env bash
set -euo pipefail

packet_root="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
cd "$packet_root"
export LC_ALL=C
export LANG=C
export SOURCE_DATE_EPOCH=1787036400

jobs="${JOBS:-4}"
case "$jobs" in
  ''|*[!0-9]*) echo "JOBS must be a positive integer" >&2; exit 2 ;;
  0) echo "JOBS must be a positive integer" >&2; exit 2 ;;
esac

echo "[1/7] checking the pinned execution environment"
python3 code/check_environment.py

echo "[2/7] checking the facet complex and Reisner criterion"
python3 code/verify_combinatorics.py

echo "[3/7] recomputing the rational direction and canonical two-jet"
M2 --script code/verify_formal_data.m2 --no-randomize

echo "[4/7] computing the intrinsic Andre-Quillen bracket"
M2 --script code/verify_aq_bracket.m2 --no-randomize

echo "[5/7] proving all 280 truncated singular-incidence memberships"
python3 code/verify_all_incidence.py --jobs "$jobs"

echo "[6/7] checking semantic outputs and compiling the proof"
python3 code/check_results.py
latexmk -norc -pdf -interaction=nonstopmode -halt-on-error PROOF.tex
latexmk -norc -c PROOF.tex >/dev/null

echo "[7/7] checking packet hashes"
shasum -a 256 -c MANIFEST.sha256

echo "VERIFIED: every exact computation, PROOF.pdf, and manifest entry passed."
