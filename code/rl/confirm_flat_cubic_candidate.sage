"""Independently verify the serialized GF(32003) cubic candidate."""

import time
from pathlib import Path

_SR_ENVIRONMENT_SKIP_SMOKE = True
load("code/rl/sr_environment.sage")

CANDIDATE_FILE = (
    Path.cwd()
    / "code"
    / "rl"
    / "cache"
    / "flat_cubic_candidate_GF32003.sobj"
)
candidate = load(str(CANDIDATE_FILE))

assert candidate["characteristic"] == 32003
assert candidate["T1_DIM"] == T1_DIM
assert candidate["RAW_DIM"] == RAW_DIM

# From this point onward the generators and corrections come only from the
# saved object.  No lifting solver is called.
saved_generators = tuple(candidate["generators"])
assert len(saved_generators) == 16
_parse_cubic_generators(saved_generators)

exact_generators, J = _build_exact_family_ideal(saved_generators)
assert len(exact_generators) == 16

special_fibre = _specialize_exact_ideal_at_t_zero(J)
sr_ideal = _exact_special_sr_ideal()
special_fibre_equal = (
    all(generator in special_fibre for generator in sr_ideal.gens())
    and all(generator in sr_ideal for generator in special_fibre.gens())
)
assert special_fibre_equal

colon_started = time.perf_counter()
colon_by_t = J.quotient(_EXACT_RING.ideal(_exact_t))
colon_equal = colon_by_t == J
colon_seconds = time.perf_counter() - colon_started
assert colon_equal

diagnostic = exact_flatness_diagnostic(saved_generators)
assert diagnostic["flat"] is True
assert diagnostic["t_saturated"] is True
assert diagnostic["torsion_witness"] is None

# Rebuild compatible syzygy coefficients from the saved g and h, then verify
# the saved q directly through degree three in t.  This does not alter q.
saved_second_order_result = {
    "first_order_corrections": tuple(candidate["first_order_corrections"]),
    "second_order_corrections": tuple(candidate["second_order_corrections"]),
}
third_order_problem = _third_order_problem(saved_second_order_result)
verified_generators = _verify_third_order_relations(
    saved_second_order_result["first_order_corrections"],
    saved_second_order_result["second_order_corrections"],
    tuple(candidate["third_order_corrections"]),
    third_order_problem["alpha_rows"],
    third_order_problem["beta_rows"],
)
assert tuple(verified_generators) == tuple(R_t(F) for F in saved_generators)

print("Saved cubic candidate verified")
print("field: GF(32003)")
print("number of generators: 16")
print("special fibre equals original SR ideal: True")
print("J:t = J: True")
print("flat near t=0: True")
print("independent colon runtime: %.6f seconds" % colon_seconds)
