#!/usr/bin/env python3
"""Independently compute dim T^1 using Altmann--Christophersen, Theorem 5.7.

The vertex-link terms detect a short list of exceptional triangulated
2-spheres, while the edge terms count low-valency edges.  Everything below
is reconstructed from the canonical facets, independently of syzygy data.
"""

from collections import Counter
from fractions import Fraction
from itertools import combinations
from pathlib import Path
import sys


REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO_ROOT))

from foundations.M_FACETS import normalized_facets


def faces_of_size(facets, size):
    """Return all faces with the requested number of vertices."""
    return sorted({face for facet in facets for face in combinations(facet, size)})


def complex_edges(triangles):
    return {edge for triangle in triangles for edge in combinations(triangle, 2)}


def boundary_tetrahedron():
    return {tuple(face) for face in combinations(range(4), 3)}


def suspension_polygon(n):
    """Facets of the suspension of the boundary of an n-gon."""
    apices = (n, n + 1)
    return {
        tuple(sorted((i, (i + 1) % n, apex)))
        for i in range(n)
        for apex in apices
    }


def boundary_cyclic_3_polytope(n):
    """Facets of boundary(C(n,3)) from AC, Section 2.1.

    This realizes boundary(Delta_1)*C_(n-3) union
    boundary(C_(n-3))*Delta_1, where the chain has vertices 1,...,n-2.
    """
    assert n >= 4
    triangles = {
        tuple(sorted((apex, i, i + 1)))
        for apex in (0, n - 1)
        for i in range(1, n - 2)
    }
    triangles.update({(0, 1, n - 1), (0, n - 2, n - 1)})
    return triangles


def isomorphic_triangular_complexes(source, target):
    """Test combinatorial isomorphism by a pruned brute-force bijection."""
    source = {tuple(sorted(face)) for face in source}
    target = {tuple(sorted(face)) for face in target}
    source_vertices = sorted({v for face in source for v in face})
    target_vertices = sorted({v for face in target for v in face})

    if len(source_vertices) != len(target_vertices) or len(source) != len(target):
        return False

    source_edges = complex_edges(source)
    target_edges = complex_edges(target)
    if len(source_edges) != len(target_edges):
        return False

    def signatures(vertices, edges, triangles):
        return {
            v: (
                sum(v in edge for edge in edges),
                sum(v in triangle for triangle in triangles),
            )
            for v in vertices
        }

    source_signature = signatures(source_vertices, source_edges, source)
    target_signature = signatures(target_vertices, target_edges, target)
    if Counter(source_signature.values()) != Counter(target_signature.values()):
        return False

    ordered_source = sorted(source_vertices, key=lambda v: source_signature[v])
    mapping = {}
    used = set()

    def compatible(source_vertex, target_vertex):
        for other_source, other_target in mapping.items():
            source_is_edge = tuple(sorted((source_vertex, other_source))) in source_edges
            target_is_edge = tuple(sorted((target_vertex, other_target))) in target_edges
            if source_is_edge != target_is_edge:
                return False
        return True

    def search(position):
        if position == len(ordered_source):
            mapped = {
                tuple(sorted(mapping[v] for v in triangle)) for triangle in source
            }
            return mapped == target

        source_vertex = ordered_source[position]
        for target_vertex in target_vertices:
            if target_vertex in used:
                continue
            if source_signature[source_vertex] != target_signature[target_vertex]:
                continue
            if not compatible(source_vertex, target_vertex):
                continue
            mapping[source_vertex] = target_vertex
            used.add(target_vertex)
            if search(position + 1):
                return True
            used.remove(target_vertex)
            del mapping[source_vertex]
        return False

    return search(0)


def classify_link(triangles):
    n_vertices = len({v for face in triangles for v in face})
    candidates = []
    if n_vertices == 4:
        candidates.append(("boundary(Delta_3)", boundary_tetrahedron()))
    if n_vertices >= 5:
        polygon_size = n_vertices - 2
        if polygon_size == 3:
            label = "Suspension(E_3)"
        elif polygon_size == 4:
            label = "Suspension(E_4)"
        else:
            label = f"Suspension(E_{polygon_size}), n >= 5"
        candidates.append((label, suspension_polygon(polygon_size)))
    if n_vertices >= 6:
        candidates.append(
            (f"boundary(C({n_vertices},3)), n >= 6",
             boundary_cyclic_3_polytope(n_vertices))
        )

    matches = [
        label for label, model in candidates
        if isomorphic_triangular_complexes(triangles, model)
    ]
    assert len(matches) <= 1, f"overlapping special link types: {matches}"
    return matches[0] if matches else "none of the special types"


def boundary_matrix(higher_faces, lower_faces):
    """Matrix of the oriented simplicial boundary, stored by rows."""
    row_index = {face: i for i, face in enumerate(lower_faces)}
    matrix = [[0] * len(higher_faces) for _ in lower_faces]
    for column, face in enumerate(higher_faces):
        for i in range(len(face)):
            subface = face[:i] + face[i + 1:]
            matrix[row_index[subface]][column] = (-1) ** i
    return matrix


def matrix_rank(matrix):
    """Exact Gaussian-elimination rank over QQ."""
    work = [[Fraction(entry) for entry in row] for row in matrix]
    if not work:
        return 0
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


def matrix_product(left, right):
    return [
        [sum(a * b for a, b in zip(row, column)) for column in zip(*right)]
        for row in left
    ]


# Exercise each model family before classifying the links of M.
assert classify_link(boundary_tetrahedron()) == "boundary(Delta_3)"
assert classify_link(suspension_polygon(3)) == "Suspension(E_3)"
assert classify_link(suspension_polygon(4)) == "Suspension(E_4)"
assert classify_link(suspension_polygon(5)) == "Suspension(E_5), n >= 5"
assert classify_link(boundary_cyclic_3_polytope(6)) == \
    "boundary(C(6,3)), n >= 6"

facets = sorted(normalized_facets())
vertices = faces_of_size(facets, 1)
edges = faces_of_size(facets, 2)
triangles = faces_of_size(facets, 3)

assert len(vertices) == 8
assert len(facets) == 20
assert all(len(facet) == 4 for facet in facets)

triangle_cofacets = Counter(
    triangle for facet in facets for triangle in combinations(facet, 3)
)
assert set(triangle_cofacets) == set(triangles)
assert set(triangle_cofacets.values()) == {2}

print("Facet-data checks")
print("-----------------")
print("number of vertices =", len(vertices))
print("number of tetrahedral facets =", len(facets))
print("every triangle lies in exactly two tetrahedra = True")
print("f-vector =", (len(vertices), len(edges), len(triangles), len(facets)))
print()

edge_valency = Counter()
for edge in edges:
    edge_valency[sum(set(edge) <= set(triangle) for triangle in triangles)] += 1

print("Edge valencies")
print("--------------")
print("valency  number of edges")
for valency in sorted(edge_valency):
    print(f"{valency:<8} {edge_valency[valency]}")
f1_3 = edge_valency[3]
f1_4 = edge_valency[4]
print("f_1^(3) =", f1_3)
print("f_1^(4) =", f1_4)
print()

link_classifications = {}
print("Vertex links")
print("------------")
for (vertex,) in vertices:
    link_triangles = {
        tuple(v for v in facet if v != vertex)
        for facet in facets if vertex in facet
    }
    link_vertices = {v for face in link_triangles for v in face}
    link_edges = complex_edges(link_triangles)
    classification = classify_link(link_triangles)
    link_classifications[vertex] = classification
    print("vertex =", vertex)
    print("  number of link vertices =", len(link_vertices))
    print("  number of link edges =", len(link_edges))
    print("  number of link triangles =", len(link_triangles))
    print("  maximal faces =", sorted(link_triangles))
    print("  classification =", classification)
print()

d_3 = sum(value == "boundary(Delta_3)" for value in link_classifications.values())
e_3 = sum(value == "Suspension(E_3)" for value in link_classifications.values())
e_4 = sum(value == "Suspension(E_4)" for value in link_classifications.values())
e_ge_5 = sum("Suspension(E_" in value and "n >= 5" in value
             for value in link_classifications.values())
c_ge_6 = sum(value.startswith("boundary(C(") for value in link_classifications.values())

print("Special vertex-link counts")
print("--------------------------")
print("d_3 =", d_3)
print("e_3 =", e_3)
print("e_4 =", e_4)
print("e_ge_5 =", e_ge_5)
print("c_ge_6 =", c_ge_6)
print()

d3_to_d2 = boundary_matrix(facets, triangles)
d2_to_d1 = boundary_matrix(triangles, edges)
composition = matrix_product(d2_to_d1, d3_to_d2)
boundary_squared_zero = all(entry == 0 for row in composition for entry in row)
assert boundary_squared_zero

rank_d3 = matrix_rank(d3_to_d2)
rank_d2 = matrix_rank(d2_to_d1)
h2 = len(triangles) - rank_d2 - rank_d3

print("Rational homology")
print("-----------------")
print("rank(C_3 -> C_2) =", rank_d3)
print("rank(C_2 -> C_1) =", rank_d2)
print("boundary maps compose to zero =", boundary_squared_zero)
print("h^2(K) = dim H_2(K; QQ) =", h2)
print()

contributions = [
    ("11*d_3", 11 * d_3),
    ("5*e_3", 5 * e_3),
    ("3*e_4", 3 * e_4),
    ("e_ge_5", e_ge_5),
    ("c_ge_6", c_ge_6),
    ("5*f1_3", 5 * f1_3),
    ("2*f1_4", 2 * f1_4),
    ("h2", h2),
]
dim_T1 = sum(value for _, value in contributions)

print("Altmann--Christophersen Theorem 5.7")
print("------------------------------------")
for label, value in contributions:
    print(f"{label:<11} = {value}")
print("----------------")
print("dim T^1     =", dim_T1)

# Regression check, deliberately applied only after deriving the total.
assert dim_T1 == 53
