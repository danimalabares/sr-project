"""Sample one second-order correction above a supplied first-order y."""

import argparse
import sys
import time

if "second_order_lift_space" not in globals():
    _SR_ENVIRONMENT_SKIP_SMOKE = True
    load("rl/sr_environment.sage")
if "h_input_hash" not in globals():
    load("rl/search/pipeline_common.sage")


def parse_y_entries(entries):
    """Build a T^1 vector from repeated ``INDEX=COEFFICIENT`` arguments."""
    y = vector(K, T1_DIM)
    seen = set()
    for entry in entries or ():
        if entry.count("=") != 1:
            raise ValueError(
                "invalid --y-entry %r; expected INDEX=COEFFICIENT" % entry
            )
        index_text, coefficient_text = entry.split("=", 1)
        try:
            index = int(index_text)
        except ValueError as error:
            raise ValueError("invalid T^1 index in %r" % entry) from error
        if index < 0 or index >= T1_DIM:
            raise ValueError(
                "T^1 index %d is outside 0..%d" % (index, T1_DIM - 1)
            )
        if index in seen:
            raise ValueError("T^1 index %d was assigned twice" % index)
        try:
            y[index] = K(coefficient_text)
        except (TypeError, ValueError) as error:
            raise ValueError("invalid coefficient in %r" % entry) from error
        seen.add(index)
    if not seen:
        raise ValueError("at least one --y-entry is required")
    return y


def random_h_search(
    y,
    seed=0,
    input_identifier=None,
    runs_directory="rl/runs",
    timestamp=None,
):
    """Save and return one h-stage record for the supplied y."""
    started = time.perf_counter()
    y = _pipeline_y(y)
    input_hash = h_input_hash(y, seed)
    space = second_order_lift_space(y)
    if not space["exists"]:
        record = {
            "status": "second_order_obstructed",
            "y": y,
            "second_order_parameters": None,
            "h": None,
            "obstruction": space["obstruction"],
            "random_seed": int(seed),
            "sampling": "one_random_nonzero_parameter",
            "runtime": time.perf_counter() - started,
        }
    else:
        parameters = _sample_affine_parameters(space["dimension"], seed)
        h = second_order_corrections_from_parameters(space, parameters)
        record = {
            "status": "success",
            "y": y,
            "second_order_parameters": parameters,
            "h": h,
            "obstruction": space["obstruction"],
            "random_seed": int(seed),
            "runtime": time.perf_counter() - started,
        }
    return _save_stage_record(
        record,
        "h",
        input_hash,
        input_identifier=input_identifier,
        runs_directory=runs_directory,
        timestamp=timestamp,
    )


def _parse_arguments(argv):
    parser = argparse.ArgumentParser(
        description="Sample one second-order lift above a supplied y."
    )
    parser.add_argument("--y-entry", action="append", default=[])
    parser.add_argument("--seed", type=int, default=0)
    parser.add_argument("--runs-directory", default="rl/runs")
    return parser.parse_args(argv)


if not globals().get("_RANDOM_H_SEARCH_LIBRARY", False):
    arguments = _parse_arguments(sys.argv[1:])
    try:
        fixed_y = parse_y_entries(arguments.y_entry)
        result = random_h_search(
            fixed_y,
            seed=arguments.seed,
            runs_directory=arguments.runs_directory,
        )
    except ValueError as error:
        raise SystemExit("random_h_search: %s" % error)
    print(result["output_file"])
