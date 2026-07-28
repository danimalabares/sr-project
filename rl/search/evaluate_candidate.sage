"""Reusable cheap and exact evaluation of arbitrary cubic candidates."""

import time

if "exact_flatness_diagnostic" not in globals():
    _SR_ENVIRONMENT_SKIP_SMOKE = True
    load("rl/sr_environment.sage")


def evaluate_cubic_candidate(
    cubic_generators,
    run_cheap_test=True,
    run_exact_test=True,
    cheap_degrees=(4, 5),
):
    """Evaluate one cubic candidate without making a smoothness claim."""
    started = time.perf_counter()
    cubic_generators = tuple(cubic_generators)

    cheap_diagnostic = None
    if run_cheap_test:
        cheap_diagnostic = low_degree_flatness_diagnostic(
            cubic_generators,
            degrees=cheap_degrees,
        )

    exact_diagnostic = None
    flat = None
    if run_exact_test:
        exact_diagnostic = exact_flatness_diagnostic(cubic_generators)
        # Only the exact colon calculation supplies a flatness verdict.
        flat = exact_diagnostic["flat"]

    return {
        "cheap_test_ran": bool(run_cheap_test),
        "cheap_diagnostic": cheap_diagnostic,
        "exact_test_ran": bool(run_exact_test),
        "flat": flat,
        "exact_diagnostic": exact_diagnostic,
        "runtime": time.perf_counter() - started,
    }
