"""Reconstruct and freeze the exact representatives selected by script 29."""

from pathlib import Path
from sage.repl.preparse import preparse


def _find_project_and_repository():
    candidates = []
    try:
        candidates.append(Path(__file__).resolve().parent)
    except NameError:
        pass
    cwd = Path.cwd().resolve()
    candidates.extend([cwd] + list(cwd.parents))
    for candidate in candidates:
        project = (
            candidate
            if candidate.name == "y8-y20-branch"
            else candidate / "serendipity" / "y8-y20-branch"
        )
        if not project.is_dir():
            continue
        for repository in [project] + list(project.parents):
            source = (
                repository
                / "old-code"
                / "more-lifting"
                / "29_y8_y20_grid_probe.sage"
            )
            if source.is_file():
                return project, repository
    raise RuntimeError("could not locate the branch project and repository")


PROJECT, REPOSITORY_ROOT = _find_project_and_repository()
DATA = PROJECT / "data"
DATA.mkdir(parents=True, exist_ok=True)

# Execute only the definitions from the historical script.  Rewriting these
# four path constants keeps its exact matrices, coordinate conventions, and
# solve_right choices while preventing writes under old-code/more-lifting/.
SOURCE = (
    REPOSITORY_ROOT
    / "old-code"
    / "more-lifting"
    / "29_y8_y20_grid_probe.sage"
)
source_text = SOURCE.read_text()
marker = 'pr("y8,y20 coefficient-grid probe")'
if marker not in source_text:
    raise RuntimeError("could not locate the historical execution marker")
definitions = source_text.split(marker, 1)[0]
replacements = {
    'PICKLE_FILE = "../cotangent/part-1.pkl"':
        'PICKLE_FILE = "old-code/cotangent/part-1.pkl"',
    'RAW_FILE = "../cotangent/order2/cache/raw_obstruction_data.sobj"':
        'RAW_FILE = "old-code/cotangent/order2/cache/raw_obstruction_data.sobj"',
    'QUADRIC_FILE = "../cotangent/order2/cache/obstruction_quadrics_ff32003.sage"':
        'QUADRIC_FILE = "old-code/cotangent/order2/cache/obstruction_quadrics_ff32003.sage"',
    'FORMAL_LIFT_FILE = "../cotangent/order2/cache/formal_lift_to_order30.sobj"':
        'FORMAL_LIFT_FILE = "old-code/cotangent/order2/cache/formal_lift_to_order30.sobj"',
    'OUT_FILE = "cache/29_y8_y20_grid_probe.log"':
        'OUT_FILE = %r' % str(DATA / "reconstruction_audit.log"),
}
for old, new in replacements.items():
    if old not in definitions:
        raise RuntimeError("historical path declaration changed: %s" % old)
    definitions = definitions.replace(old, new)
exec(preparse(definitions), globals())

KNOWN_PAIRS = ((1, 1), (2, 1), (3, 1), (5, 1))
EXPECTED_BASE = {
    0: 6,
    2: 97,
    3: 10,
    19: 899,
    33: 5251,
    34: 101,
    41: 103,
}


def terms_to_polynomial(T, terms):
    variables = T.gens()[1:]
    polynomial = T.zero()
    for exponents, coefficient in terms.items():
        polynomial += T(coefficient) * prod(
            variable**int(exponent)
            for variable, exponent in zip(variables, exponents)
        )
    return polynomial


def correction_polynomials(T, raw_vector):
    return tuple(
        terms_to_polynomial(T, terms)
        for terms in direction_to_terms(raw_vector)
    )


def saved_lifted_syzygies(T, corrections):
    """Complete exact syzygies through t^3 for the historical generators."""
    t_local = T.gen(0)
    variables = T.gens()[1:]

    def monomial(exponents):
        return prod(
            variable**int(exponent)
            for variable, exponent in zip(variables, exponents)
        )

    f_local = tuple(monomial(exponents) for exponents in f_exps)

    def lift_residual(residual):
        lifted = [T.zero() for _ in range(n_gens)]
        for exponents, coefficient in T(residual).dict().items():
            exponents = tuple(ZZ(exponent) for exponent in exponents)
            assert exponents[0] == 0
            x_exponents = exponents[1:]
            for index, generator_exponents in enumerate(f_exps):
                if all(
                    generator_exponents[j] <= x_exponents[j]
                    for j in range(nvars)
                ):
                    quotient = monomial(tuple(
                        x_exponents[j] - generator_exponents[j]
                        for j in range(nvars)
                    ))
                    lifted[index] -= T(coefficient) * quotient
                    break
            else:
                raise RuntimeError(
                    "historical residual is not in the original ideal: %s"
                    % residual
                )
        assert residual == -sum(
            (coefficient * generator
             for coefficient, generator in zip(lifted, f_local)),
            T.zero(),
        )
        return tuple(lifted)

    rows = []
    for row_index in range(syz.nrows()):
        original_row = []
        for generator_index in range(n_gens):
            coefficient = T.zero()
            for exponents, value in syz_terms[row_index][generator_index].items():
                coefficient += T(value) * monomial(exponents)
            original_row.append(coefficient)
        original_row = tuple(original_row)
        first_residual = sum(
            (a_i * g_i for a_i, g_i
             in zip(original_row, corrections[1])),
            T.zero(),
        )
        alpha = lift_residual(first_residual)
        second_residual = sum(
            (a_i * h_i + alpha_i * g_i
             for a_i, h_i, alpha_i, g_i
             in zip(
                 original_row, corrections[2], alpha, corrections[1]
             )),
            T.zero(),
        )
        beta = lift_residual(second_residual)
        third_residual = sum(
            (a_i * q_i + alpha_i * h_i + beta_i * g_i
             for a_i, q_i, alpha_i, h_i, beta_i, g_i
             in zip(
                 original_row,
                 corrections[3],
                 alpha,
                 corrections[2],
                 beta,
                 corrections[1],
             )),
            T.zero(),
        )
        gamma = lift_residual(third_residual)
        rows.append(tuple(
            a_i
            + t_local * alpha_i
            + t_local**2 * beta_i
            + t_local**3 * gamma_i
            for a_i, alpha_i, beta_i, gamma_i
            in zip(original_row, alpha, beta, gamma)
        ))
    return tuple(rows)


def freeze_pair(y8_coefficient, y20_coefficient):
    y = y8_y20_point(y8_coefficient, y20_coefficient)
    if y is None:
        raise RuntimeError("historical pair failed its quadratic equations")
    for index, coefficient in EXPECTED_BASE.items():
        assert K(y[index]) == K(coefficient)
    assert K(y[8]) == K(y8_coefficient)
    assert K(y[20]) == K(29 * y20_coefficient)

    state, infos = state_for_y(y, PROMISING_MAX_ORDER)
    if state is None:
        raise RuntimeError(
            "historical representative did not reach order 6: %s" % infos
        )
    for order in range(2, PROMISING_MAX_ORDER + 1):
        assert infos[order]["success"]
    for order in (4, 5, 6):
        if state["gen_vectors"][order] != 0:
            raise RuntimeError(
                "pair %s has a nonzero generator correction at order %d"
                % ((y8_coefficient, y20_coefficient), order)
            )

    T, t_local, S, J, I_S, f_S = build_family_ideal(
        state["gen_vectors"]
    )
    exact_generators = tuple(J.gens())
    corrections = {
        order: correction_polynomials(T, state["gen_vectors"][order])
        for order in (1, 2, 3)
    }
    lifted_syzygies = saved_lifted_syzygies(T, corrections)
    for row in lifted_syzygies:
        relation = sum(
            (coefficient * generator
             for coefficient, generator in zip(row, exact_generators)),
            T.zero(),
        )
        assert all(
            tuple(ZZ(exponent) for exponent in exponents)[0] >= 4
            for exponents in T(relation).dict()
        )

    frozen = {
        "characteristic": PRIME,
        "field": K,
        "pair": (int(y8_coefficient), int(y20_coefficient)),
        "y": vector(K, y),
        "first_order_raw": vector(K, state["gen_vectors"][1]),
        "second_order_raw": vector(K, state["gen_vectors"][2]),
        "third_order_raw": vector(K, state["gen_vectors"][3]),
        "first_order_corrections": corrections[1],
        "second_order_corrections": corrections[2],
        "third_order_corrections": corrections[3],
        "higher_generator_raw": {
            order: vector(K, state["gen_vectors"][order])
            for order in (4, 5, 6)
        },
        "generators": exact_generators,
        "lifted_syzygies_mod_t4": lifted_syzygies,
        "historical_syzygy_raw": {
            order: vector(K, state["syz_vectors"][order])
            for order in (1, 2, 3, 4, 5)
        },
        "coordinate_metadata": {
            "raw_index_formula": "generator_index * 104 + monomial_index",
            "generator_exponents": tuple(f_exps),
            "correction_exponents": tuple(basis3_exps),
            "historical_exact_variable_names": tuple(
                str(variable) for variable in T.gens()
            ),
            "original_variable_names": tuple(str(variable) for variable in x),
            "generator_count": n_gens,
            "correction_monomial_count": n_mons,
        },
        "provenance": {
            "source_script": str(SOURCE),
            "part1_cache": "old-code/cotangent/part-1.pkl",
            "raw_cache":
                "old-code/cotangent/order2/cache/raw_obstruction_data.sobj",
            "quadrics":
                "old-code/cotangent/order2/cache/obstruction_quadrics_ff32003.sage",
            "formal_lift_reference":
                "old-code/cotangent/order2/cache/formal_lift_to_order30.sobj",
            "formal_lift_cache_used_for_these_representatives": False,
            "solver": "historical A.solve_right(b) from script 29",
            "orders_recomputed": (2, 3, 4, 5, 6),
        },
    }

    stem = "family_y8_%d_y20_%d_GF32003" % (
        y8_coefficient, y20_coefficient
    )
    save(frozen, str(DATA / (stem + ".sobj")))
    with open(DATA / (stem + ".txt"), "w") as output:
        output.write("Historical y8,y20 cubic family over GF(32003)\n")
        output.write("pair: (%d, %d)\n" % (
            y8_coefficient, y20_coefficient
        ))
        output.write("nonzero T^1 coordinates:\n")
        for index, coefficient in enumerate(y):
            if coefficient:
                output.write("y[%d] = %s\n" % (index, coefficient))
        output.write("orders 4, 5, 6 generator corrections vanish: True\n")
        output.write("exact cubic generators:\n")
        for index, generator in enumerate(exact_generators):
            output.write("F[%d] = %s\n" % (index, generator))
    return frozen


print("Historical grid size:", len(Y8_GRID) * len(Y20_GRID))
quadratic_count = sum(
    y8_y20_point(y8_value, y20_value) is not None
    for y20_value in Y20_GRID for y8_value in Y8_GRID
)
print("Historical quadratic survivors:", quadratic_count)
assert quadratic_count == 56

# The historical log is not checked in, so reproduce its 56 exact colon
# verdicts once and retain the audit rather than relying on prose notes.
grid_audit_path = DATA / "historical_56_pair_flatness_audit.sobj"
grid_audit_text_path = DATA / "historical_56_pair_flatness_audit.txt"
if grid_audit_path.is_file():
    grid_audit = load(str(grid_audit_path))
else:
    grid_audit = []
    for y20_value in Y20_GRID:
        for y8_value in Y8_GRID:
            pair = (int(y8_value), int(y20_value))
            started = cputime()
            y_grid = y8_y20_point(*pair)
            state_grid, infos_grid = state_for_y(y_grid, MAX_ORDER)
            reached_order4 = (
                state_grid is not None
                and all(infos_grid[order]["success"] for order in (2, 3, 4))
            )
            colon_equal = False
            if reached_order4:
                T_grid, t_grid, _, J_grid, _, _ = build_family_ideal(
                    state_grid["gen_vectors"]
                )
                colon_equal = (
                    J_grid.quotient(T_grid.ideal(t_grid)) == J_grid
                )
            record = {
                "pair": pair,
                "reached_order4": reached_order4,
                "colon_equal": colon_equal,
                "flat": reached_order4 and colon_equal,
                "cpu_seconds": cputime(started),
            }
            grid_audit.append(record)
            print(
                "grid pair %s: order4=%s J:t=J=%s"
                % (pair, reached_order4, colon_equal)
            )
    grid_audit = tuple(grid_audit)
    save(grid_audit, str(grid_audit_path))
    with open(grid_audit_text_path, "w") as output:
        output.write("Historical 56-pair y8,y20 flatness audit\n")
        for record in grid_audit:
            output.write(
                "%s order4=%s J:t=J=%s flat=%s cpu_seconds=%.3f\n"
                % (
                    record["pair"],
                    record["reached_order4"],
                    record["colon_equal"],
                    record["flat"],
                    record["cpu_seconds"],
                )
            )
assert len(grid_audit) == 56
assert all(record["flat"] for record in grid_audit)
print("Historical exact flat pairs:", sum(
    record["flat"] for record in grid_audit
), "/ 56")

for pair in KNOWN_PAIRS:
    started = cputime()
    frozen = freeze_pair(*pair)
    print(
        "reconstructed pair %s through order 6 in %.3f CPU seconds"
        % (pair, cputime(started))
    )
out.close()
print("Frozen historical families saved under", DATA)
