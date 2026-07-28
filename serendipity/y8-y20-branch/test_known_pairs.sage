"""Test t=1 smoothness for the four frozen, independently flat families."""

import argparse
import sys
import time
from pathlib import Path

_Y8_Y20_FLATNESS_LIBRARY = True
load("serendipity/y8-y20-branch/verify_flatness.sage")
load("serendipity/y8-y20-branch/test_smoothness.sage")

parser = argparse.ArgumentParser(
    description="Validate cached smoothness results for the known flat pairs."
)
parser.add_argument(
    "--recompute-smoothness",
    action="store_true",
    help="repeat and replace the expensive t=1 smoothness calculations",
)
arguments = parser.parse_args(sys.argv[1:])


def diagonal_rescaling(family):
    """Solve the term-weight equations exactly over QQ and verify a solution."""
    rows = []
    rhs = []
    generators_local = family["generators"]
    for generator_index, generator in enumerate(generators_local):
        for exponents in generator.dict():
            exponents = tuple(ZZ(exponent) for exponent in exponents)
            row = list(exponents[1:]) + [0] * len(generators_local)
            row[8 + generator_index] = -1
            rows.append(row)
            rhs.append(-exponents[0])
    matrix_weights = matrix(QQ, rows)
    rhs_vector = vector(QQ, rhs)
    augmented = matrix_weights.augment(
        matrix(QQ, len(rhs), 1, rhs)
    )
    if matrix_weights.rank() != augmented.rank():
        return {"exists": False, "integer": False}
    solution = matrix_weights.solve_right(rhs_vector)
    kernel = matrix_weights.right_kernel()
    integer_solution = None
    # The ordinary cubic grading usually supplies the only free shift.
    candidates = [solution]
    if kernel.dimension() == 1:
        grading = kernel.basis()[0]
        candidates.extend(
            solution + QQ(n) / 3 * grading for n in range(-6, 7)
        )
    for candidate in candidates:
        if all(coefficient.denominator() == 1 for coefficient in candidate):
            integer_solution = candidate
            break
    chosen = integer_solution if integer_solution is not None else solution
    assert matrix_weights * chosen == rhs_vector
    return {
        "exists": True,
        "integer": integer_solution is not None,
        "variable_weights": tuple(chosen[:8]),
        "generator_weights": tuple(chosen[8:]),
    }


KNOWN_PAIRS = ((1, 1), (2, 1), (3, 1), (5, 1))
results = []
total_started = time.perf_counter()
smooth_pair = None

for pair in KNOWN_PAIRS:
    flatness = verify_family_flatness(*pair)
    assert flatness["flat"]
    smoothness_cache = PROJECT_ROOT / "data" / (
        "smoothness_y8_%d_y20_%d_t1_GF32003.sobj" % pair
    )
    if arguments.recompute_smoothness:
        smoothness = test_family_smoothness(*pair, t_value=1)
        save(smoothness, str(smoothness_cache))
    else:
        if not smoothness_cache.is_file():
            raise RuntimeError(
                "missing smoothness cache %s; rerun with "
                "--recompute-smoothness" % smoothness_cache
            )
        smoothness = load(str(smoothness_cache))
    assert tuple(smoothness["pair"]) == pair
    assert smoothness["t_value"] == 1
    assert smoothness["smooth"] is False
    assert smoothness["singular_locus_empty"] is False
    result = {
        "pair": pair,
        "flatness": flatness,
        "smoothness": smoothness,
        "rescaling": None,
    }
    print(
        "pair %s: flat=True, t=1 smooth=%s, runtime=%.6f seconds"
        % (pair, smoothness["smooth"], smoothness["runtime"])
    )
    if smoothness["smooth"]:
        smooth_pair = pair
        results.append(result)
        break
    family = load_family(*pair)
    result["rescaling"] = diagonal_rescaling(family)
    print("  diagonal rescaling:", result["rescaling"])
    results.append(result)

summary = {
    "pairs_requested": KNOWN_PAIRS,
    "pairs_tested": tuple(result["pair"] for result in results),
    "smooth_pair": smooth_pair,
    "smooth_found": smooth_pair is not None,
    "results": tuple(results),
    "runtime": time.perf_counter() - total_started,
}
if arguments.recompute_smoothness:
    save(
        summary,
        str(PROJECT_ROOT / "data" / "known_pair_smoothness_results.sobj"),
    )
    with open(
        PROJECT_ROOT / "data" / "known_pair_smoothness_results.txt", "w"
    ) as output:
        output.write("Known y8,y20 pair smoothness results over GF(32003)\n")
        for result in results:
            smoothness = result["smoothness"]
            output.write(
                "pair %s: flat=True, t=1 smooth=%s, "
                "projective_dimension=%s, degree=%s, runtime=%.6f seconds\n"
                % (
                    result["pair"],
                    smoothness["smooth"],
                    smoothness["projective_dimension"],
                    smoothness["degree"],
                    smoothness["runtime"],
                )
            )
            output.write("  rescaling: %s\n" % result["rescaling"])
        output.write("smooth fibre found: %s\n" % (smooth_pair is not None))
        if smooth_pair is None and len(results) == len(KNOWN_PAIRS):
            output.write("These four known flat families are not smooth.\n")
        output.write("total runtime: %.6f seconds\n" % summary["runtime"])

if smooth_pair is not None:
    print("Smooth nonzero fibre found for pair", smooth_pair)
else:
    print("These four known flat families are not smooth.")
print("total runtime: %.6f seconds" % summary["runtime"])
