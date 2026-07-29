"""Sample one third-order correction above an exact supplied pair (y, h)."""

import argparse
import sys
import time

if "third_order_lift_space" not in globals():
    _SR_ENVIRONMENT_SKIP_SMOKE = True
    load("rl/sr_environment.sage")
if "q_input_hash" not in globals():
    load("rl/search/pipeline_common.sage")


def random_q_search(
    y,
    h,
    seed=0,
    input_identifier=None,
    runs_directory="rl/runs",
    timestamp=None,
):
    """Save and return one q-stage record for the supplied exact (y, h)."""
    started = time.perf_counter()
    y = _pipeline_y(y)
    h = _pipeline_corrections(h, "h")
    input_hash = q_input_hash(y, h, seed)

    try:
        space = third_order_lift_space(y, h)
    except ValueError as error:
        record = {
            "status": "invalid_second_order_lift",
            "y": y,
            "h": h,
            "third_order_parameters": None,
            "q": None,
            "obstruction": str(error),
            "random_seed": int(seed),
            "runtime": time.perf_counter() - started,
        }
    else:
        if not space["exists"]:
            record = {
                "status": "third_order_obstructed",
                "y": y,
                "h": h,
                "third_order_parameters": None,
                "q": None,
                "obstruction": space["obstruction"],
                "random_seed": int(seed),
                "sampling": "one_random_nonzero_parameter",
                "runtime": time.perf_counter() - started,
            }
        else:
            parameters = _sample_affine_parameters(
                space["dimension"], seed
            )
            q = third_order_corrections_from_parameters(space, parameters)
            record = {
                "status": "success",
                "y": y,
                "h": h,
                "third_order_parameters": parameters,
                "q": q,
                "obstruction": space["obstruction"],
                "random_seed": int(seed),
                "runtime": time.perf_counter() - started,
            }
    return _save_stage_record(
        record,
        "q",
        input_hash,
        input_identifier=input_identifier,
        runs_directory=runs_directory,
        timestamp=timestamp,
    )


def _parse_arguments(argv):
    parser = argparse.ArgumentParser(
        description="Sample one q above a saved successful h record."
    )
    parser.add_argument("--input", required=True)
    parser.add_argument("--seed", type=int, default=0)
    parser.add_argument("--runs-directory", default="rl/runs")
    return parser.parse_args(argv)


if not globals().get("_RANDOM_Q_SEARCH_LIBRARY", False):
    arguments = _parse_arguments(sys.argv[1:])
    source = load(arguments.input)
    if source.get("stage") != "h" or source.get("status") != "success":
        raise SystemExit("--input must be a successful h-stage record")
    result = random_q_search(
        source["y"],
        source["h"],
        seed=arguments.seed,
        input_identifier=source["input_hash"],
        runs_directory=arguments.runs_directory,
    )
    print(result["output_file"])
