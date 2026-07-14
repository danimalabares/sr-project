from itertools import combinations
from collections import Counter, deque

facets = [
    [1,2,3,4], [1,2,3,7], [1,2,6,7], [1,3,4,7], [1,5,6,7],
    [2,3,4,5], [2,3,6,7], [3,4,6,7], [3,4,5,6], [4,5,6,7],
    [2,3,5,8], [2,3,6,8], [3,5,6,8], [1,2,6,8], [1,5,6,8],
    [1,2,4,8], [2,4,5,8], [1,4,7,8], [1,5,7,8], [4,5,7,8]
]
# same facets as your t1.py input. :contentReference[oaicite:1]{index=1}

def powerset(s):
    s = tuple(sorted(s))
    for r in range(len(s) + 1):
        for c in combinations(s, r):
            yield tuple(c)

def all_faces_from_facets(facets):
    faces = set()
    for F in facets:
        for G in powerset(F):
            faces.add(G)
    return faces

def minimal_nonfaces(vertices, faces):
    out = []
    V = tuple(sorted(vertices))
    for r in range(1, len(V) + 1):
        for S in combinations(V, r):
            if S in faces:
                continue
            if all(T in faces for k in range(r) for T in combinations(S, k)):
                out.append(S)
    return out

def edge_valencies(facets):
    C = Counter()
    for F in facets:
        for e in combinations(sorted(F), 2):
            C[e] += 1
    return C

def triangle_incidence(facets):
    C = Counter()
    for F in facets:
        for t in combinations(sorted(F), 3):
            C[t] += 1
    return C

def dual_graph_connected(facets):
    n = len(facets)
    Fs = [set(F) for F in facets]
    adj = [[] for _ in range(n)]

    for i in range(n):
        for j in range(i + 1, n):
            if len(Fs[i] & Fs[j]) == 3:
                adj[i].append(j)
                adj[j].append(i)

    seen = {0}
    q = deque([0])
    while q:
        i = q.popleft()
        for j in adj[i]:
            if j not in seen:
                seen.add(j)
                q.append(j)

    return len(seen) == n

def monomial(S):
    return "*".join(f"x{i}" for i in S)

facets = [tuple(sorted(F)) for F in facets]
faces = all_faces_from_facets(facets)
vertices = sorted({v for F in facets for v in F})

fvec = tuple(sum(1 for F in faces if len(F) == r) for r in range(1, 5))
mnf = minimal_nonfaces(vertices, faces)
edge_val = edge_valencies(facets)
tri_inc = triangle_incidence(facets)

print("vertices =", vertices)
print("number of vertices =", len(vertices))
print("number of facets =", len(facets))
print("f-vector =", fvec)
print("Euler characteristic =", fvec[0] - fvec[1] + fvec[2] - fvec[3])
print()

print("minimal nonfaces:")
for S in mnf:
    print(" ", S, monomial(S))

print("number of minimal nonfaces =", len(mnf))
print()

print("SR ideal generators:")
print("ideal(" + ", ".join(monomial(S) for S in mnf) + ")")
print()

print("edge valency distribution =", dict(sorted(Counter(edge_val.values()).items())))
for e, v in sorted(edge_val.items()):
    print(f"  {e}: {v}")

bad_triangles = {t: c for t, c in sorted(tri_inc.items()) if c != 2}

print()
print("bad triangle incidences =", bad_triangles)
print("dual graph connected =", dual_graph_connected(facets))
print()

print("checks:")
print("  f-vector == (8,28,40,20):", fvec == (8,28,40,20))
print("  all triangles incidence 2:", all(c == 2 for c in tri_inc.values()))
print("  dual graph connected:", dual_graph_connected(facets))

