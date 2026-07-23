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


def _check_corrections_against_syzygies(corrections):
    """Check the cached syzygy rows for an already constructed correction."""
    for syzygy_index, row in enumerate(_syzygy_rows):
        residual = sum(
            (a_i * g_i for a_i, g_i in zip(row, corrections)),
            R.zero(),
        )
        normal_form = residual.reduce(_original_ideal)
        if normal_form != 0:
            raise ValueError(
                "first-order syzygy %d failed: residual=%s; "
                "normal form modulo I=%s"
                % (syzygy_index, residual, normal_form)
            )
    return True


def check_first_order_syzygies(y):
    """Verify all cached first syzygies for the T^1 direction y modulo I."""
    direction = y_to_direction(y)
    corrections = direction_to_corrections(direction)
    return _check_corrections_against_syzygies(corrections)


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


def lift_first_order_syzygies(y):
    """Return the 38 lifted coefficient rows (a_i + t*b_i)."""
    direction = y_to_direction(y)
    corrections = direction_to_corrections(direction)
    _check_corrections_against_syzygies(corrections)

    lifted_rows = []
    deformed_generators = tuple(
        R_t(f_i) + t * R_t(g_i)
        for f_i, g_i in zip(generators, corrections)
    )
    for syzygy_index, row in enumerate(_syzygy_rows):
        residual = sum(
            (a_i * g_i for a_i, g_i in zip(row, corrections)),
            R.zero(),
        )
        b = _lift_residual(residual)
        lifted_row = tuple(
            R_t(a_i) + t * R_t(b_i) for a_i, b_i in zip(row, b)
        )

        relation = sum(
            (coefficient * deformed_generator
             for coefficient, deformed_generator
             in zip(lifted_row, deformed_generators)),
            R_t.zero(),
        )
        residual_mod_t2 = R_t(relation[0]) + t * R_t(relation[1])
        if residual_mod_t2 != 0:
            raise RuntimeError(
                "constructed lift for syzygy %d failed modulo t^2: %s"
                % (syzygy_index, residual_mod_t2)
            )
        lifted_rows.append(lifted_row)
    return tuple(lifted_rows)


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

    assert check_first_order_syzygies(zero_y)
    for i in range(T1_DIM):
        standard_basis_vector = [0] * T1_DIM
        standard_basis_vector[i] = 1
        assert check_first_order_syzygies(standard_basis_vector)
        assert len(lift_first_order_syzygies(standard_basis_vector)) == 38

    invalid_direction = vector(K, RAW_DIM)
    invalid_direction[0] = 1
    try:
        _check_corrections_against_syzygies(
            direction_to_corrections(invalid_direction)
        )
    except ValueError:
        pass
    else:
        raise AssertionError("deliberately invalid raw correction passed")

    print("sr_environment smoke test passed")


if __name__ == "__main__":
    _smoke_test()
