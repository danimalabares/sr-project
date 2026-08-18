#!/usr/bin/env sage
"""Compare the historical deterministic two-jet with the versal two-jet.

The historical lift is computed over GF(32003).  Its coefficients have small
centered representatives, which are lifted coefficientwise to QQ and then
checked exactly.  The difference from Macaulay2's canonical second-order
term is decomposed in the common 1664-dimensional correction space into
coordinate derivations plus the historical T^1 complement.
"""

from pathlib import Path
import argparse
import hashlib


PROOF_DIRECTORY = Path(__file__).resolve().parent
REPOSITORY_ROOT = PROOF_DIRECTORY.parents[1]
PRIME = 32003
RAW_DIMENSION = 1664


def proof_path(value):
    path = Path(value)
    return path if path.is_absolute() else PROOF_DIRECTORY / path


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def nonzero_entries(vector_value):
    return tuple(
        (index + 1, value)
        for index, value in enumerate(vector_value)
        if value != 0
    )


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--m2-two-jet", default="generated/m2_rational_two_jet_QQ.txt"
    )
    parser.add_argument(
        "--base", default="generated/versal_base_QQ_deg2_5.txt"
    )
    parser.add_argument(
        "--certificate", default="certificates/prescribed_two_jet_QQ.txt"
    )
    args = parser.parse_args()

    m2_two_jet_path = proof_path(args.m2_two_jet)
    base_path = proof_path(args.base)
    certificate_path = proof_path(args.certificate)
    raw_cache_path = (
        REPOSITORY_ROOT
        / "old-code/cotangent/order2/cache/raw_obstruction_data.sobj"
    )
    foundation_path = REPOSITORY_ROOT / "foundations/part-1.pkl"

    # Load the historical exact finite-field deformation code without its
    # command-line smoke test.
    global _SR_ENVIRONMENT_SKIP_SMOKE
    _SR_ENVIRONMENT_SKIP_SMOKE = True
    load(str(REPOSITORY_ROOT / "rl/sr_environment.sage"))

    old_y = vector(K, (
        1,3,1,2,6,1,7,3,14,4,1,1,1,1,1,21,28,1,1,5,10,1,9,8,55,
        66,12,15,1,18,1,2,35,42,1,4,6,22,20,10,11,1,1,25,12,30,1,
        15,5,33,44,1,6,
    ))
    historical_space = second_order_lift_space(old_y)
    assert historical_space["exists"]
    historical_g_ff = historical_space["first_order_corrections"]
    historical_h_ff = historical_space["particular_corrections"]

    RQ = PolynomialRing(QQ, names=["x%d" % i for i in range(1, 9)])
    xq = RQ.gens()
    IQ = RQ.ideal([RQ(str(generator)) for generator in generators])

    def centered(coefficient):
        value = ZZ(coefficient)
        return value if value <= (PRIME - 1) // 2 else value - PRIME

    def lift_polynomial(polynomial):
        return RQ(dict(
            (exponents, centered(coefficient))
            for exponents, coefficient in polynomial.dict().items()
        ))

    historical_g = tuple(lift_polynomial(f) for f in historical_g_ff)
    historical_h = tuple(lift_polynomial(f) for f in historical_h_ff)

    m2_rows = []
    for line_number, line in enumerate(
        m2_two_jet_path.read_text().splitlines(), 1
    ):
        if not line.strip():
            continue
        pieces = line.split("|", 2)
        if len(pieces) != 3:
            raise ValueError("malformed M2 two-jet line %d" % line_number)
        index = int(pieces[0])
        m2_rows.append((
            index,
            RQ(pieces[1].replace("x_", "x")),
            RQ(pieces[2].replace("x_", "x")),
        ))
    assert [row[0] for row in m2_rows] == list(range(16))
    m2_g = tuple(row[1] for row in m2_rows)
    m2_h = tuple(row[2] for row in m2_rows)
    assert historical_g == m2_g

    # Reuse the independently certified historical complement construction.
    global _TRANSPORT_COORDINATES_SKIP_MAIN
    _TRANSPORT_COORDINATES_SKIP_MAIN = True
    load(str(PROOF_DIRECTORY / "transport_coordinates.sage"))
    (
        foundation_ring, foundation_ideal, standard_cubics, monomial_index,
        linearized_relations, derivation_basis, historical_basis,
    ) = reconstruct_historical_complement(foundation_path)

    correction_monomials_QQ = tuple(
        prod(xq[index] ** exponent for index, exponent in enumerate(exponents))
        for exponents in _correction_exponents
    )
    assert tuple(RQ(str(monomial)) for monomial in standard_cubics) == (
        correction_monomials_QQ
    )

    def raw_vector(corrections):
        answer = vector(QQ, RAW_DIMENSION)
        block_size = len(standard_cubics)
        for generator_index, polynomial in enumerate(corrections):
            reduced = polynomial.reduce(IQ)
            for exponents, coefficient in reduced.dict().items():
                monomial = foundation_ring.monomial(*exponents)
                raw_index = (
                    generator_index * block_size + monomial_index[monomial]
                )
                answer[raw_index] += QQ(coefficient)
        return answer

    difference = raw_vector(tuple(
        historical_h[index] - m2_h[index] for index in range(16)
    ))
    assert linearized_relations * difference == 0
    decomposition = matrix(
        QQ, derivation_basis + historical_basis, sparse=True
    )
    pivot_columns = decomposition.pivots()
    assert len(pivot_columns) == 109
    minor = decomposition.matrix_from_columns(pivot_columns)
    coefficients = minor.transpose().solve_right(vector(
        QQ, [difference[index] for index in pivot_columns]
    ))
    assert coefficients * decomposition == difference
    derivation_coefficients = vector(QQ, coefficients[:56])
    old_v2 = vector(QQ, coefficients[56:])
    assert old_v2 == 0

    old_from_m2 = zero_matrix(QQ, 53, 53)
    for column, old_index in enumerate(EXPECTED_OLD_INDEX_BY_M2_COLUMN):
        old_from_m2[old_index - 1, column] = 1
    m2_v2 = old_from_m2.solve_right(old_v2)
    assert m2_v2 == 0

    # The cubic base coefficient must vanish for this prescribed two-jet to
    # extend one step.  Verify it directly on the exact QQ export.
    T = PolynomialRing(QQ, names=["t_%d" % i for i in range(1, 54)])
    groups = {}
    for line_number, line in enumerate(base_path.read_text().splitlines(), 1):
        if not line.strip():
            continue
        pieces = line.split("|", 2)
        if len(pieces) != 3:
            raise ValueError("malformed base-export line %d" % line_number)
        group, row = map(int, pieces[:2])
        groups.setdefault(group + 2, {})[row] = T(pieces[2])
    q = tuple(groups[2][index] for index in range(27))
    cubic = tuple(groups[3][index] for index in range(27))
    m2_y = EXPECTED_M2_RATIONAL_POINT
    substitution = dict(zip(T.gens(), m2_y))
    Dq = matrix(QQ, [
        [polynomial.derivative(variable).subs(substitution)
         for variable in T.gens()]
        for polynomial in q
    ])
    cubic_at_y = vector(QQ, [
        polynomial.subs(substitution) for polynomial in cubic
    ])
    assert Dq.rank() == 15
    assert Dq * m2_v2 + cubic_at_y == 0

    certificate_lines = [
        "field=QQ",
        "historical_source_field=GF(32003)_centered_lift",
        "m2_two_jet_sha256=%s" % digest(m2_two_jet_path),
        "base_export_sha256=%s" % digest(base_path),
        "raw_cache_sha256=%s" % digest(raw_cache_path),
        "foundation_sha256=%s" % digest(foundation_path),
        "first_order_cubics_exactly_equal=true",
        "second_order_difference_in_linearized_kernel=true",
        "second_order_difference_is_coordinate_derivation=true",
        "derivation_basis_nonzero_coefficients=%s"
        % (nonzero_entries(derivation_coefficients),),
        "historical_v2=%s" % (tuple(old_v2),),
        "m2_v2=%s" % (tuple(m2_v2),),
        "rank_Dq_y=15",
        "cubic_base_coefficient_zero=true",
        "prescribed_two_jet_extends_to_order_three=true",
    ]
    certificate_path.parent.mkdir(parents=True, exist_ok=True)
    certificate_path.write_text("\n".join(certificate_lines) + "\n")

    print("first-order cubics agree exactly over QQ")
    print("second-order difference is a coordinate derivation")
    print("base v2", tuple(m2_v2))
    print("Dq rank", Dq.rank())
    print("cubic base coefficient zero")
    print("certificate", certificate_path)


if __name__ == "__main__":
    main()
