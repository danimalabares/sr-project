#!/usr/bin/env sage
"""Certify the exact historical-y to Macaulay2-t coordinate permutation.

Macaulay2 CT^1 representatives and the historical deterministic complement
are compared in the common 1664-dimensional space of cubic corrections,
modulo the 56-dimensional space of coordinate derivations.  All arithmetic
is exact over QQ.
"""

from pathlib import Path
import argparse
import hashlib
import pickle


PROOF_DIRECTORY = Path(__file__).resolve().parent
REPOSITORY_ROOT = PROOF_DIRECTORY.parents[1]
RAW_DIMENSION = 1664
T1_DIMENSION = 53

# Entry j is the one-based historical coordinate occupied by M2 coordinate j.
EXPECTED_OLD_INDEX_BY_M2_COLUMN = (
    1, 2, 3, 4, 5, 11, 12, 13, 14, 15, 16, 17, 19, 20, 21, 25, 26,
    28, 29, 30, 32, 33, 34, 35, 36, 40, 43, 44, 45, 46, 49, 50, 51,
    52, 53, 8, 9, 7, 6, 23, 22, 37, 27, 39, 18, 10, 38, 47, 48, 31,
    42, 24, 41,
)

HISTORICAL_RATIONAL_POINT = vector(QQ, (
    1,3,1,2,6,1,7,3,14,4,1,1,1,1,1,21,28,1,1,5,10,1,9,8,55,
    66,12,15,1,18,1,2,35,42,1,4,6,22,20,10,11,1,1,25,12,30,1,
    15,5,33,44,1,6,
))

EXPECTED_M2_RATIONAL_POINT = vector(QQ, (
    1,3,1,2,6,1,1,1,1,1,21,28,1,5,10,55,66,15,1,18,2,35,42,1,4,
    10,1,25,12,30,5,33,44,1,6,3,14,7,1,9,1,6,12,20,1,4,22,1,
    15,1,1,8,11,
))


def relative_to_proof(path_text):
    path = Path(path_text)
    return path if path.is_absolute() else PROOF_DIRECTORY / path


def reconstruct_historical_complement(foundation_path):
    with foundation_path.open("rb") as input_file:
        data = pickle.load(input_file)

    R = data["R"]
    I = data["I"]
    parameter_ring = data["R_param"]
    parameters = [parameter_ring(name) for name in data["def_params"]]
    standard_cubics = [R(monomial) for monomial in data["nonzero_monomials"]]
    nonzero_equations = [
        parameter_ring(coefficient)
        for coefficient in data["all_coeffs"]
        if parameter_ring(coefficient) != 0
    ]

    linearized_relations = matrix(QQ, [
        [equation.monomial_coefficient(parameter) for parameter in parameters]
        for equation in nonzero_equations
    ], sparse=True)
    hom_space = linearized_relations.right_kernel()
    assert linearized_relations.nrows() == 4484
    assert linearized_relations.ncols() == RAW_DIMENSION
    assert linearized_relations.rank() == 1555
    assert hom_space.dimension() == 109

    variables = R.gens()
    generators = list(I.gens())
    monomial_index = {
        monomial: index for index, monomial in enumerate(standard_cubics)
    }
    derivation_rows = []
    for source_index in range(8):
        for target_index in range(8):
            direction = [QQ.zero()] * RAW_DIMENSION
            for generator_index, generator in enumerate(generators):
                image = R(
                    generator.derivative(variables[source_index])
                    * variables[target_index]
                ).reduce(I)
                for exponent, coefficient in image.dict().items():
                    monomial = R.monomial(*exponent)
                    raw_index = (
                        generator_index * len(standard_cubics)
                        + monomial_index[monomial]
                    )
                    direction[raw_index] += QQ(coefficient)
            derivation_rows.append(direction)

    derivation_matrix = matrix(QQ, derivation_rows, sparse=True)
    derivation_basis = list(derivation_matrix.row_space().basis())
    hom_basis = list(hom_space.basis())
    candidates = matrix(QQ, derivation_basis + hom_basis, sparse=True)
    independent_rows = candidates.transpose().pivots()
    historical_basis = [
        hom_basis[index - len(derivation_basis)]
        for index in independent_rows
        if index >= len(derivation_basis)
    ]

    assert len(derivation_basis) == 56
    assert len(historical_basis) == T1_DIMENSION
    return (
        R, I, standard_cubics, monomial_index, linearized_relations,
        derivation_basis, historical_basis,
    )


def load_m2_representatives(path, R, I, standard_cubics, monomial_index):
    corrections = [
        [R.zero() for _ in range(16)] for _ in range(T1_DIMENSION)
    ]
    seen = set()
    for line_number, line in enumerate(path.read_text().splitlines(), 1):
        if not line.strip():
            continue
        pieces = line.split("|", 2)
        if len(pieces) != 3:
            raise ValueError("malformed line %d" % line_number)
        column, row = map(int, pieces[:2])
        if not (0 <= column < 53 and 0 <= row < 16):
            raise ValueError("out-of-range index on line %d" % line_number)
        if (column, row) in seen:
            raise ValueError("duplicate entry on line %d" % line_number)
        seen.add((column, row))
        corrections[column][row] = R(pieces[2]).reduce(I)
    assert len(seen) == 16 * 53

    raw_representatives = []
    block_size = len(standard_cubics)
    for column in range(T1_DIMENSION):
        raw_vector = vector(QQ, RAW_DIMENSION)
        for generator_index, polynomial in enumerate(corrections[column]):
            for exponent, coefficient in polynomial.dict().items():
                monomial = R.monomial(*exponent)
                raw_index = (
                    generator_index * block_size + monomial_index[monomial]
                )
                raw_vector[raw_index] += QQ(coefficient)
        raw_representatives.append(raw_vector)
    return raw_representatives


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", default="generated/m2_t1_QQ.txt")
    parser.add_argument(
        "--foundation", default=str(REPOSITORY_ROOT / "foundations/part-1.pkl")
    )
    parser.add_argument(
        "--certificate", default="certificates/t1_transport_QQ.txt"
    )
    args = parser.parse_args()

    input_path = relative_to_proof(args.input)
    foundation_path = Path(args.foundation)
    certificate_path = relative_to_proof(args.certificate)
    input_digest = hashlib.sha256(input_path.read_bytes()).hexdigest()
    foundation_digest = hashlib.sha256(foundation_path.read_bytes()).hexdigest()

    (
        R, I, standard_cubics, monomial_index, linearized_relations,
        derivation_basis, historical_basis,
    ) = reconstruct_historical_complement(foundation_path)
    m2_representatives = load_m2_representatives(
        input_path, R, I, standard_cubics, monomial_index
    )
    assert all(linearized_relations * vector_value == 0
               for vector_value in m2_representatives)

    decomposition_matrix = matrix(
        QQ, derivation_basis + historical_basis, sparse=True
    )
    pivot_columns = decomposition_matrix.pivots()
    assert len(pivot_columns) == 109
    minor = decomposition_matrix.matrix_from_columns(pivot_columns)
    assert minor.det() != 0

    coordinate_columns = []
    for vector_value in m2_representatives:
        pivot_values = vector(QQ, [vector_value[i] for i in pivot_columns])
        coefficients = minor.transpose().solve_right(pivot_values)
        assert coefficients * decomposition_matrix == vector_value
        coordinate_columns.append(vector(QQ, coefficients[56:]))

    old_from_m2 = matrix(
        QQ, 53, 53,
        lambda row, column: coordinate_columns[column][row],
    )
    expected = zero_matrix(QQ, 53, 53)
    for column, old_index in enumerate(EXPECTED_OLD_INDEX_BY_M2_COLUMN):
        expected[old_index - 1, column] = 1
    assert old_from_m2 == expected
    assert old_from_m2.rank() == 53
    assert old_from_m2.det() == -1
    assert old_from_m2 * vector(QQ, [1] * 53) == vector(QQ, [1] * 53)

    transported = old_from_m2.solve_right(HISTORICAL_RATIONAL_POINT)
    assert transported == EXPECTED_M2_RATIONAL_POINT
    assert old_from_m2 * transported == HISTORICAL_RATIONAL_POINT

    certificate_lines = [
        "field=QQ",
        "m2_t1_sha256=%s" % input_digest,
        "foundation_sha256=%s" % foundation_digest,
        "raw_dimension=1664",
        "derivation_rank=56",
        "historical_t1_dimension=53",
        "m2_t1_dimension=53",
        "old_from_m2_rank=53",
        "old_from_m2_determinant=-1",
        "old_from_m2_nnz=53",
        "old_index_by_m2_column=%s" % (
            EXPECTED_OLD_INDEX_BY_M2_COLUMN,
        ),
        "historical_point=%s" % (tuple(HISTORICAL_RATIONAL_POINT),),
        "transported_m2_point=%s" % (tuple(transported),),
        "all_coordinates_nonzero=%s" % all(value != 0 for value in transported),
    ]
    certificate_path.parent.mkdir(parents=True, exist_ok=True)
    certificate_path.write_text("\n".join(certificate_lines) + "\n")

    print("old_from_m2 rank", old_from_m2.rank())
    print("old_from_m2 determinant", old_from_m2.det())
    print("old index by M2 column", EXPECTED_OLD_INDEX_BY_M2_COLUMN)
    print("transported M2 point", tuple(transported))
    print("certificate", certificate_path)


if (
    __name__ == "__main__"
    and not globals().get("_TRANSPORT_COORDINATES_SKIP_MAIN", False)
):
    main()
