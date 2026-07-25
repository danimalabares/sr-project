"""Test a projective fibre for smoothness over GF(32003)."""

import time

load("serendipity/family.sage")

S = PolynomialRing(K, ["x%d" % i for i in range(1, 9)], order="degrevlex")
X = S.gens()


def _specialize_fibre(polynomial, t_value):
    """Specialize t while preserving the frozen exponent convention."""
    t_value = K(t_value)
    result = S.zero()
    for exponents, coefficient in R(polynomial).dict().items():
        exponents = tuple(ZZ(exponent) for exponent in exponents)
        monomial = prod(
            variable**exponent
            for variable, exponent in zip(X, exponents[1:])
        )
        result += S(coefficient * t_value**exponents[0]) * monomial
    return result


def test_fibre_smoothness(t_value):
    """Return invariants and the projective Jacobian test at ``t_value``."""
    started = time.perf_counter()
    t_value = K(t_value)
    fibre_generators = tuple(
        _specialize_fibre(generator, t_value) for generator in F
    )
    fibre_ideal = S.ideal(fibre_generators)

    affine_dimension = fibre_ideal.dimension()
    projective_dimension = affine_dimension - 1
    codimension = S.ngens() - affine_dimension
    hilbert_series = fibre_ideal.hilbert_series()
    try:
        hilbert_polynomial = fibre_ideal.hilbert_polynomial()
        degree = (
            hilbert_polynomial.leading_coefficient()
            * factorial(projective_dimension)
        )
    except Exception:
        hilbert_polynomial = None
        degree = None

    assert 0 < codimension <= min(len(fibre_generators), S.ngens())
    jacobian = matrix(S, [
        [generator.derivative(variable) for variable in X]
        for generator in fibre_generators
    ])

    completed = False
    singular_locus_empty = None
    error_message = None
    try:
        # Rank < codimension is cut out by the codimension-sized minors.
        # Saturation removes the vertex of the affine cone.
        singular_ideal = fibre_ideal + S.ideal(
            jacobian.minors(codimension)
        )
        projective_singular_ideal, _ = singular_ideal.saturation(
            S.ideal(X)
        )
        singular_locus_empty = projective_singular_ideal.is_one()
        completed = True
    except Exception as error:
        error_message = str(error)

    return {
        "t_value": t_value,
        "affine_dimension": affine_dimension,
        "projective_dimension": projective_dimension,
        "codimension": codimension,
        "degree": degree,
        "hilbert_polynomial": hilbert_polynomial,
        "hilbert_series": hilbert_series,
        "projective_singular_locus_empty": singular_locus_empty,
        "smooth": singular_locus_empty if completed else None,
        "completed": completed,
        "error": error_message,
        "runtime": time.perf_counter() - started,
    }


def print_smoothness_result(result):
    """Print a compact human-readable summary."""
    print("Fibre tested: t=%s over GF(32003)" % result["t_value"])
    print("affine-cone dimension: %s" % result["affine_dimension"])
    print("projective dimension: %s" % result["projective_dimension"])
    print("codimension: %s" % result["codimension"])
    print("degree: %s" % result["degree"])
    print("Hilbert polynomial: %s" % result["hilbert_polynomial"])
    print(
        "projective singular locus empty: %s"
        % result["projective_singular_locus_empty"]
    )
    print("smooth: %s" % result["smooth"])
    print("runtime: %.6f seconds" % result["runtime"])
    if result["error"] is not None:
        print("smoothness calculation did not complete: %s" % result["error"])


if not globals().get("_SERENDIPITY_SMOOTHNESS_LIBRARY", False):
    print_smoothness_result(test_fibre_smoothness(1))
