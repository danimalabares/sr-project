"""Fast safety checks for the initial random-search pipeline."""

from datetime import datetime
from pathlib import Path

_SR_ENVIRONMENT_SKIP_SMOKE = True
load("rl/sr_environment.sage")
load("rl/search/evaluate_candidate.sage")
_RANDOM_Q_SEARCH_LIBRARY = True
load("rl/search/random_q_search.sage")

start = default_q_search_start()
y = start["y"]
second_corrections = start["second_order_corrections"]
third_space = start["third_order_space"]
assert third_space["dimension"] == 109

zero_parameters = [0] * third_space["dimension"]
zero_corrections = third_order_corrections_from_parameters(
    third_space, zero_parameters
)
deterministic = lift_to_third_order(y)
assert zero_corrections == deterministic["third_order_corrections"]

changed_parameters = list(zero_parameters)
changed_parameters[0] = 1
changed_corrections = third_order_corrections_from_parameters(
    third_space, changed_parameters
)
assert (
    _corrections_to_direction(changed_corrections)
    != _corrections_to_direction(zero_corrections)
)
assert (
    _second_order_matrix * third_space["kernel_basis_raw"][0]
    == 0
)

# Reproducibly sampled affine points differ from the particular solution by
# homogeneous kernel vectors.
test_rng = random.Random(int(23))
for mode, support_size in (("sparse", 3), ("dense", 109)):
    sampled_parameters = _sample_parameters(
        third_space["dimension"], test_rng, mode, support_size
    )
    sampled_raw = _corrections_to_direction(
        third_order_corrections_from_parameters(
            third_space, sampled_parameters
        )
    )
    assert (
        _second_order_matrix
        * (sampled_raw - third_space["particular_raw"])
        == 0
    )

changed_generators = third_order_generators_from_parameters(
    y, second_corrections, changed_parameters
)
assert len(changed_generators) == 16

try:
    third_order_corrections_from_parameters(
        third_space, [0] * (third_space["dimension"] - 1)
    )
except ValueError as error:
    assert "expected 109" in str(error)
else:
    raise AssertionError("short third-order parameter vector was accepted")

constant_family = tuple(R_t(generator) for generator in generators)
evaluation = evaluate_cubic_candidate(
    constant_family,
    run_cheap_test=False,
    run_exact_test=True,
)
for field in (
    "cheap_test_ran",
    "cheap_diagnostic",
    "exact_test_ran",
    "flat",
    "exact_diagnostic",
    "runtime",
):
    assert field in evaluation
assert not evaluation["cheap_test_ran"]
assert evaluation["exact_test_ran"]
assert evaluation["flat"] is True

try:
    evaluate_cubic_candidate(
        constant_family[:15],
        run_cheap_test=True,
        run_exact_test=False,
        cheap_degrees=(4,),
    )
except ValueError as error:
    assert "expected 16" in str(error)
else:
    raise AssertionError("malformed candidate was accepted")

test_name = "test_search_pipeline_%s" % datetime.now().strftime(
    "%Y%m%d_%H%M%S_%f"
)
test_run_directory = Path("rl/runs") / test_name
tiny_run = run_random_q_search(
    samples=3,
    seed=17,
    mode="sparse",
    support_size=1,
    cheap_only=False,
    output=test_run_directory,
    cheap_degrees=(4,),
)
for filename in (
    "config.txt",
    "run.log",
    "summary.txt",
    "samples.sobj",
    "flat_candidates.sobj",
):
    assert (test_run_directory / filename).is_file()

saved_samples = load(str(test_run_directory / "samples.sobj"))
saved_flat_candidates = load(str(
    test_run_directory / "flat_candidates.sobj"
))
assert len(saved_samples) == 3
assert len(saved_samples) == tiny_run["summary"]["total_samples"]
assert len(saved_flat_candidates) == tiny_run["summary"]["exactly_flat"]

print("search pipeline tests passed")
print("test run directory:", test_run_directory.resolve())
