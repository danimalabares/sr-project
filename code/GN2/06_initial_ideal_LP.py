"""
Step 6.  THE decisive experiment (exact linear algebra + LP).

In degree 3, (I_GN)_3 = W = span of the 16 cubic minors, a 16-dim
subspace of the 120-dim space of cubics in x1..x8.  We want a weight
omega with  in_omega(W) = span{16 SR monomials} = (I_SR)_3.

Two-part test, for a given 4x4 matrix A of linear forms:

  (a) omega-INDEPENDENT: the 16x16 submatrix of W's coefficient matrix
      on the SR-monomial columns must be invertible.  Then W has a unique
      reduced basis  g_a = m_a + sum_{m' not in SR} c_{a,m'} m'.

  (b) LP: find omega with  omega.exp(m_a) > omega.exp(m')  for every
      non-SR monomial m' actually occurring in g_a (all a).  Feasible
      => in_omega(W) = (I_SR)_3.

If (a)+(b) hold for the GENERIC (smooth) matrix, the homogenisation is a
FLAT family with special fibre SR(M) and smooth generic fibre -- a
smoothing.  (Ideal-level in_omega = I_SR is then verified in M2, step 7.)

Run:  python3 06_initial_ideal_LP.py [seed]
"""

import sys
import json
from itertools import combinations
import sympy as sp
from gn_common import (x, given_matrix, minors_3x3, poly_support,
                       SR_NAME_EXP, lp_weight)

# all degree-3 monomials in 8 vars, fixed index
from itertools import combinations_with_replacement


def gen_deg3():
    mons = []
    for a in combinations_with_replacement(range(8), 3):
        e = [0] * 8
        for v in a:
            e[v] += 1
        mons.append(tuple(e))
    return mons


DEG3 = gen_deg3()
IDX = {e: k for k, e in enumerate(DEG3)}            # exp -> column
assert len(DEG3) == 120, len(DEG3)

SR_EXPS = set(SR_NAME_EXP.values())
SR_COLS = [IDX[e] for e in SR_NAME_EXP.values()]    # 16 SR columns
SR_NAMES_BY_COL = {IDX[e]: n for n, e in SR_NAME_EXP.items()}


def coeff_matrix(minor_polys):
    """16 x 120 sympy Rational matrix; row i = coeffs of minor i."""
    M = sp.zeros(len(minor_polys), 120)
    for i, poly in enumerate(minor_polys):
        for e, c in poly_support(poly).items():
            M[i, IDX[e]] = sp.Rational(c)
    return M


def analyse(A, label):
    print(f"\n===== {label} =====")
    minors = [p for _, p in minors_3x3(A)]
    W = coeff_matrix(minors)
    r = W.rank()
    print(f"dim W (cubic part of I_GN) = {r}  (expect 16)")

    # (a) invertibility of SR block
    SRblock = W[:, SR_COLS]
    detblock = SRblock.det()
    print(f"det of 16x16 SR-monomial block = {detblock}  "
          f"-> invertible: {detblock != 0}")
    if detblock == 0:
        print("  SR monomials are NOT a transversal of W; this matrix/ "
              "labelling cannot give in_omega = I_SR in degree 3.")
        return None

    # reduce W so that columns SR_COLS become identity: g_a = m_a + (rest)
    # Solve  X * SRblock = I  => X = SRblock^{-1}; then G = X * W.
    G = SRblock.inv() * W                 # 16 x 120, rows g_a
    # row a corresponds to SR column SR_COLS[a]; its leading (SR) monomial:
    constraints = []
    occur = 0
    for a in range(16):
        ma_col = SR_COLS[a]
        ma_exp = DEG3[ma_col]
        for col in range(120):
            if col == ma_col:
                continue
            c = G[a, col]
            if c != 0:
                occur += 1
                m_exp = DEG3[col]
                # require omega.(ma_exp - m_exp) > 0
                constraints.append(tuple(ma_exp[k] - m_exp[k]
                                         for k in range(8)))
    print(f"reduced basis g_a = m_a + (non-SR terms); "
          f"total non-SR terms across all g_a = {occur}")

    feas, omega, margin = lp_weight(constraints, box=50.0)
    print(f"LP for separating weight: feasible = {feas}, margin = "
          f"{round(margin,4) if omega else None}")
    if feas:
        print(f"omega = {[round(w,4) for w in omega]}")
        return {"label": label, "omega": omega, "margin": margin,
                "n_constraints": len(constraints)}
    return None


def main():
    seed = int(sys.argv[1]) if len(sys.argv) > 1 else 42

    # 1) given circulant matrix
    res_given = analyse(given_matrix(), "given circulant matrix")

    # 2) generic matrix of linear forms (the smooth CY3), several seeds
    import random
    rng = random.Random(seed)
    hits = []
    for s in range(8):
        A = sp.Matrix(4, 4, lambda i, j: sum(
            rng.randint(-3, 3) * x[k] for k in range(8)))
        res = analyse(A, f"generic linear matrix (subseed {s})")
        if res:
            res["matrix"] = [[str(A[i, j]) for j in range(4)]
                             for i in range(4)]
            hits.append(res)
            break

    out = {"given": res_given, "generic_hit": hits[0] if hits else None}
    with open("cache/06_initial_ideal_LP.json", "w") as f:
        json.dump(out, f, indent=2)
    print("\nsaved cache/06_initial_ideal_LP.json")
    if hits:
        print("\n*** FOUND omega with in_omega = I_SR in degree 3 for a "
              "SMOOTH generic determinantal matrix. Verify ideal-level in "
              "M2 (step 7). ***")


if __name__ == "__main__":
    main()
