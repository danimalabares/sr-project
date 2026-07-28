"""
Step 7.  Find an EXACT determinantal presentation of I_SR.

Goal: a 4x4 matrix A0 with entries in {0, x1,...,x8} whose sixteen 3x3
minors are EXACTLY the sixteen SR monomials (each minor a single
squarefree cubic).  Then

    A(t) = A0 + t * (generic 4x4 linear matrix)

is a family of 3x3-minor determinantal ideals.  As long as the codim
stays 4 (the expected/maximal value) the Hilbert function is constant
(determinantal CM), so the family is FLAT; special fibre = SR(M),
generic fibre would then need to be checked separately. If all these
conditions held, this would give a smoothing; the script does not prove it.

Construction in two stages:
  (7a) support patterns: 0/1 4x4 matrices for which every 3x3 submatrix
       has permanent exactly 1 (a unique transversal => each minor is a
       single +/- product, no cancellation).
  (7b) [next script] assign variables x1..x8 to the 1-cells so the 16
       unique-transversal products are the 16 SR monomials.

Run:  python3 07_find_exact_matrix.py
"""

from itertools import combinations, permutations, product

ROWS = list(combinations(range(4), 3))
COLS = list(combinations(range(4), 3))
PERMS = list(permutations(range(3)))


def submatrix_permanent(P, R, C):
    """number of nonzero transversals of the 3x3 submatrix P[R,C]."""
    tot = 0
    for p in PERMS:
        prod = 1
        for k in range(3):
            prod *= P[R[k]][C[p[k]]]
            if prod == 0:
                break
        tot += prod
    return tot


def all_minors_unique_transversal(P):
    for R in ROWS:
        for C in COLS:
            if submatrix_permanent(P, R, C) != 1:
                return False
    return True


def unique_transversal_cells(P, R, C):
    """the single nonzero transversal as a list of 3 cells (row,col)."""
    for p in PERMS:
        if all(P[R[k]][C[p[k]]] for k in range(3)):
            return [(R[k], C[p[k]]) for k in range(3)]
    return None


def enumerate_patterns():
    survivors = []
    for bits in range(1 << 16):
        P = [[(bits >> (4 * i + j)) & 1 for j in range(4)]
             for i in range(4)]
        if all_minors_unique_transversal(P):
            survivors.append(P)
    return survivors


def pattern_signature(P):
    ones = sum(sum(r) for r in P)
    return ones


def main():
    print("Enumerating 4x4 0/1 patterns with every 3x3 permanent == 1 ...")
    surv = enumerate_patterns()
    print(f"survivors: {len(surv)}")
    if not surv:
        print("none -- relax to allow cancellation (permanent>1 with sign).")
        return

    from collections import Counter
    cnt = Counter(pattern_signature(P) for P in surv)
    print("distribution by number of 1-cells:", dict(sorted(cnt.items())))

    # show a few with the SAME number of 1-cells as distinct vars*mult.
    # Each SR monomial is squarefree cubic; 16 minors * 3 = 48 variable
    # incidences over the transversals.  Show some patterns and their
    # transversal-cell structure.
    import json
    out = []
    for P in surv:
        cells_per_minor = {}
        for R in ROWS:
            for C in COLS:
                cells_per_minor[f"{R}|{C}"] = unique_transversal_cells(P, R, C)
        out.append({"P": P, "ones": pattern_signature(P),
                    "transversals": cells_per_minor})
    with open("cache/07_support_patterns.json", "w") as f:
        json.dump(out, f, indent=2)
    print(f"saved {len(out)} patterns to cache/07_support_patterns.json")

    for k, P in enumerate(surv[:3]):
        print(f"\npattern #{k+1} ({pattern_signature(P)} ones):")
        for r in range(4):
            print("   " + " ".join(str(P[r][c]) for c in range(4)))


if __name__ == "__main__":
    main()
