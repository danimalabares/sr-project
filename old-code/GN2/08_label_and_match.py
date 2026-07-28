"""
Step 8.  Label the 8 nonzero cells of a support pattern by x1..x8 so the
16 unique-transversal products equal the 16 SR monomials.

Each surviving pattern (step 7) has exactly 8 one-cells.  Bijectively
labelling them by x1..x8 turns the 16 transversals into a 3-uniform
hypergraph on 8 vertices.  We need a labelling making it equal (as a set
of 16 triples) to the SR hypergraph.  This is a hypergraph isomorphism
search (8 vertices), pruned by vertex degree sequences.

A success yields a 4x4 matrix A0 with entries in {0,x1..x8} and
minors(A0) = I_SR exactly.

Run:  python3 08_label_and_match.py
"""

import json
from itertools import combinations, permutations
from collections import Counter
from gn_common import SR_NAME_EXP

ROWS = list(combinations(range(4), 3))
COLS = list(combinations(range(4), 3))
PERMS = list(permutations(range(3)))

# SR hypergraph: 16 triples of variable indices (0..7)
SR_TRIPLES = []
for name, exp in SR_NAME_EXP.items():
    t = tuple(sorted(i for i in range(8) for _ in range(exp[i])))
    SR_TRIPLES.append(t)
SR_SET = frozenset(frozenset(t) for t in SR_TRIPLES)
assert len(SR_SET) == 16

# SR vertex degree sequence (how many triples each variable is in)
SR_DEG = Counter()
for t in SR_TRIPLES:
    for v in t:
        SR_DEG[v] += 1
SR_DEG_SEQ = tuple(sorted(SR_DEG.values()))


def transversal_cells(P, R, C):
    for p in PERMS:
        if all(P[R[k]][C[p[k]]] for k in range(3)):
            return tuple(sorted(4 * R[k] + C[p[k]] for k in range(3)))
    return None


def pattern_hypergraph(P):
    """Return (cell_ids sorted, list of 16 triples over those cells)."""
    triples = []
    for R in ROWS:
        for C in COLS:
            triples.append(transversal_cells(P, R, C))
    cells = sorted({c for t in triples for c in t})
    return cells, triples


def try_match(cells, triples):
    """Find a bijection cell->variable(0..7) making {triples}==SR_SET."""
    assert len(cells) == 8
    # cell degree sequence must match SR
    deg = Counter()
    for t in triples:
        for c in t:
            deg[c] += 1
    if tuple(sorted(deg.values())) != SR_DEG_SEQ:
        return None

    cell_index = {c: i for i, c in enumerate(cells)}
    # triples as index-frozensets over 0..7 (cell order)
    tri_idx = [frozenset(cell_index[c] for c in t) for t in triples]
    tri_set_target = SR_SET

    # group cells and variables by degree to prune the bijection search
    cell_by_deg = {}
    for c in cells:
        cell_by_deg.setdefault(deg[c], []).append(cell_index[c])
    var_by_deg = {}
    for v in range(8):
        var_by_deg.setdefault(SR_DEG[v], []).append(v)
    for d in cell_by_deg:
        if d not in var_by_deg or \
           len(cell_by_deg[d]) != len(var_by_deg[d]):
            return None

    # backtracking: assign each cell-index a distinct variable of equal deg
    mapping = {}
    used = set()
    degs = sorted(cell_by_deg)

    def bt(di, pos):
        if di == len(degs):
            # full mapping; verify
            mapped = frozenset(frozenset(mapping[i] for i in t)
                               for t in tri_idx)
            return mapped == tri_set_target
        d = degs[di]
        cidxs = cell_by_deg[d]
        if pos == len(cidxs):
            return bt(di + 1, 0)
        ci = cidxs[pos]
        for v in var_by_deg[d]:
            if v in used:
                continue
            mapping[ci] = v
            used.add(v)
            if bt(di, pos + 1):
                return True
            used.discard(v)
            del mapping[ci]
        return False

    if bt(0, 0):
        # mapping: cell_index -> variable; convert to cell(row,col)->var
        inv = {}
        for c in cells:
            inv[c] = mapping[cell_index[c]]
        return inv
    return None


def main():
    with open("cache/07_support_patterns.json") as f:
        patterns = json.load(f)
    print(f"loaded {len(patterns)} support patterns")
    print(f"SR vertex degree sequence: {SR_DEG_SEQ}")

    solutions = []
    for pi, entry in enumerate(patterns):
        P = entry["P"]
        cells, triples = pattern_hypergraph(P)
        m = try_match(cells, triples)
        if m:
            solutions.append((pi, P, m))

    print(f"\npatterns admitting an SR labelling: {len(solutions)}")
    if not solutions:
        print("None with a pure bijection. Next: allow repeated variables "
              "or richer entries.")
        return

    # build and save the matrices
    out = []
    for pi, P, m in solutions:
        grid = [["0"] * 4 for _ in range(4)]
        for i in range(4):
            for j in range(4):
                if P[i][j]:
                    grid[i][j] = f"x{m[4*i+j]+1}"
        out.append({"pattern_index": pi, "matrix": grid})

    with open("cache/08_exact_matrices.json", "w") as f:
        json.dump(out, f, indent=2)
    print(f"saved {len(out)} exact matrices to cache/08_exact_matrices.json")

    for k, o in enumerate(out[:5]):
        print(f"\n===== exact matrix #{k+1} (pattern {o['pattern_index']}) "
              f"=====")
        for row in o["matrix"]:
            print("   [" + ", ".join(f"{e:>3}" for e in row) + "]")


if __name__ == "__main__":
    main()
