"""Reusable first-order deformation space for the Stanley--Reisner example."""

import pickle
from pathlib import Path

from sage.all import GF, PolynomialRing, load, prod, vector


K = GF(32003)
T1_DIM = 53
RAW_DIM = 1664

_RAW_DATA_FILE = (
    Path.cwd()
    / "code"
    / "cotangent"
    / "order2"
    / "cache"
    / "raw_obstruction_data.sobj"
)
_PART1_DATA_FILE = Path.cwd() / "code" / "cotangent" / "part-1.pkl"
_QUADRATIC_SAMPLES_FILE = (
    Path.cwd()
    / "code"
    / "cotangent"
    / "order2"
    / "cache"
    / "sample_points_on_Z.sobj"
)
_raw_data = load(str(_RAW_DATA_FILE))
with open(_PART1_DATA_FILE, "rb") as _part1_file:
    _part1_data = pickle.load(_part1_file)

assert _raw_data["n_T1"] == T1_DIM
assert _raw_data["n_params"] == RAW_DIM

T1_basis = [vector(K, list(v)) for v in _raw_data["T1_basis"]]

assert len(T1_basis) == T1_DIM
assert all(len(v) == RAW_DIM for v in T1_basis)

# The cache records the exponent tuples in exactly the order used to construct
# the raw coordinates.  The obstruction code defines coordinate (i, j) as
# i * 104 + j: 16 consecutive generator blocks, with each block ordered by
# basis3_exps.  This agrees with part-1.pkl's a1,...,a104,b1,...,p104 order.
_generator_exponents = list(_raw_data["f_exps"])
_correction_exponents = list(_raw_data["basis3_exps"])
_N_GENERATORS = len(_generator_exponents)
_N_CORRECTION_MONOMIALS = len(_correction_exponents)

assert _N_GENERATORS == 16
assert _N_CORRECTION_MONOMIALS == 104
assert _N_GENERATORS * _N_CORRECTION_MONOMIALS == RAW_DIM

R = PolynomialRing(K, names=["x%d" % i for i in range(1, 9)])
_x = R.gens()
generators = tuple(
    prod(x_i**exponent for x_i, exponent in zip(_x, exponents))
    for exponents in _generator_exponents
)

def original_ideal():
    """Return the original Stanley--Reisner ideal."""
    return R.ideal(generators)


def print_original_ideal():
    """Print the original 16 monomial generators."""
    print("Original Stanley--Reisner ideal:")
    for i, generator in enumerate(generators):
        print("f_%d = %s" % (i, generator))

_correction_monomials = tuple(
    prod(x_i**exponent for x_i, exponent in zip(_x, exponents))
    for exponents in _correction_exponents
)

R_t = PolynomialRing(R, "t")
t = R_t.gen()

# part-1.sage constructs syz = I.syzygy_module() and then treats each of its
# 38 rows as one relation, summing syz[row, j] * f_j over the 16 columns.
_cached_syzygy_matrix = _part1_data["syz"]
assert _cached_syzygy_matrix.nrows() == 38
assert _cached_syzygy_matrix.ncols() == _N_GENERATORS
_syzygy_rows = tuple(
    tuple(R(_cached_syzygy_matrix[row, column])
          for column in range(_N_GENERATORS))
    for row in range(_cached_syzygy_matrix.nrows())
)
assert all(
    sum((a_i * f_i for a_i, f_i in zip(row, generators)), R.zero()) == 0
    for row in _syzygy_rows
)
_original_ideal = original_ideal()

# Cached order-two convention from 01_build_raw_obstruction.sage:
#   B*h + Q0*q(y) = 0 modulo I,
# where B has one column per raw h-coordinate and q(y) is ordered by
# quad_pairs = [(i, j) for i <= j].  OB is the coordinate map from q(y)
# to the 27-dimensional obstruction space, so OB*q(y) vanishes exactly
# when the cached order-two system is solvable.
_second_order_matrix = _raw_data["B"]
_quadratic_rhs_matrix = _raw_data["Q0"]
_obstruction_matrix = _raw_data["OB"]
_quadratic_pairs = list(_raw_data["quad_pairs"])
_order2_row = dict(_raw_data["order2_row"])

assert _second_order_matrix.ncols() == RAW_DIM
assert _second_order_matrix.nrows() == _quadratic_rhs_matrix.nrows()
assert _quadratic_rhs_matrix.ncols() == len(_quadratic_pairs)
assert _obstruction_matrix.ncols() == len(_quadratic_pairs)
assert _obstruction_matrix.nrows() == _raw_data["obs_rank"] == 27
assert _raw_data["rank_B"] == 1555


def y_to_direction(y):
    """Convert 53 T^1 coordinates into a 1664-coordinate raw direction."""
    coefficients = list(y)
    if len(coefficients) != T1_DIM:
        raise ValueError(
            "expected %d T^1 coefficients, got %d"
            % (T1_DIM, len(coefficients))
        )

    direction = vector(K, RAW_DIM)
    for coefficient, basis_vector in zip(coefficients, T1_basis):
        coefficient = K(coefficient)
        if coefficient:
            direction += coefficient * basis_vector
    return direction


def direction_to_corrections(d):
    """Convert a raw direction into one correction polynomial per generator."""
    coordinates = list(d)
    if len(coordinates) != RAW_DIM:
        raise ValueError(
            "expected %d raw deformation coordinates, got %d"
            % (RAW_DIM, len(coordinates))
        )

    corrections = []
    for generator_index in range(_N_GENERATORS):
        block_start = generator_index * _N_CORRECTION_MONOMIALS
        correction = R.zero()
        for monomial_index, monomial in enumerate(_correction_monomials):
            coefficient = K(coordinates[block_start + monomial_index])
            if coefficient:
                correction += coefficient * monomial
        corrections.append(correction)
    return tuple(corrections)


def _corrections_to_direction(corrections):
    """Inverse of direction_to_corrections on the cached monomial span."""
    corrections = list(corrections)
    if len(corrections) != _N_GENERATORS:
        raise ValueError(
            "expected %d correction polynomials, got %d"
            % (_N_GENERATORS, len(corrections))
        )

    coordinates = []
    for correction in corrections:
        correction = R(correction)
        block = [
            K(correction.monomial_coefficient(m))
            for m in _correction_monomials
        ]
        reconstructed = sum(
            (coefficient * monomial
             for coefficient, monomial in zip(block, _correction_monomials)),
            R.zero(),
        )
        if reconstructed != correction:
            raise ValueError(
                "correction contains monomials outside the cached raw basis"
            )
        coordinates.extend(block)
    return vector(K, coordinates)


def first_order_generators(y):
    """Return the 16 generators deformed to first order by T^1 coordinates y."""
    coefficients = list(y)
    if len(coefficients) != T1_DIM:
        raise ValueError(
            "expected %d T^1 coefficients, got %d"
            % (T1_DIM, len(coefficients))
        )

    direction = y_to_direction(coefficients)
    corrections = direction_to_corrections(direction)
    return tuple(
        R_t(generator) + t * R_t(correction)
        for generator, correction in zip(generators, corrections)
    )


def _lift_residual(residual):
    """Find b_i with residual = -sum_i b_i*f_i for the monomial ideal I."""
    b = [R.zero() for _ in range(_N_GENERATORS)]
    for exponents, coefficient in residual.dict().items():
        exponents = tuple(exponents)
        for i, generator_exponents in enumerate(_generator_exponents):
            if all(
                generator_exponents[j] <= exponents[j]
                for j in range(len(_x))
            ):
                quotient = prod(
                    _x[j]**(exponents[j] - generator_exponents[j])
                    for j in range(len(_x))
                )
                # The minus sign gives residual = -sum_i b_i*f_i.
                b[i] -= K(coefficient) * quotient
                break
        else:
            raise ValueError(
                "cannot lift residual because it is not in I: %s" % residual
            )
    assert residual == -sum(
        (b_i * f_i for b_i, f_i in zip(b, generators)), R.zero()
    )
    return tuple(b)


def _quadratic_coordinate_vector(y):
    """Evaluate the cached i <= j quadratic-monomial ordering at y."""
    coefficients = list(y)
    if len(coefficients) != T1_DIM:
        raise ValueError(
            "expected %d T^1 coefficients, got %d"
            % (T1_DIM, len(coefficients))
        )
    coefficients = [K(coefficient) for coefficient in coefficients]
    return vector(
        K,
        [coefficients[i] * coefficients[j]
         for i, j in _quadratic_pairs],
    )


def second_order_obstruction(y):
    """Return the 27 cached quadratic obstruction coordinates for y."""
    return _obstruction_matrix * _quadratic_coordinate_vector(y)


def _order2_residual_vector(first_corrections, first_syzygy_lifts):
    """Encode alpha*g modulo I in the cached (syzygy row, monomial) rows."""
    residual_vector = vector(K, _second_order_matrix.nrows())
    for syzygy_index, alpha in enumerate(first_syzygy_lifts):
        residual = sum(
            (alpha_i * g_i
             for alpha_i, g_i in zip(alpha, first_corrections)),
            R.zero(),
        ).reduce(_original_ideal)
        for exponents, coefficient in residual.dict().items():
            key = (syzygy_index, tuple(exponents))
            if key not in _order2_row:
                raise RuntimeError(
                    "order-two residual uses an uncached row %s" % (key,)
                )
            residual_vector[_order2_row[key]] += K(coefficient)
    return residual_vector


def _verify_second_order_relations(
    first_corrections, second_corrections, first_syzygy_lifts
):
    """Complete and verify all syzygy relations through degree two in t."""
    deformed_generators = tuple(
        R_t(f_i) + t * R_t(g_i) + t**2 * R_t(h_i)
        for f_i, g_i, h_i
        in zip(generators, first_corrections, second_corrections)
    )

    for syzygy_index, (row, alpha) in enumerate(
        zip(_syzygy_rows, first_syzygy_lifts)
    ):
        order2_residual = sum(
            (a_i * h_i + alpha_i * g_i
             for a_i, h_i, alpha_i, g_i
             in zip(row, second_corrections, alpha, first_corrections)),
            R.zero(),
        )
        normal_form = order2_residual.reduce(_original_ideal)
        if normal_form != 0:
            raise RuntimeError(
                "second-order syzygy %d has nonzero normal form: %s"
                % (syzygy_index, normal_form)
            )

        beta = _lift_residual(order2_residual)
        lifted_coefficients = tuple(
            R_t(a_i) + t * R_t(alpha_i) + t**2 * R_t(beta_i)
            for a_i, alpha_i, beta_i in zip(row, alpha, beta)
        )
        relation = sum(
            (coefficient * generator
             for coefficient, generator
             in zip(lifted_coefficients, deformed_generators)),
            R_t.zero(),
        )
        residual_mod_t3 = sum(
            (t**degree * R_t(relation[degree]) for degree in range(3)),
            R_t.zero(),
        )
        if residual_mod_t3 != 0:
            raise RuntimeError(
                "constructed lift for syzygy %d failed modulo t^3: %s"
                % (syzygy_index, residual_mod_t3)
            )
    return deformed_generators


def lift_to_second_order(y):
    """Attempt to lift the T^1 direction y through order two."""
    coefficients = list(y)
    if len(coefficients) != T1_DIM:
        raise ValueError(
            "expected %d T^1 coefficients, got %d"
            % (T1_DIM, len(coefficients))
        )

    direction = y_to_direction(coefficients)
    first_corrections = direction_to_corrections(direction)
    obstruction = second_order_obstruction(coefficients)
    if obstruction != 0:
        return {
            "exists": False,
            "first_order_corrections": first_corrections,
            "second_order_corrections": None,
            "generators": None,
            "obstruction": obstruction,
        }

    # Use deterministic exact residual lifts for the first syzygies.  Their
    # alpha*g residual differs from the cached Q0 representative only by
    # image(B), so solving the cached B system gives compatible h_i.
    first_syzygy_lifts = []
    for row in _syzygy_rows:
        residual = sum(
            (a_i * g_i for a_i, g_i in zip(row, first_corrections)),
            R.zero(),
        )
        first_syzygy_lifts.append(_lift_residual(residual))

    order2_residual = _order2_residual_vector(
        first_corrections, first_syzygy_lifts
    )
    try:
        second_direction = _second_order_matrix.solve_right(-order2_residual)
    except ValueError as error:
        raise RuntimeError(
            "cached obstruction vanished but the second-order system "
            "was inconsistent"
        ) from error

    second_direction = vector(K, list(second_direction))
    second_corrections = direction_to_corrections(second_direction)
    deformed_generators = _verify_second_order_relations(
        first_corrections, second_corrections, first_syzygy_lifts
    )
    return {
        "exists": True,
        "first_order_corrections": first_corrections,
        "second_order_corrections": second_corrections,
        "generators": deformed_generators,
        "obstruction": obstruction,
    }


def second_order_generators(y):
    """Return the 16 generators through order two, or reject an obstruction."""
    result = lift_to_second_order(y)
    if not result["exists"]:
        raise ValueError(
            "direction is obstructed at second order: obstruction=%s"
            % result["obstruction"]
        )
    return result["generators"]


def _target_vector_from_residuals(residuals):
    """Encode 38 quotient residuals in the cached B-row ordering."""
    target = vector(K, _second_order_matrix.nrows())
    for syzygy_index, residual in enumerate(residuals):
        normal_form = R(residual).reduce(_original_ideal)
        for exponents, coefficient in normal_form.dict().items():
            key = (syzygy_index, tuple(exponents))
            if key not in _order2_row:
                raise RuntimeError(
                    "higher-order residual uses an uncached row %s" % (key,)
                )
            target[_order2_row[key]] += K(coefficient)
    return target


def _third_order_problem(second_order_result):
    """Build the cached B*q = -r order-three problem for Step 3's h."""
    first_corrections = second_order_result["first_order_corrections"]
    second_corrections = second_order_result["second_order_corrections"]

    # The existing order-three scripts use
    #   s*q + alpha*h + beta*g = 0 modulo I.
    # Choose alpha and beta deterministically by the same exact residual lifts
    # used by the direct Step 3 verification.  This fixes a syzygy lift
    # compatible with the particular h returned by lift_to_second_order().
    alpha_rows = []
    beta_rows = []
    order3_residuals = []
    for row in _syzygy_rows:
        order1_residual = sum(
            (a_i * g_i for a_i, g_i in zip(row, first_corrections)),
            R.zero(),
        )
        alpha = _lift_residual(order1_residual)

        order2_residual = sum(
            (a_i * h_i + alpha_i * g_i
             for a_i, h_i, alpha_i, g_i
             in zip(row, second_corrections, alpha, first_corrections)),
            R.zero(),
        )
        beta = _lift_residual(order2_residual)

        order3_residual = sum(
            (alpha_i * h_i + beta_i * g_i
             for alpha_i, h_i, beta_i, g_i
             in zip(alpha, second_corrections, beta, first_corrections)),
            R.zero(),
        )
        alpha_rows.append(alpha)
        beta_rows.append(beta)
        order3_residuals.append(order3_residual)

    return {
        "target": _target_vector_from_residuals(order3_residuals),
        "alpha_rows": tuple(alpha_rows),
        "beta_rows": tuple(beta_rows),
    }


def _solve_third_order_problem(problem):
    """Return (solution, obstruction); obstruction uses cached B-row coords."""
    target = problem["target"]
    try:
        solution = _second_order_matrix.solve_right(-target)
    except ValueError:
        # The raw target is a concrete residual in the documented
        # (syzygy row, monomial) ordering.  It is returned only after the
        # cached B system proves that its cokernel class is nonzero.
        return None, target
    return vector(K, list(solution)), vector(K, len(target))


def third_order_obstruction(y):
    """Return the order-three obstruction for Step 3's chosen second lift."""
    coefficients = list(y)
    if len(coefficients) != T1_DIM:
        raise ValueError(
            "expected %d T^1 coefficients, got %d"
            % (T1_DIM, len(coefficients))
        )
    second_order_result = lift_to_second_order(coefficients)
    if not second_order_result["exists"]:
        raise ValueError(
            "cannot test third order: direction is obstructed at second "
            "order with obstruction=%s"
            % second_order_result["obstruction"]
        )
    problem = _third_order_problem(second_order_result)
    _, obstruction = _solve_third_order_problem(problem)
    return obstruction


def _verify_third_order_relations(
    first_corrections,
    second_corrections,
    third_corrections,
    alpha_rows,
    beta_rows,
):
    """Complete and directly verify all relations through degree three in t."""
    deformed_generators = tuple(
        R_t(f_i)
        + t * R_t(g_i)
        + t**2 * R_t(h_i)
        + t**3 * R_t(q_i)
        for f_i, g_i, h_i, q_i
        in zip(
            generators,
            first_corrections,
            second_corrections,
            third_corrections,
        )
    )

    for syzygy_index, (row, alpha, beta) in enumerate(
        zip(_syzygy_rows, alpha_rows, beta_rows)
    ):
        order3_residual = sum(
            (a_i * q_i + alpha_i * h_i + beta_i * g_i
             for a_i, q_i, alpha_i, h_i, beta_i, g_i
             in zip(
                 row,
                 third_corrections,
                 alpha,
                 second_corrections,
                 beta,
                 first_corrections,
             )),
            R.zero(),
        )
        normal_form = order3_residual.reduce(_original_ideal)
        if normal_form != 0:
            raise RuntimeError(
                "third-order syzygy %d has nonzero normal form: %s"
                % (syzygy_index, normal_form)
            )
        gamma = _lift_residual(order3_residual)

        lifted_coefficients = tuple(
            R_t(a_i)
            + t * R_t(alpha_i)
            + t**2 * R_t(beta_i)
            + t**3 * R_t(gamma_i)
            for a_i, alpha_i, beta_i, gamma_i
            in zip(row, alpha, beta, gamma)
        )
        relation = sum(
            (coefficient * generator
             for coefficient, generator
             in zip(lifted_coefficients, deformed_generators)),
            R_t.zero(),
        )
        residual_mod_t4 = sum(
            (t**degree * R_t(relation[degree]) for degree in range(4)),
            R_t.zero(),
        )
        if residual_mod_t4 != 0:
            raise RuntimeError(
                "constructed lift for syzygy %d failed modulo t^4: %s"
                % (syzygy_index, residual_mod_t4)
            )
    return deformed_generators


def lift_to_third_order(y):
    """Attempt to extend Step 3's particular second-order lift to order three."""
    coefficients = list(y)
    if len(coefficients) != T1_DIM:
        raise ValueError(
            "expected %d T^1 coefficients, got %d"
            % (T1_DIM, len(coefficients))
        )

    second_order_result = lift_to_second_order(coefficients)
    if not second_order_result["exists"]:
        return {
            "exists": False,
            "first_order_corrections":
                second_order_result["first_order_corrections"],
            "second_order_corrections": None,
            "third_order_corrections": None,
            "generators": None,
            "obstruction": second_order_result["obstruction"],
            "failed_order": 2,
        }

    problem = _third_order_problem(second_order_result)
    third_direction, obstruction = _solve_third_order_problem(problem)
    if third_direction is None:
        return {
            "exists": False,
            "first_order_corrections":
                second_order_result["first_order_corrections"],
            "second_order_corrections":
                second_order_result["second_order_corrections"],
            "third_order_corrections": None,
            "generators": None,
            "obstruction": obstruction,
            "failed_order": 3,
        }

    third_corrections = direction_to_corrections(third_direction)
    deformed_generators = _verify_third_order_relations(
        second_order_result["first_order_corrections"],
        second_order_result["second_order_corrections"],
        third_corrections,
        problem["alpha_rows"],
        problem["beta_rows"],
    )
    return {
        "exists": True,
        "first_order_corrections":
            second_order_result["first_order_corrections"],
        "second_order_corrections":
            second_order_result["second_order_corrections"],
        "third_order_corrections": third_corrections,
        "generators": deformed_generators,
        "obstruction": obstruction,
        "failed_order": None,
    }


def third_order_generators(y):
    """Return generators through t^3, or raise with the failed obstruction."""
    result = lift_to_third_order(y)
    if not result["exists"]:
        raise ValueError(
            "direction does not lift to third order (failed at order %s): "
            "obstruction=%s"
            % (result["failed_order"], result["obstruction"])
        )
    return result["generators"]


def _smoke_test():
    assert tuple(original_ideal().gens()) == generators
    zero_y = [0] * T1_DIM
    zero_direction = y_to_direction(zero_y)
    assert zero_direction == vector(K, RAW_DIM)
    assert first_order_generators(zero_y) == tuple(
        R_t(generator) for generator in generators
    )

    for i in range(T1_DIM):
        standard_basis_vector = [0] * T1_DIM
        standard_basis_vector[i] = 1
        assert y_to_direction(standard_basis_vector) == T1_basis[i]

    standard_basis_vector = [0] * T1_DIM
    standard_basis_vector[0] = 1
    direction = y_to_direction(standard_basis_vector)
    assert direction == T1_basis[0]
    assert _corrections_to_direction(
        direction_to_corrections(direction)
    ) == direction

    zero_lift = lift_to_second_order(zero_y)
    assert zero_lift["exists"]
    assert zero_lift["obstruction"] == 0
    assert all(correction == 0
               for correction in zero_lift["second_order_corrections"])

    known_liftable = [0] * T1_DIM
    known_liftable[0] = 1
    liftable_result = lift_to_second_order(known_liftable)
    assert liftable_result["exists"]

    # The cached quadrics show that y0 + y23 is obstructed.
    known_obstructed = [0] * T1_DIM
    known_obstructed[0] = 1
    known_obstructed[23] = 1
    obstructed_result = lift_to_second_order(known_obstructed)
    assert not obstructed_result["exists"]
    assert obstructed_result["obstruction"] != 0

    assert second_order_generators(vector(K, T1_DIM)) == tuple(
        R_t(generator) for generator in generators
    )
    assert len(second_order_generators(known_liftable)) == _N_GENERATORS
    try:
        second_order_generators(known_obstructed)
    except ValueError as error:
        assert "obstruction=" in str(error)
    else:
        raise AssertionError("obstructed direction returned generators")

    zero_third_lift = lift_to_third_order(vector(K, T1_DIM))
    assert zero_third_lift["exists"]
    assert zero_third_lift["obstruction"] == 0
    assert all(q == 0 for q in zero_third_lift["third_order_corrections"])
    assert third_order_generators(vector(K, T1_DIM)) == tuple(
        R_t(generator) for generator in generators
    )

    # Literal T^1 coordinates recovered from the checked-in
    # order2/cache/one_order3_lift.sobj example.
    nontrivial_third_order_y = vector(K, T1_DIM)
    nontrivial_third_order_y[0] = 1403
    nontrivial_third_order_y[2] = 30586
    nontrivial_third_order_y[3] = 25586
    nontrivial_third_order_y[19] = 4225
    nontrivial_third_order_y[33] = 3849
    nontrivial_third_order_y[34] = 8966
    nontrivial_third_order_y[41] = 27546
    nontrivial_third_order_result = lift_to_third_order(
        nontrivial_third_order_y
    )
    assert nontrivial_third_order_result["exists"]
    assert nontrivial_third_order_result["obstruction"] == 0
    assert any(
        q != 0
        for q in nontrivial_third_order_result["third_order_corrections"]
    )
    assert len(
        third_order_generators(nontrivial_third_order_y)
    ) == _N_GENERATORS

    # Checked-in sample 158 is on the quadratic cone (so it reaches order
    # two) but the particular Step 3 lift fails the cached order-three solve.
    quadratic_samples = load(str(_QUADRATIC_SAMPLES_FILE))
    order3_obstructed_y = vector(K, list(quadratic_samples[158]))
    order3_obstructed_result = lift_to_third_order(order3_obstructed_y)
    assert not order3_obstructed_result["exists"]
    assert order3_obstructed_result["failed_order"] == 3
    assert order3_obstructed_result["obstruction"] != 0
    try:
        third_order_generators(order3_obstructed_y)
    except ValueError as error:
        assert "failed at order 3" in str(error)
    else:
        raise AssertionError("order-three obstructed direction lifted")

    print("sr_environment smoke test passed")


if __name__ == "__main__":
    _smoke_test()
