# random_second_order_lift_test.sage
#
# Exploratory obstruction test for SR(M).
#
# Input needed in this directory:
#   - M_FACETS.py
#   - part-1.pkl
#
# What it does:
#   1. Loads Michele's first-order syzygy constraints from part-1.pkl.
#   2. Picks random first-order directions in Hom_S(I,S/I)_0.
#   3. For each direction, asks whether the generators can be lifted to order 2:
#
#          f_i + t phi_i + t^2 psi_i     modulo t^3.
#
#   4. This is done by solving the linearized second-order syzygy-lifting equations.
#
# Interpretation:
#   - If a random direction does NOT lift, it is obstructed at order 2.
#   - If it lifts, this does not prove unobstructedness; test higher order next.
#
# By default this works over a finite field for speed. This is exploratory.

import pickle
import random
from itertools import combinations
from collections import Counter

# ------------------------------------------------------------
# User parameters
# ------------------------------------------------------------

PICKLE_FILE = "../part-1.pkl"
N_TESTS = 5
SEED = 20

USE_FINITE_FIELD = True
PRIME = 32003

if USE_FINITE_FIELD:
    BASE_FIELD = GF(PRIME)
else:
    BASE_FIELD = QQ

random.seed(int(SEED))

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
    if value == 0:
        return
    d[key] = d.get(key, BASE_FIELD(0)) + value
    if d[key] == 0:
        del d[key]


def add_row(entries, rhs, coeffs, constant=0):
    """
    Add equation: sum coeffs[col]*unknown[col] + constant = 0.
    Returns the row index, or None if the equation is 0=0.
    """
    constant = BASE_FIELD(constant)
    coeffs = {c: BASE_FIELD(v) for c, v in coeffs.items() if BASE_FIELD(v) != 0}

    if not coeffs and constant == 0:
        return None

    row = len(rhs)
    for col, val in coeffs.items():
        entries[(row, col)] = entries.get((row, col), BASE_FIELD(0)) + val
    rhs.append(-constant)
    return row


# ------------------------------------------------------------
# Load data
# ------------------------------------------------------------

print("Loading", PICKLE_FILE)
with open(PICKLE_FILE, "rb") as f:
    data = pickle.load(f)

R = data["R"]
I = data["I"]
syz = data["syz"]
R_param = data["R_param"]
def_params = data["def_params"]
all_coeffs = data["all_coeffs"]
nonzero_monomials = data["nonzero_monomials"]

x = R.gens()
nvars = len(x)

f_list = list(I.gens())
n_gens = len(f_list)
n_mons = len(nonzero_monomials)
n_params = len(def_params)

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

# monomial ideal membership test
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
assert n_params == n_gens * n_mons

# ------------------------------------------------------------
# Build the first-order Hom-space matrix C
# ------------------------------------------------------------

param_index_from_exp = {}
for i in range(n_params):
    e = [0] * n_params
    e[i] = 1
    param_index_from_exp[tuple(e)] = i

constraint_entries = {}
constraint_rhs = []

for c in all_coeffs:
    c = R_param(c)
    if c == 0:
        continue

    row_coeffs = {}
    constant = BASE_FIELD(0)

    for e, coeff in c.dict().items():
        e = exp_tuple(e)
        coeff = BASE_FIELD(coeff)
        deg = sum(e)

        if deg == 0:
            constant += coeff
        elif deg == 1:
            j = e.index(1)
            row_coeffs[j] = row_coeffs.get(j, BASE_FIELD(0)) + coeff
        else:
            raise RuntimeError("nonlinear first-order constraint found")

    add_row(constraint_entries, constraint_rhs, row_coeffs, constant)

C = matrix(BASE_FIELD, len(constraint_rhs), n_params, constraint_entries, sparse=True)

print("First-order Hom-space")
print("---------------------")
print("constraint matrix =", C.nrows(), "x", C.ncols())
print("rank =", C.rank())
print("dim Hom_S(I,S/I)_0 =", n_params - C.rank())
print()

kernel_basis = C.right_kernel().basis()
print("kernel basis length =", len(kernel_basis))
print()

if len(kernel_basis) == 0:
    raise RuntimeError("Hom-space kernel is zero; something is wrong")

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
# Random first-order direction
# ------------------------------------------------------------

def random_hom_direction():
    v = vector(BASE_FIELD, n_params)
    while v == 0:
        for b in kernel_basis:
            if USE_FINITE_FIELD:
                a = BASE_FIELD(random.randrange(PRIME))
            else:
                a = BASE_FIELD(random.randint(-5, 5))
            v += a * b
    return v


def direction_to_phi(direction):
    phi = []
    for j in range(n_gens):
        terms = {}
        for m_idx, e in enumerate(basis3_exps):
            coeff = direction[raw_param_index(j, m_idx)]
            if coeff != 0:
                terms[e] = coeff
        phi.append(terms)
    return phi


def multiply_term_dict(A, B, quotient=False):
    """
    Multiply two sparse polynomials represented by exponent dictionaries.
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
# Main second-order lifting test
# ------------------------------------------------------------

def test_lift_to_order_2(direction, test_number):
    phi = direction_to_phi(direction)

    # Unknowns:
    #   psi_{j,m}: second-order generator correction
    #   alpha_{r,j,q}: first-order syzygy correction for syzygy row r
    #
    # We start with psi columns.
    col_count = n_params
    alpha_col = {}

    def get_alpha_col(r, j, q_exp):
        nonlocal col_count
        key = (r, j, q_exp)
        if key not in alpha_col:
            alpha_col[key] = col_count
            col_count += 1
        return alpha_col[key]

    entries = {}
    rhs = []
    order1_rows = []
    order2_rows = []

    for r in range(syz.nrows()):
        D = syz_degrees[r]
        alpha_deg = D - 3
        if alpha_deg < 0:
            raise RuntimeError("negative alpha degree")

        alpha_mons = list(degree_exps(nvars, alpha_deg))

        # ----------------------------------------------------
        # Order 1 equations:
        #   sum_j s_j phi_j + sum_j alpha_j f_j = 0 in S
        # ----------------------------------------------------
        rows_by_exp = {}

        # constant part: sum s_j phi_j
        P1 = {}
        for j in range(n_gens):
            prod = multiply_term_dict(syz_terms[r][j], phi[j], quotient=False)
            for e, c in prod.items():
                add_to_dict(P1, e, c)

        # alpha_j f_j terms
        for j in range(n_gens):
            for q_exp in alpha_mons:
                col = get_alpha_col(r, j, q_exp)
                e = add_exp(q_exp, f_exps[j])
                rows_by_exp.setdefault(e, {})[col] = rows_by_exp.setdefault(e, {}).get(col, BASE_FIELD(0)) + BASE_FIELD(1)

        for e, const in P1.items():
            rows_by_exp.setdefault(e, {})

        for e, coeffs in rows_by_exp.items():
            const = P1.get(e, BASE_FIELD(0))
            row = add_row(entries, rhs, coeffs, const)
            if row is not None:
                order1_rows.append(row)

        # ----------------------------------------------------
        # Order 2 equations modulo I:
        #   sum_j s_j psi_j + sum_j alpha_j phi_j = 0 in S/I
        # ----------------------------------------------------
        rows_by_exp = {}

        # psi terms: sum s_j psi_j
        for j in range(n_gens):
            st = syz_terms[r][j]
            if not st:
                continue

            for m_idx, m_exp in enumerate(basis3_exps):
                psi_col = raw_param_index(j, m_idx)
                mon = {m_exp: BASE_FIELD(1)}
                prod = multiply_term_dict(st, mon, quotient=True)
                for e, c in prod.items():
                    rows_by_exp.setdefault(e, {})[psi_col] = rows_by_exp.setdefault(e, {}).get(psi_col, BASE_FIELD(0)) + c

        # alpha terms: sum alpha_j phi_j
        for j in range(n_gens):
            if not phi[j]:
                continue

            for q_exp in alpha_mons:
                col = get_alpha_col(r, j, q_exp)
                q = {q_exp: BASE_FIELD(1)}
                prod = multiply_term_dict(q, phi[j], quotient=True)
                for e, c in prod.items():
                    rows_by_exp.setdefault(e, {})[col] = rows_by_exp.setdefault(e, {}).get(col, BASE_FIELD(0)) + c

        for e, coeffs in rows_by_exp.items():
            row = add_row(entries, rhs, coeffs, BASE_FIELD(0))
            if row is not None:
                order2_rows.append(row)

    A = matrix(BASE_FIELD, len(rhs), col_count, entries, sparse=True)
    b = vector(BASE_FIELD, rhs)

    # Check order-1 subsystem first. If this fails, the script is wrong or direction not in Hom.
    A1 = A.matrix_from_rows(order1_rows)
    b1 = vector(BASE_FIELD, [b[i] for i in order1_rows])
    B1 = A1.augment(matrix(BASE_FIELD, len(order1_rows), 1, list(b1), sparse=True))

    rank_A1 = A1.rank()
    rank_B1 = B1.rank()
    order1_ok = (rank_A1 == rank_B1)

    B = A.augment(matrix(BASE_FIELD, A.nrows(), 1, list(b), sparse=True))
    rank_A = A.rank()
    rank_B = B.rank()
    lifts = (rank_A == rank_B)

    print("Test", test_number)
    print("------")
    print("unknowns total =", col_count)
    print("  psi unknowns =", n_params)
    print("  alpha unknowns =", col_count - n_params)
    print("equations total =", A.nrows())
    print("  order-1 equations =", len(order1_rows))
    print("  order-2 equations =", len(order2_rows))
    print("order-1 lift exists:", order1_ok, " ranks", rank_A1, rank_B1)
    print("joint order-1/order-2 lift exists:", lifts, " ranks", rank_A, rank_B)
    print()

    return lifts


# ------------------------------------------------------------
# Run tests
# ------------------------------------------------------------

results = []

raw = load("cache/raw_obstruction_data.sobj")
samples = load("cache/sample_points_on_Z.sobj")

T1_basis = raw["T1_basis"]

# Skip the first 53 coordinate-axis samples.
# Those are too trivial.
# Skip coordinate axes.
samples = samples[53:]

# The sample list is grouped:
# 20 of support size 2,
# 20 of support size 3,
# ...
# 20 of support size 7.
chosen = []
for block in range(6):
    chosen += samples[20*block : 20*block + 5]

samples = chosen
N_TESTS = len(samples)

for test in range(1, min(N_TESTS, len(samples)) + 1):
    y = samples[test - 1]

    v = vector(BASE_FIELD, n_params)
    for i, coeff in enumerate(y):
        coeff = BASE_FIELD(coeff)
        if coeff != 0:
            v += coeff * T1_basis[i]

    print("Testing Z-sample", test)
    print("support =", [i for i, c in enumerate(y) if c != 0])
    lifts = test_lift_to_order_2(v, test)
    results.append(lifts)

print("Summary")
print("-------")
print("tests =", N_TESTS)
print("lifts to order 2 =", sum(1 for x in results if x))
print("obstructed at order 2 =", sum(1 for x in results if not x))

if any(not x for x in results):
    print()
    print("Conclusion: at least one tested first-order direction is obstructed at order 2.")
else:
    print()
    print("Conclusion: all tested directions lifted to order 2.")
    print("This is only evidence, not a proof of unobstructedness.")
