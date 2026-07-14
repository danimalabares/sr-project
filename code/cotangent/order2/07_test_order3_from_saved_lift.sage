# 07_test_order3_from_saved_lift.sage
#
# Test whether the saved order-2 lift extends to order 3.
#
# Run from:
#   code/cotangent/order2
#
# Input:
#   ../part-1.pkl
#   cache/one_order2_lift.sobj
#
# Output, if solvable:
#   cache/one_order3_lift.sobj
#
# Order-3 equation modulo I:
#
#   sum_j s_{rj} chi_j
# + sum_j alpha_{rj} psi_j
# + sum_j beta_{rj} phi_j
# = 0 in S/I.
#
# Unknown terms: s*chi + beta*phi
# Constant term: alpha*psi

import pickle
from collections import Counter

# ------------------------------------------------------------
# User parameters
# ------------------------------------------------------------

PICKLE_FILE = "../part-1.pkl"
ORDER2_FILE = "cache/one_order2_lift.sobj"
ORDER3_FILE = "cache/one_order3_lift.sobj"

USE_FINITE_FIELD = True
PRIME = 32003

if USE_FINITE_FIELD:
    BASE_FIELD = GF(PRIME)
else:
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
print("number of variables =", nvars)
print("number of generators =", n_gens)
print("monomials in (S/I)_3 =", n_mons)
print("raw deformation parameters =", n_params)
print("syzygy rows =", syz.nrows())
print()

assert n_gens == 16
assert n_params == 1664

# ------------------------------------------------------------
# Syzygy preprocessing, exactly as in 05/06
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

def direction_to_phi(direction):
    phi = []
    for j in range(n_gens):
        terms = {}
        for m_idx, e in enumerate(basis3_exps):
            coeff = BASE_FIELD(direction[raw_param_index(j, m_idx)])
            if coeff != 0:
                terms[e] = coeff
        phi.append(terms)
    return phi


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
# Reconstruct alpha_col exactly as in 06
# ------------------------------------------------------------

# In 06 the columns are:
#   0, ..., n_params-1      psi columns
#   n_params, ...           alpha columns
#
# get_alpha_col is first called in this order:
#   for r:
#     alpha_mons = degree_exps(nvars, syz_degrees[r] - 3)
#     for j:
#       for q_exp in alpha_mons:
#         get_alpha_col(r, j, q_exp)

alpha_col = {}
col_count = n_params

for r in range(syz.nrows()):
    D = syz_degrees[r]
    alpha_deg = D - 3
    if alpha_deg < 0:
        raise RuntimeError("negative alpha degree")

    alpha_mons = list(degree_exps(nvars, alpha_deg))

    for j in range(n_gens):
        for q_exp in alpha_mons:
            key = (r, j, q_exp)
            alpha_col[key] = col_count
            col_count += 1

n_alpha = col_count - n_params

print("Reconstructed alpha columns")
print("---------------------------")
print("alpha unknowns =", n_alpha)
print()

# ------------------------------------------------------------
# Load saved order-2 lift
# ------------------------------------------------------------

print("Loading", ORDER2_FILE)
saved = load(ORDER2_FILE)

direction = vector(BASE_FIELD, list(saved["direction"]))
psi_solution = vector(BASE_FIELD, list(saved["psi_solution"]))
alpha_solution = vector(BASE_FIELD, list(saved["alpha_solution"]))

if len(direction) != n_params:
    raise RuntimeError("direction has wrong length")
if len(psi_solution) != n_params:
    raise RuntimeError("psi_solution has wrong length")
if len(alpha_solution) != n_alpha:
    print("len(alpha_solution) =", len(alpha_solution))
    print("reconstructed n_alpha =", n_alpha)
    raise RuntimeError("alpha_solution length does not match reconstructed alpha_col")

phi = direction_to_phi(direction)
psi = direction_to_phi(psi_solution)

print("Saved order-2 lift")
print("------------------")
print("direction length =", len(direction))
print("psi length =", len(psi_solution))
print("alpha length =", len(alpha_solution))
print("old rank_A =", saved.get("rank_A", None))
print("old rank_B =", saved.get("rank_B", None))
print()

# ------------------------------------------------------------
# Build order-3 linear system
# ------------------------------------------------------------

# Unknowns in this script:
#   chi_{j,m}:       columns 0, ..., n_params-1
#   beta_{r,j,q}:    columns n_params, ..., n_params+n_alpha-1
#
# beta uses the same local indexing as alpha_solution.

def beta_col_from_alpha_key(key):
    return n_params + (alpha_col[key] - n_params)


def alpha_coeff(key):
    return BASE_FIELD(alpha_solution[alpha_col[key] - n_params])

entries = {}
rhs = []
order3_rows = []

for r in range(syz.nrows()):
    D = syz_degrees[r]
    beta_deg = D - 3
    if beta_deg < 0:
        raise RuntimeError("negative beta degree")

    beta_mons = list(degree_exps(nvars, beta_deg))

    rows_by_exp = {}
    constant_by_exp = {}

    # --------------------------------------------------------
    # Unknown chi terms:
    #   sum_j s_{rj} chi_j
    # --------------------------------------------------------
    for j in range(n_gens):
        st = syz_terms[r][j]
        if not st:
            continue

        for m_idx, m_exp in enumerate(basis3_exps):
            chi_col = raw_param_index(j, m_idx)
            mon = {m_exp: BASE_FIELD(1)}
            prod = multiply_term_dict(st, mon, quotient=True)
            for e, c in prod.items():
                rows_by_exp.setdefault(e, {})[chi_col] = (
                    rows_by_exp.setdefault(e, {}).get(chi_col, BASE_FIELD(0)) + c
                )

    # --------------------------------------------------------
    # Unknown beta terms:
    #   sum_j beta_{rj} phi_j
    # --------------------------------------------------------
    for j in range(n_gens):
        if not phi[j]:
            continue

        for q_exp in beta_mons:
            key = (r, j, q_exp)
            beta_col = beta_col_from_alpha_key(key)
            q = {q_exp: BASE_FIELD(1)}
            prod = multiply_term_dict(q, phi[j], quotient=True)
            for e, c in prod.items():
                rows_by_exp.setdefault(e, {})[beta_col] = (
                    rows_by_exp.setdefault(e, {}).get(beta_col, BASE_FIELD(0)) + c
                )

    # --------------------------------------------------------
    # Constant alpha*psi terms:
    #   sum_j alpha_{rj} psi_j
    # --------------------------------------------------------
    for j in range(n_gens):
        if not psi[j]:
            continue

        for q_exp in beta_mons:
            key = (r, j, q_exp)
            a = alpha_coeff(key)
            if a == 0:
                continue

            q = {q_exp: a}
            prod = multiply_term_dict(q, psi[j], quotient=True)
            for e, c in prod.items():
                add_to_dict(constant_by_exp, e, c)

    # Make sure pure-constant equations are not missed.
    for e in constant_by_exp:
        rows_by_exp.setdefault(e, {})

    for e, coeffs in rows_by_exp.items():
        constant = constant_by_exp.get(e, BASE_FIELD(0))
        row = add_row(entries, rhs, coeffs, constant)
        if row is not None:
            order3_rows.append(row)

n_unknowns = n_params + n_alpha
A = matrix(BASE_FIELD, len(rhs), n_unknowns, entries, sparse=True)
b = vector(BASE_FIELD, rhs)

print("Order-3 linear system")
print("---------------------")
print("unknowns total =", n_unknowns)
print("  chi unknowns =", n_params)
print("  beta unknowns =", n_alpha)
print("equations total =", A.nrows())
print("  order-3 equations =", len(order3_rows))
print()

B = A.augment(matrix(BASE_FIELD, A.nrows(), 1, list(b), sparse=True))
rank_A = A.rank()
rank_augmented = B.rank()
lifts = (rank_A == rank_augmented)

print("Order-3 rank test")
print("-----------------")
print("rank_A =", rank_A)
print("rank_augmented =", rank_augmented)
print("lifts to order 3:", lifts)
print()

if lifts:
    sol = A.solve_right(b)
    chi_solution = sol[:n_params]
    beta_solution = sol[n_params:]

    save(
        {
            "direction": direction,
            "psi_solution": psi_solution,
            "alpha_solution": alpha_solution,
            "chi_solution": chi_solution,
            "beta_solution": beta_solution,
            "rank_A": rank_A,
            "rank_augmented": rank_augmented,
            # compatibility with previous naming
            "rank_B": rank_augmented,
        },
        ORDER3_FILE,
    )

    print("Saved", ORDER3_FILE)
else:
    print("No order-3 lift found for this saved order-2 lift.")
