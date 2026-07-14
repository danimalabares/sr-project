# 20_verify_cubic_family_over_QQ_from_json.sage
#
# Independent QQ verifier for the cubic family.
#
# This script does NOT load:
#   cache/formal_lift_to_order30.sobj
# and does NOT use any finite field.
#
# It only uses:
#   ../part-1.pkl
#   cache/cubic_family_QQ_data.json
#
# It verifies the four identities:
#
#   order 1: s G_1 + A_1 f = 0          exactly over QQ
#   order 2: s G_2 + A_1 G_1 = 0        modulo I over QQ
#   order 3: s G_3 + A_1 G_2 = 0        modulo I over QQ
#   order 4:         A_1 G_3 = 0        modulo I over QQ
#
# It also reports exact polynomial-module checks for orders 2,3,4.

import pickle
import json
from collections import Counter

# ------------------------------------------------------------
# User parameters
# ------------------------------------------------------------

PICKLE_FILE = "../part-1.pkl"
INPUT_JSON = "cache/cubic_family_QQ_data.json"
OUTPUT_FILE = "cache/cubic_family_QQ_verification.sobj"

MAX_EXAMPLES = 8
BASE_FIELD = QQ

# ------------------------------------------------------------
# Small utilities
# ------------------------------------------------------------

def exp_tuple(e):
    return tuple(int(a) for a in e)


def add_exp(a, b):
    return tuple(x + y for x, y in zip(a, b))


def total_degree(e):
    return sum(e)


def balanced_lift_from_finite_field(c):
    a = int(c.lift())
    try:
        p = int(c.parent().order())
        if a > p // 2:
            a -= p
    except Exception:
        pass
    return ZZ(a)


def as_QQ(c):
    try:
        return QQ(c)
    except Exception:
        if hasattr(c, "lift"):
            return QQ(balanced_lift_from_finite_field(c))
        return QQ(ZZ(c))


def poly_terms(poly):
    out = {}
    for e, c in poly.dict().items():
        c = as_QQ(c)
        if c != 0:
            out[exp_tuple(e)] = c
    return out


def monomial_divides(a, b):
    return all(x <= y for x, y in zip(a, b))


def add_to_dict(d, key, value):
    value = QQ(value)
    if value == 0:
        return
    d[key] = d.get(key, QQ(0)) + value
    if d[key] == 0:
        del d[key]


def add_poly_inplace(A, B):
    for e, c in B.items():
        add_to_dict(A, e, c)


def degree_exps(nvars, degree):
    if nvars == 1:
        yield (degree,)
        return
    for a in range(degree + 1):
        for rest in degree_exps(nvars - 1, degree - a):
            yield (a,) + rest


def nnz(v):
    return sum(1 for c in v if c != 0)


def rational_from_json(pair):
    return QQ(ZZ(pair[0])) / QQ(ZZ(pair[1]))


def sparse_rational_data_to_vector(items, length):
    v = vector(QQ, length)
    for i, pair in items:
        v[int(i)] = rational_from_json(pair)
    return v

# ------------------------------------------------------------
# Load data
# ------------------------------------------------------------

print("Loading", INPUT_JSON)
with open(INPUT_JSON, "r") as f:
    cubic = json.load(f)

if cubic.get("base_field", None) != "QQ":
    raise RuntimeError("expected QQ cubic data JSON")

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

print()
print("Basic data")
print("----------")
print("base field = QQ")
print("number of variables =", nvars)
print("number of generators =", n_gens)
print("monomials in (S/I)_3 =", n_mons)
print("raw deformation parameters =", n_params)
print("syzygy rows =", syz.nrows())
print()

assert n_gens == 16
assert n_params == int(cubic["n_params"])

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

def direction_to_terms(direction):
    out = []
    for j in range(n_gens):
        terms = {}
        for m_idx, e in enumerate(basis3_exps):
            coeff = QQ(direction[raw_param_index(j, m_idx)])
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
assert n_corr == int(cubic["n_corr"])


def syz_vector_to_terms(v):
    out = [[{} for j in range(n_gens)] for r in range(syz.nrows())]
    if len(v) != n_corr:
        raise RuntimeError("syzygy vector has wrong length")
    for key, col in alpha_col.items():
        r, j, q_exp = key
        coeff = QQ(v[col - n_params])
        if coeff != 0:
            out[r][j][q_exp] = coeff
    return out

# ------------------------------------------------------------
# Load QQ cubic family
# ------------------------------------------------------------

G = {}
G_terms = {}
for k in [1, 2, 3]:
    G[k] = sparse_rational_data_to_vector(cubic["G"][str(k)], n_params)
    G_terms[k] = direction_to_terms(G[k])

A1 = sparse_rational_data_to_vector(cubic["A"]["1"], n_corr)
A1_terms = syz_vector_to_terms(A1)

print("Loaded QQ cubic data")
print("--------------------")
for k in [1, 2, 3]:
    print("G_%d length = %d nnz = %d" % (k, len(G[k]), nnz(G[k])))
print("A_1 length = %d nnz = %d" % (len(A1), nnz(A1)))
print()

# ------------------------------------------------------------
# Row expressions
# ------------------------------------------------------------

def row_s_times_G(r, G_row_terms, quotient=False):
    total = {}
    for j in range(n_gens):
        if not syz_terms[r][j] or not G_row_terms[j]:
            continue
        prod = multiply_term_dict(syz_terms[r][j], G_row_terms[j], quotient=quotient)
        add_poly_inplace(total, prod)
    return total


def row_A1_times_H(r, H_terms, quotient=False):
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


def order_expr(order, r, quotient=False):
    if order == 1:
        return add_expr(
            row_s_times_G(r, G_terms[1], quotient=quotient),
            row_A1_times_H(r, f_terms, quotient=quotient),
        )
    if order == 2:
        return add_expr(
            row_s_times_G(r, G_terms[2], quotient=quotient),
            row_A1_times_H(r, G_terms[1], quotient=quotient),
        )
    if order == 3:
        return add_expr(
            row_s_times_G(r, G_terms[3], quotient=quotient),
            row_A1_times_H(r, G_terms[2], quotient=quotient),
        )
    if order == 4:
        return row_A1_times_H(r, G_terms[3], quotient=quotient)
    raise RuntimeError("bad order")


def check_identity(order, quotient=False):
    bad = []
    total_terms = 0
    max_terms = 0

    for r in range(syz.nrows()):
        expr = order_expr(order, r, quotient=quotient)
        if expr:
            bad.append((r, expr))
            total_terms += len(expr)
            max_terms = max(max_terms, len(expr))

    return {
        "order": order,
        "quotient": quotient,
        "ok": (len(bad) == 0),
        "bad_rows": len(bad),
        "total_nonzero_terms": total_terms,
        "max_terms_in_bad_row": max_terms,
        "examples": bad[:MAX_EXAMPLES],
    }

# ------------------------------------------------------------
# Run checks
# ------------------------------------------------------------

results = []

print("QQ cubic-family identity checks")
print("--------------------------------")
for order in [1, 2, 3, 4]:
    exact = check_identity(order, quotient=False)
    modI = check_identity(order, quotient=True)
    results.append((exact, modI))

    print("order", order)
    print("  exact in polynomial module:", exact["ok"])
    print("    bad rows =", exact["bad_rows"],
          "nonzero terms =", exact["total_nonzero_terms"])
    print("  modulo I:", modI["ok"])
    print("    bad rows =", modI["bad_rows"],
          "nonzero terms =", modI["total_nonzero_terms"])

    if not modI["ok"]:
        print("  examples modulo I:")
        for r, expr in modI["examples"]:
            print("    row", r, "terms", sorted(expr.items())[:MAX_EXAMPLES])

    if modI["ok"] and not exact["ok"]:
        print("  note: exact check fails, but only by terms inside I")

print()

all_modI_ok = all(modI["ok"] for exact, modI in results)
all_exact_ok = all(exact["ok"] for exact, modI in results)
order1_exact_ok = results[0][0]["ok"]
orders234_modI_ok = all(results[k - 1][1]["ok"] for k in [2, 3, 4])

print("Final verdict")
print("-------------")
print("order 1 exact over QQ:", order1_exact_ok)
print("orders 2,3,4 modulo I over QQ:", orders234_modI_ok)
print("all four identities modulo I over QQ:", all_modI_ok)
print("all four identities exactly over QQ:", all_exact_ok)
print()

out = {
    "base_field": "QQ",
    "input_json": INPUT_JSON,
    "order1_exact_ok": order1_exact_ok,
    "orders234_modI_ok": orders234_modI_ok,
    "all_modI_ok": all_modI_ok,
    "all_exact_ok": all_exact_ok,
    "results": results,
}

save(out, OUTPUT_FILE)
print("Saved", OUTPUT_FILE)

if not order1_exact_ok:
    raise RuntimeError("order 1 exact QQ verification failed")
if not orders234_modI_ok:
    raise RuntimeError("orders 2,3,4 modulo-I QQ verification failed")

print("QQ verifier passed.")
