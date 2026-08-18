"""Exact QQ Newton/local-model cross-check for the rational direction.

The input is the order-two truncation

    f_i + s*g_i + s^2*h_i

obtained by evaluating the characteristic-zero Macaulay2 versal family on
the rational direction recorded below.  The ridge, edge, and fixed two-jet
initial calculations remain useful exact cross-checks.  Their old face-flag
argument did not control arbitrary order-three terms after every weight
refinement, so this script is not the exhaustive smoothness proof.  That is
now `verify_grassmann_mod_s3.m2`, run over all charts by
`verify_grassmann_all.py`.

Run from the repository root with

    sage proofs/rational-two-jet-smoothness/verify_local_smoothness.sage
"""

import hashlib
import itertools
from collections import Counter
from pathlib import Path

from sage.all import (
    GF,
    QQ,
    ZZ,
    LaurentPolynomialRing,
    PolynomialRing,
    matrix,
    prod,
)


def repository_root():
    starts = [Path.cwd().resolve()]
    try:
        starts.append(Path(__file__).resolve().parent)
    except NameError:
        pass
    for start in starts:
        for candidate in (start,) + tuple(start.parents):
            if (candidate / "rl" / "sr_environment.sage").is_file():
                return candidate
    raise RuntimeError("run this verifier from inside the repository")


ROOT = repository_root()
load(str(ROOT / "rl" / "sr_environment.sage"))

Y = [
    1, 3, 1, 2, 6, 1, 7, 3, 14, 4, 1, 1, 1, 1, 1, 21, 28, 1,
    1, 5, 10, 1, 9, 8, 55, 66, 12, 15, 1, 18, 1, 2, 35, 42, 1, 4,
    6, 22, 20, 10, 11, 1, 1, 25, 12, 30, 1, 15, 5, 33, 44, 1, 6,
]
assert len(Y) == 53 and all(c != 0 for c in Y)

S = PolynomialRing(QQ, names=["x%d" % i for i in range(1, 9)])
x = S.gens()
fQ = [S.monomial(*tuple(map(int, exponents)))
      for exponents in _generator_exponents]

data_file = ROOT / "proofs" / "rational-two-jet-smoothness" / "universal_2jet_QQ.txt"
two_jet_sha256 = hashlib.sha256(data_file.read_bytes()).hexdigest()
assert two_jet_sha256 == (
    "40e64e61674b6a4e61f1ea6822dc79327bf4ba397285f84ed8738c4c18cd1795"
)
rows = [line.split("|") for line in data_file.read_text().splitlines()]
assert len(rows) == 16
assert [int(row[0]) for row in rows] == list(range(16))


def parse_m2_polynomial(text):
    return S(text.replace("x_", "x"))


gQ = [parse_m2_polynomial(row[1]) for row in rows]
hQ = [parse_m2_polynomial(row[2]) for row in rows]


def reduce_mod_32003(poly):
    return R({exponents: K(coefficient) for exponents, coefficient
              in poly.dict().items()})


# The exact first-order cubics in the M2 export agree with the historical
# 53-coordinate direction, not merely after a change of generator basis.
g_historical = direction_to_corrections(y_to_direction(Y))
assert all(reduce_mod_32003(a) == b for a, b in zip(gQ, g_historical))


def centered_QQ(poly):
    out = S.zero()
    for exponents, coefficient in poly.dict().items():
        value = int(coefficient)
        if value > 16001:
            value -= 32003
        out += QQ(value) * S.monomial(*exponents)
    return out


# Exact first-order syzygy check over QQ.  (The h_i come directly from the
# characteristic-zero universal family, whose flatness is checked upstream.)
syzygies_QQ = [[centered_QQ(entry) for entry in row]
               for row in _syzygy_rows]
IQ = S.ideal(fQ)
for row in syzygies_QQ:
    residual = sum((a * b for a, b in zip(row, gQ)), S.zero())
    assert residual.reduce(IQ) == 0
print("INPUT: universal two-jet SHA-256 =", two_jet_sha256)
print("INPUT: exact QQ first-order direction verified; 16 universal two-jet rows")


FACETS = [
    (1, 2, 3, 4), (1, 2, 3, 7), (1, 2, 6, 7), (1, 3, 4, 7),
    (1, 5, 6, 7), (2, 3, 4, 5), (2, 3, 6, 7), (3, 4, 6, 7),
    (3, 4, 5, 6), (4, 5, 6, 7), (2, 3, 5, 8), (2, 3, 6, 8),
    (3, 5, 6, 8), (1, 2, 6, 8), (1, 5, 6, 8), (1, 2, 4, 8),
    (2, 4, 5, 8), (1, 4, 7, 8), (1, 5, 7, 8), (4, 5, 7, 8),
]
assert len(FACETS) == 20


# ---------------------------------------------------------------------------
# Ridge strata: node smoothing functions on the two-dimensional ridge torus.
# ---------------------------------------------------------------------------

RIDGES = sorted({tuple(sorted(face)) for facet in FACETS
                 for face in itertools.combinations(facet, 3)})
assert len(RIDGES) == 40


def restricted_ridge_terms(ridge, corrections):
    adjacent = [facet for facet in FACETS if set(ridge).issubset(facet)]
    assert len(adjacent) == 2
    normals = sorted((set(adjacent[0]) | set(adjacent[1])) - set(ridge))
    candidates = []
    for index, exponents in enumerate(_generator_exponents):
        support = {i + 1 for i, exponent in enumerate(exponents) if exponent}
        if (set(normals).issubset(support)
                and support.issubset(set(ridge) | set(normals))):
            candidates.append(index)
    assert candidates
    generator_index = candidates[0]
    denominator = list(map(int, _generator_exponents[generator_index]))
    for normal in normals:
        denominator[normal - 1] -= 1

    terms = {}
    for exponents, coefficient in corrections[generator_index].dict().items():
        if all(exponents[k] == 0 for k in range(8) if k + 1 not in ridge):
            laurent_exponents = tuple(
                int(exponents[vertex - 1]) - denominator[vertex - 1]
                for vertex in ridge
            )
            terms[laurent_exponents] = (
                terms.get(laurent_exponents, QQ.zero()) + QQ(coefficient)
            )
    return normals, generator_index, {
        exponents: coefficient for exponents, coefficient in terms.items()
        if coefficient
    }


ridge_data = {}
for ridge in RIDGES:
    normals, generator_index, first = restricted_ridge_terms(ridge, gQ)
    normals2, generator_index2, second = restricted_ridge_terms(ridge, hQ)
    assert (normals, generator_index) == (normals2, generator_index2)
    if first:
        ridge_data[ridge] = (normals, generator_index, 1, first)
    else:
        assert second
        ridge_data[ridge] = (normals, generator_index, 2, second)

exceptional = [ridge for ridge, data in ridge_data.items() if data[2] == 2]
assert exceptional == [(1, 2, 8)]
assert ridge_data[(1, 2, 8)][3] == {
    (2, 0, 0): -10,
    (1, 1, 0): -241,
    (1, 0, 1): -90,
    (0, 2, 0): -1155,
    (0, 1, 1): -928,
    (0, 0, 2): -180,
}

A = PolynomialRing(QQ, names=["u", "v", "w"], order="degrevlex")
u, v, w = A.gens()
ridge_polynomials = {}
for ridge, (_, _, smoothing_order, terms) in ridge_data.items():
    pairs = [(exponents[0], exponents[1], QQ(coefficient))
             for exponents, coefficient in terms.items()]
    min_u = min(a for a, b, c in pairs)
    min_v = min(b for a, b, c in pairs)
    polynomial = sum(
        coefficient * u ** (a - min_u) * v ** (b - min_v)
        for a, b, coefficient in pairs
    )
    critical_ideal = A.ideal([
        polynomial,
        u * polynomial.derivative(u),
        v * polynomial.derivative(v),
        w * u * v - 1,
    ])
    assert critical_ideal.groebner_basis() == [A.one()], ridge
    ridge_polynomials[ridge] = polynomial

conic_matrix = matrix(QQ, [
    [10, QQ(241) / 2, 45],
    [QQ(241) / 2, 1155, 464],
    [45, 464, 180],
])
assert conic_matrix.det() == 5600
print("RIDGES: 40/40 logarithmic critical ideals are [1]")
print("RIDGES: (1,2,8) first smooths at order 2; conic determinant = 5600")


# ---------------------------------------------------------------------------
# Edge strata: Altmann--Christophersen Z_n normal forms, n = 3,4,5,6.
# ---------------------------------------------------------------------------

EDGES = sorted({tuple(sorted(face)) for facet in FACETS
                for face in itertools.combinations(facet, 2)})
assert len(EDGES) == 28


def link_cycle(edge):
    vertices = sorted({vertex for facet in FACETS if set(edge).issubset(facet)
                       for vertex in facet if vertex not in edge})
    adjacency = {vertex: [] for vertex in vertices}
    for facet in FACETS:
        if set(edge).issubset(facet):
            other = [vertex for vertex in facet if vertex not in edge]
            assert len(other) == 2
            adjacency[other[0]].append(other[1])
            adjacency[other[1]].append(other[0])
    cycle = [vertices[0]]
    previous = None
    current = vertices[0]
    while True:
        following = [vertex for vertex in adjacency[current] if vertex != previous]
        next_vertex = following[0]
        if next_vertex == cycle[0]:
            break
        cycle.append(next_vertex)
        previous, current = current, next_vertex
    return cycle


edge_lengths = Counter(len(link_cycle(edge)) for edge in EDGES)
assert edge_lengths == Counter({3: 7, 4: 9, 5: 9, 6: 3})

LR = LaurentPolynomialRing(QQ, "r")
r_laurent = LR.gen()


def ridge_coefficients_along_edge(edge, vertex):
    ridge = tuple(sorted(edge + (vertex,)))
    _, _, smoothing_order, terms = ridge_data[ridge]
    if smoothing_order != 1:
        return {}
    ordering = sorted(ridge)
    edge_position = ordering.index(edge[0])
    vertex_position = ordering.index(vertex)
    coefficients = {}
    for exponents, coefficient in terms.items():
        degree = exponents[vertex_position]
        coefficients[degree] = (
            coefficients.get(degree, LR.zero())
            + QQ(coefficient) * r_laurent ** exponents[edge_position]
        )
    return coefficients


def laurent_in_fraction_field(poly, fraction_field, r0):
    return sum(QQ(coefficient) * fraction_field(r0) ** int(exponent)
               for exponent, coefficient in poly.dict().items())


def test_E3(edge):
    cycle = link_cycle(edge)
    data = [ridge_coefficients_along_edge(edge, vertex) for vertex in cycle]
    parameters = [entry.get(-1, LR.zero()) for entry in data]
    assert parameters[0] == parameters[1] == parameters[2] and parameters[0]

    P = PolynomialRing(QQ, names=["r", "z1", "z2", "z3", "w"],
                       order="degrevlex")
    r0, z1, z2, z3, w0 = P.gens()
    fraction_field = P.fraction_field()
    parameter = laurent_in_fraction_field(parameters[0], fraction_field, r0)
    equation = P((fraction_field(z1 * z2 * z3) + parameter).numerator())
    jacobian = matrix(P, [[equation.derivative(variable)
                           for variable in [r0, z1, z2, z3]]])
    singular = P.ideal([equation, r0 * w0 - 1] + jacobian.minors(1))
    return singular.groebner_basis() == [P.one()]


def test_E4(edge):
    cycle = link_cycle(edge)
    parameters = [ridge_coefficients_along_edge(edge, vertex).get(0, LR.zero())
                  for vertex in cycle]
    assert (parameters[0] == parameters[2] and parameters[0]
            and parameters[1] == parameters[3] and parameters[1])

    P = PolynomialRing(QQ, names=["r", "z1", "z2", "z3", "z4", "w"],
                       order="degrevlex")
    r0 = P.gen(0)
    z = P.gens()[1:5]
    w0 = P.gen(5)
    fraction_field = P.fraction_field()
    a = laurent_in_fraction_field(parameters[0], fraction_field, r0)
    b = laurent_in_fraction_field(parameters[1], fraction_field, r0)
    equations = [
        P((fraction_field(z[0] * z[2]) + a).numerator()),
        P((fraction_field(z[1] * z[3]) + b).numerator()),
    ]
    base = P.ideal(equations + [r0 * w0 - 1])
    jacobian = matrix(P, [[equation.derivative(variable)
                           for variable in [r0] + list(z)]
                          for equation in equations])
    singular = base + P.ideal(jacobian.minors(2))
    return base.dimension() == 3 and singular.groebner_basis() == [P.one()]


def test_E5(edge):
    cycle = link_cycle(edge)
    parameters0 = [ridge_coefficients_along_edge(edge, vertex).get(1, LR.zero())
                   for vertex in cycle]
    P = PolynomialRing(QQ, names=["r"] + ["z%d" % i for i in range(1, 6)]
                       + ["w"], order="degrevlex")
    r0 = P.gen(0)
    z = P.gens()[1:6]
    w0 = P.gen(6)
    fraction_field = P.fraction_field()
    parameters = [laurent_in_fraction_field(entry, fraction_field, r0)
                  for entry in parameters0]
    equations = []
    for i in range(5):
        expression = (
            fraction_field(z[(i - 1) % 5]) * z[(i + 1) % 5]
            + parameters[i] * z[i]
            - parameters[(i - 2) % 5] * parameters[(i + 2) % 5]
        )
        equations.append(P(expression.numerator()))
    base = P.ideal(equations + [r0 * w0 - 1])
    jacobian = matrix(P, [[equation.derivative(variable)
                           for variable in [r0] + list(z)]
                          for equation in equations])
    singular = base + P.ideal(jacobian.minors(3))
    return base.dimension() == 3 and singular.groebner_basis() == [P.one()]


def test_E6(edge):
    cycle = link_cycle(edge)
    parameters0 = [ridge_coefficients_along_edge(edge, vertex).get(1, LR.zero())
                   for vertex in cycle]
    rank_one_matrix = matrix(LR, [
        [parameters0[0], parameters0[2], parameters0[4]],
        [parameters0[3], parameters0[5], parameters0[1]],
    ])
    assert all(minor == 0 for minor in rank_one_matrix.minors(2))

    P = PolynomialRing(QQ, names=["r"] + ["z%d" % i for i in range(1, 7)]
                       + ["w"], order="degrevlex")
    r0 = P.gen(0)
    z = P.gens()[1:7]
    w0 = P.gen(7)
    fraction_field = P.fraction_field()
    parameters = [laurent_in_fraction_field(entry, fraction_field, r0)
                  for entry in parameters0]
    equations = []
    for i in range(6):
        expression = (
            fraction_field(z[(i - 1) % 6]) * z[(i + 1) % 6]
            + parameters[i] * z[i]
        )
        equations.append(P(expression.numerator()))
    for i in range(3):
        expression = (
            fraction_field(z[i]) * z[i + 3]
            - parameters[(i + 1) % 6] * parameters[(i + 2) % 6]
        )
        equations.append(P(expression.numerator()))
    base = P.ideal(equations + [r0 * w0 - 1])
    jacobian = matrix(P, [[equation.derivative(variable)
                           for variable in [r0] + list(z)]
                          for equation in equations])
    singular = base + P.ideal(jacobian.minors(4))
    return base.dimension() == 3 and singular.groebner_basis() == [P.one()]


for length, test in [(3, test_E3), (4, test_E4), (5, test_E5), (6, test_E6)]:
    selected = [edge for edge in EDGES if len(link_cycle(edge)) == length]
    for edge in selected:
        assert test(edge), edge
    print("EDGES: E%d, %d/%d total Jacobian singular ideals are [1]"
          % (length, len(selected), len(selected)))


def lower_newton_breakpoints(points):
    """Positive breakpoints of min(s_order + normal_degree * lambda)."""
    points = [(QQ(s_order), QQ(normal_degree))
              for s_order, normal_degree in points]
    breakpoints = set()
    for p in points:
        for q in points:
            if p[1] == q[1]:
                continue
            lam = (q[0] - p[0]) / (p[1] - q[1])
            if (lam > 0
                    and p[0] + lam * p[1]
                    == min(a + lam * degree for a, degree in points)):
                breakpoints.add(lam)
    return sorted(breakpoints)


# These are the only new radial walls after a face-support localization.
# Below a wall one sees the Stanley--Reisner normal slice and recurses to a
# larger face; at the wall one sees exactly the total-Jacobian models above.
assert lower_newton_breakpoints([(0, 2), (1, 0)]) == [QQ(1) / 2]
assert lower_newton_breakpoints([(0, 2), (2, 0)]) == [QQ(1)]
assert lower_newton_breakpoints([(0, 3), (1, 0)]) == [QQ(1) / 3]
assert lower_newton_breakpoints([(0, 2), (1, 0)]) == [QQ(1) / 2]
assert lower_newton_breakpoints([(0, 2), (1, 1), (2, 0)]) == [QQ(1)]
print("NORMAL SLICES: ridge walls=1/2,1; E3=1/3, E4=1/2, E5/E6=1")


# ---------------------------------------------------------------------------
# Vertex strata: exact Newton/valuation audit of every radial chamber and
# every support torus.  Face supports recurse to an edge/ridge/facet stratum.
# ---------------------------------------------------------------------------


def homogeneous_part(poly, degree):
    parent = poly.parent()
    return parent(sum(
        (coefficient * parent.monomial(*exponents)
         for exponents, coefficient in poly.dict().items()
         if sum(exponents) == degree),
        parent.zero(),
    ))


def vertex_weight_initial(vertex, lam):
    other = [j for j in range(1, 9) if j != vertex]
    P = PolynomialRing(QQ, names=["z%d" % j for j in other],
                       order="degrevlex")
    z = P.gens()
    substitution = {x[vertex - 1]: P.one()}
    substitution.update({x[j - 1]: z[k] for k, j in enumerate(other)})
    equations = []
    for original, first, second in zip(fQ, gQ, hQ):
        pieces = []
        for s_order, polynomial in [(0, original), (1, first), (2, second)]:
            restricted = P(polynomial.subs(substitution))
            for exponents, coefficient in restricted.dict().items():
                pieces.append((QQ(s_order) + lam * sum(exponents),
                               coefficient * P.monomial(*exponents)))
        if pieces:
            minimum = min(weight for weight, monomial in pieces)
            initial = sum((monomial for weight, monomial in pieces
                           if weight == minimum), P.zero())
            if initial:
                equations.append(initial)
    return P, equations


def vertex_breakpoints(vertex):
    other = [j for j in range(1, 9) if j != vertex]
    P = PolynomialRing(QQ, names=["z%d" % j for j in other])
    z = P.gens()
    substitution = {x[vertex - 1]: P.one()}
    substitution.update({x[j - 1]: z[k] for k, j in enumerate(other)})
    breakpoints = set()
    for original, first, second in zip(fQ, gQ, hQ):
        points = set()
        for s_order, polynomial in [(0, original), (1, first), (2, second)]:
            restricted = P(polynomial.subs(substitution))
            points.update((QQ(s_order), sum(exponents))
                          for exponents in restricted.dict())
        for p in points:
            for q in points:
                if p[1] == q[1]:
                    continue
                lam = QQ(q[0] - p[0]) / QQ(p[1] - q[1])
                if (lam > 0
                        and p[0] + lam * p[1]
                        == min(a + lam * degree for a, degree in points)):
                    breakpoints.add(lam)
    return sorted(breakpoints)


stacked_vertices = [1, 2, 3, 5, 7, 8]
for vertex in stacked_vertices:
    assert vertex_breakpoints(vertex) == [QQ(1) / 2, QQ(2) / 3, QQ(1), QQ(2)]
for vertex in [4, 6]:
    assert vertex_breakpoints(vertex) == [QQ(1) / 2, QQ(1), QQ(2)]
print("VERTICES: radial Newton breakpoints verified exactly")


def is_link_face(vertex, support):
    return any(set([vertex] + list(support)).issubset(facet) for facet in FACETS)


def audit_vertex_lambda(lam):
    result = {}
    for vertex in range(1, 9):
        P, equations = vertex_weight_initial(vertex, lam)
        basis = list(P.ideal(equations).groebner_basis())
        other = [j for j in range(1, 9) if j != vertex]
        z = P.gens()
        jacobian = matrix(P, [[equation.derivative(variable) for variable in z]
                              for equation in basis])
        rank_four_minors = jacobian.minors(4)
        face_supports = []
        nonface_supports = []
        for mask in range(1, 1 << 7):
            indices = [i for i in range(7) if (mask >> i) & 1]
            support = tuple(other[i] for i in indices)
            Q = PolynomialRing(QQ, names=list(P.variable_names()) + ["w"],
                               order="degrevlex")
            q = Q.gens()
            include = P.hom(q[:7], Q)
            base_generators = (
                [include(equation) for equation in basis]
                + [q[i] for i in range(7) if i not in indices]
                + [q[7] * prod(q[i] for i in indices) - 1]
            )
            base = Q.ideal(base_generators)
            if base.groebner_basis() == [Q.one()]:
                continue
            if is_link_face(vertex, support):
                face_supports.append(support)
            else:
                singular = Q.ideal(
                    base_generators + [include(minor) for minor in rank_four_minors]
                )
                nonface_supports.append(
                    (support, singular.groebner_basis() == [Q.one()])
                )
        result[vertex] = (face_supports, nonface_supports)
        print("VERTEX lambda=%s v=%d: face supports=%d; nonfaces=%s"
              % (lam, vertex, len(face_supports), nonface_supports))
    return result


EXPECTED_HALF = {
    1: [(2, 3, 4, 7), (5, 6, 7, 8)],
    2: [(1, 3, 6, 7), (3, 4, 5, 8)],
    3: [(1, 2, 4, 7), (2, 5, 6, 8)],
    4: [(3, 5, 6, 7)],
    5: [(2, 3, 4, 8), (1, 6, 7, 8)],
    6: [(3, 4, 5, 7)],
    7: [(1, 2, 3, 6), (1, 4, 5, 8)],
    8: [(2, 3, 5, 6), (1, 4, 5, 7)],
}
EXPECTED_THREE_FIFTHS = {
    1: [(2, 4, 7), (6, 7, 8)],
    2: [(1, 3, 6), (3, 4, 8)],
    3: [(2, 5, 6), (2, 4, 7)],
    4: [(3, 5, 7)],
    5: [(3, 4, 8), (6, 7, 8)],
    6: [(3, 5, 7)],
    7: [(1, 4, 5), (1, 3, 6)],
    8: [(1, 4, 5), (2, 5, 6)],
}
EXPECTED_TWO_THIRDS = {
    1: [(2, 7, 8), (2, 4, 7, 8), (2, 6, 7, 8)],
    2: [(1, 3, 8), (1, 3, 4, 8), (1, 3, 6, 8)],
    3: [(2, 4, 6), (2, 4, 5, 6), (2, 4, 6, 7)],
    4: [(3, 5, 7)],
    5: [(4, 6, 8), (3, 4, 6, 8), (4, 6, 7, 8)],
    6: [(3, 5, 7)],
    7: [(1, 4, 6), (1, 3, 4, 6), (1, 4, 5, 6)],
    8: [(1, 2, 5), (1, 2, 4, 5), (1, 2, 5, 6)],
}
EXPECTED_FOUR_FIFTHS = {
    1: [], 2: [], 3: [], 4: [(3, 5, 7)],
    5: [], 6: [(3, 5, 7)], 7: [], 8: [],
}


def assert_support_result(result, expected, singular_allowed=()):
    singular_allowed = set(singular_allowed)
    for vertex in range(1, 9):
        actual = result[vertex][1]
        assert [support for support, smooth in actual] == expected[vertex]
        for support, smooth in actual:
            assert smooth == ((vertex, support) not in singular_allowed)


# A sample in each open chamber, plus every breakpoint below one.
one_third = audit_vertex_lambda(QQ(1) / 3)
assert_support_result(one_third, {vertex: [] for vertex in range(1, 9)})

one_half = audit_vertex_lambda(QQ(1) / 2)
assert_support_result(one_half, EXPECTED_HALF)

three_fifths = audit_vertex_lambda(QQ(3) / 5)
assert_support_result(three_fifths, EXPECTED_THREE_FIFTHS)

critical_triples = [
    (1, (2, 7, 8)), (2, (1, 3, 8)), (3, (2, 4, 6)),
    (5, (4, 6, 8)), (7, (1, 4, 6)), (8, (1, 2, 5)),
]
two_thirds = audit_vertex_lambda(QQ(2) / 3)
assert_support_result(two_thirds, EXPECTED_TWO_THIRDS, critical_triples)

four_fifths = audit_vertex_lambda(QQ(4) / 5)
assert_support_result(four_fifths, EXPECTED_FOUR_FIFTHS)


def vertex_multi_initial(vertex, minimum_support, outside_weight=3):
    """Refine lambda=2/3 after the base change s=t^3."""
    other = [j for j in range(1, 9) if j != vertex]
    P = PolynomialRing(QQ, names=["z%d" % j for j in other],
                       order="degrevlex")
    z = P.gens()
    substitution = {x[vertex - 1]: P.one()}
    substitution.update({x[j - 1]: z[k] for k, j in enumerate(other)})
    variable_weight = {
        j: (2 if j in minimum_support else outside_weight) for j in other
    }
    equations = []
    for original, first, second in zip(fQ, gQ, hQ):
        pieces = []
        for s_order, polynomial in [(0, original), (1, first), (2, second)]:
            restricted = P(polynomial.subs(substitution))
            for exponents, coefficient in restricted.dict().items():
                weight = 3 * s_order + sum(
                    exponents[k] * variable_weight[j]
                    for k, j in enumerate(other)
                )
                pieces.append((weight, coefficient * P.monomial(*exponents)))
        if pieces:
            minimum = min(weight for weight, monomial in pieces)
            initial = sum((monomial for weight, monomial in pieces
                           if weight == minimum), P.zero())
            if initial:
                equations.append(initial)
    return P, equations


EXPECTED_REFINED = {
    1: ["z2*z7*z8-8", "z4*z6-10", "z3", "z5"],
    2: ["z1*z3*z8-231", "z4*z6-1155", "z5", "z7"],
    3: ["z2*z4*z6-924", "z5*z7-462", "z1", "z8"],
    5: ["z4*z6*z8-60", "z3*z7-45", "z1", "z2"],
    7: ["z1*z4*z6-36", "z3*z5-48", "z2", "z8"],
    8: ["z1*z2*z5-270", "z4*z6-180", "z3", "z7"],
}

for vertex, support in critical_triples:
    P, equations = vertex_multi_initial(vertex, support)
    base = P.ideal(equations)
    basis = list(base.groebner_basis())
    expected = [P(text) for text in EXPECTED_REFINED[vertex]]
    assert basis == expected
    assert base.dimension() == 3
    other = [j for j in range(1, 9) if j != vertex]
    support_indices = [other.index(j) for j in support]
    Q = PolynomialRing(QQ, names=list(P.variable_names()) + ["w"],
                       order="degrevlex")
    q = Q.gens()
    include = P.hom(q[:7], Q)
    localized_generators = (
        [include(equation) for equation in basis]
        + [q[7] * prod(q[i] for i in support_indices) - 1]
    )
    localized = Q.ideal(localized_generators)
    assert localized.groebner_basis() != [Q.one()]
    jacobian = matrix(P, [[equation.derivative(variable)
                           for variable in P.gens()] for equation in basis])
    singular = Q.ideal(
        localized_generators + [include(minor) for minor in jacobian.minors(4)]
    )
    assert singular.groebner_basis() == [Q.one()]
    print("VERTEX refined v=%d: %s; singular ideal=[1]" % (vertex, basis))


# At and beyond lambda=1 the initial ideal is already the unit ideal.  The
# samples cover the remaining chambers and breakpoints 1 and 2.
for lam in [QQ(1), QQ(3) / 2, QQ(2), QQ(5) / 2]:
    for vertex in range(1, 9):
        P, equations = vertex_weight_initial(vertex, lam)
        assert P.ideal(equations).groebner_basis() == [P.one()]
    print("VERTICES: lambda=%s, all eight initial ideals are [1]" % lam)

print("SUCCESS: every ridge, edge, and vertex valuation model passes over QQ")
print("CROSS-CHECK: all fixed-two-jet Newton/local models tested here pass")
