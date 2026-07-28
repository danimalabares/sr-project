"""Projective smoothness test for a frozen historical branch family."""

import time

load("serendipity/y8-y20-branch/family.sage")


def test_family_smoothness(y8_coefficient, y20_coefficient, t_value=1):
    started = time.perf_counter()
    family = load_family(y8_coefficient, y20_coefficient)
    K_local = family["K"]
    R_local = family["R"]
    t_local = family["t"]
    S = PolynomialRing(
        K_local, ["x%d" % i for i in range(8)], order="degrevlex"
    )
    X = S.gens()
    t_value = K_local(t_value)

    fibre_generators = []
    for generator in family["generators"]:
        polynomial = S.zero()
        for exponents, coefficient in R_local(generator).dict().items():
            exponents = tuple(ZZ(exponent) for exponent in exponents)
            polynomial += S(coefficient * t_value**exponents[0]) * prod(
                variable**exponent
                for variable, exponent in zip(X, exponents[1:])
            )
        fibre_generators.append(polynomial)
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
    singular_ideal = fibre_ideal + S.ideal(
        jacobian.minors(codimension)
    )
    projective_singular_ideal, _ = singular_ideal.saturation(S.ideal(X))
    singular_locus_empty = projective_singular_ideal.is_one()
    return {
        "pair": family["pair"],
        "t_value": t_value,
        "affine_dimension": affine_dimension,
        "projective_dimension": projective_dimension,
        "codimension": codimension,
        "degree": degree,
        "hilbert_polynomial": hilbert_polynomial,
        "hilbert_series": hilbert_series,
        "singular_locus_empty": singular_locus_empty,
        "smooth": singular_locus_empty,
        "runtime": time.perf_counter() - started,
    }
