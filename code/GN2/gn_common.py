"""
Common utilities for experiments testing a possible determinantal smoothing.

Goal recap
----------
SR(M) is the Stanley-Reisner ideal of Gruenbaum's 8-vertex 3-sphere:
16 cubic monomials in x1..x8. We test whether SR(M) can be realised as a
Groebner/weight degeneration of the Gulliksen-Negard determinantal CY3
in P^7, given by the 16 cubic 3x3 minors of a 4x4 matrix of linear forms.

If we find a weight omega and a matrix A(x) with
    in_omega( ideal of 3x3 minors of A )  ==  I_SR,
then Groebner homogenisation gives a flat family with special fibre SR(M).
Smoothness of the chosen generic fibre would still need to be verified.
No such weight and matrix have been found here.

This module: build minors symbolically, extract supports, and run the
matching + linear-program search for omega.
"""

import sympy as sp
from itertools import combinations

x = sp.symbols('x1:9')  # x[0]=x1 ... x[7]=x8


# ----------------------------------------------------------------------
# The 16 Stanley-Reisner generators (cubic monomials in x1..x8).
# Indices are 1-based as in the journal / coefficients report.
# ----------------------------------------------------------------------
SR_STR = {
    'f1':  'x6*x7*x8', 'f2':  'x4*x6*x8', 'f3':  'x3*x7*x8', 'f4':  'x3*x5*x7',
    'f5':  'x3*x4*x8', 'f6':  'x2*x7*x8', 'f7':  'x2*x5*x7', 'f8':  'x2*x5*x6',
    'f9':  'x2*x4*x7', 'f10': 'x2*x4*x6', 'f11': 'x1*x4*x6', 'f12': 'x1*x4*x5',
    'f13': 'x1*x3*x8', 'f14': 'x1*x3*x6', 'f15': 'x1*x3*x5', 'f16': 'x1*x2*x5',
}


def mon_to_exp(s):
    """'x3^2*x5' -> (0,0,2,0,1,0,0,0)."""
    e = [0] * 8
    for part in s.split('*'):
        part = part.strip()
        if '^' in part:
            v, p = part.split('^')
            e[int(v[1:]) - 1] += int(p)
        else:
            e[int(part[1:]) - 1] += 1
    return tuple(e)


SR_EXP = {mon_to_exp(v): k for k, v in SR_STR.items()}   # exp -> name
SR_NAME_EXP = {k: mon_to_exp(v) for k, v in SR_STR.items()}  # name -> exp


def term_exp(term):
    """sympy monomial term -> exponent tuple over x1..x8."""
    e = [0] * 8
    p = sp.Poly(term, *x)
    (monom,) = p.monoms()
    return tuple(int(a) for a in monom)


def poly_support(expr):
    """Return {exp_tuple: coeff} for a sympy polynomial in x1..x8."""
    p = sp.Poly(sp.expand(expr), *x)
    out = {}
    for monom, coeff in p.terms():
        out[tuple(int(a) for a in monom)] = sp.Rational(coeff)
    return out


# ----------------------------------------------------------------------
# Matrices
# ----------------------------------------------------------------------
def given_matrix():
    """The circulant-type matrix from stanley-reisner.tex (eq. matrix)."""
    x1, x2, x3, x4, x5, x6, x7, x8 = x
    return sp.Matrix([
        [x1, x2, x3, x4],
        [x5, x6, x7, x8],
        [x2, x3, x4, x5],
        [x6, x7, x8, x1],
    ])


def minors_3x3(M):
    """Return the 16 (signed) 3x3 minors of a 4x4 matrix as sympy polys.

    Indexed by (rows_kept, cols_kept) but we just return a flat list
    together with their (rowset, colset) label.
    """
    out = []
    rows = list(combinations(range(4), 3))
    cols = list(combinations(range(4), 3))
    for R in rows:
        for C in cols:
            sub = M[list(R), list(C)]
            out.append(((R, C), sp.expand(sub.det())))
    return out


def sr_terms_in(support):
    """Which SR generator names appear as a monomial of this minor."""
    return [SR_EXP[e] for e in support if e in SR_EXP]


# ----------------------------------------------------------------------
# Linear program for a separating weight omega.
#
# For a chosen leading exponent a* of a minor and every other term a,
# require   omega . (a* - a) >= margin,   margin > 0.
# Maximise margin (bounded omega box) -> strict separation if max>0.
# ----------------------------------------------------------------------
def lp_weight(constraints, nvars=8, box=10.0):
    """
    constraints: list of exponent-difference vectors d = a* - a (len nvars),
                 each requiring  omega . d >= margin.
    Returns (feasible, omega_list, margin) maximising margin with
    -box <= omega_i <= box.  feasible iff margin > tiny.
    """
    import numpy as np
    from scipy.optimize import linprog

    if not constraints:
        return True, [0.0] * nvars, float(box)

    # variables: omega_0..omega_{n-1}, margin   (n+1 vars)
    n = nvars
    # maximise margin  ->  minimise -margin
    c = [0.0] * n + [-1.0]

    A_ub = []
    b_ub = []
    for d in constraints:
        # omega.d - margin >= 0   ->   -omega.d + margin <= 0
        row = [-float(di) for di in d] + [1.0]
        A_ub.append(row)
        b_ub.append(0.0)

    bounds = [(-box, box)] * n + [(0.0, box)]
    res = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=bounds, method='highs')
    if not res.success:
        return False, None, 0.0
    omega = list(res.x[:n])
    margin = float(res.x[n])
    return (margin > 1e-7), omega, margin
