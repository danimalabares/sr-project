"""Check whether the nonzero fibres differ by a diagonal rescaling."""

load("serendipity/family.sage")

# For a term c*t^k*x^a of F_i, impose k + a.w - r_i = 0.
rows = []
right_hand_side = []
for generator_index, generator in enumerate(F):
    for exponents in generator.dict():
        exponents = tuple(ZZ(exponent) for exponent in exponents)
        row = list(exponents[1:]) + [0] * len(F)
        row[8 + generator_index] = -1
        rows.append(row)
        right_hand_side.append(-exponents[0])

weight_matrix = matrix(QQ, rows)
weight_rhs = vector(QQ, right_hand_side)
augmented = weight_matrix.augment(
    matrix(QQ, len(weight_rhs), 1, list(weight_rhs))
)
solution_exists = weight_matrix.rank() == augmented.rank()
assert solution_exists

rational_solution = weight_matrix.solve_right(weight_rhs)
kernel_basis = weight_matrix.right_kernel().basis()

# The one-dimensional ambiguity adds the ordinary cubic grading:
# add s to every variable weight and 3s to every generator weight.
assert len(kernel_basis) == 1
grading_shift = kernel_basis[0]
assert tuple(grading_shift[:8]) == (1,) * 8
assert tuple(grading_shift[8:]) == (3,) * 16

# This shift clears the denominators in the solver's chosen solution.
integer_solution = rational_solution + QQ(2) / 3 * grading_shift
assert weight_matrix * integer_solution == weight_rhs
integer_solution_exists = all(
    coefficient.denominator() == 1 for coefficient in integer_solution
)
assert integer_solution_exists

x_weights = tuple(ZZ(coefficient) for coefficient in integer_solution[:8])
generator_weights = tuple(
    ZZ(coefficient) for coefficient in integer_solution[8:]
)

# Verify F_i(u, u^w X) = u^r_i F_i(1, X) directly.  A Laurent ring is
# appropriate because the rescaling is asserted only over u != 0.
X_ring = PolynomialRing(K, ["X%d" % i for i in range(1, 9)])
X = X_ring.gens()
Laurent = LaurentPolynomialRing(X_ring, "u")
u = Laurent.gen()
for generator_index, generator in enumerate(F):
    transformed = Laurent.zero()
    fibre_at_one = X_ring.zero()
    for exponents, coefficient in generator.dict().items():
        exponents = tuple(ZZ(exponent) for exponent in exponents)
        x_monomial = prod(
            variable**exponent
            for variable, exponent in zip(X, exponents[1:])
        )
        transformed += Laurent(X_ring(coefficient) * x_monomial) * u**(
            exponents[0]
            + sum(
                exponent * weight
                for exponent, weight in zip(exponents[1:], x_weights)
            )
        )
        fibre_at_one += X_ring(coefficient) * x_monomial
    expected = u**generator_weights[generator_index] * Laurent(
        fibre_at_one
    )
    assert transformed == expected

rescaling_result = {
    "solution_exists": True,
    "integer_solution_exists": True,
    "rational_solution_only": False,
    "x_weights": x_weights,
    "generator_weights": generator_weights,
    "identities_verified": True,
}

if not globals().get("_SERENDIPITY_RESCALING_LIBRARY", False):
    print("Diagonal fibre rescaling: integer weights exist")
    print("variable weights: %s" % (x_weights,))
    print("generator weights: %s" % (generator_weights,))
    print("identities verified directly: True")
    print(
        "Integer weights give diagonal isomorphisms among all nonzero "
        "fibres."
    )
    print(
        "Rational weights would give such isomorphisms after a finite "
        "base change."
    )
    print(
        "Failure of this test would not prove that the fibres are "
        "non-isomorphic."
    )
    print(
        "Since the t=1 fibre is singular, its singularity persists "
        "geometrically on the generic fibre."
    )
