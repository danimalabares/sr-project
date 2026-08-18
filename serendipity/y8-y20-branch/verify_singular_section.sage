"""Certify a fixed singular section in the historical y8,y20 families.

The fast default checks the four frozen families.  ``--all-56`` reconstructs
every historical grid pair from the source deformation data, recomputes the
exact colon test, and checks the same section without reading the saved
56-pair Boolean audit.
"""

import argparse
import os
import sys
import traceback


FROZEN_PAIRS = ((1, 1), (2, 1), (3, 1), (5, 1))


def expected_sr_generators(ring, variables):
    """Return the canonical Grünbaum generators in their frozen order."""
    x0, x1, x2, x3, x4, x5, x6, x7 = variables
    return (
        x5*x6*x7, x3*x5*x7, x2*x6*x7, x2*x4*x6,
        x2*x3*x7, x1*x6*x7, x1*x4*x6, x1*x4*x5,
        x1*x3*x6, x1*x3*x5, x0*x3*x5, x0*x3*x4,
        x0*x2*x7, x0*x2*x5, x0*x2*x4, x0*x1*x4,
    )


def expected_sr_ideal(ring, variables):
    return ring.ideal(expected_sr_generators(ring, variables))


def fixed_section_certificate(
    ring,
    t_parameter,
    generators,
    ideal,
    check_dimension=True,
):
    """Check the rank-zero section [0:0:0:0:0:0:1:0] exactly."""
    variables = ring.gens()[1:]
    section = {
        variable: ring(1 if index == 6 else 0)
        for index, variable in enumerate(variables)
    }

    section_values = tuple(ring(generator).subs(section) for generator in generators)
    assert all(value == 0 for value in section_values)

    jacobian_values = tuple(
        ring(generator).derivative(variable).subs(section)
        for generator in generators
        for variable in variables
    )
    assert all(value == 0 for value in jacobian_values)

    specialized_generators = tuple(
        ring(generator).subs({t_parameter: 0}) for generator in generators
    )
    assert specialized_generators == expected_sr_generators(ring, variables)
    if check_dimension:
        special_fibre = ideal + ring.ideal(t_parameter)
        assert special_fibre.dimension() == 4

    return {
        "section": (0, 0, 0, 0, 0, 0, 1, 0),
        "section_lies_on_entire_family": True,
        "jacobian_zero_along_entire_section": True,
        "jacobian_rank": 0,
        "generic_projective_dimension": 3,
        "projective_tangent_dimension": 7,
        "geometric_generic_fibre_singular": True,
    }


def verify_frozen_families():
    """Recompute flatness and the section certificate for four frozen pairs."""
    global _Y8_Y20_FLATNESS_LIBRARY
    _Y8_Y20_FLATNESS_LIBRARY = True
    load("serendipity/y8-y20-branch/verify_flatness.sage")

    results = []
    for pair in FROZEN_PAIRS:
        flatness = verify_family_flatness(*pair)
        assert flatness["flat"]
        family = load_family(*pair)
        certificate = fixed_section_certificate(
            family["R"],
            family["t"],
            family["generators"],
            family["ideal"],
        )
        results.append((pair, flatness, certificate))
        print(
            "pair %s: J:t=J=True, fixed section=True, "
            "Jacobian rank=0, generic fibre singular=True" % (pair,)
        )
    print("All four frozen families have a fixed singular section.")
    return tuple(results)


def load_reconstruction_library():
    """Load the historical solver without using or rewriting its grid audit."""
    global _Y8_Y20_RECONSTRUCTION_LIBRARY
    global _Y8_Y20_RECONSTRUCTION_LOG_PATH
    _Y8_Y20_RECONSTRUCTION_LIBRARY = True
    _Y8_Y20_RECONSTRUCTION_LOG_PATH = os.devnull
    load("serendipity/y8-y20-branch/reconstruct_families.sage")


def verify_reconstructed_pair(pair):
    """Reconstruct one grid pair and recompute both exact certificates."""
    y = y8_y20_point(*pair)
    assert y is not None
    state, infos = state_for_y(y, MAX_ORDER)
    assert state is not None
    assert all(infos[order]["success"] for order in (2, 3, 4))

    ring, t_parameter, _, ideal, _, _ = build_family_ideal(
        state["gen_vectors"]
    )
    colon_equal = ideal.quotient(ring.ideal(t_parameter)) == ideal
    assert colon_equal
    certificate = fixed_section_certificate(
        ring,
        t_parameter,
        tuple(ideal.gens()),
        ideal,
        check_dimension=False,
    )
    return {
        "pair": pair,
        "reached_order4": True,
        "colon_equal": True,
        "flat_near_t_zero": True,
        "certificate": certificate,
    }


def historical_pairs():
    return tuple(
        (int(y8_value), int(y20_value))
        for y20_value in Y20_GRID
        for y8_value in Y8_GRID
    )


def verify_pair_chunk(pairs):
    """Verify a sequence of pairs, raising immediately on any failed assertion."""
    for pair in pairs:
        verify_reconstructed_pair(pair)
        print(
            "pair %s: reconstructed=True, J:t=J=True, "
            "fixed section=True, Jacobian rank=0" % (pair,),
            flush=True,
        )


def verify_all_56(workers):
    """Reconstruct all pairs; optionally distribute them over forked workers."""
    load_reconstruction_library()
    dimension_ring = PolynomialRing(
        K, ["z%d" % index for index in range(8)], order="degrevlex"
    )
    assert expected_sr_ideal(
        dimension_ring, dimension_ring.gens()
    ).dimension() == 4
    pairs = historical_pairs()
    assert len(pairs) == 56
    workers = max(1, min(int(workers), len(pairs)))

    if workers == 1:
        verify_pair_chunk(pairs)
    else:
        if not hasattr(os, "fork"):
            raise RuntimeError("--workers greater than 1 requires os.fork")
        sys.stdout.flush()
        children = []
        for worker_index in range(workers):
            pid = os.fork()
            if pid == 0:
                exit_code = 0
                try:
                    verify_pair_chunk(pairs[worker_index::workers])
                except BaseException:
                    traceback.print_exc()
                    exit_code = 1
                os._exit(exit_code)
            children.append(pid)
        exit_codes = []
        for pid in children:
            _, status = os.waitpid(pid, 0)
            exit_codes.append(os.waitstatus_to_exitcode(status))
        assert all(exit_code == 0 for exit_code in exit_codes)

    print(
        "All 56 historical pairs were independently reconstructed: "
        "J:t=J for each, and each geometric generic fibre is singular "
        "along the fixed rank-zero section."
    )


parser = argparse.ArgumentParser(
    description="Verify the fixed singular section in the y8,y20 families."
)
parser.add_argument(
    "--all-56",
    action="store_true",
    help="reconstruct and verify all 56 pairs instead of the four frozen pairs",
)
parser.add_argument(
    "--workers",
    type=int,
    default=1,
    help="fork this many workers for --all-56 (default: 1)",
)
arguments = parser.parse_args(sys.argv[1:])

if arguments.all_56:
    verify_all_56(arguments.workers)
else:
    if arguments.workers != 1:
        parser.error("--workers is only meaningful with --all-56")
    verify_frozen_families()
