#!/usr/bin/env python3
"""Compute dim T^2_{A_M,0} using Altmann--Christophersen Proposition 4.8.

The calculation reconstructs M and every link from the canonical facet list.
It uses no deformation bases, obstruction equations, or cached algebra data.
"""

from collections import Counter
from fractions import Fraction
from itertools import combinations
from math import comb
from pathlib import Path
import sys


REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO_ROOT))

from foundations.M_FACETS import normalized_facets, vertices


def subsets(face):
    face = tuple(sorted(face))
    for size in range(len(face) + 1):
        yield from combinations(face, size)


def proper_subsets(face):
    face = tuple(sorted(face))
    for size in range(len(face)):
        yield from combinations(face, size)


def closure(facets):
    return {subface for facet in facets for subface in subsets(facet)}


def face_dimension(face):
    return len(face) - 1


def complex_dimension(complex_):
    return max(map(face_dimension, complex_)) if complex_ else -2


def faces_by_dimension(complex_):
    result = {}
    for face in complex_:
        result.setdefault(face_dimension(face), []).append(tuple(sorted(face)))
    return {dimension: sorted(set(faces)) for dimension, faces in result.items()}


def f_vector(complex_, maximum_dimension=None):
    if maximum_dimension is None:
        maximum_dimension = complex_dimension(complex_)
    by_dimension = faces_by_dimension(complex_)
    return tuple(
        len(by_dimension.get(dimension, []))
        for dimension in range(maximum_dimension + 1)
    )


def complex_vertices(complex_):
    return sorted({vertex for face in complex_ for vertex in face})


def maximal_faces(complex_):
    return sorted(
        face for face in complex_
        if face and not any(set(face) < set(other) for other in complex_)
    )


def link(face, complex_):
    """Compute the link using only membership in the given complex."""
    face = tuple(sorted(face))
    if face not in complex_:
        return set()
    face_set = set(face)
    return {
        other
        for other in complex_
        if face_set.isdisjoint(other)
        and tuple(sorted(face_set | set(other))) in complex_
    }


def simplex_boundary_is_contained(b, complex_):
    return all(face in complex_ for face in proper_subsets(b))


def common_link_L_b(b, complex_):
    """Return L_b = intersection_{b' proper subset b} link(b', K)."""
    links = [link(face, complex_) for face in proper_subsets(b)]
    return set.intersection(*links) if links else set(complex_)


# ---------- exact reduced simplicial homology over QQ ----------

def rational_rank(matrix):
    if not matrix:
        return 0
    work = [[Fraction(entry) for entry in row] for row in matrix]
    n_rows, n_columns = len(work), len(work[0])
    pivot_row = 0
    for column in range(n_columns):
        pivot = next(
            (row for row in range(pivot_row, n_rows) if work[row][column]),
            None,
        )
        if pivot is None:
            continue
        work[pivot_row], work[pivot] = work[pivot], work[pivot_row]
        pivot_value = work[pivot_row][column]
        work[pivot_row] = [entry / pivot_value for entry in work[pivot_row]]
        for row in range(n_rows):
            if row != pivot_row and work[row][column]:
                multiple = work[row][column]
                work[row] = [
                    a - multiple * b
                    for a, b in zip(work[row], work[pivot_row])
                ]
        pivot_row += 1
        if pivot_row == n_rows:
            break
    return pivot_row


def boundary_matrix(complex_, dimension):
    """Augmented simplicial boundary C_dimension -> C_(dimension-1)."""
    by_dimension = faces_by_dimension(complex_)
    columns = by_dimension.get(dimension, [])
    rows = by_dimension.get(dimension - 1, [])
    row_index = {face: index for index, face in enumerate(rows)}
    matrix = [[0] * len(columns) for _ in rows]
    for column, face in enumerate(columns):
        for index in range(len(face)):
            subface = face[:index] + face[index + 1:]
            matrix[row_index[subface]][column] = (-1) ** index
    return matrix


def product_is_zero(left, right):
    """Check a matrix product without constructing it."""
    if not left or not right:
        return True
    for row in left:
        for column in zip(*right):
            if sum(a * b for a, b in zip(row, column)) != 0:
                return False
    return True


def reduced_homology_dimension(complex_, degree):
    """Return dim H-tilde_degree(complex_; QQ), including degree -1."""
    complex_ = set(complex_)
    if degree < -1:
        return 0
    if degree == -1:
        # {()} is our simplicial model for the empty geometric realization.
        return int(complex_ == {()})

    boundary = boundary_matrix(complex_, degree)
    next_boundary = boundary_matrix(complex_, degree + 1)
    assert product_is_zero(boundary, next_boundary)

    chain_dimension = len(faces_by_dimension(complex_).get(degree, []))
    return (
        chain_dimension
        - rational_rank(boundary)
        - rational_rank(next_boundary)
    )


# Regression test for the convention explicitly required in Proposition 4.8.
assert reduced_homology_dimension({()}, -1) == 1


# ---------- Altmann--Christophersen formulas ----------

def U_tilde_b(b, complex_):
    b_set = set(b)
    return {
        face
        for face in complex_
        if any(
            tuple(sorted((set(face) | b_set) - {vertex})) not in complex_
            for vertex in b
        )
    }


def dim_T1_empty_minus_b(b, complex_):
    if len(b) < 2:
        return 0
    return int(not U_tilde_b(b, complex_))


def dim_T2_empty_minus_b(b, complex_):
    """Return Proposition 4.8 data for T^2_{empty-b}(K)."""
    b = tuple(sorted(b))
    assert b
    n = complex_dimension(complex_)

    # Proposition 4.8 first gives vanishing unless boundary(b) is in K.
    if not simplex_boundary_is_contained(b, complex_):
        return {
            "dimension": 0, "L_b": set(), "homology_degree": None,
            "homology_dimension": 0, "case": "boundary(b) not contained",
        }

    L_b = common_link_L_b(b, complex_)
    homology_degree = n - len(b)

    if b not in complex_:
        # Proposition 4.8(i), specialized to the sphere K:
        # T^2_{empty-b}(K) = H-tilde_{n-|b|}(L_b; k).
        homology_dimension = reduced_homology_dimension(L_b, homology_degree)
        return {
            "dimension": homology_dimension, "L_b": L_b,
            "homology_degree": homology_degree,
            "homology_dimension": homology_dimension,
            "case": "b not in K",
        }

    if len(b) == 1:
        # Proposition 4.8(ii), for a vertex b in an oriented n-manifold:
        # T^2_{empty-b}(K) = H-tilde_{n-1}(K; k).
        homology_degree = n - 1
        homology_dimension = reduced_homology_dimension(
            complex_, homology_degree
        )
        return {
            "dimension": homology_dimension, "L_b": L_b,
            "homology_degree": homology_degree,
            "homology_dimension": homology_dimension,
            "case": "b is a vertex of K",
        }

    if dim_T1_empty_minus_b(b, complex_):
        # Proposition 4.8(ii): for b in K with |b| >= 2, T^2 vanishes
        # whenever the corresponding T^1_{empty-b} is nonzero.
        return {
            "dimension": 0, "L_b": L_b,
            "homology_degree": homology_degree,
            "homology_dimension": reduced_homology_dimension(
                L_b, homology_degree
            ),
            "case": "b in K, |b| >= 2, T1 nonzero",
        }

    # Remaining case of Proposition 4.8(ii), for b in K and |b| >= 2:
    # dim T^2 = max(dim H-tilde_{n-|b|}(L_b; k) - 1, 0).
    homology_dimension = reduced_homology_dimension(L_b, homology_degree)
    return {
        "dimension": max(homology_dimension - 1, 0), "L_b": L_b,
        "homology_degree": homology_degree,
        "homology_dimension": homology_dimension,
        "case": "b in K, |b| >= 2, T1 zero",
    }


def degree_zero_multiplicity(support_size, b_size):
    """Count positive exponent vectors on A whose entries sum to |b|."""
    if b_size < support_size:
        return 0
    # Stars and bars gives C(|b|-1, |A|-1) positive compositions.
    return comb(b_size - 1, support_size - 1)


def degree_zero_T2_pieces(complex_):
    pieces = []
    checked = 0
    support_faces = sorted(
        (face for face in complex_ if face), key=lambda face: (len(face), face)
    )
    for support in support_faces:
        support_link = link(support, complex_)
        link_vertices = complex_vertices(support_link)
        for b_size in range(len(support), len(link_vertices) + 1):
            for b in combinations(link_vertices, b_size):
                checked += 1
                local = dim_T2_empty_minus_b(b, support_link)
                if local["dimension"] == 0:
                    continue
                multiplicity = degree_zero_multiplicity(len(support), len(b))
                pieces.append({
                    "A": support,
                    "b": b,
                    "link": support_link,
                    **local,
                    "multiplicity": multiplicity,
                    "contribution": local["dimension"] * multiplicity,
                })
    return pieces, checked


def print_piece(piece):
    print("A =", piece["A"])
    print("b =", piece["b"])
    print("link(A) facets =", maximal_faces(piece["link"]))
    print("L_b =", sorted(piece["L_b"]))
    print("L_b facets =", maximal_faces(piece["L_b"]))
    print("Proposition 4.8 case =", piece["case"])
    print("homology degree used =", piece["homology_degree"])
    print("reduced homology dimension =", piece["homology_dimension"])
    print("dim T2_-b =", piece["dimension"])
    print("degree-zero multiplicity =", piece["multiplicity"])
    print("contribution =", piece["contribution"])
    print()


def main():
    facets = normalized_facets()
    complex_ = closure(facets)

    assert vertices() == list(range(1, 9))
    assert f_vector(complex_, 3) == (8, 28, 40, 20)
    assert all(facet in complex_ for facet in facets)

    # Check the augmented simplicial boundary identities for M itself.
    for dimension in range(3):
        assert product_is_zero(
            boundary_matrix(complex_, dimension),
            boundary_matrix(complex_, dimension + 1),
        )

    pieces, checked = degree_zero_T2_pieces(complex_)

    print("Basic data")
    print("----------")
    print("vertices =", vertices())
    print("f-vector =", f_vector(complex_, 3))
    print("dimension of M =", complex_dimension(complex_))
    print("simplicial boundary maps compose to zero = True")
    print()

    ordinary_pieces = [
        piece for piece in pieces
        if not (
            piece["homology_degree"] == -1
            and piece["L_b"] == {()}
        )
    ]
    empty_realization_pieces = [
        piece for piece in pieces
        if piece["homology_degree"] == -1 and piece["L_b"] == {()}
    ]

    print("Nonzero pieces visible with the legacy H-tilde_-1 convention")
    print("------------------------------------------------------------")
    for piece in ordinary_pieces:
        print_piece(piece)

    print("Additional pieces from H-tilde_-1({empty face}) = QQ")
    print("-----------------------------------------------------")
    for piece in empty_realization_pieces:
        print_piece(piece)

    breakdown = Counter()
    for piece in pieces:
        breakdown[(len(piece["A"]), len(piece["b"]))] += piece["contribution"]
    total = sum(piece["contribution"] for piece in pieces)

    print("Summary")
    print("-------")
    print("number of candidate pairs checked =", checked)
    print("number of nonzero support-pieces =", len(pieces))
    print("breakdown by (|A|, |b|):")
    for sizes in sorted(breakdown):
        print(" ", sizes, "=", breakdown[sizes])
    print("total dim T^2_{A_M,0} =", total)

    # Regression check applied only after the incidence calculation is complete.
    assert total == 27


if __name__ == "__main__":
    main()
