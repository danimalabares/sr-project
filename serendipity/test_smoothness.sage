"""Test the projective t=1 fibre for smoothness over GF(32003)."""

import time

load("serendipity/family.sage")

S = PolynomialRing(
    K, ["x%d" % i for i in range(1, 9)], order="degrevlex"
)
X = S.gens()


def specialize_t_one(polynomial):
    result = S.zero()
    for exponents, coefficient in R(polynomial).dict().items():
        exponents = tuple(int(exponent) for exponent in exponents)
        monomial = prod(
            variable**exponent
            for variable, exponent in zip(X, exponents[1:])
        )
        result += S(coefficient) * monomial
    return result


F1 = tuple(specialize_t_one(generator) for generator in F)
J1 = S.ideal(F1)

invariants_started = time.perf_counter()
affine_dimension = J1.dimension()
projective_dimension = affine_dimension - 1
codimension = S.ngens() - affine_dimension
hilbert_series = J1.hilbert_series()
try:
    hilbert_polynomial = J1.hilbert_polynomial()
    degree = (
        hilbert_polynomial.leading_coefficient()
        * factorial(projective_dimension)
    )
except Exception:
    hilbert_polynomial = None
    degree = None
invariants_seconds = time.perf_counter() - invariants_started

assert codimension > 0
assert codimension <= min(len(F1), S.ngens())

jacobian = matrix(S, [
    [generator.derivative(variable) for variable in X]
    for generator in F1
])

smoothness_completed = False
projective_singular_locus_empty = None
smoothness_error = None
smoothness_started = time.perf_counter()
try:
    # For an affine cone of codimension c, rank(Jacobian) < c is cut out by
    # the c-by-c minors.  Saturating by the irrelevant ideal removes the
    # cone vertex before interpreting the result projectively.
    jacobian_minors = jacobian.minors(codimension)
    singular_ideal = J1 + S.ideal(jacobian_minors)
    irrelevant_ideal = S.ideal(X)
    projective_singular_ideal, _ = singular_ideal.saturation(
        irrelevant_ideal
    )
    projective_singular_locus_empty = projective_singular_ideal.is_one()
    smoothness_completed = True
except Exception as error:
    smoothness_error = str(error)
smoothness_seconds = time.perf_counter() - smoothness_started

print("Fibre tested: t=1 over GF(32003)")
print("affine-cone dimension: %s" % affine_dimension)
print("projective dimension: %s" % projective_dimension)
print("codimension: %s" % codimension)
print("degree: %s" % degree)
print("Hilbert series: %s" % hilbert_series)
print("Hilbert polynomial: %s" % hilbert_polynomial)
print("invariants runtime: %.6f seconds" % invariants_seconds)
print("Jacobian minor size: %d" % codimension)
print(
    "projective singular locus empty: %s"
    % projective_singular_locus_empty
)
print(
    "smooth: %s"
    % (
        projective_singular_locus_empty
        if smoothness_completed
        else "not determined"
    )
)
print("smoothness runtime: %.6f seconds" % smoothness_seconds)
if smoothness_error is not None:
    print("smoothness calculation did not complete: %s" % smoothness_error)
