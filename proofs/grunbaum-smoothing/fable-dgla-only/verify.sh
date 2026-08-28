#!/bin/sh
# Non-mutating verification wrapper for fable-dgla-only.
#
#   ./verify.sh --local   new exact checks + TeX compilation only
#   ./verify.sh --all     also replay the three frozen canonical packages
#                         from a fresh temporary copy (frozen trees are
#                         never written)
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
parent=$(CDPATH= cd -- "$root/.." && pwd)
mode=${1:---all}

case "$mode" in
  --all|--local) ;;
  *) echo "usage: ./verify.sh [--all|--local]" >&2; exit 2 ;;
esac

if command -v python3.13 >/dev/null 2>&1; then
  pinned_python=$(command -v python3.13)
else
  echo "python3.13 is required by the frozen environment certificate" >&2
  exit 2
fi

echo "[local 1/3] exact controller / starting-jet / homogeneity checks"
(
  cd "$root"
  M2 --script verify_fable_dgla.m2 --no-randomize
  "$pinned_python" check_fable.py
)

echo "[local 2/3] compiling the two proof documents"
(
  cd "$root"
  latexmk -norc -pdf -interaction=nonstopmode -halt-on-error PROOF_DGLA.tex
  latexmk -norc -pdf -interaction=nonstopmode -halt-on-error DG_LIE_INDUCTION.tex
)

echo "[local 3/3] scanning TeX logs"
if grep -nE "Undefined control sequence|LaTeX Warning: Reference .* undefined|There were undefined references" \
  "$root/PROOF_DGLA.log" "$root/DG_LIE_INDUCTION.log"; then
  echo "TeX log scan failed" >&2
  exit 1
fi

if [ "$mode" = "--local" ]; then
  echo "FABLE_DGLA_LOCAL_VERIFIED"
  exit 0
fi

# Full replay of the three canonical frozen packages, from a temporary copy.
# The python3 shim repairs the frozen wrappers' hard-coded executable name;
# /dev/null as stdin keeps the pinned Singular version probe from waiting on
# an interactive terminal.  Neither repair touches a frozen byte.
temporary_parent=${TMPDIR:-/tmp}
replay_root=$(mktemp -d "$temporary_parent/grunbaum-fable-replay.XXXXXX")
mkdir -p "$replay_root/audits" "$replay_root/bin"
cp -p "$parent/COMPLETION.md" "$replay_root/COMPLETION.md"
cp -pR "$parent/referee-packet" "$replay_root/referee-packet"
cp -pR "$parent/audits/tate-stage" "$replay_root/audits/tate-stage"
cp -pR "$parent/completion" "$replay_root/completion"
ln -s "$pinned_python" "$replay_root/bin/python3"

echo "[full 1/3] frozen referee packet (from temporary copy)"
(
  cd "$replay_root/referee-packet"
  PATH="$replay_root/bin:$PATH" JOBS="${JOBS:-4}" ./verify.sh </dev/null
)

echo "[full 2/3] low Tate-stage audit (from temporary copy)"
(
  cd "$replay_root/audits/tate-stage"
  PATH="$replay_root/bin:$PATH" ./verify.sh </dev/null
)

echo "[full 3/3] R4 starting deformation (from temporary copy)"
(
  cd "$replay_root/completion"
  PATH="$replay_root/bin:$PATH" ./verify.sh </dev/null
)

echo "FABLE_DGLA_FULL_REPLAY_VERIFIED"
echo "temporary_replay_copy=$replay_root"
