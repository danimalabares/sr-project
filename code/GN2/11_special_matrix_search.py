"""
Step 11.  Probe the remaining gap left by the certificates (step 10):

The generic certificate (cubes) and the squarefree certificate (faces)
kill full-support matrices.  A matrix could still escape if its minors'
reduced basis omits enough cubes/faces that the non-SR support S becomes
strictly omega-separable below the SR monomials -- equivalently
conv(SR) and conv(S) are separable, which (since the SR centroid is
(3/8,...,3/8)) needs S to NOT surround that centroid.

This script searches matrices with varied sparsity (zero entries) for one
whose reduced-basis non-SR support S is LP-separable below SR AND whose
SR-block has rank 16 (so in_omega(W) = (I_SR)_3 in degree 3). Such a
matrix would be a genuine Groebner-degeneration candidate; we'd then test
its smoothness. If none is even LP-separable, that is evidence against
this method, not evidence that a smoothing exists.

Run:  python3 11_special_matrix_search.py [n_trials] [seed]
"""

import sys
import numpy as np
import importlib.util
from gn_common import lp_weight

spec = importlib.util.spec_from_file_location(
    "s9", "09_solve_exact_presentation.py")
s9 = importlib.util.module_from_spec(spec)
spec.loader.exec_module(s9)
minors_coeffs = s9.minors_coeffs
SR_COLS = s9.SR_COLS
NONSR_COLS = s9.NONSR_COLS
DEG3_TRIP = s9.DEG3                 # variable-index triples (len 3)


def exp_of(col):
    """exponent vector (len 8) of the monomial in column `col`."""
    v = [0] * 8
    for t in DEG3_TRIP[col]:
        v[t] += 1
    return tuple(v)


DEG3 = [exp_of(c) for c in range(len(DEG3_TRIP))]   # exponent vectors


def reduced_support(entries, tol=1e-7):
    """Return (sr_rank, set of non-SR columns appearing in reduced basis,
    or None if SR-block singular)."""
    W = minors_coeffs(entries)
    SRb = W[:, SR_COLS]
    if np.linalg.matrix_rank(SRb, tol=1e-6) < 16:
        return None
    G = np.linalg.solve(SRb, W)            # 16 x 120 reduced basis
    support = set()
    for c in NONSR_COLS:
        if np.any(np.abs(G[:, c]) > tol):
            support.add(c)
    return support


def lp_separable(support):
    """Is there omega with omega.e(m_a) > omega.e(m') for all SR a and all
    non-SR m' in support?  (Necessary for in_omega(W)=(I_SR)_3.)"""
    cons = []
    for a in SR_COLS:
        ea = DEG3[a]
        for c in support:
            ec = DEG3[c]
            cons.append(tuple(ea[k] - ec[k] for k in range(8)))
    feas, omega, margin = lp_weight(cons, box=100.0)
    return feas, margin, len(cons)


def random_sparse(rng, p_zero):
    E = np.zeros((4, 4, 8))
    for i in range(4):
        for j in range(4):
            if rng.random() < p_zero:
                continue
            E[i, j] = rng.standard_normal(8)
            # also randomly sparsify within an entry
            mask = rng.random(8) < 0.5
            E[i, j] *= mask
    return E


def main():
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 4000
    seed = int(sys.argv[2]) if len(sys.argv) > 2 else 0
    rng = np.random.default_rng(seed)

    best = {"sep": False, "supp": 9999, "margin": -1}
    feasible_found = 0
    invertible = 0
    for p in [0.0, 0.2, 0.35, 0.5, 0.6, 0.7]:
        for _ in range(n // 6):
            E = random_sparse(rng, p)
            supp = reduced_support(E)
            if supp is None:
                continue
            invertible += 1
            feas, margin, _ = lp_separable(supp)
            if feas:
                feasible_found += 1
                if len(supp) < best["supp"]:
                    best = {"sep": True, "supp": len(supp),
                            "margin": margin, "p": p}
            else:
                if not best["sep"] and len(supp) < best["supp"]:
                    best = {"sep": False, "supp": len(supp),
                            "margin": margin, "p": p}

    print(f"trials with invertible SR-block (rank 16): {invertible}")
    print(f"of those, LP-separable (Groebner-degeneration candidates): "
          f"{feasible_found}")
    print(f"best: {best}")
    if feasible_found == 0:
        print("\nNo rank-16 matrix had an omega-separable reduced support.")
        print("=> strong evidence: SR(M) is NOT a coordinate Groebner "
              "degeneration of ANY (smooth or not) determinantal matrix in "
              "this search.  This does not decide whether a smoothing "
              "exists.")
    else:
        print("\nFound Groebner-degeneration candidate(s) -- next: test "
              "smoothness of those matrices in M2.")


if __name__ == "__main__":
    main()
