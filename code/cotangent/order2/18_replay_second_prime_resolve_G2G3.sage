# 18_replay_second_prime_resolve_G2G3.sage
#
# Second-prime replay, but with the correct test after 17 fails.
#
# The balanced integer lift of the F_32003 coefficients need not be
# an integral/rational solution. So here we keep the integral data
# G_1 and A_1 fixed, because order 1 already replayed over 32009,
# and re-solve for G_2 and G_3 over the second prime using the same
# sparse supports as the exported F_32003 solution.
#
# Checks modulo I:
#
#   order 1: s G_1 + A_1 f = 0
#   order 2: s G_2 + A_1 G_1 = 0    solve for G_2 on same support
#   order 3: s G_3 + A_1 G_2 = 0    solve for G_3 on same support
#   order 4: A_1 G_3 = 0            verify
#
# Run from:
#   code/cotangent/order2
#
# First run:
#   sage 16_export_cubic_data.sage
#
# Then run:
#   sage 18_replay_second_prime_resolve_G2G3.sage

import pickle
import json
from collections import Counter

# ------------------------------------------------------------
# User parameters
# ------------------------------------------------------------

PICKLE_FILE = "../part-1.pkl"
INPUT_JSON = "cache/cubic_family_data.json"
OUTPUT_FILE = "cache/cubic_family_second_prime_resolved_G2G3.sobj"

REPLAY_PRIME = 32009
MAX_EXAMPLES = 8

BASE_FIELD = GF(REPLAY_PRIME)

# ------------------------------------------------------------
# Small utilities
# ------------------------------------------------------------

def exp_tuple(e):
    return tuple(int(a) for a in e)


def add_exp(a, b):
    return tuple(x + y for x, y in zip(a, b))


def total_degree(e):
    return sum(e)


def poly_terms(poly):
    out = {}
    for e, c in poly.dict().items():
        c = BASE_FIELD(c)
        if c != 0:
            out[exp_tuple(e)] = c
    return out


def monomial_divides(a, b):
    return all(x <= y for x, y in zip(a, b))


def add_to_dict(d, key, value):
    value = BASE_FIELD(value)
    if value == 0:
        return
    d[key] = d.get(key, BASE_FIELD(0)) + value
    if d[key] == 0:
        del d[key]


def add_poly_inplace(A, B):
    for e, c in B.items():
        add_to_dict(A, e, c)


def add_exp_coeff_to_rows(rows_by_key, key, col, coeff):
    coeff = BASE_FIELD(coeff)
    if coeff == 0:
        return
    rows_by_key.setdefault(key, {})[col] = rows_by_key.setdefault(key, {}).get(col, BASE_FIELD(0)) + coeff
    if rows_by_key[key][col] == 0:
        del rows_by_key[key][col]


def degree_exps(nvars, degree):
    if nvars == 1:
        yield (degree,)
        return
    for a in range(degree + 1):
        for rest in degree_exps(nvars - 1, degree - a):
            yield (a,) + rest


def nnz(v):
    return sum(1 for c in v if c != 0)

# ------------------------------------------------------------
# Load data
# ------------------------------------------------------------

print("Loading", INPUT_JSON)
with open(INPUT_JSON, "r") as f:
    exported = json.load(f)

print("Loading", PICKLE_FILE)
with open(PICKLE_FILE, "rb") as f:
    data = pickle.load(f)

R = data["R"]
I = data["I"]
syz = data["syz"]
nonzero_monomials = data["nonzero_monomials"]

x = R.gens()
nvars = len(x)

f_list = list(I.gens())
n_gens = len(f_list)
n_mons = len(nonzero_monomials)
n_params = n_gens * n_mons

f_terms = [poly_terms(R(f)) for f in f_list]
f_exps = []
for ft in f_terms:
    assert len(ft) == 1
    f_exps.append(list(ft.keys())[0])

basis3_exps = []
for m in nonzero_monomials:
    mt = poly_terms(R(m))
    assert len(mt) == 1
    basis3_exps.append(list(mt.keys())[0])

GEN_EXP_LIST = f_exps


def monomial_in_I(e):
    return any(monomial_divides(g, e) for g in GEN_EXP_LIST)


def raw_param_index(gen_index, mon_index):
    return gen_index * n_mons + mon_index


def raw_index_to_pair(idx):
    return int(idx) // n_mons, int(idx) % n_mons

print()
print("Basic data")
print("----------")
print("source prime =", exported["source_prime"])
print("replay prime =", REPLAY_PRIME)
print("base field =", BASE_FIELD)
print("number of variables =", nvars)
print("number of generators =", n_gens)
print("monomials in (S/I)_3 =", n_mons)
print("raw deformation parameters =", n_params)
print("syzygy rows =", syz.nrows())
print()

assert n_gens == 16
assert n_params == int(exported["n_params"])

# ------------------------------------------------------------
# Syzygy preprocessing
# ------------------------------------------------------------

syz_terms = []
syz_degrees = []

for r in range(syz.nrows()):
    row_terms = []
    degrees = set()

    for j in range(n_gens):
        s = R(syz[r, j])
        st = poly_terms(s)
        row_terms.append(st)

        for e, coeff in st.items():
            degrees.add(total_degree(e) + total_degree(f_exps[j]))

    if len(degrees) != 1:
        print("Bad syzygy row:", r, "degrees =", degrees)
        raise RuntimeError("syzygy row is not homogeneous")

    syz_terms.append(row_terms)
    syz_degrees.append(list(degrees)[0])

print("Syzygy total-degree histogram:")
print(dict(sorted(Counter(syz_degrees).items())))
print()

# ------------------------------------------------------------
# Coordinate conversions
# ------------------------------------------------------------

def sparse_data_to_vector(items, length):
    v = vector(BASE_FIELD, length)
    for i, a in items:
        v[int(i)] = BASE_FIELD(ZZ(a))
    return v


def direction_to_terms(direction):
    out = []
    for j in range(n_gens):
        terms = {}
        for m_idx, e in enumerate(basis3_exps):
            coeff = BASE_FIELD(direction[raw_param_index(j, m_idx)])
            if coeff != 0:
                terms[e] = coeff
        out.append(terms)
    return out


def multiply_term_dict(A, B, quotient=False):
    out = {}
    for e1, c1 in A.items():
        for e2, c2 in B.items():
            e = add_exp(e1, e2)
            if quotient and monomial_in_I(e):
                continue
            add_to_dict(out, e, c1 * c2)
    return out

# ------------------------------------------------------------
# Reconstruct A_1 columns and terms
# ------------------------------------------------------------

alpha_col = {}
col_count = n_params

for r in range(syz.nrows()):
    D = syz_degrees[r]
    corr_deg = D - 3
    if corr_deg < 0:
        raise RuntimeError("negative syzygy-correction degree")

    corr_mons = list(degree_exps(nvars, corr_deg))

    for j in range(n_gens):
        for q_exp in corr_mons:
            key = (r, j, q_exp)
            alpha_col[key] = col_count
            col_count += 1

n_corr = col_count - n_params
assert n_corr == int(exported["n_corr"])


def syz_vector_to_terms(v):
    out = [[{} for j in range(n_gens)] for r in range(syz.nrows())]
    if len(v) != n_corr:
        raise RuntimeError("syzygy vector has wrong length")
    for key, col in alpha_col.items():
        r, j, q_exp = key
        coeff = BASE_FIELD(v[col - n_params])
        if coeff != 0:
            out[r][j][q_exp] = coeff
    return out

# ------------------------------------------------------------
# Fixed G_1 and A_1 from exported integer lift
# ------------------------------------------------------------

G1 = sparse_data_to_vector(exported["G"]["1"], n_params)
A1 = sparse_data_to_vector(exported["A"]["1"], n_corr)
G1_terms = direction_to_terms(G1)
A1_terms = syz_vector_to_terms(A1)

G2_support = [int(i) for i, a in exported["G"]["2"]]
G3_support = [int(i) for i, a in exported["G"]["3"]]

print("Fixed / support data")
print("--------------------")
print("G_1 nnz =", nnz(G1))
print("A_1 nnz =", nnz(A1))
print("G_2 support size =", len(G2_support))
print("G_3 support size =", len(G3_support))
print()

# ------------------------------------------------------------
# Expression helpers
# ------------------------------------------------------------

def row_s_times_G(r, G_row_terms, quotient=True):
    total = {}
    for j in range(n_gens):
        if not syz_terms[r][j] or not G_row_terms[j]:
            continue
        prod = multiply_term_dict(syz_terms[r][j], G_row_terms[j], quotient=quotient)
        add_poly_inplace(total, prod)
    return total


def row_A1_times_H(r, H_terms, quotient=True):
    total = {}
    for j in range(n_gens):
        if not A1_terms[r][j] or not H_terms[j]:
            continue
        prod = multiply_term_dict(A1_terms[r][j], H_terms[j], quotient=quotient)
        add_poly_inplace(total, prod)
    return total


def add_expr(A, B):
    out = dict(A)
    add_poly_inplace(out, B)
    return out


def check_order1_modI():
    bad = []
    for r in range(syz.nrows()):
        expr = add_expr(
            row_s_times_G(r, G1_terms, quotient=True),
            row_A1_times_H(r, f_terms, quotient=True),
        )
        if expr:
            bad.append((r, expr))
    return bad

# ------------------------------------------------------------
# Linear solver on fixed generator support
# ------------------------------------------------------------

def solve_G_on_support(order, support, constant_terms_by_row):
    """
    Solve

        s G + constant = 0 mod I

    where G is supported on the given raw parameter indices.
    """
    col_of_idx = {idx: c for c, idx in enumerate(support)}
    rows_by_key = {}
    constant_by_key = {}

    for r in range(syz.nrows()):
        # Unknown part: s_r * G
        for idx in support:
            j, m_idx = raw_index_to_pair(idx)
            st = syz_terms[r][j]
            if not st:
                continue
            mon = {basis3_exps[m_idx]: BASE_FIELD(1)}
            prod = multiply_term_dict(st, mon, quotient=True)
            for e, c in prod.items():
                key = (r, e)
                add_exp_coeff_to_rows(rows_by_key, key, col_of_idx[idx], c)

        # Constant part
        for e, c in constant_terms_by_row[r].items():
            key = (r, e)
            add_to_dict(constant_by_key, key, c)
            rows_by_key.setdefault(key, {})

    entries = {}
    rhs = []

    for key in sorted(set(rows_by_key.keys()).union(set(constant_by_key.keys()))):
        coeffs = rows_by_key.get(key, {})
        constant = constant_by_key.get(key, BASE_FIELD(0))
        coeffs = {c: BASE_FIELD(v) for c, v in coeffs.items() if BASE_FIELD(v) != 0}

        if not coeffs and constant == 0:
            continue

        row = len(rhs)
        for col, val in coeffs.items():
            entries[(row, col)] = val
        rhs.append(-constant)

    A = matrix(BASE_FIELD, len(rhs), len(support), entries, sparse=True)
    b = vector(BASE_FIELD, rhs)
    B = A.augment(matrix(BASE_FIELD, A.nrows(), 1, list(b), sparse=True))

    rank_A = A.rank()
    rank_B = B.rank()
    solvable = (rank_A == rank_B)

    print("Order-%d same-support solve" % order)
    print("---------------------------")
    print("unknowns =", len(support))
    print("equations =", A.nrows())
    print("rank_A =", rank_A)
    print("rank_augmented =", rank_B)
    print("solvable =", solvable)
    print()

    if not solvable:
        return None, {
            "order": order,
            "unknowns": len(support),
            "equations": A.nrows(),
            "rank_A": rank_A,
            "rank_augmented": rank_B,
            "solvable": False,
        }

    sol = A.solve_right(b)
    residual_zero = (A * sol == b)
    print("residual zero =", residual_zero)
    print()

    if not residual_zero:
        raise RuntimeError("bad solve_right result at order %d" % order)

    G = vector(BASE_FIELD, n_params)
    for idx, col in col_of_idx.items():
        G[idx] = sol[col]

    return G, {
        "order": order,
        "unknowns": len(support),
        "equations": A.nrows(),
        "rank_A": rank_A,
        "rank_augmented": rank_B,
        "solvable": True,
        "residual_zero": residual_zero,
    }

# ------------------------------------------------------------
# Run order 1, solve order 2, solve order 3, check order 4
# ------------------------------------------------------------

print("Order-1 fixed replay check modulo I")
print("-----------------------------------")
bad1 = check_order1_modI()
print("order 1 modulo I ok =", len(bad1) == 0)
print("bad rows =", len(bad1))
print()

if bad1:
    for r, expr in bad1[:MAX_EXAMPLES]:
        print("row", r, "terms", sorted(expr.items())[:MAX_EXAMPLES])
    raise RuntimeError("G_1,A_1 do not replay at order 1")

# order 2 constant is A_1 G_1
constant2 = []
for r in range(syz.nrows()):
    constant2.append(row_A1_times_H(r, G1_terms, quotient=True))

G2, info2 = solve_G_on_support(2, G2_support, constant2)
if G2 is None:
    save({"replay_prime": REPLAY_PRIME, "order1_ok": True, "order2": info2}, OUTPUT_FILE)
    raise RuntimeError("no same-support G_2 over second prime")

G2_terms = direction_to_terms(G2)

# order 3 constant is A_1 G_2
constant3 = []
for r in range(syz.nrows()):
    constant3.append(row_A1_times_H(r, G2_terms, quotient=True))

G3, info3 = solve_G_on_support(3, G3_support, constant3)
if G3 is None:
    save({"replay_prime": REPLAY_PRIME, "order1_ok": True, "order2": info2, "order3": info3}, OUTPUT_FILE)
    raise RuntimeError("no same-support G_3 over second prime")

G3_terms = direction_to_terms(G3)

print("Order-4 check modulo I")
print("----------------------")
bad4 = []
for r in range(syz.nrows()):
    expr = row_A1_times_H(r, G3_terms, quotient=True)
    if expr:
        bad4.append((r, expr))

order4_ok = (len(bad4) == 0)
print("order 4 modulo I ok =", order4_ok)
print("bad rows =", len(bad4))
print()

if bad4:
    for r, expr in bad4[:MAX_EXAMPLES]:
        print("row", r, "terms", sorted(expr.items())[:MAX_EXAMPLES])

print("Resolved coefficients over second prime")
print("---------------------------------------")
print("G_2 nnz =", nnz(G2))
print("G_3 nnz =", nnz(G3))
print()

out = {
    "source_prime": int(exported["source_prime"]),
    "replay_prime": REPLAY_PRIME,
    "order1_ok": True,
    "order2": info2,
    "order3": info3,
    "order4_ok": order4_ok,
    "G1": G1,
    "A1": A1,
    "G2_resolved": G2,
    "G3_resolved": G3,
}

save(out, OUTPUT_FILE)
print("Saved", OUTPUT_FILE)

if not order4_ok:
    raise RuntimeError("resolved G_3 does not pass order 4")
