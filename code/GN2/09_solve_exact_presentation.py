"""
Step 9.  Solve for a 4x4 matrix A0 of linear forms in x1..x8 whose 16
cubic 3x3 minors all lie in span(SR monomials) -- i.e. every term of
every minor is one of the 16 SR generators, with the 16 minors linearly
independent.  Then  minors(A0) = I_SR  exactly (degrees/dims match), and
A0 + t*(generic) is a flat smoothing.

Method: numeric optimisation over the 128 entry-coefficients
(16 entries x 8 variables).  Residual = the 104 non-SR-monomial
coefficients of each of the 16 minors (1664 numbers) that we drive to 0,
plus one scale residual keeping the SR-part nonzero (avoids the trivial
A0=0 solution).  Multi-start least squares; verify rank 16 SR-block.

Run:  python3 09_solve_exact_presentation.py [n_starts] [seed]
"""

import sys
import json
import numpy as np
from itertools import combinations, combinations_with_replacement, permutations
from gn_common import SR_NAME_EXP

# ---- monomial bookkeeping -------------------------------------------
DEG3 = list(combinations_with_replacement(range(8), 3))   # sorted triples
IDX3 = {m: k for k, m in enumerate(DEG3)}
assert len(DEG3) == 120

SR_KEYS = []
for name, exp in SR_NAME_EXP.items():
    t = tuple(sorted(i for i in range(8) for _ in range(exp[i])))
    SR_KEYS.append(t)
SR_COLS = [IDX3[t] for t in SR_KEYS]
SR_COL_SET = set(SR_COLS)
NONSR_COLS = [k for k in range(120) if k not in SR_COL_SET]

ROWS = list(combinations(range(4), 3))
COLS = list(combinations(range(4), 3))
PERMS = list(permutations(range(3)))


def perm_sign(p):
    s = 1
    for i in range(3):
        for j in range(i + 1, 3):
            if p[i] > p[j]:
                s = -s
    return s


PERM_SIGNS = [perm_sign(p) for p in PERMS]

# precompute, for cubic = product of three length-8 vectors, the bucket
# map: for (i,j,k) in 8^3, which deg3 column.
BUCKET = np.zeros((8, 8, 8), dtype=np.int64)
for i in range(8):
    for j in range(8):
        for k in range(8):
            BUCKET[i, j, k] = IDX3[tuple(sorted((i, j, k)))]
BUCKET_FLAT = BUCKET.reshape(-1)


def cubic_of_product(L1, L2, L3):
    """deg-3 coeff vector (len120) of product of three linear forms."""
    outer = np.einsum('i,j,k->ijk', L1, L2, L3).reshape(-1)
    c = np.zeros(120)
    np.add.at(c, BUCKET_FLAT, outer)
    return c


def minors_coeffs(entries):
    """entries: (4,4,8) array -> (16,120) coeff matrix of the 16 minors."""
    out = np.zeros((16, 120))
    mi = 0
    for R in ROWS:
        for C in COLS:
            acc = np.zeros(120)
            for p, sg in zip(PERMS, PERM_SIGNS):
                acc += sg * cubic_of_product(entries[R[0], C[p[0]]],
                                             entries[R[1], C[p[1]]],
                                             entries[R[2], C[p[2]]])
            out[mi] = acc
            mi += 1
    return out


def residual(vec):
    entries = vec.reshape(4, 4, 8)
    W = minors_coeffs(entries)
    nonsr = W[:, NONSR_COLS].reshape(-1)          # want 0
    srpart = W[:, SR_COLS]
    scale = np.array([np.sum(srpart ** 2) - 16.0])  # keep SR mass ~16
    return np.concatenate([nonsr, scale])


def main():
    from scipy.optimize import least_squares
    n_starts = int(sys.argv[1]) if len(sys.argv) > 1 else 40
    seed = int(sys.argv[2]) if len(sys.argv) > 2 else 1
    rng = np.random.default_rng(seed)

    best = None
    for s in range(n_starts):
        x0 = rng.standard_normal(128)
        res = least_squares(residual, x0, method='lm', max_nfev=4000)
        r = res.cost
        entries = res.x.reshape(4, 4, 8)
        W = minors_coeffs(entries)
        nonsr_norm = np.linalg.norm(W[:, NONSR_COLS])
        srrank = np.linalg.matrix_rank(W[:, SR_COLS], tol=1e-6)
        ok = (nonsr_norm < 1e-5 and srrank == 16)
        if best is None or nonsr_norm < best[1]:
            best = (res.x.copy(), nonsr_norm, srrank)
        if ok:
            print(f"start {s}: *** SUCCESS *** nonSR={nonsr_norm:.2e}, "
                  f"SR-rank={srrank}")
            save_solution(res.x)
            report(res.x)
            return
        if s < 8 or s % 10 == 0:
            print(f"start {s}: nonSR_norm={nonsr_norm:.3e}, "
                  f"SR-rank={srrank}, cost={r:.3e}")

    print(f"\nno exact hit in {n_starts} starts. best nonSR_norm="
          f"{best[1]:.3e}, SR-rank={best[2]}")
    print("If best nonSR_norm is not ~0, an exact determinantal "
          "presentation with full 8-variable linear entries may need a "
          "structured ansatz (step 10).")
    save_solution(best[0], fname="cache/09_best_attempt.json")


def round_entries(entries, tol=1e-4):
    grid = [["0"] * 4 for _ in range(4)]
    for i in range(4):
        for j in range(4):
            terms = []
            for k in range(8):
                c = entries[i, j, k]
                if abs(c) > tol:
                    cc = round(c, 4)
                    terms.append(f"{cc}*x{k+1}")
            grid[i][j] = " + ".join(terms) if terms else "0"
    return grid


def report(vec):
    entries = vec.reshape(4, 4, 8)
    grid = round_entries(entries)
    print("matrix A0 (numeric):")
    for row in grid:
        print("   [" + ", ".join(row) + "]")


def save_solution(vec, fname="cache/09_exact_presentation.json"):
    entries = vec.reshape(4, 4, 8)
    data = {"entries": entries.tolist(), "grid": round_entries(entries)}
    with open(fname, "w") as f:
        json.dump(data, f, indent=2)
    print("saved", fname)


if __name__ == "__main__":
    main()
