#!/usr/bin/env python3
from itertools import combinations, permutations
from collections import Counter
from fractions import Fraction

from M_FACETS import normalized_facets, vertices

FACETS = normalized_facets()
VERTICES = vertices()


def powerset(s):
    s = tuple(sorted(s))
    for r in range(len(s) + 1):
        for c in combinations(s, r):
            yield tuple(c)


def closure(facets):
    K = set()
    for F in facets:
        for G in powerset(F):
            K.add(G)
    return K


def vertices_of(K):
    return sorted({v for F in K for v in F})


def faces_of_dim(K, d):
    return sorted(F for F in K if len(F) == d + 1)


def f_vector(K, max_dim=None):
    if max_dim is None:
        max_dim = max(len(F) for F in K) - 1
    return tuple(len(faces_of_dim(K, d)) for d in range(max_dim + 1))


def link(face, K):
    face = tuple(sorted(face))
    face_set = set(face)

    if face not in K:
        return set()

    out = set()
    for G in K:
        G_set = set(G)
        if face_set & G_set:
            continue
        if tuple(sorted(face_set | G_set)) in K:
            out.add(tuple(sorted(G)))

    return out


def maximal_faces(K):
    return sorted(
        [F for F in K if F and not any(set(F) < set(G) for G in K)],
        key=lambda F: (len(F), F),
    )


def edge_valencies(facets):
    C = Counter()
    for F in facets:
        for e in combinations(F, 2):
            C[e] += 1
    return C


# ------------------------------------------------------------
# Homology over Q
# ------------------------------------------------------------

def rank_q(M):
    if not M:
        return 0

    A = [[Fraction(x) for x in row] for row in M]
    nrows = len(A)
    ncols = len(A[0]) if A else 0
    r = 0
    c = 0

    while r < nrows and c < ncols:
        piv = None
        for i in range(r, nrows):
            if A[i][c] != 0:
                piv = i
                break

        if piv is None:
            c += 1
            continue

        A[r], A[piv] = A[piv], A[r]
        p = A[r][c]
        A[r] = [x / p for x in A[r]]

        for i in range(nrows):
            if i != r and A[i][c] != 0:
                lam = A[i][c]
                A[i] = [A[i][j] - lam * A[r][j] for j in range(ncols)]

        r += 1
        c += 1

    return r


def boundary_matrix(K, k):
    k_faces = faces_of_dim(K, k)
    km1_faces = faces_of_dim(K, k - 1)

    row = {F: i for i, F in enumerate(km1_faces)}
    col = {F: j for j, F in enumerate(k_faces)}

    M = [[0 for _ in k_faces] for _ in km1_faces]

    for sigma in k_faces:
        j = col[sigma]
        for i in range(len(sigma)):
            tau = sigma[:i] + sigma[i + 1:]
            M[row[tau]][j] = -1 if i % 2 else 1

    return M


def homology_dim(K, k):
    ck = len(faces_of_dim(K, k))
    if ck == 0:
        return 0

    rank_dk = rank_q(boundary_matrix(K, k))
    rank_dkp1 = rank_q(boundary_matrix(K, k + 1))
    return ck - rank_dk - rank_dkp1


# ------------------------------------------------------------
# Model links appearing in Altmann-Christophersen Theorem 5.7
# ------------------------------------------------------------

def model_boundary_tetrahedron():
    V = [0, 1, 2, 3]
    return closure(combinations(V, 3))


def model_suspension_cycle(n):
    # Sigma E_n = suspension of an n-cycle.
    # Vertices 0,1 are suspension points.
    # Vertices 2,...,n+1 form the cycle.
    cycle = list(range(2, n + 2))
    facets = []

    for i in range(n):
        a = cycle[i]
        b = cycle[(i + 1) % n]
        facets.append((0, a, b))
        facets.append((1, a, b))

    return closure(facets)


def cyclic_boundary_3(n):
    # Boundary of cyclic polytope C(n,3), via Gale evenness.
    V = list(range(n))
    facets = []

    for F in combinations(V, 3):
        Fset = set(F)
        outside = [v for v in V if v not in Fset]
        ok = True

        for a, b in combinations(outside, 2):
            lo, hi = sorted((a, b))
            between = sum(1 for x in F if lo < x < hi)
            if between % 2 != 0:
                ok = False
                break

        if ok:
            facets.append(F)

    return closure(facets)


def is_isomorphic(K1, K2):
    V1 = vertices_of(K1)
    V2 = vertices_of(K2)

    if len(V1) != len(V2):
        return False
    if f_vector(K1) != f_vector(K2):
        return False

    K2 = set(K2)

    for perm in permutations(V2):
        mp = dict(zip(V1, perm))
        image = {tuple(sorted(mp[v] for v in F)) for F in K1}
        if image == K2:
            return True

    return False


def classify_link(L):
    nverts = len(vertices_of(L))
    hits = []

    if nverts == 4 and is_isomorphic(L, model_boundary_tetrahedron()):
        hits.append("d3")

    if nverts >= 5:
        n = nverts - 2
        if is_isomorphic(L, model_suspension_cycle(n)):
            if n == 3:
                hits.append("e3")
            elif n == 4:
                hits.append("e4")
            elif n >= 5:
                hits.append("e_ge_5")

    if nverts >= 6 and is_isomorphic(L, cyclic_boundary_3(nverts)):
        hits.append("c_ge_6")

    return hits


def main():
    K = closure(FACETS)

    assert VERTICES == [1, 2, 3, 4, 5, 6, 7, 8]
    assert f_vector(K, 3) == (8, 28, 40, 20)

    edge_val = edge_valencies(FACETS)
    val_hist = Counter(edge_val.values())

    f1_3 = val_hist[3]
    f1_4 = val_hist[4]
    h2 = homology_dim(K, 2)

    print("Basic checks")
    print("------------")
    print("vertices:", VERTICES)
    print("f-vector:", f_vector(K, 3))
    print("edge valency histogram:", dict(sorted(val_hist.items())))
    print("h^2(K) = b2(K) =", h2)
    print()

    print("Edges contributing to T^1")
    print("-------------------------")

    print(f"f_1^(3) = {f1_3}")
    for e, v in sorted(edge_val.items()):
        if v == 3:
            print("  valency 3:", e)
    print(f"contribution 5*f_1^(3) = {5 * f1_3}")
    print()

    print(f"f_1^(4) = {f1_4}")
    for e, v in sorted(edge_val.items()):
        if v == 4:
            print("  valency 4:", e)
    print(f"contribution 2*f_1^(4) = {2 * f1_4}")
    print()

    counts = Counter()

    print("Vertex links")
    print("------------")
    for v in VERTICES:
        L = link((v,), K)
        hits = classify_link(L)

        print(f"Link({v})")
        print("  f-vector:", f_vector(L, 2))
        print("  facets:", maximal_faces(L))
        print("  AC type hits:", hits if hits else "none")
        print()

        for h in hits:
            counts[h] += 1

    d3 = counts["d3"]
    e3 = counts["e3"]
    e4 = counts["e4"]
    e_ge_5 = counts["e_ge_5"]
    c_ge_6 = counts["c_ge_6"]

    terms = {
        "11*d3": 11 * d3,
        "5*e3": 5 * e3,
        "3*e4": 3 * e4,
        "e_ge_5": e_ge_5,
        "c_ge_6": c_ge_6,
        "5*f_1^(3)": 5 * f1_3,
        "2*f_1^(4)": 2 * f1_4,
        "h^2(K)": h2,
    }

    dim_T1 = sum(terms.values())

    print("Altmann-Christophersen Theorem 5.7 contribution table")
    print("------------------------------------------------------")
    print(f"d3      = {d3}")
    print(f"e3      = {e3}")
    print(f"e4      = {e4}")
    print(f"e_ge_5  = {e_ge_5}")
    print(f"c_ge_6  = {c_ge_6}")
    print(f"f_1^(3) = {f1_3}")
    print(f"f_1^(4) = {f1_4}")
    print(f"h^2(K)  = {h2}")
    print()

    for name, value in terms.items():
        print(f"{name:12s} = {value}")

    print("------------")
    print("dim T^1_P(K) =", dim_T1)

    assert dim_T1 == 53


if __name__ == "__main__":
    main()
