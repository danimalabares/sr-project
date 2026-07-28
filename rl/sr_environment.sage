"""Reusable first-order deformation space for the Stanley--Reisner example."""

import pickle
import time
from pathlib import Path

from sage.all import GF, PolynomialRing, load, matrix, prod, vector


K = GF(32003)
T1_DIM = 53
RAW_DIM = 1664


def _find_repository_root():
    """Find cached legacy data without relying on Sage load() defining __file__."""
    starts = [Path.cwd().resolve()]
    try:
        starts.append(Path(__file__).resolve().parent)
    except NameError:
        pass
    candidates = []
    for start in starts:
        candidates.extend((start,) + tuple(start.parents))
    for candidate in candidates:
        if (
            (
                candidate
                / "old-code"
                / "cotangent"
                / "part-1.pkl"
            ).is_file()
            and (candidate / "rl").is_dir()
        ):
            return candidate
    raise RuntimeError(
        "could not locate the repository root; run Sage from the "
        "repository root or one of its subdirectories"
    )


_REPOSITORY_ROOT = _find_repository_root()
_RAW_DATA_FILE = (
    _REPOSITORY_ROOT
    / "old-code"
    / "cotangent"
    / "order2"
    / "cache"
    / "raw_obstruction_data.sobj"
)
_PART1_DATA_FILE = (
    _REPOSITORY_ROOT / "old-code" / "cotangent" / "part-1.pkl"
)
_QUADRATIC_SAMPLES_FILE = (
    _REPOSITORY_ROOT
    / "old-code"
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


_GENERATOR_CORRECTION_KERNEL_BASIS = None


def _generator_correction_kernel_basis():
    """Cache ker(B) in the 1664 raw generator-correction coordinates."""
    global _GENERATOR_CORRECTION_KERNEL_BASIS
    if _GENERATOR_CORRECTION_KERNEL_BASIS is None:
        basis = tuple(
            vector(K, list(direction))
            for direction in _second_order_matrix.right_kernel().basis()
        )
        assert all(
            _second_order_matrix * direction == 0 for direction in basis
        )
        assert len(basis) == RAW_DIM - _raw_data["rank_B"]
        _GENERATOR_CORRECTION_KERNEL_BASIS = basis
    return _GENERATOR_CORRECTION_KERNEL_BASIS


def second_order_lift_space(y):
    """Return the affine space of raw second-order generator corrections."""
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
            "obstruction": obstruction,
            "ambient_dimension": RAW_DIM,
            "dimension": None,
            "particular_raw": None,
            "kernel_basis_raw": (),
            "particular_corrections": None,
            "first_order_corrections": first_corrections,
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
    assert _second_order_matrix * second_direction == -order2_residual
    kernel_basis = _generator_correction_kernel_basis()
    second_corrections = direction_to_corrections(second_direction)
    deformed_generators = _verify_second_order_relations(
        first_corrections, second_corrections, first_syzygy_lifts
    )
    return {
        "exists": True,
        "obstruction": obstruction,
        "ambient_dimension": RAW_DIM,
        "dimension": len(kernel_basis),
        "particular_raw": second_direction,
        "kernel_basis_raw": kernel_basis,
        "particular_corrections": second_corrections,
        # Internal compatibility data reused by builders and verification.
        "first_order_corrections": first_corrections,
        "_first_syzygy_lifts": tuple(first_syzygy_lifts),
        "_residual_vector": order2_residual,
        "_generators": deformed_generators,
    }


def _raw_from_affine_parameters(space, parameters, label):
    """Evaluate a raw affine solution using exactly the advertised parameters."""
    if not space.get("exists", False):
        raise ValueError("%s lift space is empty" % label)
    parameters = list(parameters)
    dimension = space["dimension"]
    if len(parameters) != dimension:
        raise ValueError(
            "expected %d %s parameters, got %d"
            % (dimension, label, len(parameters))
        )
    raw = vector(K, list(space["particular_raw"]))
    for coefficient, direction in zip(
        parameters, space["kernel_basis_raw"]
    ):
        coefficient = K(coefficient)
        if coefficient:
            raw += coefficient * direction
    return raw


def second_order_corrections_from_parameters(space, parameters):
    """Evaluate h_0 + sum parameters[j]*kernel_basis[j] as 16 polynomials."""
    return direction_to_corrections(
        _raw_from_affine_parameters(space, parameters, "second-order")
    )


def second_order_generators_from_parameters(y, parameters):
    """Return f+t*g+t^2*h for the selected point of the second lift space."""
    space = second_order_lift_space(y)
    if not space["exists"]:
        raise ValueError(
            "direction is obstructed at second order: obstruction=%s"
            % space["obstruction"]
        )
    corrections = second_order_corrections_from_parameters(space, parameters)
    return _verify_second_order_relations(
        space["first_order_corrections"],
        corrections,
        space["_first_syzygy_lifts"],
    )


def lift_to_second_order(y):
    """Attempt to lift the T^1 direction y through order two."""
    space = second_order_lift_space(y)
    if not space["exists"]:
        return {
            "exists": False,
            "first_order_corrections": space["first_order_corrections"],
            "second_order_corrections": None,
            "generators": None,
            "obstruction": space["obstruction"],
        }

    return {
        "exists": True,
        "first_order_corrections": space["first_order_corrections"],
        "second_order_corrections": space["particular_corrections"],
        "generators": space["_generators"],
        "obstruction": space["obstruction"],
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


def _validated_second_order_result(y, second_order_corrections):
    """Validate supplied h exactly and package it for the order-three system."""
    coefficients = list(y)
    if len(coefficients) != T1_DIM:
        raise ValueError(
            "expected %d T^1 coefficients, got %d"
            % (T1_DIM, len(coefficients))
        )

    if second_order_corrections is None:
        return lift_to_second_order(coefficients)

    supplied = list(second_order_corrections)
    if len(supplied) != _N_GENERATORS:
        raise ValueError(
            "expected %d second-order correction polynomials, got %d"
            % (_N_GENERATORS, len(supplied))
        )
    supplied = tuple(R(correction) for correction in supplied)
    # This also rejects terms outside the documented 1664-coordinate span.
    _corrections_to_direction(supplied)

    second_space = second_order_lift_space(coefficients)
    if not second_space["exists"]:
        raise ValueError(
            "supplied corrections cannot lift a second-order obstruction: %s"
            % second_space["obstruction"]
        )
    try:
        deformed_generators = _verify_second_order_relations(
            second_space["first_order_corrections"],
            supplied,
            second_space["_first_syzygy_lifts"],
        )
    except RuntimeError as error:
        raise ValueError(
            "supplied corrections are not a valid second-order lift: %s"
            % error
        ) from error
    return {
        "exists": True,
        "first_order_corrections": second_space["first_order_corrections"],
        "second_order_corrections": supplied,
        "generators": deformed_generators,
        "obstruction": second_space["obstruction"],
    }


def third_order_lift_space(y, second_order_corrections=None):
    """Return the affine space of q extending the specified second-order h."""
    coefficients = list(y)
    if len(coefficients) != T1_DIM:
        raise ValueError(
            "expected %d T^1 coefficients, got %d"
            % (T1_DIM, len(coefficients))
        )

    second_order_result = _validated_second_order_result(
        coefficients, second_order_corrections
    )
    if not second_order_result["exists"]:
        return {
            "exists": False,
            "obstruction": second_order_result["obstruction"],
            "ambient_dimension": RAW_DIM,
            "dimension": None,
            "second_order_corrections": None,
            "particular_raw": None,
            "kernel_basis_raw": (),
            "particular_corrections": None,
            "first_order_corrections":
                second_order_result["first_order_corrections"],
            "failed_order": 2,
        }

    problem = _third_order_problem(second_order_result)
    third_direction, obstruction = _solve_third_order_problem(problem)
    if third_direction is None:
        return {
            "exists": False,
            "obstruction": obstruction,
            "ambient_dimension": RAW_DIM,
            "dimension": None,
            "second_order_corrections":
                second_order_result["second_order_corrections"],
            "particular_raw": None,
            "kernel_basis_raw": (),
            "particular_corrections": None,
            "first_order_corrections":
                second_order_result["first_order_corrections"],
            "failed_order": 3,
            "_problem": problem,
        }

    assert _second_order_matrix * third_direction == -problem["target"]
    kernel_basis = _generator_correction_kernel_basis()
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
        "obstruction": obstruction,
        "ambient_dimension": RAW_DIM,
        "dimension": len(kernel_basis),
        "second_order_corrections":
            second_order_result["second_order_corrections"],
        "particular_raw": third_direction,
        "kernel_basis_raw": kernel_basis,
        "particular_corrections": third_corrections,
        "first_order_corrections":
            second_order_result["first_order_corrections"],
        "failed_order": None,
        "_problem": problem,
        "_generators": deformed_generators,
    }


def third_order_corrections_from_parameters(space, parameters):
    """Evaluate q_0 + sum parameters[j]*kernel_basis[j] as 16 polynomials."""
    return direction_to_corrections(
        _raw_from_affine_parameters(space, parameters, "third-order")
    )


def third_order_generators_from_parameters(
    y, second_order_corrections, third_order_parameters
):
    """Return f+t*g+t^2*h+t^3*q for selected second/third lift data."""
    space = third_order_lift_space(y, second_order_corrections)
    if not space["exists"]:
        raise ValueError(
            "chosen second-order lift does not extend to third order: "
            "obstruction=%s" % space["obstruction"]
        )
    third_corrections = third_order_corrections_from_parameters(
        space, third_order_parameters
    )
    problem = space["_problem"]
    return _verify_third_order_relations(
        space["first_order_corrections"],
        space["second_order_corrections"],
        third_corrections,
        problem["alpha_rows"],
        problem["beta_rows"],
    )


def lift_to_third_order(y):
    """Attempt to extend Step 3's particular second-order lift to order three."""
    space = third_order_lift_space(y)
    if not space["exists"]:
        return {
            "exists": False,
            "first_order_corrections": space["first_order_corrections"],
            "second_order_corrections":
                space["second_order_corrections"],
            "third_order_corrections": None,
            "generators": None,
            "obstruction": space["obstruction"],
            "failed_order": space["failed_order"],
        }
    return {
        "exists": True,
        "first_order_corrections": space["first_order_corrections"],
        "second_order_corrections": space["second_order_corrections"],
        "third_order_corrections": space["particular_corrections"],
        "generators": space["_generators"],
        "obstruction": space["obstruction"],
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


def build_cubic_candidate(
    y, second_order_parameters=None, third_order_parameters=None
):
    """Build a cubic candidate from explicit affine lift-space parameters."""
    coefficients = list(y)
    if len(coefficients) != T1_DIM:
        raise ValueError(
            "expected %d T^1 coefficients, got %d"
            % (T1_DIM, len(coefficients))
        )
    y_vector = vector(K, coefficients)
    second_space = second_order_lift_space(y_vector)
    if not second_space["exists"]:
        return {
            "exists": False,
            "y": y_vector,
            "second_order_space_dimension": None,
            "third_order_space_dimension": None,
            "second_order_parameters": None,
            "third_order_parameters": None,
            "first_order_corrections":
                second_space["first_order_corrections"],
            "second_order_corrections": None,
            "third_order_corrections": None,
            "generators": None,
            "obstruction": second_space["obstruction"],
            "failed_order": 2,
        }

    if second_order_parameters is None:
        second_order_parameters = [0] * second_space["dimension"]
    second_order_parameters = tuple(
        K(parameter) for parameter in second_order_parameters
    )
    second_corrections = second_order_corrections_from_parameters(
        second_space, second_order_parameters
    )
    third_space = third_order_lift_space(y_vector, second_corrections)
    if not third_space["exists"]:
        return {
            "exists": False,
            "y": y_vector,
            "second_order_space_dimension": second_space["dimension"],
            "third_order_space_dimension": None,
            "second_order_parameters": second_order_parameters,
            "third_order_parameters": None,
            "first_order_corrections":
                second_space["first_order_corrections"],
            "second_order_corrections": second_corrections,
            "third_order_corrections": None,
            "generators": None,
            "obstruction": third_space["obstruction"],
            "failed_order": 3,
        }

    if third_order_parameters is None:
        third_order_parameters = [0] * third_space["dimension"]
    third_order_parameters = tuple(
        K(parameter) for parameter in third_order_parameters
    )
    third_corrections = third_order_corrections_from_parameters(
        third_space, third_order_parameters
    )
    problem = third_space["_problem"]
    deformed_generators = _verify_third_order_relations(
        third_space["first_order_corrections"],
        second_corrections,
        third_corrections,
        problem["alpha_rows"],
        problem["beta_rows"],
    )
    return {
        "exists": True,
        "y": y_vector,
        "second_order_space_dimension": second_space["dimension"],
        "third_order_space_dimension": third_space["dimension"],
        "second_order_parameters": second_order_parameters,
        "third_order_parameters": third_order_parameters,
        "first_order_corrections":
            second_space["first_order_corrections"],
        "second_order_corrections": second_corrections,
        "third_order_corrections": third_corrections,
        "generators": deformed_generators,
        "obstruction": third_space["obstruction"],
        "failed_order": None,
    }


_LOW_DEGREE_MONOMIAL_CACHE = {}


def _degree_exponent_tuples(nvars, degree):
    """Return all exponent tuples of a fixed total degree."""
    if nvars == 1:
        return [(degree,)]
    tuples = []
    for first_exponent in range(degree + 1):
        for rest in _degree_exponent_tuples(nvars - 1, degree - first_exponent):
            tuples.append((first_exponent,) + rest)
    return tuples


def _low_degree_basis_data(degree):
    """Cache multiplier/target monomials and target-column indices."""
    degree = int(degree)
    if degree < 3:
        raise ValueError("flatness diagnostic degrees must be at least 3")
    if degree not in _LOW_DEGREE_MONOMIAL_CACHE:
        multipliers = tuple(_degree_exponent_tuples(len(_x), degree - 3))
        columns = tuple(_degree_exponent_tuples(len(_x), degree))
        _LOW_DEGREE_MONOMIAL_CACHE[degree] = {
            "multipliers": multipliers,
            "columns": columns,
            "column_index": {
                exponents: index for index, exponents in enumerate(columns)
            },
        }
    return _LOW_DEGREE_MONOMIAL_CACHE[degree]


def _parse_cubic_generators(cubic_generators):
    """Coerce generators to R[t] and record sparse (t-degree, x-exp, coeff)."""
    cubic_generators = tuple(cubic_generators)
    if len(cubic_generators) != _N_GENERATORS:
        raise ValueError(
            "expected %d cubic generators, got %d"
            % (_N_GENERATORS, len(cubic_generators))
        )

    parsed = []
    coerced = []
    for generator_index, candidate in enumerate(cubic_generators):
        try:
            candidate = R_t(candidate)
        except (TypeError, ValueError) as error:
            raise ValueError(
                "generator %d does not coerce into %s"
                % (generator_index, R_t)
            ) from error
        if candidate == 0:
            raise ValueError("generator %d is zero, not a cubic" % generator_index)

        terms = []
        for t_degree, x_polynomial in enumerate(candidate.list()):
            for x_exponents, coefficient in R(x_polynomial).dict().items():
                x_exponents = tuple(int(e) for e in x_exponents)
                if sum(x_exponents) != 3:
                    raise ValueError(
                        "generator %d has a term of x-degree %d, expected 3"
                        % (generator_index, sum(x_exponents))
                    )
                coefficient = K(coefficient)
                if coefficient:
                    terms.append((t_degree, x_exponents, coefficient))
        parsed.append(tuple(terms))
        coerced.append(candidate)
    return tuple(coerced), tuple(parsed)


def _evaluated_generator_terms(parsed_generators, t_value, base_ring):
    """Evaluate t in the sparse generator representation."""
    evaluated = []
    t_value = base_ring(t_value)
    for generator_terms in parsed_generators:
        x_terms = {}
        for t_degree, x_exponents, coefficient in generator_terms:
            value = base_ring(coefficient) * t_value**t_degree
            if value:
                x_terms[x_exponents] = (
                    x_terms.get(x_exponents, base_ring.zero()) + value
                )
        evaluated.append({
            exponents: coefficient
            for exponents, coefficient in x_terms.items()
            if coefficient
        })
    return evaluated


def _low_degree_flatness_matrix(parsed_generators, degree, t_value, base_ring=K):
    """Build A_d(t_value) directly from exponent tuples."""
    basis = _low_degree_basis_data(degree)
    multipliers = basis["multipliers"]
    column_index = basis["column_index"]
    evaluated = _evaluated_generator_terms(
        parsed_generators, t_value, base_ring
    )

    entries = {}
    row = 0
    for generator_terms in evaluated:
        for multiplier in multipliers:
            for generator_exponents, coefficient in generator_terms.items():
                product_exponents = tuple(
                    a + b
                    for a, b in zip(multiplier, generator_exponents)
                )
                column = column_index[product_exponents]
                key = (row, column)
                entries[key] = entries.get(key, base_ring.zero()) + coefficient
                if entries[key] == 0:
                    del entries[key]
            row += 1
    return matrix(
        base_ring,
        _N_GENERATORS * len(multipliers),
        len(basis["columns"]),
        entries,
        sparse=True,
    )


def low_degree_flatness_diagnostic(
    cubic_generators,
    degrees=(4, 5),
    sample_t_values=(1, 2, 3),
):
    """Score sampled low-degree rank jumps; this does not certify flatness."""
    _, parsed_generators = _parse_cubic_generators(cubic_generators)
    degrees = tuple(int(degree) for degree in degrees)
    if not degrees:
        raise ValueError("at least one diagnostic degree is required")

    sample_values = tuple(K(value) for value in sample_t_values)
    if not sample_values:
        raise ValueError("at least one nonzero t sample is required")
    if any(value == 0 for value in sample_values):
        raise ValueError("sample_t_values must not contain zero")

    degree_results = {}
    total_defect = 0
    for degree in degrees:
        basis = _low_degree_basis_data(degree)
        special_rank = _low_degree_flatness_matrix(
            parsed_generators, degree, K.zero()
        ).rank()
        sampled_ranks = {
            value: _low_degree_flatness_matrix(
                parsed_generators, degree, value
            ).rank()
            for value in sample_values
        }
        sampled_generic_rank = max(sampled_ranks.values())
        defect = sampled_generic_rank - special_rank
        degree_results[degree] = {
            "row_count": _N_GENERATORS * len(basis["multipliers"]),
            "column_count": len(basis["columns"]),
            "special_rank": special_rank,
            "sampled_ranks": sampled_ranks,
            "sampled_generic_rank": sampled_generic_rank,
            "defect": defect,
        }
        total_defect += defect

    return {
        "degrees": degree_results,
        "total_defect": total_defect,
        "score": -total_defect,
        "passes_sampled_test": total_defect == 0,
    }


def low_degree_flatness_score(
    y,
    degrees=(4, 5),
    sample_t_values=(1, 2, 3),
):
    """Lift y cubically, then run the sampled low-degree rank diagnostic."""
    return low_degree_flatness_diagnostic(
        third_order_generators(y),
        degrees=degrees,
        sample_t_values=sample_t_values,
    )


def _exact_low_degree_rank(cubic_generators, degree):
    """Validation-only rank of A_d over K(u), not used by the search score."""
    _, parsed_generators = _parse_cubic_generators(cubic_generators)
    parameter_ring = PolynomialRing(K, "u")
    rational_function_field = parameter_ring.fraction_field()
    u = rational_function_field(parameter_ring.gen())
    return _low_degree_flatness_matrix(
        parsed_generators,
        degree,
        u,
        base_ring=rational_function_field,
    ).rank()


_EXACT_RING = PolynomialRing(
    K, ["t"] + ["x%d" % i for i in range(1, 9)], order="degrevlex"
)
_exact_t = _EXACT_RING.gen(0)
_exact_x = _EXACT_RING.gens()[1:]
_EXACT_SPECIAL_RING = PolynomialRing(
    K, ["x%d" % i for i in range(1, 9)], order="degrevlex"
)
_exact_special_x = _EXACT_SPECIAL_RING.gens()


def _monomial_from_exponents(ring_variables, exponents):
    return prod(
        variable**int(exponent)
        for variable, exponent in zip(ring_variables, exponents)
    )


def _build_exact_family_ideal(cubic_generators):
    """Coerce validated R[t] cubics into K[t,x1,...,x8]."""
    _, parsed_generators = _parse_cubic_generators(cubic_generators)
    exact_generators = []
    for generator_terms in parsed_generators:
        exact_generator = _EXACT_RING.zero()
        for t_degree, x_exponents, coefficient in generator_terms:
            exact_generator += (
                _EXACT_RING(coefficient)
                * _exact_t**t_degree
                * _monomial_from_exponents(_exact_x, x_exponents)
            )
        exact_generators.append(exact_generator)
    return tuple(exact_generators), _EXACT_RING.ideal(exact_generators)


def _specialize_exact_ideal_at_t_zero(exact_ideal):
    """Specialize generators of an exact family ideal at t=0."""
    specialized_generators = []
    for generator in exact_ideal.gens():
        specialized = _EXACT_SPECIAL_RING.zero()
        for exponents, coefficient in _EXACT_RING(generator).dict().items():
            exponents = tuple(int(e) for e in exponents)
            if exponents[0] == 0:
                specialized += (
                    _EXACT_SPECIAL_RING(coefficient)
                    * _monomial_from_exponents(
                        _exact_special_x, exponents[1:]
                    )
                )
        specialized_generators.append(specialized)
    return _EXACT_SPECIAL_RING.ideal(specialized_generators)


def _exact_special_sr_ideal():
    return _EXACT_SPECIAL_RING.ideal([
        _monomial_from_exponents(_exact_special_x, exponents)
        for exponents in _generator_exponents
    ])


def _verified_torsion_witness(ideal, colon_by_t):
    """Find and verify u in (J:t)\\J with t*u in J."""
    ideal_groebner_basis = ideal.groebner_basis()
    for colon_generator in colon_by_t.gens():
        witness = _EXACT_RING(colon_generator).reduce(ideal_groebner_basis)
        if witness == 0:
            continue
        if _EXACT_RING(_exact_t * witness).reduce(ideal_groebner_basis) != 0:
            continue
        return witness
    raise RuntimeError("J:t differs from J but no verified torsion witness found")


def exact_flatness_diagnostic(cubic_generators, analyze_failure=False):
    """Test J:t=J exactly; optional analysis saturates and compares fibres."""
    timings = {}

    started = time.perf_counter()
    exact_generators, ideal = _build_exact_family_ideal(cubic_generators)
    timings["construction_seconds"] = time.perf_counter() - started

    started = time.perf_counter()
    colon_by_t = ideal.quotient(_EXACT_RING.ideal(_exact_t))
    t_saturated = colon_by_t == ideal
    timings["colon_seconds"] = time.perf_counter() - started

    torsion_witness = None
    if not t_saturated:
        started = time.perf_counter()
        torsion_witness = _verified_torsion_witness(ideal, colon_by_t)
        timings["witness_seconds"] = time.perf_counter() - started
    else:
        timings["witness_seconds"] = 0.0

    result = {
        "flat": t_saturated,
        "t_saturated": t_saturated,
        "torsion_witness": torsion_witness,
        "ideal": ideal,
        "colon_by_t": colon_by_t,
        "timings": timings,
    }

    if analyze_failure and not t_saturated:
        started = time.perf_counter()
        saturation = ideal
        next_colon = colon_by_t
        saturation_steps = 0
        while next_colon != saturation:
            saturation = next_colon
            saturation_steps += 1
            next_colon = saturation.quotient(_EXACT_RING.ideal(_exact_t))

        special_fibre = _specialize_exact_ideal_at_t_zero(saturation)
        sr_ideal = _exact_special_sr_ideal()
        sr_in_special = all(
            generator in special_fibre for generator in sr_ideal.gens()
        )
        special_in_sr = all(
            generator in sr_ideal for generator in special_fibre.gens()
        )

        sr_groebner_basis = sr_ideal.groebner_basis()
        extra_equations = []
        for generator in special_fibre.gens():
            remainder = _EXACT_SPECIAL_RING(generator).reduce(
                sr_groebner_basis
            )
            if remainder != 0 and remainder not in extra_equations:
                extra_equations.append(remainder)

        timings["failure_analysis_seconds"] = (
            time.perf_counter() - started
        )
        result.update({
            "saturation": saturation,
            "saturation_steps": saturation_steps,
            "special_fibre": special_fibre,
            "special_fibre_equal": sr_in_special and special_in_sr,
            "sr_in_special_fibre": sr_in_special,
            "special_fibre_in_sr": special_in_sr,
            "extra_special_fibre_equations": tuple(extra_equations),
            "extra_equation_count": len(extra_equations),
        })

    return result


def exact_flatness_score(y, analyze_failure=False):
    """Lift y cubically and apply the exact J:t=J diagnostic unchanged."""
    return exact_flatness_diagnostic(
        third_order_generators(y),
        analyze_failure=analyze_failure,
    )


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
    second_space = second_order_lift_space(known_liftable)
    assert second_space["ambient_dimension"] == RAW_DIM
    assert second_space["dimension"] == len(
        second_space["kernel_basis_raw"]
    )
    assert (
        _second_order_matrix * second_space["particular_raw"]
        == -second_space["_residual_vector"]
    )
    assert all(
        _second_order_matrix * kernel_direction == 0
        for kernel_direction in second_space["kernel_basis_raw"]
    )
    zero_second_parameters = [0] * second_space["dimension"]
    assert second_order_corrections_from_parameters(
        second_space, zero_second_parameters
    ) == liftable_result["second_order_corrections"]

    second_basis = second_space["kernel_basis_raw"]
    assert second_basis[0] != second_basis[1]
    for _ in range(3):
        first_parameter = K.random_element()
        second_parameter = K.random_element()
        raw = (
            second_space["particular_raw"]
            + K(first_parameter) * second_basis[0]
            + K(second_parameter) * second_basis[1]
        )
        assert (
            _second_order_matrix * raw
            == -second_space["_residual_vector"]
        )
    varied_second_parameters = list(zero_second_parameters)
    varied_second_parameters[0] = 1
    varied_second_corrections = second_order_corrections_from_parameters(
        second_space, varied_second_parameters
    )
    _verify_second_order_relations(
        second_space["first_order_corrections"],
        varied_second_corrections,
        second_space["_first_syzygy_lifts"],
    )

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

    # Exercise the generic order-three API on a simple basis direction.
    third_order_liftable_y = vector(K, T1_DIM)
    third_order_liftable_y[0] = 1
    third_order_liftable_result = lift_to_third_order(
        third_order_liftable_y
    )
    assert third_order_liftable_result["exists"]
    assert third_order_liftable_result["obstruction"] == 0
    assert len(
        third_order_generators(third_order_liftable_y)
    ) == _N_GENERATORS
    third_space = third_order_lift_space(
        third_order_liftable_y,
        third_order_liftable_result["second_order_corrections"],
    )
    assert third_space["ambient_dimension"] == RAW_DIM
    assert third_space["dimension"] == len(
        third_space["kernel_basis_raw"]
    )
    assert (
        _second_order_matrix * third_space["particular_raw"]
        == -third_space["_problem"]["target"]
    )
    assert third_space["kernel_basis_raw"] is second_basis
    zero_third_parameters = [0] * third_space["dimension"]
    assert third_order_corrections_from_parameters(
        third_space, zero_third_parameters
    ) == third_order_liftable_result["third_order_corrections"]
    for _ in range(3):
        first_parameter = K.random_element()
        second_parameter = K.random_element()
        raw = (
            third_space["particular_raw"]
            + K(first_parameter) * third_space["kernel_basis_raw"][0]
            + K(second_parameter) * third_space["kernel_basis_raw"][1]
        )
        assert (
            _second_order_matrix * raw
            == -third_space["_problem"]["target"]
        )
    varied_third_parameters = list(zero_third_parameters)
    varied_third_parameters[0] = 1
    third_order_generators_from_parameters(
        third_order_liftable_y,
        third_space["second_order_corrections"],
        varied_third_parameters,
    )
    cubic_candidate = build_cubic_candidate(third_order_liftable_y)
    assert cubic_candidate["exists"]
    assert cubic_candidate["second_order_space_dimension"] == len(second_basis)
    assert cubic_candidate["third_order_space_dimension"] == len(second_basis)
    second_obstructed_candidate = build_cubic_candidate(known_obstructed)
    assert not second_obstructed_candidate["exists"]
    assert second_obstructed_candidate["failed_order"] == 2

    # Checked-in sample 158 is on the quadratic cone (so it reaches order
    # two) but the particular Step 3 lift fails the cached order-three solve.
    quadratic_samples = load(str(_QUADRATIC_SAMPLES_FILE))
    order3_obstructed_y = vector(K, list(quadratic_samples[158]))
    order3_obstructed_result = lift_to_third_order(order3_obstructed_y)
    assert not order3_obstructed_result["exists"]
    assert order3_obstructed_result["failed_order"] == 3
    assert order3_obstructed_result["obstruction"] != 0
    third_obstructed_candidate = build_cubic_candidate(order3_obstructed_y)
    assert not third_obstructed_candidate["exists"]
    assert third_obstructed_candidate["failed_order"] == 3
    try:
        third_order_generators(order3_obstructed_y)
    except ValueError as error:
        assert "failed at order 3" in str(error)
    else:
        raise AssertionError("order-three obstructed direction lifted")

    trivial_flatness_sample = low_degree_flatness_score(
        vector(K, T1_DIM),
        degrees=(4,),
        sample_t_values=(1,),
    )
    assert trivial_flatness_sample["total_defect"] == 0
    assert trivial_flatness_sample["score"] == 0
    assert trivial_flatness_sample["passes_sampled_test"]
    assert trivial_flatness_sample["degrees"][4]["row_count"] == 128
    assert trivial_flatness_sample["degrees"][4]["column_count"] == 330

    print("sr_environment smoke test passed")


if (
    __name__ == "__main__"
    and not globals().get("_SR_ENVIRONMENT_SKIP_SMOKE", False)
):
    _smoke_test()
