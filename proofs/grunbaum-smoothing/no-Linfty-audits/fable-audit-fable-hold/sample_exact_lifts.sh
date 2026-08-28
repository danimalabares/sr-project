#!/bin/sh
# Exact-lift spot checks for the independent Singular incidence replay.
# For each sampled (chart, pivot-set) pair, Singular computes an explicit
# lift matrix L with M*L = (0,0,1)^T and the combination is RE-MULTIPLIED
# exactly inside Singular ("lift_exact ...: 1") -- an explicit exact
# combination, stronger than any Groebner reduction.  Singular's unbounded
# lift() is fast on some charts and very slow on others, so each pair gets
# a 300 s budget and slow pairs are reported as SKIPPED (the full sweep,
# run_all_singular_incidence.py, covers all 280 pairs by degree-bounded
# reduction).
set -eu
here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
sample="1:1,2,3,4 3:2,4,5,7 2:1,2,6,7 8:4,5,6,7 6:2,3,4,5 4:1,4,5,6"
for pair in $sample; do
  chart=${pair%%:*}
  pivots=${pair#*:}
  python3 "$here/gen_singular_incidence.py" "$chart" "$pivots" 6 |
    sed 's/vector nf = reduce(tgt, G, 1);.*/matrix L = lift(M, tgt); vector chk; int jj; for (jj=1; jj<=ncols(M); jj++) { chk = chk + L[jj,1]*M[jj]; } "lift_exact chart='"$chart"' pivots='"$pivots"':", (chk - tgt == 0);/; s/string verdict; if (nf == 0).*//; s/"chart=.*verdict;//' \
    > "$tmp/lift.sing"
  python3 - "$tmp/lift.sing" "$chart" "$pivots" <<'PYEOF'
import subprocess, sys
path, chart, pivots = sys.argv[1:4]
try:
    r = subprocess.run(["Singular", "-q", path], capture_output=True,
                       text=True, stdin=subprocess.DEVNULL, timeout=300)
    line = [l for l in r.stdout.splitlines() if "lift_exact" in l]
    print(line[0] if line else f"lift_exact chart={chart} pivots={pivots}: NO_OUTPUT")
except subprocess.TimeoutExpired:
    print(f"lift_exact chart={chart} pivots={pivots}: SKIPPED_TIMEOUT_300s")
PYEOF
done
echo "SAMPLE_EXACT_LIFTS_DONE"
