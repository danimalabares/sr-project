#!/usr/bin/env python3
from itertools import combinations
from collections import Counter
from fractions import Fraction
from math import comb

from M_FACETS import normalized_facets, vertices

FACETS = normalized_facets()
VERTICES = vertices()


def powerset(s):
    s = tuple(sorted(s))
    for r in range(len(s) + 1):
        for c in combinations(s, r):
            yield tuple(c)


def proper_subsets(s):
    s = tuple(sorted(s))
    for r in range(len(s)):
        for c in combinations(s, r):
            yield tuple(c)


def closure(facets):
    K = set()
    for F in facets:
        for G in powerset(F):
            K.add(tuple(sorted(G)))
    return K


def dim_face(f):
    return len(f) - 1


def dim_complex(K):
    return max(dim_face(f) for f in K) if K else -2


def faces_by_dim(K):
    D = {}
    for f in K:
        D.setdefault(dim_face(f), []).append(tuple(sorted(f)))
    for d in D:
        D[d] = sorted(set(D[d]))
    return D


def f_vector(K, max_dim=None):
    if max_dim is None:
        max_dim = dim_complex(K)
    D = faces_by_dim(K)
    return tuple(len(D.get(d, [])) for d in range(max_dim + 1))


def vertices_of(K):
    return sorted({v for f in K for v in f})


def link(face, K):
    face = tuple(sorted(face))
    if face not in K:
        return set()
    A = set(face)
    out = set()
    for g in K:
        B = set(g)
        if A & B:
            continue
        if tuple(sorted(A | B)) in K:
            out.add(tuple(sorted(g)))
    return out


def boundary_of_simplex_in_complex(b, K):
    return all(bp in K for bp in proper_subsets(b))


def L_b(b, K):
    """Intersection of link(bp,K) over proper subsets bp of b."""
    current = None
    for bp in proper_subsets(b):
        lk = link(bp, K)
        current = set(lk) if current is None else current & set(lk)
    return current if current is not None else set(K)


# ---------- reduced homology over Q ----------

def rank_q(M):
    if not M:
        return 0
    A = [[Fraction(x) for x in row] for row in M]
    nrows, ncols = len(A), len(A[0])
    r = c = 0
    while r < nrows and c < ncols:
        piv = next((i for i in range(r, nrows) if A[i][c] != 0), None)
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
    D = faces_by_dim(K)
    k_faces = D.get(k, [])
    km1_faces = D.get(k - 1, [])
    row = {f: i for i, f in enumerate(km1_faces)}
    col = {f: j for j, f in enumerate(k_faces)}
    M = [[0 for _ in k_faces] for _ in km1_faces]
    for sigma in k_faces:
        j = col[sigma]
        for i in range(len(sigma)):
            tau = sigma[:i] + sigma[i + 1:]
            M[row[tau]][j] = -1 if i % 2 else 1
    return M


def htilde(K, k):
    K = set(K)
    if k < -1:
        return 0
    if k == -1:
        return 1 if len(K) == 0 else 0
    D = faces_by_dim(K)
    ck = len(D.get(k, []))
    if ck == 0:
        return 0
    return max(ck - rank_q(boundary_matrix(K, k)) - rank_q(boundary_matrix(K, k + 1)), 0)


# ---------- AC formulas ----------

def U_tilde_b(b, K):
    b = tuple(sorted(b))
    B = set(b)
    out = set()
    for f in K:
        U = set(f) | B
        if any(tuple(sorted(U - {v})) not in K for v in b):
            out.add(tuple(sorted(f)))
    return out


def dim_T1_empty_minus_b(b, K):
    b = tuple(sorted(b))
    if len(b) < 2:
        return 0
    return 1 if len(U_tilde_b(b, K)) == 0 else 0


def dim_T2_empty_minus_b(b, K):
    b = tuple(sorted(b))
    if len(b) == 0:
        return 0
    n = dim_complex(K)
    if not boundary_of_simplex_in_complex(b, K):
        return 0
    L = L_b(b, K)
    if b not in K:
        return htilde(L, n - len(b))
    if len(b) == 1:
        return htilde(K, n - 1)
    if dim_T1_empty_minus_b(b, K) != 0:
        return 0
    return max(htilde(L, n - len(b)) - 1, 0)


def multiplicity_for_degree_zero(support_size, b_size):
    if b_size < support_size:
        return 0
    return comb(b_size - 1, support_size - 1)


def degree_zero_T2_pieces(K):
    pieces = []
    checked = 0
    faces = sorted([a for a in K if len(a) > 0], key=lambda a: (len(a), a))
    for a in faces:
        LK = link(a, K)
        VLK = vertices_of(LK)
        s = len(a)
        for r in range(s, len(VLK) + 1):
            for b in combinations(VLK, r):
                checked += 1
                d = dim_T2_empty_minus_b(b, LK)
                if d == 0:
                    continue
                m = multiplicity_for_degree_zero(s, r)
                pieces.append((a, tuple(sorted(b)), d, m, d * m, dim_complex(LK)))
    return pieces, checked


def main():
    K = closure(FACETS)
    assert VERTICES == [1, 2, 3, 4, 5, 6, 7, 8]
    assert f_vector(K, 3) == (8, 28, 40, 20)

    pieces, checked = degree_zero_T2_pieces(K)

    print("Basic checks")
    print("------------")
    print("vertices =", VERTICES)
    print("f-vector =", f_vector(K, 3))
    print("dim K =", dim_complex(K))
    print()

    print("Nonzero degree-zero pieces")
    print("--------------------------")
    for a, b, d, m, contrib, lkdim in pieces:
        print(f"a={a}, b={b}, base_dim={d}, mult={m}, contribution={contrib}, dim_link(a)={lkdim}")

    total = sum(p[4] for p in pieces)
    print()
    print("Summary")
    print("-------")
    print("candidate pairs checked =", checked)
    print("number of nonzero support-pieces =", len(pieces))
    print("total dim T^2_{A_M,0} =", total)
    print()

    print("Breakdown by (|support(a)|, |b|)")
    print("--------------------------------")
    breakdown = Counter()
    for a, b, d, m, contrib, lkdim in pieces:
        breakdown[(len(a), len(b))] += contrib
    for key in sorted(breakdown):
        print(f"{key}: {breakdown[key]}")


if __name__ == "__main__":
    main()
