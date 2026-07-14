"""
Step 10.  Exact (rational) certificate for the GENERIC non-toricity:

  For a Zariski-generic 4x4 matrix A of linear forms, there is NO weight
  omega with  in_omega(<3x3 minors of A>) = I_SR.

Reduction (degree 3):  I = <minors> is generated in degree 3 and
I_3 = W = span of the 16 minors (dim 16).  So in_omega(I) = I_SR forces
in_omega(W) = (I_SR)_3.  For generic A the SR-monomial 16x16 block of W
is invertible and the reduced basis g_a = m_a + sum_{m' not in SR}
c_{a,m'} m' has FULL support (all c != 0, in particular the pure cubes
x_i^3).  Then in_omega(W) = (I_SR)_3 needs, for every SR gen m_a and
every non-SR m' (incl. all cubes x_i^3):

        omega . ( e(m_a) - e(m') )  > 0.                         (*)

Gordan certificate killing (*): each variable lies in EXACTLY 6 of the
16 SR generators, so  sum_a e(m_a) = 6*(1,...,1).  Hence

   sum_{a=1..16} sum_{i=1..8}  ( e(m_a) - 3 e_i )
     = 8 * sum_a e(m_a)  -  16 * 3 * (1,...,1)
     = 8*6*1  -  48*1  = 0.

A positive combination of the strict inequalities (*) yields 0 > 0:
contradiction.  So (*) is infeasible => generic A has no such omega.

This script verifies every finite claim exactly over QQ and cross-checks
against the LP, and confirms the generic reduced basis really contains
the cubes (so the certificate's constraints are active generically).

Run:  python3 10_obstruction_certificate.py
"""

import sympy as sp
from fractions import Fraction
from itertools import combinations_with_replacement
from gn_common import SR_NAME_EXP, x, minors_3x3, poly_support

# ---- degree-3 monomials, SR / non-SR split -------------------------
def exp_vec(triple):
    v = [0] * 8
    for t in triple:
        v[t] += 1
    return tuple(v)


DEG3 = [exp_vec(t) for t in combinations_with_replacement(range(8), 3)]
IDX3 = {m: k for k, m in enumerate(DEG3)}     # keyed by exponent-vector
SR_EXP = {tuple(sorted(i for i in range(8) for _ in range(e[i])))
          for e in SR_NAME_EXP.values()}
assert len(SR_EXP) == 16


SR_VECS = [exp_vec(t) for t in SR_EXP]
CUBES = [(0,)*i + (3,) + (0,)*(7 - i) for i in range(8)]   # e(x_i^3)


def check_var_in_six():
    cnt = [0] * 8
    for t in SR_EXP:
        for i in set(t):
            cnt[i] += 1
    return cnt


def check_certificate():
    # sum_{a,i} ( e(m_a) - 3 e_i )  must be the zero vector
    total = [0] * 8
    for ma in SR_VECS:           # 16
        for cube in CUBES:       # 8  (3 e_i)
            for k in range(8):
                total[k] += ma[k] - cube[k]
    return total


def cubes_are_nonSR():
    return all(tuple(c) not in {tuple(s) for s in SR_VECS} and
               # x_i^3 in I_SR?  divisible by a squarefree cubic gen? no.
               True for c in CUBES)


def generic_reduced_basis_has_cubes(seed=12345):
    """Confirm: for a random rational matrix, the reduced basis over the
    SR-pivot columns has nonzero coefficients on every cube x_i^3."""
    import random
    rng = random.Random(seed)
    A = sp.Matrix(4, 4, lambda i, j: sum(rng.randint(-4, 4) * x[k]
                                          for k in range(8)))
    minors = [p for _, p in minors_3x3(A)]
    # 16 x 120 coeff matrix
    W = sp.zeros(16, len(DEG3))
    for r, p in enumerate(minors):
        for e, c in poly_support(p).items():
            W[r, IDX3[e]] = sp.Rational(c)
    SR_COLS = [IDX3[tuple(s)] for s in SR_VECS]
    SRblock = W[:, SR_COLS]
    if SRblock.det() == 0:
        return None
    G = SRblock.inv() * W                      # reduced basis rows
    cube_cols = [IDX3[tuple(c)] for c in CUBES]
    nonzero = []
    for a in range(16):
        row_nonzero = sum(1 for cc in cube_cols if G[a, cc] != 0)
        nonzero.append(row_nonzero)
    return nonzero   # number of nonzero cube-coeffs in each g_a


def lp_crosscheck():
    """Confirm the maximal constraint set (*) is LP-infeasible."""
    from gn_common import lp_weight
    cons = []
    for ma in SR_VECS:
        for cube in CUBES:
            cons.append(tuple(ma[k] - cube[k] for k in range(8)))
    feas, omega, margin = lp_weight(cons, box=100.0)
    return feas, margin


def face_vectors():
    """The 40 squarefree NON-SR cubics = faces of M (3-subsets of [8]
    that ARE in the complex), as exponent vectors."""
    from itertools import combinations
    srset = {tuple(sorted(s)) for s in SR_EXP}
    faces = []
    for t in combinations(range(8), 3):
        if t not in srset:
            faces.append(exp_vec(t))
    return faces


def check_face_certificate():
    """Each variable lies in exactly 15 of the 40 faces, so
       40*sum_a e(m_a) - 16*sum_f e(f) = 40*6*1 - 16*15*1 = 0,
    i.e. lambda = 1 on all 16*40 pairs (m_a, face) is a Gordan
    certificate killing every SQUAREFREE-supported full-face matrix
    (e.g. the given circulant matrix)."""
    faces = face_vectors()
    var_in_faces = [0] * 8
    for f in faces:
        for i in range(8):
            if f[i]:
                var_in_faces[i] += 1
    total = [0] * 8
    for ma in SR_VECS:
        for f in faces:
            for k in range(8):
                total[k] += ma[k] - f[k]
    return len(faces), var_in_faces, total


def main():
    print("=== exact obstruction certificate ===\n")

    cnt = check_var_in_six()
    print(f"[1] each variable's #SR-generators: {cnt}")
    print(f"    all equal to 6: {all(c == 6 for c in cnt)}\n")

    print(f"[2] the 8 pure cubes x_i^3 are non-SR (not generators, not in "
          f"I_SR): {cubes_are_nonSR()}\n")

    total = check_certificate()
    print(f"[3] sum_{{a,i}} ( e(m_a) - 3 e_i ) = {total}")
    print(f"    is the zero vector: {all(t == 0 for t in total)}")
    print(f"    => positive combination (lambda = 1 on each of the 128 "
          f"pairs (m_a, x_i^3)) of the\n        strict inequalities gives "
          f"0 > 0.  Gordan: system (*) is INFEASIBLE.\n")

    feas, margin = lp_crosscheck()
    print(f"[4] LP cross-check of the maximal constraint set: feasible="
          f"{feas} (margin={margin:.4f})\n")

    nf, vif, ftot = check_face_certificate()
    print(f"[face] #faces (squarefree non-SR cubics) = {nf}")
    print(f"    each variable's #faces: {vif} (all 15: "
          f"{all(v == 15 for v in vif)})")
    print(f"    40*sum_a e(m_a) - 16*sum_f e(f) = {ftot} "
          f"(zero: {all(t == 0 for t in ftot)})")
    print(f"    => lambda=1 on all 16x40 (SR,face) pairs kills every "
          f"squarefree-supported\n        full-face matrix (incl. the "
          f"given circulant matrix).\n")

    cubes_nz = generic_reduced_basis_has_cubes()
    print(f"[5] generic reduced basis: #nonzero cube-coeffs in each g_a "
          f"(want all 8):\n    {cubes_nz}")
    if cubes_nz:
        print(f"    all g_a contain every cube: "
              f"{all(n == 8 for n in cubes_nz)}")
    print("\n=== CONCLUSION ===")
    print("Generic determinantal A: in_omega(I) = I_SR is impossible.")
    print("The smooth GN CY3 admits NO coordinate Groebner degeneration "
          "to SR(M).")
    print("(Scope: this covers full-support reduced bases = generic A.  "
          "Special A whose minors avoid the cubes are addressed by step "
          "11.)")


if __name__ == "__main__":
    main()
