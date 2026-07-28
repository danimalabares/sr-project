"""Controlled random search in a fixed affine third-order correction space."""

import argparse
import random
import statistics
import sys
import time
from datetime import datetime
from pathlib import Path

if "third_order_lift_space" not in globals():
    _SR_ENVIRONMENT_SKIP_SMOKE = True
    load("rl/sr_environment.sage")
if "evaluate_cubic_candidate" not in globals():
    load("rl/search/evaluate_candidate.sage")


def default_q_search_start():
    """Return the isolated default y, zero-parameter h, and its q-space."""
    y = vector(K, T1_DIM)
    y[0] = 1
    second_space = second_order_lift_space(y)
    if not second_space["exists"]:
        raise RuntimeError("default direction is obstructed at second order")
    second_parameters = tuple(K.zero() for _ in range(
        second_space["dimension"]
    ))
    second_corrections = second_order_corrections_from_parameters(
        second_space, second_parameters
    )
    third_space = third_order_lift_space(y, second_corrections)
    if not third_space["exists"]:
        raise RuntimeError(
            "default zero-parameter second-order lift is obstructed at "
            "third order: %s" % third_space["obstruction"]
        )
    return {
        "y": y,
        "second_order_space": second_space,
        "second_order_parameters": second_parameters,
        "second_order_corrections": second_corrections,
        "third_order_space": third_space,
    }


def _sample_parameters(dimension, rng, mode, support_size):
    """Sample one reproducible dense or fixed-support field vector."""
    if mode == "dense":
        return tuple(K(rng.randrange(K.order())) for _ in range(dimension))
    if mode != "sparse":
        raise ValueError("sampling mode must be 'dense' or 'sparse'")
    if support_size < 0 or support_size > dimension:
        raise ValueError(
            "support size must lie between 0 and %d" % dimension
        )
    support = rng.sample(range(dimension), support_size)
    parameters = [K.zero()] * dimension
    for index in support:
        parameters[index] = K(rng.randrange(1, K.order()))
    return tuple(parameters)


def _new_run_directory(seed, output=None):
    """Create a unique run directory, or require a fresh explicit output."""
    if output is not None:
        path = Path(output)
        if path.exists():
            raise ValueError("output directory already exists: %s" % path)
        path.mkdir(parents=True)
        return path.resolve()

    timestamp = datetime.now().strftime("%Y-%m-%d_%H%M%S")
    base = Path("rl/runs") / (
        "random_q_%s_seed%d" % (timestamp, seed)
    )
    path = base
    suffix = 1
    while path.exists():
        path = Path("%s_%d" % (base, suffix))
        suffix += 1
    path.mkdir(parents=True)
    return path.resolve()


def _write_config(path, start, samples, seed, mode, support_size,
                  run_cheap_test, run_exact_test, cheap_degrees):
    with open(path / "config.txt", "w") as output:
        output.write("search: random_q\n")
        output.write("field: GF(%d)\n" % K.order())
        output.write("y: %s\n" % start["y"])
        output.write(
            "second_order_parameters: %s\n"
            % (start["second_order_parameters"],)
        )
        output.write(
            "third_order_space_dimension: %d\n"
            % start["third_order_space"]["dimension"]
        )
        output.write("samples: %d\n" % samples)
        output.write("mode: %s\n" % mode)
        output.write("support_size: %d\n" % support_size)
        output.write("seed: %d\n" % seed)
        output.write("cheap_test: %s\n" % run_cheap_test)
        output.write("cheap_degrees: %s\n" % (tuple(cheap_degrees),))
        output.write("exact_test: %s\n" % run_exact_test)


def run_random_q_search(
    samples=100,
    seed=0,
    mode="sparse",
    support_size=3,
    cheap_only=False,
    output=None,
    cheap_degrees=(4, 5),
):
    """Run the baseline plus ``samples-1`` random q-parameter evaluations."""
    samples = int(samples)
    seed = int(seed)
    support_size = int(support_size)
    if samples < 1:
        raise ValueError("samples must be at least 1 (including baseline)")
    if mode not in ("dense", "sparse"):
        raise ValueError("mode must be 'dense' or 'sparse'")

    run_directory = _new_run_directory(seed, output)
    start = default_q_search_start()
    third_space = start["third_order_space"]
    dimension = third_space["dimension"]
    rng = random.Random(seed)
    run_exact_test = not bool(cheap_only)
    _write_config(
        run_directory,
        start,
        samples,
        seed,
        mode,
        support_size,
        True,
        run_exact_test,
        cheap_degrees,
    )

    sample_records = []
    flat_candidates = []
    log_path = run_directory / "run.log"
    with open(log_path, "w") as log:
        log.write("random_q_search started\n")
        log.write("run directory: %s\n" % run_directory)

        for sample_index in range(samples):
            if sample_index == 0:
                q_parameters = tuple(K.zero() for _ in range(dimension))
            else:
                q_parameters = _sample_parameters(
                    dimension, rng, mode, support_size
                )
            support = tuple(
                index for index, coefficient in enumerate(q_parameters)
                if coefficient
            )

            # Construct q explicitly, then use the public generator builder,
            # whose direct relation check treats any failure as an exception.
            third_corrections = third_order_corrections_from_parameters(
                third_space, q_parameters
            )
            cubic_generators = third_order_generators_from_parameters(
                start["y"],
                start["second_order_corrections"],
                q_parameters,
            )
            recovered_q = tuple(
                R(cubic_generators[index][3])
                for index in range(_N_GENERATORS)
            )
            if recovered_q != third_corrections:
                raise AssertionError(
                    "constructed cubic generators do not preserve q"
                )

            evaluation = evaluate_cubic_candidate(
                cubic_generators,
                run_cheap_test=True,
                run_exact_test=run_exact_test,
                cheap_degrees=cheap_degrees,
            )
            cheap = evaluation["cheap_diagnostic"]
            record = {
                "index": sample_index,
                "q_parameters": q_parameters,
                "support": support,
                "cheap_score": cheap["score"],
                "cheap_total_defect": cheap["total_defect"],
                "flat": evaluation["flat"],
                "runtime": evaluation["runtime"],
            }
            sample_records.append(record)

            if evaluation["flat"] is True:
                flat_candidates.append({
                    "index": sample_index,
                    "q_parameters": q_parameters,
                    "support": support,
                    "generators": cubic_generators,
                    "cheap_diagnostic": cheap,
                    "exact_diagnostic": evaluation["exact_diagnostic"],
                    "runtime": evaluation["runtime"],
                })

            log.write(
                "sample %d support=%s cheap_score=%s flat=%s "
                "runtime=%.6f\n"
                % (
                    sample_index,
                    support,
                    record["cheap_score"],
                    record["flat"],
                    record["runtime"],
                )
            )
            log.flush()

        log.write("random_q_search completed\n")

    save(tuple(sample_records), str(run_directory / "samples.sobj"))
    save(tuple(flat_candidates), str(
        run_directory / "flat_candidates.sobj"
    ))

    runtimes = [record["runtime"] for record in sample_records]
    cheap_passes = sum(
        record["cheap_total_defect"] == 0 for record in sample_records
    )
    best_cheap_score = max(
        record["cheap_score"] for record in sample_records
    )
    flat_supports = tuple(
        candidate["support"] for candidate in flat_candidates
    )
    summary = {
        "run_directory": str(run_directory),
        "total_samples": samples,
        "valid_candidates": len(sample_records),
        "cheap_passes": cheap_passes,
        "exactly_flat": len(flat_candidates),
        "average_runtime": statistics.mean(runtimes),
        "median_runtime": statistics.median(runtimes),
        "best_cheap_score": best_cheap_score,
        "flat_supports": flat_supports,
    }
    with open(run_directory / "summary.txt", "w") as output_file:
        output_file.write("total samples: %d\n" % samples)
        output_file.write(
            "valid candidates: %d\n" % len(sample_records)
        )
        output_file.write("passing cheap test: %d\n" % cheap_passes)
        output_file.write(
            "exactly flat: %d\n" % len(flat_candidates)
        )
        output_file.write(
            "average evaluation time: %.6f seconds\n"
            % summary["average_runtime"]
        )
        output_file.write(
            "median evaluation time: %.6f seconds\n"
            % summary["median_runtime"]
        )
        output_file.write("best cheap score: %s\n" % best_cheap_score)
        output_file.write(
            "flat candidate supports: %s\n" % (flat_supports,)
        )
        output_file.write("run directory: %s\n" % run_directory)

    print("random_q_search completed")
    print("run directory:", run_directory)
    print("total samples:", samples)
    print("passing cheap test:", cheap_passes)
    print("exactly flat:", len(flat_candidates))
    print(
        "average evaluation time: %.6f seconds"
        % summary["average_runtime"]
    )
    print(
        "median evaluation time: %.6f seconds"
        % summary["median_runtime"]
    )
    return {
        "summary": summary,
        "samples": tuple(sample_records),
        "flat_candidates": tuple(flat_candidates),
        "run_directory": run_directory,
    }


def _parse_arguments(argv):
    parser = argparse.ArgumentParser(
        description="Random search in a fixed third-order correction space."
    )
    parser.add_argument("--samples", type=int, default=100)
    parser.add_argument("--seed", type=int, default=0)
    parser.add_argument(
        "--mode", choices=("dense", "sparse"), default="sparse"
    )
    parser.add_argument("--support-size", type=int, default=3)
    parser.add_argument("--cheap-only", action="store_true")
    parser.add_argument("--output")
    return parser.parse_args(argv)


if not globals().get("_RANDOM_Q_SEARCH_LIBRARY", False):
    arguments = _parse_arguments(sys.argv[1:])
    run_random_q_search(
        samples=arguments.samples,
        seed=arguments.seed,
        mode=arguments.mode,
        support_size=arguments.support_size,
        cheap_only=arguments.cheap_only,
        output=arguments.output,
    )
