# 03_probe_order3_on_quadratic_samples.sage
#
# Probe how cubic-order lifting interacts with the quadratic obstruction cone.
#
# This script:
#   1. loads the saved 53-dimensional T1 quotient basis from
#      ../cotangent/order2/cache/raw_obstruction_data.sobj;
#   2. projects the known formal cubic family to the y0,...,y52 coordinates;
#   3. tests a small set of sample points on the quadratic cone Z = V(kappa_2)
#      for lifting to order 2 and then order 3.
#
# Run from:
#   code/more-lifting
#
# Suggested invocation:
#   HOME=/tmp sage 03_probe_order3_on_quadratic_samples.sage

import json
import pickle
from collections import Counter

PICKLE_FILE = "../cotangent/part-1.pkl"
RAW_FILE = "../cotangent/order2/cache/raw_obstruction_data.sobj"
SAMPLES_FILE = "../cotangent/order2/cache/sample_points_on_Z.sobj"
CUBIC_FILE = "../cotangent/order2/cache/cubic_family_data.json"
OUT_FILE = "cache/03_probe_order3_on_quadratic_samples.log"

PRIME = 32003
K = GF(PRIME)

A_BLOCK = {0, 3, 7, 9, 23, 31, 35, 36, 39, 44, 48, 52}
B_BLOCK = {1, 4, 19, 20, 22, 26, 27, 29, 38, 43, 45, 47}
C_BLOCK = {6, 8, 15, 16, 24, 25, 32, 33, 37, 40, 49, 50}
FREE_BLOCK = {2, 5, 10, 11, 12, 13, 14, 17, 18, 21, 28, 30, 34, 41, 42, 46, 51}

out = open(OUT_FILE, "w")


def pr(s=""):
    print(s)
    out.write(str(s) + "\n")
    out.flush()


def exp_tuple(e):
    return tuple(int(a) for a in e)


def add_exp(a, b):
    return tuple(x + y for x, y in zip(a, b))


def total_degree(e):
    return sum(e)


def monomial_divides(a, b):
    return all(x <= y for x, y in zip(a, b))


def poly_terms(poly):
    out = {}
    for e, c in poly.dict().items():
        c = K(c)
        if c != 0:
            out[exp_tuple(e)] = c
    return out


def degree_exps(nvars, degree):
    if nvars == 1:
        yield (degree,)
        return
    for a in range(degree + 1):
        for rest in degree_exps(nvars - 1, degree - a):
            yield (a,) + rest


def add_to_dict(d, key, value):
    value = K(value)
    if value == 0:
        return
    d[key] = d.get(key, K(0)) + value
    if d[key] == 0:
        del d[key]


def add_row(entries, rhs, coeffs, constant=0):
    constant = K(constant)
    coeffs = {c: K(v) for c, v in coeffs.items() if K(v) != 0}
    if not coeffs and constant == 0:
        return None
    row = len(rhs)
    for col, val in coeffs.items():
        entries[(row, col)] = entries.get((row, col), K(0)) + val
        if entries[(row, col)] == 0:
            del entries[(row, col)]
    rhs.append(-constant)
    return row


def multiply_term_dict(A, B, quotient=False):
    out = {}
    for e1, c1 in A.items():
        for e2, c2 in B.items():
            e = add_exp(e1, e2)
            if quotient and monomial_in_I(e):
                continue
            add_to_dict(out, e, c1 * c2)
    return out


def raw_param_index(gen_index, mon_index):
    return gen_index * n_mons + mon_index


def sparse_vector_from_json(items, length):
    v = vector(K, length)
    for idx, a in items:
        v[int(idx)] = K(int(a))
    return v


def direction_to_phi(direction):
    phi = []
    for j in range(n_gens):
        terms = {}
        for m_idx, e in enumerate(basis3_exps):
            coeff = K(direction[raw_param_index(j, m_idx)])
            if coeff != 0:
                terms[e] = coeff
        phi.append(terms)
    return phi


def y_support_data(y):
    supp = [i for i, c in enumerate(y) if K(c) != 0]
    return {
        "support": supp,
        "A": [i for i in supp if i in A_BLOCK],
        "B": [i for i in supp if i in B_BLOCK],
        "C": [i for i in supp if i in C_BLOCK],
        "free": [i for i in supp if i in FREE_BLOCK],
    }


def project_to_y(direction):
    coeff = decomp_matrix.transpose().solve_right(direction.column())
    coeff = vector(K, [coeff[i, 0] for i in range(coeff.nrows())])
    return coeff[len(derivation_rows):]


def solve_order2(direction):
    phi = direction_to_phi(direction)

    entries = {}
    rhs = []
    order1_rows = []
    order2_rows = []

    for r in range(syz.nrows()):
        alpha_mons = alpha_mons_by_r[r]

        rows_by_exp = {}
        P1 = {}
        for j in range(n_gens):
            prod = multiply_term_dict(syz_terms[r][j], phi[j], quotient=False)
            for e, c in prod.items():
                add_to_dict(P1, e, c)

        for j in range(n_gens):
            for q_exp in alpha_mons:
                col = alpha_col[(r, j, q_exp)]
                e = add_exp(q_exp, f_exps[j])
                rows_by_exp.setdefault(e, {})[col] = rows_by_exp.setdefault(e, {}).get(col, K(0)) + K(1)

        for e, const in P1.items():
            rows_by_exp.setdefault(e, {})

        for e, coeffs in rows_by_exp.items():
            const = P1.get(e, K(0))
            row = add_row(entries, rhs, coeffs, const)
            if row is not None:
                order1_rows.append(row)

        rows_by_exp = {}
        for j in range(n_gens):
            st = syz_terms[r][j]
            if not st:
                continue
            for m_idx, m_exp in enumerate(basis3_exps):
                psi_col = raw_param_index(j, m_idx)
                mon = {m_exp: K(1)}
                prod = multiply_term_dict(st, mon, quotient=True)
                for e, c in prod.items():
                    rows_by_exp.setdefault(e, {})[psi_col] = rows_by_exp.setdefault(e, {}).get(psi_col, K(0)) + c

        for j in range(n_gens):
            if not phi[j]:
                continue
            for q_exp in alpha_mons:
                col = alpha_col[(r, j, q_exp)]
                q = {q_exp: K(1)}
                prod = multiply_term_dict(q, phi[j], quotient=True)
                for e, c in prod.items():
                    rows_by_exp.setdefault(e, {})[col] = rows_by_exp.setdefault(e, {}).get(col, K(0)) + c

        for e, coeffs in rows_by_exp.items():
            row = add_row(entries, rhs, coeffs, K(0))
            if row is not None:
                order2_rows.append(row)

    A = matrix(K, len(rhs), n_params + n_alpha, entries, sparse=True)
    b = vector(K, rhs)

    A1 = A.matrix_from_rows(order1_rows)
    b1 = vector(K, [b[i] for i in order1_rows])
    B1 = A1.augment(matrix(K, len(order1_rows), 1, list(b1), sparse=True))
    rank_A1 = A1.rank()
    rank_B1 = B1.rank()
    order1_ok = (rank_A1 == rank_B1)

    Bfull = A.augment(matrix(K, A.nrows(), 1, list(b), sparse=True))
    rank_A = A.rank()
    rank_B = Bfull.rank()
    lifts = (rank_A == rank_B)

    result = {
        "order1_ok": order1_ok,
        "rank_A1": rank_A1,
        "rank_B1": rank_B1,
        "rank_A": rank_A,
        "rank_B": rank_B,
        "order1_rows": len(order1_rows),
        "order2_rows": len(order2_rows),
        "lifts": lifts,
    }

    if lifts:
        sol = A.solve_right(b)
        result["psi_solution"] = vector(K, [sol[i] for i in range(n_params)])
        result["alpha_solution"] = vector(K, [sol[n_params + i] for i in range(n_alpha)])

    return result


def solve_order3(direction, psi_solution, alpha_solution):
    phi = direction_to_phi(direction)
    psi = direction_to_phi(psi_solution)

    def alpha_coeff(key):
        return K(alpha_solution[alpha_col[key] - n_params])

    entries = {}
    rhs = []
    order3_rows = []

    for r in range(syz.nrows()):
        beta_mons = alpha_mons_by_r[r]
        rows_by_exp = {}
        constant_by_exp = {}

        for j in range(n_gens):
            st = syz_terms[r][j]
            if not st:
                continue
            for m_idx, m_exp in enumerate(basis3_exps):
                chi_col = raw_param_index(j, m_idx)
                mon = {m_exp: K(1)}
                prod = multiply_term_dict(st, mon, quotient=True)
                for e, c in prod.items():
                    rows_by_exp.setdefault(e, {})[chi_col] = rows_by_exp.setdefault(e, {}).get(chi_col, K(0)) + c

        for j in range(n_gens):
            if not phi[j]:
                continue
            for q_exp in beta_mons:
                key = (r, j, q_exp)
                beta_col = n_params + (alpha_col[key] - n_params)
                q = {q_exp: K(1)}
                prod = multiply_term_dict(q, phi[j], quotient=True)
                for e, c in prod.items():
                    rows_by_exp.setdefault(e, {})[beta_col] = rows_by_exp.setdefault(e, {}).get(beta_col, K(0)) + c

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

        for e in constant_by_exp:
            rows_by_exp.setdefault(e, {})

        for e, coeffs in rows_by_exp.items():
            constant = constant_by_exp.get(e, K(0))
            row = add_row(entries, rhs, coeffs, constant)
            if row is not None:
                order3_rows.append(row)

    A = matrix(K, len(rhs), n_params + n_alpha, entries, sparse=True)
    b = vector(K, rhs)
    Bfull = A.augment(matrix(K, A.nrows(), 1, list(b), sparse=True))
    rank_A = A.rank()
    rank_augmented = Bfull.rank()
    lifts = (rank_A == rank_augmented)

    return {
        "rank_A": rank_A,
        "rank_augmented": rank_augmented,
        "order3_rows": len(order3_rows),
        "lifts": lifts,
    }


pr("Loading " + PICKLE_FILE)
with open(PICKLE_FILE, "rb") as f:
    data = pickle.load(f)

pr("Loading " + CUBIC_FILE)
with open(CUBIC_FILE, "r") as f:
    cubic = json.load(f)

pr("Loading " + RAW_FILE)
raw = load(RAW_FILE)

pr("Loading " + SAMPLES_FILE)
samples = load(SAMPLES_FILE)

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

f_exps = []
for f in f_list:
    ft = poly_terms(R(f))
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
        raise RuntimeError("syzygy row is not homogeneous")
    syz_terms.append(row_terms)
    syz_degrees.append(list(degrees)[0])

alpha_mons_by_r = {}
alpha_col = {}
col_count = n_params
for r in range(syz.nrows()):
    alpha_deg = syz_degrees[r] - 3
    if alpha_deg < 0:
        raise RuntimeError("negative alpha degree")
    alpha_mons = list(degree_exps(nvars, alpha_deg))
    alpha_mons_by_r[r] = alpha_mons
    for j in range(n_gens):
        for q_exp in alpha_mons:
            alpha_col[(r, j, q_exp)] = col_count
            col_count += 1
n_alpha = col_count - n_params

derivation_rows = []
basis3_index = {e: i for i, e in enumerate(basis3_exps)}
for i in range(nvars):
    for j in range(nvars):
        row = [K(0)] * n_params
        for a, g in enumerate(f_exps):
            if g[i] == 0:
                continue
            e = list(g)
            e[i] -= 1
            e[j] += 1
            e = tuple(e)
            if monomial_in_I(e):
                continue
            col = raw_param_index(a, basis3_index[e])
            row[col] += K(g[i])
        v = vector(K, row)
        if v != 0:
            derivation_rows.append(v)

T1_basis = [vector(K, v) for v in raw["T1_basis"]]
decomp_matrix = matrix(K, derivation_rows + T1_basis)

pr("")
pr("Basic data")
pr("----------")
pr("base field = %s" % K)
pr("number of generators = %d" % n_gens)
pr("monomials in (S/I)_3 = %d" % n_mons)
pr("raw deformation parameters = %d" % n_params)
pr("syzygy rows = %d" % syz.nrows())
pr("alpha/beta unknowns = %d" % n_alpha)
pr("T1 basis size = %d" % len(T1_basis))
pr("derivation rows kept = %d" % len(derivation_rows))
pr("syzygy total-degree histogram = %s" % dict(sorted(Counter(syz_degrees).items())))

cubic_direction = sparse_vector_from_json(cubic["G"]["1"], n_params)
cubic_y = project_to_y(cubic_direction)
cubic_support = y_support_data(cubic_y)

pr("")
pr("Known higher-order branch")
pr("-------------------------")
pr("finite-field G1 support size = %d" % sum(1 for c in cubic_direction if c != 0))
pr("projected y support size = %d" % len(cubic_support["support"]))
pr("projected y support = %s" % cubic_support["support"])
pr("A-block coordinates used = %s" % cubic_support["A"])
pr("B-block coordinates used = %s" % cubic_support["B"])
pr("C-block coordinates used = %s" % cubic_support["C"])
pr("free coordinates used = %s" % cubic_support["free"])
pr("nonzero y coefficients = %s" % [(i, int(c)) for i, c in enumerate(cubic_y) if c != 0])

tests = [("known_order30_branch", cubic_y, cubic_direction)]

samples = samples[53:]
for support_size in range(2, 8):
    idx0 = (support_size - 2) * 20
    y = vector(K, samples[idx0])
    direction = vector(K, n_params)
    for i, coeff in enumerate(y):
        coeff = K(coeff)
        if coeff != 0:
            direction += coeff * T1_basis[i]
    tests.append(("sample_support_%d" % support_size, y, direction))

pr("")
pr("Order-2 / order-3 probes")
pr("------------------------")

results = []
for name, y, direction in tests:
    sdata = y_support_data(y)
    pr("")
    pr(name)
    pr("  y support size = %d" % len(sdata["support"]))
    pr("  y support = %s" % sdata["support"])
    pr("  A/B/C/free support sizes = %d / %d / %d / %d" % (
        len(sdata["A"]), len(sdata["B"]), len(sdata["C"]), len(sdata["free"])
    ))

    info2 = solve_order2(direction)
    pr("  order 2: order1_ok = %s, lifts = %s, rank_A = %d, rank_B = %d" % (
        info2["order1_ok"], info2["lifts"], info2["rank_A"], info2["rank_B"]
    ))

    info3 = None
    if info2["lifts"]:
        info3 = solve_order3(direction, info2["psi_solution"], info2["alpha_solution"])
        pr("  order 3: lifts = %s, rank_A = %d, rank_augmented = %d" % (
            info3["lifts"], info3["rank_A"], info3["rank_augmented"]
        ))
    else:
        pr("  order 3: skipped because order 2 already fails")

    results.append({
        "name": name,
        "order2": info2["lifts"],
        "order3": None if info3 is None else info3["lifts"],
    })

pr("")
pr("Summary")
pr("-------")
for item in results:
    pr("%s : order2=%s order3=%s" % (item["name"], item["order2"], item["order3"]))

order3_true = [item["name"] for item in results if item["order3"] is True]
order3_false = [item["name"] for item in results if item["order3"] is False]

pr("")
pr("order-3 survivors = %d" % len(order3_true))
pr("order-3 failures = %d" % len(order3_false))
pr("survivors: %s" % order3_true)
pr("failures: %s" % order3_false)

out.close()
