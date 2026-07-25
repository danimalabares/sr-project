"""Analyze the projective singular locus of the frozen fibre at t=1."""

import time
from pathlib import Path

load("serendipity/family.sage")

S = PolynomialRing(K, ["x%d" % i for i in range(1, 9)], order="degrevlex")
X = S.gens()


def specialize_at_one(polynomial):
    """Specialize a frozen family polynomial at t=1."""
    result = S.zero()
    for exponents, coefficient in R(polynomial).dict().items():
        exponents = tuple(ZZ(exponent) for exponent in exponents)
        result += S(coefficient) * prod(
            variable**exponent
            for variable, exponent in zip(X, exponents[1:])
        )
    return result


def ideal_degree(ideal):
    """Compute degree from the Hilbert polynomial when it is available."""
    polynomial = ideal.hilbert_polynomial()
    projective_dimension = ideal.dimension() - 1
    return polynomial.leading_coefficient() * factorial(projective_dimension)


total_started = time.perf_counter()
timings = {}

F1 = tuple(specialize_at_one(generator) for generator in F)
J1 = S.ideal(F1)
fibre_affine_dimension = J1.dimension()
fibre_projective_dimension = fibre_affine_dimension - 1
fibre_codimension = S.ngens() - fibre_affine_dimension
assert fibre_codimension == 4

# Construct this expensive ideal exactly once.  A checked intermediate cache
# makes subsequent analysis runs reproducible without rebuilding the minors.
started = time.perf_counter()
jacobian = matrix(S, [
    [generator.derivative(variable) for variable in X]
    for generator in F1
])
intermediate_path = Path(
    "serendipity/data/singular_locus_ideal_GF32003.sobj"
)
if intermediate_path.exists():
    intermediate = load(str(intermediate_path))
    assert intermediate["field_characteristic"] == K.characteristic()
    assert intermediate["fibre_generators"] == tuple(str(f) for f in F1)
    S_sing = S.ideal(
        tuple(S(generator) for generator in intermediate["ideal_generators"])
    )
    saturation_exponent = intermediate["saturation_exponent"]
    used_intermediate_cache = True
else:
    jacobian_minors = jacobian.minors(fibre_codimension)
    unsaturated_singular_ideal = J1 + S.ideal(jacobian_minors)
    S_sing, saturation_exponent = unsaturated_singular_ideal.saturation(
        S.ideal(X)
    )
    intermediate = {
        "field_characteristic": K.characteristic(),
        "fibre_generators": tuple(str(f) for f in F1),
        "ideal_generators": tuple(str(f) for f in S_sing.gens()),
        "saturation_exponent": saturation_exponent,
    }
    save(intermediate, str(intermediate_path))
    used_intermediate_cache = False
timings["construct_and_saturate"] = time.perf_counter() - started

started = time.perf_counter()
singular_locus_empty = S_sing.is_one()
singular_affine_dimension = None if singular_locus_empty else S_sing.dimension()
singular_projective_dimension = (
    None if singular_locus_empty else singular_affine_dimension - 1
)
singular_codimension_in_fibre = (
    None
    if singular_locus_empty
    else fibre_projective_dimension - singular_projective_dimension
)
singular_hilbert_series = (
    None if singular_locus_empty else S_sing.hilbert_series()
)
singular_hilbert_polynomial = (
    None if singular_locus_empty else S_sing.hilbert_polynomial()
)
singular_degree = None if singular_locus_empty else ideal_degree(S_sing)
timings["basic_invariants"] = time.perf_counter() - started

# Radical and component calculations are separate so the report never
# confuses a failed decomposition with a computed one.
radical_ideal = None
is_radical = None
radical_error = None
radical_degree = None
radical_hilbert_polynomial = None
started = time.perf_counter()
try:
    radical_ideal = S_sing.radical()
    is_radical = radical_ideal == S_sing
    radical_degree = ideal_degree(radical_ideal)
    radical_hilbert_polynomial = radical_ideal.hilbert_polynomial()
except Exception as error:
    radical_error = str(error)
timings["radical"] = time.perf_counter() - started

minimal_primes = None
minimal_primes_error = None
started = time.perf_counter()
try:
    decomposition_source = (
        radical_ideal if radical_ideal is not None else S_sing
    )
    minimal_primes = tuple(decomposition_source.minimal_associated_primes())
except Exception as error:
    minimal_primes_error = str(error)
timings["minimal_primes"] = time.perf_counter() - started

components = []
if minimal_primes is not None:
    for index, prime in enumerate(minimal_primes):
        component_dimension = prime.dimension()
        component_projective_dimension = component_dimension - 1
        component_degree = ideal_degree(prime)
        if component_projective_dimension == 2 and component_degree == 1:
            geometry = "projective plane"
        elif (
            component_projective_dimension == 2
            and component_degree == 2
            and sum(generator.degree() == 1 for generator in prime.gens()) >= 4
        ):
            geometry = "quadric surface in a linear P^3"
        else:
            geometry = "not classified"
        components.append({
            "index": index,
            "ideal": prime,
            "generators": tuple(prime.gens()),
            "affine_dimension": component_dimension,
            "projective_dimension": component_projective_dimension,
            "degree": component_degree,
            "geometry": geometry,
            "is_prime": prime.is_prime(),
        })

# Every coordinate point is cheap to test and provides explicit rational
# geometry even when the singular locus is positive-dimensional.
singular_points = []
point_search_error = None
started = time.perf_counter()
for coordinate_index in range(S.ngens()):
    point = tuple(
        K(index == coordinate_index) for index in range(S.ngens())
    )
    if all(generator(*point) == 0 for generator in S_sing.gens()):
        singular_points.append(point)

# For a zero-dimensional locus, additionally enumerate all rational points
# chart by chart, normalizing the first nonzero coordinate.
if not singular_locus_empty and singular_projective_dimension == 0:
    try:
        seen = set()
        for chart_index, chart_variable in enumerate(X):
            chart_ideal = S_sing + S.ideal(chart_variable - 1)
            for solution in chart_ideal.variety(ring=K):
                point = tuple(K(solution.get(variable, 0)) for variable in X)
                first_nonzero = next(
                    (i for i, coordinate in enumerate(point) if coordinate),
                    None,
                )
                if first_nonzero is None:
                    continue
                normalized = tuple(
                    coordinate / point[first_nonzero] for coordinate in point
                )
                if normalized in seen:
                    continue
                seen.add(normalized)
                singular_points.append(normalized)
    except Exception as error:
        point_search_error = str(error)
timings["rational_point_search"] = time.perf_counter() - started

# At a nonzero cone point, projectivization removes the radial direction.
tangent_samples = []
for point in singular_points[:10]:
    evaluated_jacobian = matrix(K, [
        [entry(*point) for entry in row]
        for row in jacobian.rows()
    ])
    jacobian_rank = evaluated_jacobian.rank()
    tangent_samples.append({
        "point": point,
        "jacobian_rank": jacobian_rank,
        "affine_tangent_dimension": S.ngens() - jacobian_rank,
        "projective_tangent_dimension": S.ngens() - jacobian_rank - 1,
    })

results = {
    "field_characteristic": K.characteristic(),
    "fibre_ideal": J1,
    "fibre_affine_dimension": fibre_affine_dimension,
    "fibre_projective_dimension": fibre_projective_dimension,
    "fibre_codimension": fibre_codimension,
    "singular_locus_ideal": S_sing,
    "saturation_exponent": saturation_exponent,
    "used_intermediate_cache": used_intermediate_cache,
    "singular_locus_empty": singular_locus_empty,
    "singular_affine_dimension": singular_affine_dimension,
    "singular_projective_dimension": singular_projective_dimension,
    "singular_codimension_in_fibre": singular_codimension_in_fibre,
    "singular_degree": singular_degree,
    "singular_hilbert_series": singular_hilbert_series,
    "singular_hilbert_polynomial": singular_hilbert_polynomial,
    "radical_ideal": radical_ideal,
    "radical_degree": radical_degree,
    "radical_hilbert_polynomial": radical_hilbert_polynomial,
    "is_radical": is_radical,
    "appears_reduced": is_radical,
    "radical_error": radical_error,
    "minimal_primes": minimal_primes,
    "minimal_primes_error": minimal_primes_error,
    "components": tuple(components),
    "primary_decomposition_computed": False,
    "singular_points": tuple(singular_points),
    "point_search_error": point_search_error,
    "tangent_samples": tuple(tangent_samples),
    "timings": timings,
    "total_runtime": time.perf_counter() - total_started,
}
save(results, "serendipity/data/singular_locus_GF32003.sobj")

report_lines = [
    "Singular locus of the t=1 fibre over GF(32003)",
    "empty: %s" % singular_locus_empty,
    "affine-cone dimension: %s" % singular_affine_dimension,
    "projective dimension: %s" % singular_projective_dimension,
    "codimension inside fibre: %s" % singular_codimension_in_fibre,
    "degree: %s" % singular_degree,
    "Hilbert series: %s" % singular_hilbert_series,
    "Hilbert polynomial: %s" % singular_hilbert_polynomial,
    "radical: %s" % is_radical,
    "appears reduced: %s" % is_radical,
    "degree of reduced support: %s" % radical_degree,
    "Hilbert polynomial of reduced support: %s"
    % radical_hilbert_polynomial,
    "saturation exponent: %s" % saturation_exponent,
    "used checked intermediate cache: %s" % used_intermediate_cache,
    "",
    "Singular-locus ideal generators:",
]
report_lines.extend("  %s" % generator for generator in S_sing.gens())
if radical_ideal is not None:
    report_lines.extend(["", "Radical ideal generators:"])
    report_lines.extend("  %s" % generator for generator in radical_ideal.gens())
if radical_error is not None:
    report_lines.append("Radical calculation failed: %s" % radical_error)

report_lines.extend(["", "Components actually computed: %d" % len(components)])
for component in components:
    report_lines.append(
        "component %d: %s, projective dimension %s, degree %s, prime=%s"
        % (
            component["index"],
            component["geometry"],
            component["projective_dimension"],
            component["degree"],
            component["is_prime"],
        )
    )
    report_lines.extend(
        "  %s" % generator for generator in component["generators"]
    )
if minimal_primes_error is not None:
    report_lines.append(
        "Minimal-prime calculation failed: %s" % minimal_primes_error
    )
report_lines.append(
    "Full primary decomposition: not computed; the minimal primes above "
    "are the verified irreducible components of the reduced support."
)

report_lines.extend(["", "GF(32003)-rational projective singular points:"])
if singular_points:
    report_lines.extend("  %s" % (point,) for point in singular_points)
else:
    report_lines.append("  none found")
if point_search_error is not None:
    report_lines.append("Point search failed: %s" % point_search_error)

report_lines.extend(["", "Tangent-space samples:"])
for sample in tangent_samples:
    report_lines.append(
        "  point %s: Jacobian rank %s, affine tangent dimension %s, "
        "projective tangent dimension %s"
        % (
            sample["point"],
            sample["jacobian_rank"],
            sample["affine_tangent_dimension"],
            sample["projective_tangent_dimension"],
        )
    )

report_lines.extend(["", "Runtimes (seconds):"])
for name, runtime in timings.items():
    report_lines.append("  %s: %.6f" % (name, runtime))
report_lines.append("  total: %.6f" % results["total_runtime"])

with open("serendipity/data/singular_locus_GF32003.txt", "w") as output:
    output.write("\n".join(report_lines) + "\n")

print("\n".join(report_lines))
