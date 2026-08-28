#!/usr/bin/env python3
"""Independent cross-CAS incidence membership check (Singular).

Re-proves, with Singular instead of Macaulay2 and with an ideal-theoretic
encoding instead of the packet's 3x240 module encoding, the membership

    s^2  in  ( 16 dehomogenized two-jet cubics,
               64 entries of J^T K_Pi,  s^3 )   in  Q[s,z,k]

for chosen (x-chart, Grassmann-4-subset) pairs.  A zero reduce() against a
(possibly degree-bounded) standard basis is an exact membership certificate;
a nonzero result is only inconclusive.

Input: the frozen two-jet file (read-only).  Output: a Singular script on
stdout.  Usage: gen_singular_incidence.py CHART PIVOTSPEC [DEGBOUND]
where PIVOTSPEC is a comma-separated 4-subset of 1..7 (rows of the affine
Jacobian) and DEGBOUND is optional (0 = no bound).
"""
import sys
import re
from itertools import combinations
from pathlib import Path

HERE = Path(__file__).resolve().parent
TWO_JET = HERE / "../../referee-packet/data/universal_2jet_QQ.txt"

MONOMIALS = [
    "x_6*x_7*x_8", "x_4*x_6*x_8", "x_3*x_7*x_8", "x_3*x_5*x_7",
    "x_3*x_4*x_8", "x_2*x_7*x_8", "x_2*x_5*x_7", "x_2*x_5*x_6",
    "x_2*x_4*x_7", "x_2*x_4*x_6", "x_1*x_4*x_6", "x_1*x_4*x_5",
    "x_1*x_3*x_8", "x_1*x_3*x_6", "x_1*x_3*x_5", "x_1*x_2*x_5",
]


def main():
    chart = int(sys.argv[1])
    pivots = sorted(int(t) for t in sys.argv[2].split(","))
    degbound = int(sys.argv[3]) if len(sys.argv) > 3 else 0
    assert 1 <= chart <= 8
    assert len(pivots) == 4 and all(1 <= p <= 7 for p in pivots)

    lines = [l for l in TWO_JET.read_text().splitlines() if l]
    assert len(lines) == 16
    g = []
    h = []
    for i, line in enumerate(lines):
        idx, first, second = line.split("|")
        assert int(idx) == i
        g.append(first)
        h.append(second)

    # substitution x_chart -> 1, remaining x's -> z1..z7 in order
    sub = {}
    zi = 0
    for i in range(1, 9):
        if i == chart:
            sub[f"x_{i}"] = "1"
        else:
            zi += 1
            sub[f"x_{i}"] = f"z{zi}"

    def dehom(poly):
        return re.sub(r"x_([1-8])", lambda m: sub[f"x_{m.group(1)}"], poly)

    # Module encoding over B = Q[z,k]: an element of Q[z,k][s]/(s^3) is a
    # 3-vector of s-coefficients.  c*q contributes columns
    # [q0,q1,q2], [0,q0,q1], [0,0,q0] per generator q; target is s^2=(0,0,1).
    print("ring r = 0, (z1, z2, z3, z4, z5, z6, z7,"
          " k1, k2, k3, k4, k5, k6, k7, k8, k9, k10, k11, k12,"
          " s), (dp(19), dp(1));")
    print("ideal J;")
    for i in range(16):
        print(f"poly F{i+1} = ({dehom(MONOMIALS[i])})"
              f" + s*({dehom(g[i])}) + s^2*({dehom(h[i])});")
        print(f"J[{i+1}] = F{i+1};")
    free = [rr for rr in range(1, 8) if rr not in pivots]
    entries = []
    for rr in range(1, 8):
        for c in range(4):
            if rr in pivots:
                entries.append("1" if pivots.index(rr) == c else "0")
            else:
                entries.append(f"k{4 * free.index(rr) + c + 1}")
    print("matrix KM[7][4] = " + ",".join(entries) + ";")
    print("matrix JM[16][7];")
    print("int i; int u;")
    print("for (i=1; i<=16; i++) { for (u=1; u<=7; u++)"
          " { JM[i,u] = diff(J[i], var(u)); } }")
    print("matrix IE = JM*KM;")
    print("ideal Q0 = J;")
    print("for (i=1; i<=16; i++) { for (u=1; u<=4; u++)"
          " { Q0 = Q0, IE[i,u]; } }")
    # split each generator into s-coefficients (s = var(20))
    print("module M;")
    print("poly q; poly c0; poly c1; poly c2;")
    print("for (i=1; i<=size(Q0); i++) {")
    print("  q = Q0[i];")
    print("  c0 = subst(q, s, 0);")
    print("  c1 = subst(diff(q, s), s, 0);")
    print("  c2 = subst(diff(diff(q, s), s), s, 0)/2;")
    print("  M = M, [c0, c1, c2], [0, c0, c1], [0, 0, c0];")
    print("}")
    print("M = simplify(M, 2);")
    print(f'int db = {degbound};')
    print('if (db > 0) { degBound = db; }')
    print("module G = std(M);")
    print("degBound = 0;")
    print("vector tgt = [0, 0, 1];")
    print("vector nf = reduce(tgt, G, 1);")
    print('string verdict; if (nf == 0)'
          ' { verdict = "MEMBERSHIP_PROVED"; } else'
          ' { verdict = "INCONCLUSIVE"; }')
    print(f'"chart={chart} pivots={",".join(map(str, pivots))}'
          f' degbound={degbound} " + verdict;')
    print("exit;")


if __name__ == "__main__":
    main()
