"""
Step 2.  CONSTRUCT a 4x4 pattern matrix V (each entry a single variable
x1..x8) such that, under a diagonal term order, the 16 main-diagonal
leading terms of its 3x3 minors are EXACTLY the 16 SR generators.

Why this is the right object
----------------------------
For a matrix order in which, inside every 3x3 submatrix, the product of
the main-diagonal entries is the omega-leading term (a "diagonal term
order", which exists for determinantal ideals -- Sturmfels, Herzog-Trung,
Bernstein-Sturmfels-Zelevinsky), the initial term of the minor on rows
R=(r0<r1<r2), cols C=(c0<c1<c2) is

      V[r0,c0] * V[r1,c1] * V[r2,c2].

So if the 16 such diagonal products are precisely the 16 SR monomials,
then in_omega( det ideal ) contains all 16 SR generators, and (matching
Hilbert functions) equals I_SR.  Perturbing the entries by lower-omega-
weight linear forms would produce a candidate family whose special fibre,
flatness, and generic-fibre smoothness would still need verification.

This script solves the combinatorial design (find the pattern V).

Run:  python3 02_design_matrix.py
"""

from itertools import combinations
from gn_common import SR_NAME_EXP

VARS = range(8)                       # variable indices 0..7  (x1..x8)
ROWS = list(combinations(range(4), 3))   # 4 row-triples
COLS = list(combinations(range(4), 3))   # 4 col-triples

# SR generators as sorted exponent multisets (each is a squarefree cubic,
# so a frozenset / sorted triple of 3 distinct variable indices).
SR_TRIPLES = {}
for name, exp in SR_NAME_EXP.items():
    vs = tuple(sorted(i for i in range(8) for _ in range(exp[i])))
    SR_TRIPLES[name] = vs            # e.g. f1 -> (5,6,7)  (x6,x7,x8)
TARGET = {v: n for n, v in SR_TRIPLES.items()}   # triple -> name
TARGET_SET = set(SR_TRIPLES.values())


# For each minor (R,C) the three diagonal cells (as (row,col)).
def diag_cells(R, C):
    return [(R[k], C[k]) for k in range(3)]


MINORS = []   # list of (label, [cell0,cell1,cell2])
for R in ROWS:
    for C in COLS:
        MINORS.append(((R, C), diag_cells(R, C)))

# cells are (i,j) in 4x4
ALL_CELLS = [(i, j) for i in range(4) for j in range(4)]

# which minors does each cell participate in (for pruning order)
MINOR_OF_CELL = {c: [] for c in ALL_CELLS}
for mi, (lab, cells) in enumerate(MINORS):
    for c in cells:
        MINOR_OF_CELL[c].append(mi)

# only cells that appear on SOME minor diagonal constrain the design;
# the rest (e.g. (0,3),(3,0)) are free, used later for perturbation.
DIAG_CELLS = [c for c in ALL_CELLS if MINOR_OF_CELL[c]]
FREE_CELLS = [c for c in ALL_CELLS if not MINOR_OF_CELL[c]]


def solve(allow_repeated_var_in_minor=False, want_all=True, cap=50):
    """
    Backtracking assignment V: cell -> variable index, so the multiset of
    16 diagonal products equals the 16 SR triples (each used once).

    Returns a list of solutions (each a dict cell->varindex).
    """
    solutions = []

    # assign cells in an order that completes minors early
    # (greedy: order cells so that minors get their 3rd cell asap)
    order = sorted(DIAG_CELLS, key=lambda c: (min(MINOR_OF_CELL[c]),
                                              -len(MINOR_OF_CELL[c])))

    assign = {}
    used_targets = set()
    # product accumulator per minor: list of assigned var indices
    minor_state = [list() for _ in MINORS]

    def bt(pos):
        if len(solutions) >= cap:
            return
        if pos == len(order):
            # all cells assigned; verify full coverage
            prods = []
            for cells in (m[1] for m in MINORS):
                prods.append(tuple(sorted(assign[c] for c in cells)))
            if sorted(prods) == sorted(TARGET_SET):
                solutions.append(dict(assign))
            return

        cell = order[pos]
        for v in VARS:
            assign[cell] = v
            ok = True
            completed = []
            for mi in MINOR_OF_CELL[cell]:
                cells = MINORS[mi][1]
                if all(c in assign for c in cells):
                    trip = tuple(sorted(assign[c] for c in cells))
                    # squarefree check (SR gens are squarefree)
                    if not allow_repeated_var_in_minor and \
                       len(set(trip)) != 3:
                        ok = False
                        break
                    if trip not in TARGET_SET or trip in used_targets:
                        ok = False
                        break
                    used_targets.add(trip)
                    completed.append(trip)
            if ok:
                bt(pos + 1)
            for t in completed:
                used_targets.discard(t)
            del assign[cell]

    bt(0)
    return solutions


def show(sol):
    grid = [["(free)"] * 4 for _ in range(4)]
    for (i, j), v in sol.items():
        grid[i][j] = f"x{v+1}"
    for i in range(4):
        print("   [" + ", ".join(grid[i]) + "]")
    print("   diagonal products -> SR gens:")
    for lab, cells in MINORS:
        trip = tuple(sorted(sol[c] for c in cells))
        nm = TARGET.get(trip, "??")
        prod = "*".join(f"x{v+1}" for v in trip)
        print(f"     minor {lab}: {prod}  = {nm}")


def main():
    print("Searching for a 4x4 single-variable pattern whose 16 main-"
          "diagonal\n3x3-minor products are exactly the 16 SR generators "
          "...\n")
    sols = solve(cap=20)
    print(f"Number of pattern solutions found (capped): {len(sols)}\n")
    for k, sol in enumerate(sols[:5]):
        print(f"===== pattern #{k+1} =====")
        show(sol)
        print()
    if not sols:
        print("No exact single-variable pattern with the diagonal order.")
        print("Next: relax (allow weight to pick a non-diagonal permutation,"
              " or use richer linear-form entries).")


if __name__ == "__main__":
    main()
