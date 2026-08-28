#!/usr/bin/env python3
"""Drive the independent Singular incidence replay over all 280 chart pairs.

For each (x-chart, 4-subset of {1..7}) pair, generate the module encoding
with gen_singular_incidence.py and reduce the target vector (0,0,1) (= s^2)
against a degree-bounded standard basis (degBound 6, retrying at 8).  A zero
normal form is an exact membership certificate: every element of a partial
standard basis is an exact polynomial combination of the input columns.
This matches the packet's logical standard but runs in an independent CAS,
with an independent chart/ideal encoding and enumeration.  (Exact re-multiplied
lifts are additionally verified on a sample by sample_exact_lifts.sh, where
Singular's unbounded lift terminates quickly.)  Results are written to
independent_incidence_singular.txt in this directory.
"""
import subprocess
import sys
import tempfile
from concurrent.futures import ThreadPoolExecutor
from itertools import combinations
from pathlib import Path

HERE = Path(__file__).resolve().parent
GEN = HERE / "gen_singular_incidence.py"
OUT = HERE / "independent_incidence_singular.txt"

def one(pair):
    chart, pivots = pair
    spec = ",".join(map(str, pivots))
    for degbound in (6, 8):
        gen = subprocess.run(
            [sys.executable, str(GEN), str(chart), spec, str(degbound)],
            capture_output=True, text=True, check=True,
        ).stdout
        with tempfile.NamedTemporaryFile(
                "w", suffix=".sing", delete=False) as handle:
            handle.write(gen)
            path = handle.name
        result = subprocess.run(
            ["Singular", "-q", path], capture_output=True, text=True,
            stdin=subprocess.DEVNULL, timeout=1800,
        )
        Path(path).unlink()
        text = " ".join(result.stdout.split())
        if "MEMBERSHIP_PROVED" in text:
            return chart, spec, True, f"degbound={degbound}"
    return chart, spec, False, text[-200:]


def main():
    pairs = [(chart, pivots)
             for chart in range(1, 9)
             for pivots in combinations(range(1, 8), 4)]
    assert len(pairs) == 280
    results = []
    with ThreadPoolExecutor(max_workers=4) as pool:
        for i, res in enumerate(pool.map(one, pairs), 1):
            results.append(res)
            if i % 20 == 0:
                print(f"done {i}/280", flush=True)
    failed = [r for r in results if not r[2]]
    with OUT.open("w") as handle:
        handle.write("independent Singular incidence replay (degree-bounded reduce)\n")
        handle.write(f"pairs={len(results)} proved={len(results)-len(failed)}"
                     f" failed={len(failed)}\n")
        for chart, spec, ok, tail in sorted(results):
            handle.write(f"chart={chart} pivots={spec} "
                         f"{'MEMBERSHIP_PROVED' if ok else 'FAILED'}\n")
        for chart, spec, ok, tail in sorted(results):
            if not ok:
                handle.write(f"FAILURE DETAIL chart={chart} pivots={spec}: "
                             f"{tail}\n")
    print(f"proved {len(results)-len(failed)}/280, failures: {len(failed)}")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
