"""Independently verify exact flatness of the four frozen branch families."""

import time

load("serendipity/y8-y20-branch/family.sage")

KNOWN_PAIRS = ((1, 1), (2, 1), (3, 1), (5, 1))


def verify_family_flatness(y8_coefficient, y20_coefficient):
    family = load_family(y8_coefficient, y20_coefficient)
    R_local = family["R"]
    t_local = family["t"]
    generators_local = family["generators"]
    ideal_local = family["ideal"]
    sr_ideal = family["original_sr_ideal"]
    assert len(generators_local) == 16

    specialized = R_local.ideal(tuple(
        R_local(generator.subs({t_local: 0}))
        for generator in generators_local
    ))
    special_correct = specialized == sr_ideal
    assert special_correct

    started = time.perf_counter()
    colon = ideal_local.quotient(R_local.ideal(t_local))
    colon_runtime = time.perf_counter() - started
    colon_equal = colon == ideal_local
    torsion_witness = None
    if not colon_equal:
        for candidate in colon.gens():
            if candidate not in ideal_local and t_local * candidate in ideal_local:
                torsion_witness = candidate
                break
    assert colon_equal
    assert torsion_witness is None

    syzygies_verified = None
    frozen = family["frozen"]
    if "lifted_syzygies_mod_t4" in frozen:
        syzygies_verified = True
        saved_rows = frozen["lifted_syzygies_mod_t4"]
        for row_index, saved_row in enumerate(saved_rows):
            row = tuple(R_local(coefficient) for coefficient in saved_row)
            relation = sum(
                (coefficient * generator
                 for coefficient, generator in zip(row, generators_local)),
                R_local.zero(),
            )
            residual = R_local.zero()
            for exponents, coefficient in R_local(relation).dict().items():
                exponents = tuple(ZZ(exponent) for exponent in exponents)
                if exponents[0] < 4:
                    residual += R_local(coefficient) * prod(
                        variable**exponent
                        for variable, exponent
                        in zip(R_local.gens(), exponents)
                    )
            if residual != 0:
                raise RuntimeError(
                    "saved syzygy %d failed modulo t^4: %s"
                    % (row_index, residual)
                )
    return {
        "pair": family["pair"],
        "special_fibre_correct": special_correct,
        "colon_equal": colon_equal,
        "flat": colon_equal,
        "torsion_witness": torsion_witness,
        "syzygies_mod_t4_verified": syzygies_verified,
        "colon_runtime": colon_runtime,
    }


if not globals().get("_Y8_Y20_FLATNESS_LIBRARY", False):
    print("pair       special fibre   J:t=J   flat   colon seconds")
    for pair in KNOWN_PAIRS:
        result = verify_family_flatness(*pair)
        print(
            "%-10s %-15s %-7s %-6s %.6f"
            % (
                str(pair),
                result["special_fibre_correct"],
                result["colon_equal"],
                result["flat"],
                result["colon_runtime"],
            )
        )
    print("All four frozen y8,y20 families verified flat")
