#!/usr/bin/env sage-python
"""Independent low-degree controller check from the frozen sparse Tate data.

This deliberately does not load VersalDeformations or DGAlgebras.  It builds
the weight-zero vector-space complexes Der_S(P,A) and Der_Q(P,A) in degrees
0--3 directly from F, R, and the linear-f part of Z.  Reduction modulo the
Stanley--Reisner ideal is combinatorial because the ideal is monomial.
"""

from fractions import Fraction
from itertools import product
from pathlib import Path

from sage.all import Matrix, QQ


ROOT = Path(__file__).resolve().parents[2]
INPUT = ROOT / "audits" / "tate-stage" / "data" / "tate_candidate.tsv"


def weak_compositions(total, length, prefix=()):
    if length == 1:
        yield prefix + (total,)
        return
    for first in range(total + 1):
        yield from weak_compositions(total - first, length - 1, prefix + (first,))


def parse_input(path):
    matrices = {"F": {}, "R": {}, "Z": {}}
    gdegrees = {}
    for line in path.read_text(encoding="ascii").splitlines():
        fields = line.split("\t")
        if fields[0] == "gdegree":
            gdegrees[int(fields[1])] = int(fields[2])
        elif fields[0] == "term":
            name = fields[1]
            row, column = int(fields[2]), int(fields[3])
            coefficient = Fraction(fields[4])
            exponent = tuple(map(int, fields[5:13]))
            matrices[name].setdefault((row, column), []).append((coefficient, exponent))
    assert len(matrices["F"]) == 16
    assert gdegrees == {i: 5 if i < 16 else 6 for i in range(136)}
    return matrices, gdegrees


def divides(a, b):
    return all(x <= y for x, y in zip(a, b))


def add_exp(a, b):
    return tuple(x + y for x, y in zip(a, b))


matrices, gdegrees = parse_input(INPUT)
assert all(
    len(matrices["F"][(0, i)]) == 1
    and matrices["F"][(0, i)][0][0] == 1
    and sum(matrices["F"][(0, i)][0][1]) == 3
    for i in range(16)
)
nonfaces = [matrices["F"][(0, i)][0][1] for i in range(16)]


def quotient_basis(degree):
    return [
        exponent
        for exponent in weak_compositions(degree, 8)
        if not any(divides(generator, exponent) for generator in nonfaces)
    ]


bases = {degree: quotient_basis(degree) for degree in range(1, 7)}
indices = {degree: {m: i for i, m in enumerate(basis)} for degree, basis in bases.items()}


def block_offsets(block_degrees):
    offsets = []
    total = 0
    for degree in block_degrees:
        offsets.append(total)
        total += len(bases[degree])
    return offsets, total


# Absolute C^0 -> C^1: a degree-zero derivation sends each x_j to A_1.
c0_blocks = [1] * 8
c1_blocks = [3] * 16
c0_offsets, c0_dimension = block_offsets(c0_blocks)
c1_offsets, c1_dimension = block_offsets(c1_blocks)
d0_entries = {}
for generator in range(16):
    fexp = nonfaces[generator]
    for variable in range(8):
        if fexp[variable] == 0:
            continue
        derivative = list(fexp)
        derivative[variable] -= 1
        derivative = tuple(derivative)
        for value_index, value_monomial in enumerate(bases[1]):
            target = add_exp(derivative, value_monomial)
            if target in indices[3]:
                row = c1_offsets[generator] + indices[3][target]
                column = c0_offsets[variable] + value_index
                d0_entries[(row, column)] = d0_entries.get((row, column), QQ(0)) + QQ(fexp[variable])
d0 = Matrix(QQ, c1_dimension, c0_dimension, d0_entries, sparse=True)


# Relative/absolute C^1 -> C^2 from d(f_j)=sum_i R_ij e_i.
c2_blocks = [4] * 30
c2_offsets, c2_dimension = block_offsets(c2_blocks)
d1_entries = {}
for (e_index, f_index), terms in matrices["R"].items():
    for coefficient, coefficient_monomial in terms:
        for value_index, value_monomial in enumerate(bases[3]):
            target = add_exp(coefficient_monomial, value_monomial)
            if target in indices[4]:
                row = c2_offsets[f_index] + indices[4][target]
                column = c1_offsets[e_index] + value_index
                key = (row, column)
                d1_entries[key] = d1_entries.get(key, QQ(0)) + QQ(coefficient)
d1 = Matrix(QQ, c2_dimension, c1_dimension, d1_entries, sparse=True)


# C^2 -> C^3 from the f-linear part (the first 30 rows) of every d(g_a).
c3_blocks = [gdegrees[i] for i in range(136)]
c3_offsets, c3_dimension = block_offsets(c3_blocks)
d2_entries = {}
for (source_row, g_index), terms in matrices["Z"].items():
    if source_row >= 30:
        continue
    target_degree = gdegrees[g_index]
    for coefficient, coefficient_monomial in terms:
        for value_index, value_monomial in enumerate(bases[4]):
            target = add_exp(coefficient_monomial, value_monomial)
            if target in indices[target_degree]:
                row = c3_offsets[g_index] + indices[target_degree][target]
                column = c2_offsets[source_row] + value_index
                key = (row, column)
                d2_entries[key] = d2_entries.get(key, QQ(0)) + QQ(coefficient)
d2 = Matrix(QQ, c3_dimension, c2_dimension, d2_entries, sparse=True)


rank_d0 = d0.rank()
rank_d1 = d1.rank()
rank_d2 = d2.rank()
relative_h1 = c1_dimension - rank_d1
absolute_h1 = relative_h1 - rank_d0
h2 = c2_dimension - rank_d2 - rank_d1

assert d1 * d0 == 0
assert d2 * d1 == 0
assert (rank_d0, relative_h1, absolute_h1, h2) == (56, 109, 53, 27)

print("input=" + str(INPUT))
for degree in range(1, 7):
    print(f"dim_A_{degree}={len(bases[degree])}")
print(f"C0_absolute_dimension={c0_dimension}")
print(f"C1_dimension={c1_dimension}")
print(f"C2_dimension={c2_dimension}")
print(f"C3_dimension={c3_dimension}")
print(f"rank_delta0={rank_d0}")
print(f"rank_delta1={rank_d1}")
print(f"rank_delta2={rank_d2}")
print("complex_composites_zero=true")
print(f"relative_H1_dimension={relative_h1}")
print(f"absolute_H1_dimension={absolute_h1}")
print(f"H2_dimension={h2}")
print("controller_complex_independent_check=passed")
