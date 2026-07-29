"""Small correctness tests for the one-record h -> q -> f pipeline."""

import re
from pathlib import Path

_SR_ENVIRONMENT_SKIP_SMOKE = True
load("rl/sr_environment.sage")
load("rl/search/pipeline_common.sage")
_RANDOM_H_SEARCH_LIBRARY = True
load("rl/search/random_h_search.sage")
_RANDOM_Q_SEARCH_LIBRARY = True
load("rl/search/random_q_search.sage")
_EVALUATE_CANDIDATE_LIBRARY = True
load("rl/search/evaluate_candidate.sage")


def assert_saved_record(record, stage, expected_hash):
    path = Path(record["output_file"])
    assert path.is_file()
    assert path.parent.resolve() == Path("rl/runs").resolve()
    assert re.fullmatch(
        r"%s-\d{8}-%s\.sobj" % (stage, expected_hash),
        path.name,
    )
    assert record["stage"] == stage
    assert record["input_hash"] == expected_hash
    assert record["input_identifier"] == expected_hash
    reloaded = load(str(path))
    assert reloaded["stage"] == record["stage"]
    assert reloaded["status"] == record["status"]
    assert reloaded["input_hash"] == record["input_hash"]
    return reloaded


# This non-default direction is known to lift to second order.  Keeping the
# extra y[30] coordinate checks that no stage silently substitutes e_0.
y = vector(K, T1_DIM)
y[0] = 1
y[30] = 1
h_record = random_h_search(y, seed=0)
assert h_record["status"] == "success"
assert h_record["y"] == y
assert h_record["y"][30] == 1
assert len(h_record["second_order_parameters"]) == 109
assert len(h_record["h"]) == 16
h_reloaded = assert_saved_record(h_record, "h", h_input_hash(y, 0))
assert h_reloaded["y"] == y
assert h_reloaded["h"] == h_record["h"]

q_record = random_q_search(
    h_reloaded["y"], h_reloaded["h"], seed=0,
    input_identifier=h_reloaded["input_hash"],
)
assert q_record["status"] == "success"
assert q_record["y"] == y
assert q_record["h"] == h_record["h"]
assert len(q_record["third_order_parameters"]) == 109
assert len(q_record["q"]) == 16
q_reloaded = assert_saved_record(
    q_record, "q", q_input_hash(y, h_record["h"], 0)
)
assert q_reloaded["q"] == q_record["q"]

f_record = evaluate_candidate(
    q_reloaded["y"],
    q_reloaded["h"],
    q_reloaded["q"],
    cheap_degrees=(4,),
    input_identifier=q_reloaded["input_hash"],
)
assert f_record["status"] in (
    "nonflat_low_degree", "nonflat_exact", "flat"
)
assert f_record["y"] == y
assert f_record["h"] == h_record["h"]
assert f_record["q"] == q_record["q"]
assert len(f_record["cubic_generators"]) == 16
assert f_record["cheap_diagnostic"] is not None
if f_record["cheap_diagnostic"]["total_defect"] > 0:
    assert not f_record["exact_test_ran"]
    assert f_record["exact_diagnostic"] is None
    assert f_record["flat"] is False
else:
    assert f_record["exact_test_ran"]
    assert f_record["exact_diagnostic"] is not None
f_reloaded = assert_saved_record(
    f_record, "f", f_input_hash(y, h_record["h"], q_record["q"])
)
assert f_reloaded["cubic_generators"] == f_record["cubic_generators"]

# The cached quadratic obstruction gives a fast, genuine failed h record.
obstructed_y = vector(K, T1_DIM)
obstructed_y[0] = 1
obstructed_y[23] = 1
failed_h = random_h_search(obstructed_y, seed=7)
assert failed_h["status"] == "second_order_obstructed"
assert failed_h["h"] is None
assert failed_h["second_order_parameters"] is None
assert failed_h["obstruction"] != 0
failed_reloaded = assert_saved_record(
    failed_h, "h", h_input_hash(obstructed_y, 7)
)
assert failed_reloaded["status"] == "second_order_obstructed"

# Hashes are deterministic and distinguish the three mathematical inputs.
assert h_input_hash(y, 0) == h_input_hash(vector(K, list(y)), 0)
assert h_input_hash(y, 0) != h_input_hash(y, 1)
assert q_input_hash(y, h_record["h"], 0) == q_record["input_hash"]
assert q_input_hash(y, h_record["h"], 0) != (
    q_input_hash(y, h_record["h"], 1)
)
assert f_input_hash(y, h_record["h"], q_record["q"]) == (
    f_record["input_hash"]
)
assert len({
    h_record["input_hash"],
    q_record["input_hash"],
    f_record["input_hash"],
}) == 3

# Repeating an identical invocation reports the collision and preserves the
# existing record rather than silently overwriting it.
existing_path = Path(h_record["output_file"])
existing_mtime = existing_path.stat().st_mtime_ns
same_h_record = random_h_search(y, seed=0)
assert same_h_record["output_file"] == h_record["output_file"]
assert existing_path.stat().st_mtime_ns == existing_mtime

print("search pipeline tests passed")
print("h record:", h_record["output_file"])
print("q record:", q_record["output_file"])
print("f record:", f_record["output_file"])
print("failure record:", failed_h["output_file"])
