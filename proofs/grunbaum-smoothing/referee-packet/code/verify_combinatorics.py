#!/usr/bin/env python3
"""Exact combinatorial checks for the special fibre.

The only input is data/grunbaum_facets.txt.  Boundary-matrix ranks are
computed over QQ by Fraction Gaussian elimination.  Reisner's criterion is
then checked for every face, including the empty face.
"""

from fractions import Fraction
from itertools import combinations
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
FACET_FILE = ROOT / "data/grunbaum_facets.txt"
OUTPUT = ROOT / "verification/combinatorics_QQ.txt"
VERTICES = frozenset(range(1, 9))
EXPECTED_MINIMAL_NONFACES = {
    frozenset(t) for t in (
        (6, 7, 8), (4, 6, 8), (3, 7, 8), (3, 5, 7),
        (3, 4, 8), (2, 7, 8), (2, 5, 7), (2, 5, 6),
        (2, 4, 7), (2, 4, 6), (1, 4, 6), (1, 4, 5),
        (1, 3, 8), (1, 3, 6), (1, 3, 5), (1, 2, 5),
    )
}


def read_facets():
    facets = []
    for line in FACET_FILE.read_text().splitlines():
        line = line.split("#", 1)[0].strip()
        if line:
            facets.append(frozenset(map(int, line.split())))
    return facets


def all_faces(facets):
    answer = {frozenset()}
    for facet in facets:
        ordered = sorted(facet)
        for size in range(1, len(ordered) + 1):
            answer.update(frozenset(c) for c in combinations(ordered, size))
    return answer


def matrix_rank(matrix):
    if not matrix:
        return 0
    rows = [[Fraction(value) for value in row] for row in matrix]
    row_count = len(rows)
    column_count = len(rows[0]) if rows else 0
    pivot_row = 0
    for column in range(column_count):
        pivot = next((r for r in range(pivot_row, row_count)
                      if rows[r][column]), None)
        if pivot is None:
            continue
        rows[pivot_row], rows[pivot] = rows[pivot], rows[pivot_row]
        scale = rows[pivot_row][column]
        rows[pivot_row] = [entry / scale for entry in rows[pivot_row]]
        for row in range(row_count):
            if row == pivot_row or not rows[row][column]:
                continue
            multiple = rows[row][column]
            rows[row] = [a - multiple * b
                         for a, b in zip(rows[row], rows[pivot_row])]
        pivot_row += 1
        if pivot_row == row_count:
            break
    return pivot_row


def boundary_rank(faces_by_dimension, dimension):
    """Rank of d_dimension: C_dimension -> C_(dimension-1)."""
    if dimension <= 0:
        return 0
    columns = faces_by_dimension.get(dimension, [])
    rows = faces_by_dimension.get(dimension - 1, [])
    row_index = {face: index for index, face in enumerate(rows)}
    matrix = [[0 for _ in columns] for _ in rows]
    for column, face in enumerate(columns):
        ordered = sorted(face)
        for removed in range(len(ordered)):
            subface = frozenset(ordered[:removed] + ordered[removed + 1:])
            matrix[row_index[subface]][column] = (-1) ** removed
    return matrix_rank(matrix)


def reduced_betti_numbers(complex_faces):
    maximum = max(len(face) for face in complex_faces) - 1
    by_dimension = {
        dimension: sorted(
            (face for face in complex_faces if len(face) == dimension + 1),
            key=lambda face: tuple(sorted(face)),
        )
        for dimension in range(maximum + 1)
    }
    ranks = {dimension: boundary_rank(by_dimension, dimension)
             for dimension in range(1, maximum + 1)}
    betti = {}
    for dimension in range(maximum + 1):
        chains = len(by_dimension[dimension])
        incoming = ranks.get(dimension + 1, 0)
        outgoing = ranks.get(dimension, 0)
        value = chains - outgoing - incoming
        if dimension == 0:
            value -= 1
        betti[dimension] = value
    return maximum, betti


def main():
    facets = read_facets()
    assert len(facets) == 20 and len(set(facets)) == 20
    assert all(len(facet) == 4 and facet <= VERTICES for facet in facets)
    faces = all_faces(facets)

    nonfaces = []
    ordered_vertices = sorted(VERTICES)
    for size in range(1, len(ordered_vertices) + 1):
        for subset_tuple in combinations(ordered_vertices, size):
            subset = frozenset(subset_tuple)
            if subset in faces:
                continue
            if all(frozenset(proper) in faces
                   for proper in combinations(subset_tuple, size - 1)):
                nonfaces.append(subset)
    assert set(nonfaces) == EXPECTED_MINIMAL_NONFACES

    ridges = [face for face in faces if len(face) == 3]
    assert all(sum(ridge < facet for facet in facets) == 2 for ridge in ridges)
    adjacency = {
        i: {j for j in range(len(facets)) if i != j
            and len(facets[i] & facets[j]) == 3}
        for i in range(len(facets))
    }
    reached = {0}
    frontier = [0]
    while frontier:
        current = frontier.pop()
        for neighbor in adjacency[current] - reached:
            reached.add(neighbor)
            frontier.append(neighbor)
    assert len(reached) == len(facets)

    top_betti = None
    checked_links = 0
    for sigma in sorted(faces, key=lambda f: (len(f), tuple(sorted(f)))):
        link = {
            tau for tau in faces
            if not (tau & sigma) and (tau | sigma) in faces
        }
        link_dimension, betti = reduced_betti_numbers(link)
        assert all(betti[degree] == 0 for degree in range(link_dimension))
        if link_dimension >= 0:
            assert betti[link_dimension] == 1
        if not sigma:
            assert link_dimension == 3
            top_betti = tuple(betti[i] for i in range(4))
        checked_links += 1

    lines = [
        "field=QQ",
        "vertices=8",
        "tetrahedral_facets=20",
        "minimal_nonfaces=16",
        "minimal_nonfaces_all_cubic=true",
        "pure_dimension=3",
        "every_ridge_in_two_facets=true",
        "facet_dual_graph_connected=true",
        "faces_checked_for_reisner=%d" % checked_links,
        "all_links_lower_reduced_homology_zero=true",
        "all_nonempty_dimensional_links_top_betti_one=true",
        "whole_complex_reduced_betti=%s" % (top_betti,),
        "stanley_reisner_ring_cohen_macaulay=true",
    ]
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text("\n".join(lines) + "\n")
    print("\n".join(lines))
    print("certificate=%s" % OUTPUT)


if __name__ == "__main__":
    main()
