# 15_verify_cubic_family.sage
#
# Verify directly that the order-30 lift actually comes from
# a finite cubic family
#
#   F(t) = f + t G_1 + t^2 G_2 + t^3 G_3
#
# with syzygy correction
#
#   S(t) = s + t A_1.
#
# Run from:
#   code/cotangent/order2
#
# Input:
#   ../part-1.pkl
#   cache/formal_lift_to_order30.sobj
#
# Checks, row by row for every first syzygy s_r:
#
#   order 1: s G_1 + A_1 f = 0
#   order 2: s G_2 + A_1 G_1 = 0
#   order 3: s G_3 + A_1 G_2 = 0
#   order 4:         A_1 G_3 = 0
#
# Each identity is checked twice:
#   (1) exactly in the polynomial module;
#   (2) modulo the SR ideal I, by dropping monomials in I.

import pickle
from collections import Counter

# ------------------------------------------------------------
# User parameters
# ------------------------------------------------------------

PICKLE_FILE = "../part-1.pkl"
INPUT_FILE = "cache/formal_lift_to_order30.sobj"
OUTPUT_FILE = "cache/cubic_family_verification.sobj"

MAX_EXAMPLES = 8

# ------------------------------------------------------------
# Load saved lift first, to recover the prime
# ------------------------------------------------------------

print("Loading", INPUT_FILE)
lift = load(INPUT_FILE)

PRIME = int(lift["prime"])
BASE_FIELD = GF(PRIME)

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
    """Return {exponent_tuple: coeff} for a Sage polynomial."""
    out = {}
    for e, c in poly.dict().items():
        c = BASE_FIELD(c)
        if c != 0:
            out[exp_tuple(e)] = c
    return out


def degree_exps(nvars, degree):
    """All exponent tuples of total degree degree in nvars variables."""
    if nvars == 1:
        yield (degree,)
        return

    for a in range(degree + 1):
        for rest in degree_exps(nvars - 1, degree - a):
            yield (a,) + rest


def monomial_divides(a, b):
    """Does x^a divide x^b?"""
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


def nnz(v):
    return sum(1 for c in v if c != 0)

# ------------------------------------------------------------
# Load first-order data
# ------------------------------------------------------------

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
print("base field =", BASE_FIELD)
print("prime =", PRIME)
print("number of variables =", nvars)
print("number of generators =", n_gens)
print("monomials in (S/I)_3 =", n_mons)
print("raw deformation parameters =", n_params)
print("syzygy rows =", syz.nrows())
print()

assert n_gens == 16
assert n_params == 1664

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
            coeff = BASE_FIELD(direction[raw_param_index(j, m_idx)])
            if coeff != 0:
                terms[e] = coeff
        out.append(terms)
    return out


def multiply_term_dict(A, B, quotient=False):
    """
    Multiply sparse polynomial dictionaries.
    If quotient=True, drop monomials in I.
    """
    out = {}
    for e1, c1 in A.items():
        for e2, c2 in B.items():
            e = add_exp(e1, e2)
            if quotient and monomial_in_I(e):
                continue
            add_to_dict(out, e, c1 * c2)
    return out

# ------------------------------------------------------------
# Reconstruct syzygy-correction columns
# ------------------------------------------------------------

alpha_col = {}
col_count = n_params
corr_mons_by_row = {}

for r in range(syz.nrows()):
    D = syz_degrees[r]
    corr_deg = D - 3
    if corr_deg < 0:
        raise RuntimeError("negative syzygy-correction degree")

    corr_mons = list(degree_exps(nvars, corr_deg))
    corr_mons_by_row[r] = corr_mons

    for j in range(n_gens):
        for q_exp in corr_mons:
            key = (r, j, q_exp)
            alpha_col[key] = col_count
            col_count += 1

n_corr = col_count - n_params

print("Reconstructed syzygy-correction columns")
print("---------------------------------------")
print("correction unknowns =", n_corr)
print()

assert n_corr == int(lift["n_corr"])


def syz_vector_to_terms(v):
    """
    Convert one syzygy-correction vector into row/column polynomial terms.

    Output shape:
        out[r][j] = sparse polynomial dictionary for A_{rj}.
    """
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
# Load G_1, G_2, G_3, A_1 and check termination pattern
# ------------------------------------------------------------

if lift.get("status", None) != "success":
    print("WARNING: saved lift status is", lift.get("status", None))

gen_vectors = lift["gen_vectors"]
syz_vectors = lift["syz_vectors"]

G = {}
G_terms = {}
for k in [1, 2, 3]:
    if k not in gen_vectors:
        raise RuntimeError("missing G_%d" % k)
    G[k] = vector(BASE_FIELD, list(gen_vectors[k]))
    if len(G[k]) != n_params:
        raise RuntimeError("G_%d has wrong length" % k)
    G_terms[k] = direction_to_terms(G[k])

if 1 not in syz_vectors:
    raise RuntimeError("missing A_1")
A1 = vector(BASE_FIELD, list(syz_vectors[1]))
A1_terms = syz_vector_to_terms(A1)

print("Loaded cubic data")
print("-----------------")
for k in [1, 2, 3]:
    print("G_%d length = %d nnz = %d" % (k, len(G[k]), nnz(G[k])))
print("A_1 length = %d nnz = %d" % (len(A1), nnz(A1)))
print()

print("Tail zero check")
print("---------------")
gen_tail_ok = True
for k in sorted(gen_vectors):
    if k >= 4:
        z = (nnz(gen_vectors[k]) == 0)
        gen_tail_ok = gen_tail_ok and z
        print("G_%d zero = %s" % (k, z))

syz_tail_ok = True
for k in sorted(syz_vectors):
    if k >= 2:
        z = (nnz(syz_vectors[k]) == 0)
        syz_tail_ok = syz_tail_ok and z
        print("A_%d zero = %s" % (k, z))
print()

# ------------------------------------------------------------
# Row expressions for the four identities
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

print("Cubic-family identity checks")
print("----------------------------")
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

print("Final verdict")
print("-------------")
print("tail generator corrections zero:", gen_tail_ok)
print("tail syzygy corrections zero:", syz_tail_ok)
print("all four identities modulo I:", all_modI_ok)
print("all four identities exactly:", all_exact_ok)
print()

out = {
    "prime": PRIME,
    "input_file": INPUT_FILE,
    "gen_tail_ok": gen_tail_ok,
    "syz_tail_ok": syz_tail_ok,
    "all_modI_ok": all_modI_ok,
    "all_exact_ok": all_exact_ok,
    "results": results,
}

save(out, OUTPUT_FILE)
print("Saved", OUTPUT_FILE)

if not all_modI_ok:
    raise RuntimeError("cubic-family verification failed modulo I")
