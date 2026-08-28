#!/bin/sh
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

echo "[local 1/3] checking the relative/absolute controller distinction"
(
  cd "$root"
  M2 --script verify_relative_controller.m2 --no-randomize
  "$pinned_python" check_local.py
)

echo "[local 2/3] compiling the strict dg Lie proof"
(
  cd "$root"
  latexmk -norc -pdf -interaction=nonstopmode -halt-on-error PROOF_DGLA.tex
  latexmk -norc -pdf -interaction=nonstopmode -halt-on-error DG_LIE_INDUCTION.tex
)

echo "[local 3/3] checking TeX logs"
! rg -n "Undefined control sequence|LaTeX Warning: Reference .* undefined|There were undefined references" \
  "$root/PROOF_DGLA.log" "$root/DG_LIE_INDUCTION.log"

if [ "$mode" = "--local" ]; then
  echo "DGLA_ONLY_LOCAL_VERIFIED"
  exit 0
fi

temporary_parent=${TMPDIR:-/tmp}
replay_root=$(mktemp -d "$temporary_parent/grunbaum-dgla-replay.XXXXXX")
mkdir -p "$replay_root/audits" "$replay_root/bin"
cp -p "$parent/COMPLETION.md" "$replay_root/COMPLETION.md"
cp -pR "$parent/referee-packet" "$replay_root/referee-packet"
cp -pR "$parent/audits/tate-stage" "$replay_root/audits/tate-stage"
cp -pR "$parent/completion" "$replay_root/completion"
ln -s "$pinned_python" "$replay_root/bin/python3"

echo "[full 1/3] replaying the frozen referee packet from a temporary copy"
(
  cd "$replay_root/referee-packet"
  PATH="$replay_root/bin:$PATH" JOBS="${JOBS:-4}" ./verify.sh </dev/null
)

echo "[full 2/3] replaying the low Tate-stage audit from a temporary copy"
(
  cd "$replay_root/audits/tate-stage"
  PATH="$replay_root/bin:$PATH" ./verify.sh </dev/null
)

echo "[full 3/3] replaying the R4 starting deformation from a temporary copy"
(
  cd "$replay_root/completion"
  PATH="$replay_root/bin:$PATH" ./verify.sh </dev/null
)

echo "DGLA_ONLY_FULL_REPLAY_VERIFIED"
echo "temporary_replay_copy=$replay_root"
