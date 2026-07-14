# 10_iterate_lifts_from_order5.sage
#
# Iterate the saved formal lift from order 5 up to MAX_ORDER.
#
# Run from:
#   code/cotangent/order2
#
# Input:
#   ../part-1.pkl
#   cache/one_order5_lift.sobj
#
# Output:
#   cache/formal_lift_to_order12.sobj
#
# General order-n equation modulo I:
#
#   s*G_n + A_{n-1}*G_1
#   + sum_{a=1}^{n-2} A_a * G_{n-a}
#   = 0 in S/I.
#
# Here:
#   G_1 = phi
#   G_2 = psi
#   G_3 = chi
#   G_4 = eta
#   G_5 = theta
#
# and:
#   A_1 = alpha
#   A_2 = beta
#   A_3 = gamma
#   A_4 = delta
#
# Unknown terms at order n:
#   s*G_n + A_{n-1}*phi
#
# Constant term at order n:
#   sum_{a=1}^{n-2} A_a * G_{n-a}

import pickle
from collections import Counter

# ------------------------------------------------------------
# User parameters
# ------------------------------------------------------------

PICKLE_FILE = "../part-1.pkl"
INPUT_FILE = "cache/one_order5_lift.sobj"
OUTPUT_FILE = "cache/formal_lift_to_order30.sobj"

START_ORDER = 6
MAX_ORDER = 30

USE_FINITE_FIELD = True
PRIME = 32003

if USE_FINITE_FIELD:
    BASE_FIELD = GF(PRIME)
else:
    BASE_FIELD = QQ

# known generator corrections G_k
GEN_SOLUTION_NAMES = {
    1: "direction",
    2: "psi_solution",
    3: "chi_solution",
    4: "eta_solution",
    5: "theta_solution",
}

# known syzygy corrections A_a
SYZ_SOLUTION_NAMES = {
    1: "alpha_solution",
    2: "beta_solution",
    3: "gamma_solution",
    4: "delta_solution",
}

GEN_LABELS = {
    1: "phi",
    2: "psi",
    3: "chi",
    4: "eta",
    5: "theta",
    6: "G6",
    7: "G7",
    8: "G8",
    9: "G9",
    10: "G10",
    11: "G11",
    12: "G12",
}

SYZ_LABELS = {
    1: "alpha",
    2: "beta",
    3: "gamma",
    4: "delta",
    5: "A5",
    6: "A6",
    7: "A7",
    8: "A8",
    9: "A9",
    10: "A10",
    11: "A11",
}

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


def add_row(entries, rhs, coeffs, constant=0):
    """
    Add equation:

        sum coeffs[col]*unknown[col] + constant = 0.

    So the matrix RHS gets -constant.
    Returns the row index, or None if the equation is 0=0.
    """
    constant = BASE_FIELD(constant)
    coeffs = {c: BASE_FIELD(v) for c, v in coeffs.items()
              if BASE_FIELD(v) != 0}

    if not coeffs and constant == 0:
        return None

    row = len(rhs)
    for col, val in coeffs.items():
        entries[(row, col)] = entries.get((row, col), BASE_FIELD(0)) + val
        if entries[(row, col)] == 0:
            del entries[(row, col)]
    rhs.append(-constant)
    return row

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
print("start order =", START_ORDER)
print("max order =", MAX_ORDER)
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
n_unknowns = n_params + n_corr

print("Reconstructed syzygy-correction columns")
print("---------------------------------------")
print("correction unknowns =", n_corr)
print("total unknowns per order =", n_unknowns)
print()

def new_syz_col_from_key(key):
    return n_params + (alpha_col[key] - n_params)

# ------------------------------------------------------------
# Load saved order-5 lift
# ------------------------------------------------------------

print("Loading", INPUT_FILE)
saved = load(INPUT_FILE)

gen_vectors = {}
gen_terms = {}
syz_vectors = {}

for k in sorted(GEN_SOLUTION_NAMES):
    name = GEN_SOLUTION_NAMES[k]
    if name not in saved:
        raise RuntimeError("missing saved generator correction: " + name)

    v = vector(BASE_FIELD, list(saved[name]))
    if len(v) != n_params:
        raise RuntimeError(name + " has wrong length")

    gen_vectors[k] = v
    gen_terms[k] = direction_to_terms(v)

for a in sorted(SYZ_SOLUTION_NAMES):
    name = SYZ_SOLUTION_NAMES[a]
    if name not in saved:
        raise RuntimeError("missing saved syzygy correction: " + name)

    v = vector(BASE_FIELD, list(saved[name]))
    if len(v) != n_corr:
        print("len(%s) =" % name, len(v))
        print("reconstructed n_corr =", n_corr)
        raise RuntimeError(name + " length does not match reconstructed alpha_col")

    syz_vectors[a] = v

print("Saved lift data")
print("---------------")
for k in sorted(gen_vectors):
    print("G_%d %-6s length =" % (k, GEN_LABELS.get(k, "?")), len(gen_vectors[k]))
for a in sorted(syz_vectors):
    print("A_%d %-6s length =" % (a, SYZ_LABELS.get(a, "?")), len(syz_vectors[a]))
print("old rank_A =", saved.get("rank_A", None))
print("old rank_augmented =", saved.get("rank_augmented", saved.get("rank_B", None)))
print()

# ------------------------------------------------------------
# Build order-n linear system
# ------------------------------------------------------------

def syz_coeff(a, key):
    return BASE_FIELD(syz_vectors[a][alpha_col[key] - n_params])


def build_order_system(order):
    """
    Build the linear system for extending from order-1 to order.

    Unknowns:
      G_order: columns 0,...,n_params-1
      A_{order-1}: columns n_params,...,n_params+n_corr-1
    """
    entries = {}
    rhs = []
    target_rows = []

    phi = gen_terms[1]

    for r in range(syz.nrows()):
        D = syz_degrees[r]
        corr_deg = D - 3
        if corr_deg < 0:
            raise RuntimeError("negative correction degree")

        corr_mons = list(degree_exps(nvars, corr_deg))

        rows_by_exp = {}
        constant_by_exp = {}

        # ----------------------------------------------------
        # Unknown new generator terms:
        #   sum_j s_{rj} G_order,j
        # ----------------------------------------------------
        for j in range(n_gens):
            st = syz_terms[r][j]
            if not st:
                continue

            for m_idx, m_exp in enumerate(basis3_exps):
                new_gen_col = raw_param_index(j, m_idx)
                mon = {m_exp: BASE_FIELD(1)}
                prod = multiply_term_dict(st, mon, quotient=True)
                for e, c in prod.items():
                    rows_by_exp.setdefault(e, {})[new_gen_col] = (
                        rows_by_exp.setdefault(e, {}).get(new_gen_col, BASE_FIELD(0)) + c
                    )

        # ----------------------------------------------------
        # Unknown new syzygy terms:
        #   sum_j A_{order-1,rj} * phi_j
        # ----------------------------------------------------
        for j in range(n_gens):
            if not phi[j]:
                continue

            for q_exp in corr_mons:
                key = (r, j, q_exp)
                new_syz_col = new_syz_col_from_key(key)
                q = {q_exp: BASE_FIELD(1)}
                prod = multiply_term_dict(q, phi[j], quotient=True)
                for e, c in prod.items():
                    rows_by_exp.setdefault(e, {})[new_syz_col] = (
                        rows_by_exp.setdefault(e, {}).get(new_syz_col, BASE_FIELD(0)) + c
                    )

        # ----------------------------------------------------
        # Constant terms:
        #   sum_{a=1}^{order-2} A_a * G_{order-a}
        # ----------------------------------------------------
        for a in range(1, order - 1):
            G_index = order - a
            A_index = a

            if A_index not in syz_vectors:
                raise RuntimeError("missing syzygy correction A_%d" % A_index)
            if G_index not in gen_terms:
                raise RuntimeError("missing generator correction G_%d" % G_index)

            G_terms = gen_terms[G_index]

            for j in range(n_gens):
                if not G_terms[j]:
                    continue

                for q_exp in corr_mons:
                    key = (r, j, q_exp)
                    a_coeff = syz_coeff(A_index, key)
                    if a_coeff == 0:
                        continue

                    q = {q_exp: a_coeff}
                    prod = multiply_term_dict(q, G_terms[j], quotient=True)
                    for e, c in prod.items():
                        add_to_dict(constant_by_exp, e, c)

        # Make sure pure-constant equations are not missed.
        for e in constant_by_exp:
            rows_by_exp.setdefault(e, {})

        for e, coeffs in rows_by_exp.items():
            constant = constant_by_exp.get(e, BASE_FIELD(0))
            row = add_row(entries, rhs, coeffs, constant)
            if row is not None:
                target_rows.append(row)

    A = matrix(BASE_FIELD, len(rhs), n_unknowns, entries, sparse=True)
    b = vector(BASE_FIELD, rhs)

    return A, b, target_rows

# ------------------------------------------------------------
# Save cumulative state
# ------------------------------------------------------------

rank_A_by_order = {}
rank_augmented_by_order = {}
residual_zero_by_order = {}


def save_state(max_order_reached, status):
    out = {
        "prime": PRIME,
        "status": status,
        "start_order": START_ORDER,
        "max_order_target": MAX_ORDER,
        "max_order_reached": max_order_reached,
        "gen_vectors": gen_vectors,
        "syz_vectors": syz_vectors,
        "rank_A_by_order": rank_A_by_order,
        "rank_augmented_by_order": rank_augmented_by_order,
        "residual_zero_by_order": residual_zero_by_order,
        "n_params": n_params,
        "n_corr": n_corr,
        "n_unknowns": n_unknowns,
    }

    save(out, OUTPUT_FILE)
    print("Saved cumulative state to", OUTPUT_FILE)

# ------------------------------------------------------------
# Iterate
# ------------------------------------------------------------

last_success = START_ORDER - 1

for order in range(START_ORDER, MAX_ORDER + 1):
    print()
    print("=" * 60)
    print("Solving order", order)
    print("=" * 60)

    A, b, target_rows = build_order_system(order)

    print("Order-%d linear system" % order)
    print("---------------------")
    print("unknowns total =", n_unknowns)
    print("  new generator unknowns =", n_params)
    print("  new syzygy unknowns =", n_corr)
    print("equations total =", A.nrows())
    print("  order-%d equations =" % order, len(target_rows))
    print()

    B = A.augment(matrix(BASE_FIELD, A.nrows(), 1, list(b), sparse=True))

    rank_A = A.rank()
    rank_augmented = B.rank()
    lifts = (rank_A == rank_augmented)

    rank_A_by_order[order] = rank_A
    rank_augmented_by_order[order] = rank_augmented

    print("Order-%d rank test" % order)
    print("-----------------")
    print("rank_A =", rank_A)
    print("rank_augmented =", rank_augmented)
    print("lifts to order %d:" % order, lifts)
    print()

    if not lifts:
        print("STOP: obstruction at order", order)
        save_state(last_success, "obstructed_at_order_%d" % order)
        break

    sol = A.solve_right(b)

    residual_zero = (A * sol == b)
    residual_zero_by_order[order] = residual_zero

    print("residual zero:", residual_zero)

    if not residual_zero:
        raise RuntimeError("Sage solve_right returned bad solution at order %d" % order)

    new_gen_solution = vector(BASE_FIELD, list(sol[:n_params]))
    new_syz_solution = vector(BASE_FIELD, list(sol[n_params:]))

    gen_vectors[order] = new_gen_solution
    gen_terms[order] = direction_to_terms(new_gen_solution)
    syz_vectors[order - 1] = new_syz_solution

    print("stored G_%d length =" % order, len(new_gen_solution))
    print("stored A_%d length =" % (order - 1), len(new_syz_solution))

    last_success = order

    save_state(last_success, "running")

else:
    print()
    print("SUCCESS")
    print("-------")
    print("Reached order", MAX_ORDER)
    save_state(MAX_ORDER, "success")
