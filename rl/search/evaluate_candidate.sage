"""Verify and evaluate one supplied order-three choice (y, h, q)."""

import argparse
import sys
import time

if "exact_flatness_diagnostic" not in globals():
    _SR_ENVIRONMENT_SKIP_SMOKE = True
    load("rl/sr_environment.sage")
if "f_input_hash" not in globals():
    load("rl/search/pipeline_common.sage")


def evaluate_cubic_candidate(cubic_generators, cheap_degrees=(4, 5)):
    """Run cheap flatness first and exact flatness only when still needed."""
    started = time.perf_counter()
    cubic_generators = tuple(cubic_generators)
    cheap = low_degree_flatness_diagnostic(
        cubic_generators, degrees=cheap_degrees
    )
    if cheap["total_defect"] > 0:
        return {
            "status": "nonflat_low_degree",
            "cheap_diagnostic": cheap,
            "exact_test_ran": False,
            "exact_diagnostic": None,
            "flat": False,
            "runtime": time.perf_counter() - started,
        }

    exact = exact_flatness_diagnostic(cubic_generators)
    return {
        "status": "flat" if exact["flat"] else "nonflat_exact",
        "cheap_diagnostic": cheap,
        "exact_test_ran": True,
        "exact_diagnostic": exact,
        "flat": exact["flat"],
        "runtime": time.perf_counter() - started,
    }


def evaluate_candidate(
    y,
    h,
    q,
    cheap_degrees=(4, 5),
    input_identifier=None,
    runs_directory="rl/runs",
    timestamp=None,
):
    """Save and return one verified f-stage flatness record."""
    started = time.perf_counter()
    y = _pipeline_y(y)
    h = _pipeline_corrections(h, "h")
    q = _pipeline_corrections(q, "q")
    input_hash = f_input_hash(y, h, q)

    try:
        third_space = third_order_lift_space(y, h)
    except ValueError as error:
        result = {
            "status": "invalid_second_order_lift",
            "cubic_generators": None,
            "cheap_diagnostic": None,
            "exact_test_ran": False,
            "exact_diagnostic": None,
            "flat": False,
            "verification_error": str(error),
        }
    else:
        if not third_space["exists"]:
            result = {
                "status": "third_order_obstructed",
                "cubic_generators": None,
                "cheap_diagnostic": None,
                "exact_test_ran": False,
                "exact_diagnostic": None,
                "flat": False,
                "verification_error": str(third_space["obstruction"]),
            }
        else:
            problem = third_space["_problem"]
            raw_q = _corrections_to_direction(q)
            if _second_order_matrix * raw_q != -problem["target"]:
                result = {
                    "status": "invalid_third_order_lift",
                    "cubic_generators": None,
                    "cheap_diagnostic": None,
                    "exact_test_ran": False,
                    "exact_diagnostic": None,
                    "flat": False,
                    "verification_error":
                        "q does not solve the third-order lifting equation",
                }
            else:
                generators_cubic = _verify_third_order_relations(
                    third_space["first_order_corrections"],
                    h,
                    q,
                    problem["alpha_rows"],
                    problem["beta_rows"],
                )
                result = evaluate_cubic_candidate(
                    generators_cubic, cheap_degrees=cheap_degrees
                )
                result["cubic_generators"] = generators_cubic
                result["verification_error"] = None

    record = {
        "status": result["status"],
        "y": y,
        "h": h,
        "q": q,
        "cubic_generators": result["cubic_generators"],
        "cheap_diagnostic": result["cheap_diagnostic"],
        "exact_test_ran": result["exact_test_ran"],
        "exact_diagnostic": result["exact_diagnostic"],
        "flat": result["flat"],
        "verification_error": result["verification_error"],
        "runtime": time.perf_counter() - started,
    }
    return _save_stage_record(
        record,
        "f",
        input_hash,
        input_identifier=input_identifier,
        runs_directory=runs_directory,
        timestamp=timestamp,
    )


def _parse_arguments(argv):
    parser = argparse.ArgumentParser(
        description="Evaluate one saved successful q-stage record."
    )
    parser.add_argument("--input", required=True)
    parser.add_argument("--runs-directory", default="rl/runs")
    return parser.parse_args(argv)


if not globals().get("_EVALUATE_CANDIDATE_LIBRARY", False):
    arguments = _parse_arguments(sys.argv[1:])
    source = load(arguments.input)
    if source.get("stage") != "q" or source.get("status") != "success":
        raise SystemExit("--input must be a successful q-stage record")
    result = evaluate_candidate(
        source["y"],
        source["h"],
        source["q"],
        input_identifier=source["input_hash"],
        runs_directory=arguments.runs_directory,
    )
    print(result["output_file"])
