"""Verify deterministic polynomial lifts of first-order syzygy residuals.

Starting only from the foundation pickle, reconstruct a deterministic basis of
T^1_0.  For every basis direction g and every first syzygy s, decompose
sum_j s_j g_j in the monomial ideal I and verify the resulting exact lift.
"""

import pickle
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
FOUNDATION_DATA = REPO_ROOT / "foundations" / "part-1.pkl"

with FOUNDATION_DATA.open("rb") as foundation_file:
    data = pickle.load(foundation_file)

R = data["R"]
I = data["I"]
syzygies = data["syz"]
parameter_ring = data["R_param"]
parameter_names = data["def_params"]
syzygy_coefficients = data["all_coeffs"]
standard_cubics = [R(monomial) for monomial in data["nonzero_monomials"]]

x = R.gens()
generators = list(I.gens())
parameters = [parameter_ring(name) for name in parameter_names]
n_generators = len(generators)
n_monomials = len(standard_cubics)
n_parameters = len(parameters)

assert n_generators == 16
assert syzygies.nrows() == 38
assert syzygies.ncols() == n_generators
assert n_monomials == 104
assert n_parameters == n_generators * n_monomials == 1664
assert all(
    sum(
        (R(syzygies[row, column]) * generators[column]
         for column in range(n_generators)),
        R.zero(),
    ) == 0
    for row in range(syzygies.nrows())
)


# Linearized evaluation of the 38 first syzygies on raw cubic corrections.
nonzero_equations = [
    parameter_ring(coefficient)
    for coefficient in syzygy_coefficients
    if parameter_ring(coefficient) != 0
]
B = matrix(QQ, [
    [equation.monomial_coefficient(parameter) for parameter in parameters]
    for equation in nonzero_equations
], sparse=True)
hom_space = B.right_kernel()

assert B.nrows() == 4484
assert B.ncols() == 1664
assert B.rank() == 1555
assert hom_space.dimension() == 109


# Degree-zero coordinate changes delta_ij(x_i) = x_j.
monomial_index = {
    monomial: index for index, monomial in enumerate(standard_cubics)
}
derivation_rows = []
for i in range(len(x)):
    for j in range(len(x)):
        direction = [QQ.zero()] * n_parameters
        for generator_index, generator in enumerate(generators):
            image = R(generator.derivative(x[i]) * x[j]).reduce(I)
            for exponent, coefficient in image.dict().items():
                monomial = R.monomial(*exponent)
                index = (
                    generator_index * n_monomials + monomial_index[monomial]
                )
                direction[index] += QQ(coefficient)
        derivation_rows.append(direction)

D = matrix(QQ, derivation_rows, sparse=True)
derivation_space = D.row_space()

assert D.nrows() == 64
assert D.ncols() == 1664
assert D.rank() == 56
assert (B * D.transpose()).is_zero()


# Scan canonical echelon bases to obtain a deterministic complement to the
# derivation image inside Hom_S(I,S/I)_0.
derivation_basis = list(derivation_space.basis())
hom_basis = list(hom_space.basis())
candidate_rows = matrix(QQ, derivation_basis + hom_basis, sparse=True)
independent_row_indices = candidate_rows.transpose().pivots()
t1_basis = [
    hom_basis[index - len(derivation_basis)]
    for index in independent_row_indices
    if index >= len(derivation_basis)
]

assert len(t1_basis) == 53
assert len(independent_row_indices) == 109


def direction_to_corrections(direction):
    """Convert 1664 raw coordinates into one cubic correction per generator."""
    corrections = []
    for generator_index in range(n_generators):
        block_start = generator_index * n_monomials
        correction = sum(
            (direction[block_start + monomial_index] * monomial
             for monomial_index, monomial in enumerate(standard_cubics)),
            R.zero(),
        )
        corrections.append(R(correction))
    return corrections


def syzygy_residual(syzygy_index, corrections):
    return sum(
        (R(syzygies[syzygy_index, generator_index])
         * corrections[generator_index]
         for generator_index in range(n_generators)),
        R.zero(),
    )


def monomial_lift(residual, reverse=False):
    """Find alpha with residual + sum_j alpha_j*f_j = 0.

    Each residual monomial is assigned to the first (or last) generator in
    the certified generator order that divides it.
    """
    alpha = [R.zero() for _ in generators]
    divisor_indices = list(range(n_generators))
    if reverse:
        divisor_indices.reverse()

    for exponent, coefficient in sorted(residual.dict().items()):
        monomial = R.monomial(*exponent)
        for generator_index in divisor_indices:
            generator = generators[generator_index]
            if generator.divides(monomial):
                alpha[generator_index] -= (
                    QQ(coefficient) * (monomial // generator)
                )
                break
        else:
            raise RuntimeError(
                "residual monomial is not in I: %s" % monomial
            )
    return alpha


def lift_identity(residual, alpha):
    return residual + sum(
        (coefficient * generator
         for coefficient, generator in zip(alpha, generators)),
        R.zero(),
    )


def quadratic_residual(alpha, corrections):
    return sum(
        (coefficient * correction
         for coefficient, correction in zip(alpha, corrections)),
        R.zero(),
    ).reduce(I)


pair_count = 0
nonzero_polynomial_residuals = 0
nonzero_reduced_quadratic_residuals = 0
first_nonzero_residual = None
first_nonzero_quadratic_residual = None

for direction_index, direction in enumerate(t1_basis):
    corrections = direction_to_corrections(direction)
    assert B * direction == 0

    for syzygy_index in range(syzygies.nrows()):
        pair_count += 1
        residual = syzygy_residual(syzygy_index, corrections)
        assert residual.reduce(I) == 0

        alpha_first = monomial_lift(residual, reverse=False)
        alpha_last = monomial_lift(residual, reverse=True)

        assert lift_identity(residual, alpha_first) == 0
        assert lift_identity(residual, alpha_last) == 0

        q_first = quadratic_residual(alpha_first, corrections)
        q_last = quadratic_residual(alpha_last, corrections)
        assert q_first == q_last

        if residual != 0:
            nonzero_polynomial_residuals += 1
            if first_nonzero_residual is None:
                first_nonzero_residual = {
                    "direction_index": direction_index,
                    "syzygy_index": syzygy_index,
                    "corrections": corrections,
                    "residual": residual,
                    "alpha_first": alpha_first,
                    "alpha_last": alpha_last,
                    "q": q_first,
                }

        if q_first != 0:
            nonzero_reduced_quadratic_residuals += 1
            if first_nonzero_quadratic_residual is None:
                first_nonzero_quadratic_residual = {
                    "direction_index": direction_index,
                    "syzygy_index": syzygy_index,
                    "corrections": corrections,
                    "residual": residual,
                    "alpha_first": alpha_first,
                    "alpha_last": alpha_last,
                    "q": q_first,
                }


assert pair_count == 53 * 38 == 2014

print("Linear data")
print("-----------")
print("B size =", B.nrows(), "x", B.ncols())
print("rank B =", B.rank())
print("dim ker B =", hom_space.dimension())
print("derivation matrix size =", D.nrows(), "x", D.ncols())
print("rank derivation image =", D.rank())
print("deterministic T^1 complement dimension =", len(t1_basis))
print()

print("Lift verification")
print("-----------------")
print("direction-syzygy pairs checked =", pair_count)
print("nonzero polynomial residuals r_s =", nonzero_polynomial_residuals)
print(
    "exact first-divisor identities verified =",
    pair_count,
)
print(
    "exact last-divisor identities verified =",
    pair_count,
)
print(
    "equal reduced q_s for first/last divisors =",
    pair_count,
)
print(
    "nonzero reduced diagonal q_s =",
    nonzero_reduced_quadratic_residuals,
)
print()


def print_example(title, example):
    print(title)
    print("-" * len(title))
    if example is None:
        print("none")
        print()
        return
    print("T^1 direction index =", example["direction_index"])
    print("syzygy row index =", example["syzygy_index"])
    print(
        "nonzero g_j =",
        [(index + 1, correction)
         for index, correction in enumerate(example["corrections"])
         if correction != 0],
    )
    print("r_s =", example["residual"])
    print(
        "first-divisor alpha =",
        [(index + 1, coefficient)
         for index, coefficient in enumerate(example["alpha_first"])
         if coefficient != 0],
    )
    print(
        "last-divisor alpha =",
        [(index + 1, coefficient)
         for index, coefficient in enumerate(example["alpha_last"])
         if coefficient != 0],
    )
    print("q_s mod I =", example["q"])
    print()


print_example("First nonzero polynomial residual", first_nonzero_residual)
print_example(
    "First nonzero reduced diagonal quadratic residual",
    first_nonzero_quadratic_residual,
)

print("SUCCESS: all deterministic first-syzygy lift checks passed.")
