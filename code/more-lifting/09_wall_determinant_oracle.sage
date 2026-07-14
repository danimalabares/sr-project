# 09_wall_determinant_oracle.sage
#
# Turn the stable 8-row obstruction support from 08 into a small determinant
# oracle for the order-4 wall on the top component.
#
# Fixed rows:
#
#   [138, 139, 142, 143, 144, 146, 150, 157]
#
# On these 8 rows the coefficient matrix has rank 7 at generic top-component
# points.  Choose 7 independent columns at the first sample.  Then the
# obstruction value is the determinant of the 8x8 matrix formed by these
# 7 coefficient columns plus the RHS column b.  Vanishing of this determinant
# is the local wall equation in determinant-oracle form.
#
# Run from:
#   code/more-lifting
#
# Suggested invocation:
#   HOME=/tmp sage 09_wall_determinant_oracle.sage

import pickle
import random
from collections import Counter, defaultdict

PICKLE_FILE = "../cotangent/part-1.pkl"
RAW_FILE = "../cotangent/order2/cache/raw_obstruction_data.sobj"
QUADRIC_FILE = "../cotangent/order2/cache/obstruction_quadrics_ff32003.sage"
FORMAL_LIFT_FILE = "../cotangent/order2/cache/formal_lift_to_order30.sobj"
OUT_FILE = "cache/09_wall_determinant_oracle.log"

PRIME = 32003
K = GF(PRIME)

TARGET_ORDER = 4
N_TOP_SAMPLES = 8
SEED_BASE = 20260629
FIXED_ROWS = [138, 139, 142, 143, 144, 146, 150, 157]

A_BLOCK = [0, 3, 7, 9, 23, 31, 35, 36, 39, 44, 48, 52]
B_BLOCK = [1, 4, 19, 20, 22, 26, 27, 29, 38, 43, 45, 47]
C_BLOCK = [6, 8, 15, 16, 24, 25, 32, 33, 37, 40, 49, 50]
FREE_BLOCK = [2, 5, 10, 11, 12, 13, 14, 17, 18, 21, 28, 30, 34, 41, 42, 46, 51]

COMPONENT_DIM = {0: 7, 1: 6, 2: 6}

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
    terms = {}
    for e, c in poly.dict().items():
        c = K(c)
        if c != 0:
            terms[exp_tuple(e)] = c
    return terms


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
    product = {}
    for e1, c1 in A.items():
        for e2, c2 in B.items():
            e = add_exp(e1, e2)
            if quotient and monomial_in_I(e):
                continue
            add_to_dict(product, e, c1 * c2)
    return product


def raw_param_index(gen_index, mon_index):
    return gen_index * n_mons + mon_index


def nnz(v):
    return sum(1 for c in v if c != 0)


def support(v):
    return [i for i, c in enumerate(v) if K(c) != 0]


def ff_int(c):
    return int(K(c))


def nz_rand(rng):
    return K(rng.randrange(1, PRIME))


def rand_block(rng, n):
    return [nz_rand(rng) for _ in range(n)]


def conv(a, b):
    vals = [K(0)] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        for j, bj in enumerate(b):
            vals[i + j] += ai * bj
    return vals


pr("Loading first-order and quotient data")
pr("-------------------------------------")

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


raw = load(RAW_FILE)
T1_basis = [vector(K, list(v)) for v in raw["T1_basis"]]

assert len(T1_basis) == 53
assert n_gens == 16
assert n_params == 1664

pr("base field = %s" % K)
pr("number of variables = %d" % nvars)
pr("number of generators = %d" % n_gens)
pr("monomials in (S/I)_3 = %d" % n_mons)
pr("raw deformation parameters = %d" % n_params)
pr("T^1 quotient basis length = %d" % len(T1_basis))
pr("")

load(QUADRIC_FILE)
quadric_gens = P.gens()


def eval_quadrics(y):
    subs = {quadric_gens[i]: K(y[i]) for i in range(53)}
    return [q.subs(subs) for q in quadrics]


def is_quadratic_solution(y):
    return all(v == 0 for v in eval_quadrics(y))


syz_terms = []
syz_degrees = []

for r in range(syz.nrows()):
    row_terms = []
    degrees = set()
    for j in range(n_gens):
        st = poly_terms(R(syz[r, j]))
        row_terms.append(st)
        for e, coeff in st.items():
            degrees.add(total_degree(e) + total_degree(f_exps[j]))
    if len(degrees) != 1:
        raise RuntimeError("syzygy row is not homogeneous")
    syz_terms.append(row_terms)
    syz_degrees.append(list(degrees)[0])

pr("Syzygy total-degree histogram:")
pr(dict(sorted(Counter(syz_degrees).items())))
pr("")

alpha_col = {}
col_count = n_params

for r in range(syz.nrows()):
    corr_deg = syz_degrees[r] - 3
    if corr_deg < 0:
        raise RuntimeError("negative syzygy-correction degree")
    corr_mons = list(degree_exps(nvars, corr_deg))
    for j in range(n_gens):
        for q_exp in corr_mons:
            alpha_col[(r, j, q_exp)] = col_count
            col_count += 1

n_corr = col_count - n_params
n_unknowns = n_params + n_corr

pr("Reconstructed correction columns")
pr("--------------------------------")
pr("correction unknowns per order = %d" % n_corr)
pr("total unknowns per higher-order step = %d" % n_unknowns)
pr("")


def direction_to_terms(direction):
    terms_by_gen = []
    for j in range(n_gens):
        terms = {}
        for m_idx, e in enumerate(basis3_exps):
            coeff = K(direction[raw_param_index(j, m_idx)])
            if coeff != 0:
                terms[e] = coeff
        terms_by_gen.append(terms)
    return terms_by_gen


def y_to_direction(y):
    v = vector(K, n_params)
    for i, coeff in enumerate(y):
        coeff = K(coeff)
        if coeff != 0:
            v += coeff * T1_basis[i]
    return v


basis3_index = {e: i for i, e in enumerate(basis3_exps)}
derivation_rows = []
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

decomp_matrix = matrix(K, derivation_rows + T1_basis)


def project_to_y(direction):
    coeff = decomp_matrix.transpose().solve_right(direction.column())
    coeff = vector(K, [coeff[i, 0] for i in range(coeff.nrows())])
    return coeff[len(derivation_rows):]


def put_values(y, indices, values):
    assert len(indices) == len(values)
    for i, value in zip(indices, values):
        y[i] = K(value)


def fill_A_component(y, comp, rng):
    if comp == 0:
        a, b = rand_block(rng, 2)
        u = rand_block(rng, 3)
        v = rand_block(rng, 3)
        put_values(y, [0, 3, 7], [a * u[0], a * u[1], a * u[2]])
        put_values(y, [31, 35, 36], [b * u[0], b * u[1], b * u[2]])
        put_values(y, [9, 48], [a * v[0], a * v[1]])
        put_values(y, [23, 39], [b * v[0], b * v[1]])
        put_values(y, [52, 44], [a * v[2], b * v[2]])
    elif comp == 1:
        vals = rand_block(rng, 6)
        put_values(y, [0, 3, 7, 31, 35, 36], vals)
        put_values(y, [9, 23, 39, 44, 48, 52], [0] * 6)
    elif comp == 2:
        h = rand_block(rng, 2)
        p = rand_block(rng, 2)
        q = rand_block(rng, 2)
        U = conv(h, q)
        V = conv(h, p)
        put_values(y, [0, 3, 7], U)
        put_values(y, [31, 35, 36], V)
        put_values(y, [39, 44], p)
        put_values(y, [48, 52], q)
        put_values(y, [9, 23], [0, 0])
    else:
        raise RuntimeError("bad A component")


def fill_B_component(y, comp, rng):
    if comp == 0:
        c, d = rand_block(rng, 2)
        w = rand_block(rng, 6)
        put_values(y, [1, 4, 22, 26, 27, 29],
                   [c * w[0], c * w[1], c * w[2], c * w[3], c * w[4], c * w[5]])
        put_values(y, [19, 20, 47, 38, 43, 45],
                   [d * w[0], d * w[1], d * w[2], d * w[3], d * w[4], d * w[5]])
    elif comp == 1:
        vals = rand_block(rng, 6)
        put_values(y, [26, 27, 29, 38, 43, 45], vals)
        put_values(y, [1, 4, 19, 20, 22, 47], [0] * 6)
    elif comp == 2:
        U = rand_block(rng, 2)
        V = rand_block(rng, 2)
        L = rand_block(rng, 2)
        P = conv(V, L)
        Q = conv(U, L)
        put_values(y, [19, 20], U)
        put_values(y, [1, 4], V)
        put_values(y, [26, 27, 29], P)
        put_values(y, [38, 43, 45], Q)
        put_values(y, [22, 47], [0, 0])
    else:
        raise RuntimeError("bad B component")


def fill_C_component(y, comp, rng):
    if comp == 0:
        e, f = rand_block(rng, 2)
        p = rand_block(rng, 4)
        q = rand_block(rng, 2)
        put_values(y, [6, 8, 15, 16], [e * p[0], e * p[1], e * p[2], e * p[3]])
        put_values(y, [40, 37, 49, 50], [f * p[0], f * p[1], f * p[2], f * p[3]])
        put_values(y, [32, 33], [e * q[0], e * q[1]])
        put_values(y, [24, 25], [f * q[0], f * q[1]])
    elif comp == 1:
        vals = rand_block(rng, 6)
        put_values(y, [8, 15, 16, 37, 49, 50], vals)
        put_values(y, [6, 24, 25, 32, 33, 40], [0] * 6)
    elif comp == 2:
        # Component 2 has y6=y40=0.  The remaining four equations are
        # linear after choosing y24,y25,y32,y33,y37,y49 generically.
        while True:
            y24, y25, y32, y33, y37, y49 = rand_block(rng, 6)
            coeff = y25 * y32 / y24 - y33
            if coeff != 0:
                break
        y8 = y33 * y37 / y25
        y15 = y32 * y49 / y24
        const = y8 * y24 + (y25 / y24) * (y33 * y49 - y15 * y25) - y32 * y37
        y50 = -const / coeff
        y16 = (y33 * y49 + y32 * y50 - y15 * y25) / y24
        put_values(y, [24, 25, 32, 33, 37, 49], [y24, y25, y32, y33, y37, y49])
        put_values(y, [8, 15, 16, 50], [y8, y15, y16, y50])
        put_values(y, [6, 40], [0, 0])
    else:
        raise RuntimeError("bad C component")


def make_component_point(component, seed):
    a_comp, b_comp, c_comp = component
    rng = random.Random(int(seed))
    y = [K(0)] * 53
    fill_A_component(y, a_comp, rng)
    fill_B_component(y, b_comp, rng)
    fill_C_component(y, c_comp, rng)
    for i in FREE_BLOCK:
        y[i] = nz_rand(rng)
    if not is_quadratic_solution(y):
        bad = [i for i, value in enumerate(eval_quadrics(y)) if value != 0]
        raise RuntimeError("component point failed quadratic equations: %s" % bad)
    return y


def solve_order_2(direction):
    entries = {}
    rhs = []
    order1_rows = []
    order2_rows = []
    phi = direction_to_terms(direction)

    for r in range(syz.nrows()):
        corr_deg = syz_degrees[r] - 3
        corr_mons = list(degree_exps(nvars, corr_deg))

        rows_by_exp = {}
        P1 = {}
        for j in range(n_gens):
            prod = multiply_term_dict(syz_terms[r][j], phi[j], quotient=False)
            for e, c in prod.items():
                add_to_dict(P1, e, c)

        for j in range(n_gens):
            for q_exp in corr_mons:
                col = alpha_col[(r, j, q_exp)]
                e = add_exp(q_exp, f_exps[j])
                rows_by_exp.setdefault(e, {})[col] = (
                    rows_by_exp.setdefault(e, {}).get(col, K(0)) + K(1)
                )

        for e in P1:
            rows_by_exp.setdefault(e, {})

        for e, coeffs in rows_by_exp.items():
            row = add_row(entries, rhs, coeffs, P1.get(e, K(0)))
            if row is not None:
                order1_rows.append(row)

        rows_by_exp = {}
        for j in range(n_gens):
            st = syz_terms[r][j]
            if not st:
                continue
            for m_idx, m_exp in enumerate(basis3_exps):
                col = raw_param_index(j, m_idx)
                prod = multiply_term_dict(st, {m_exp: K(1)}, quotient=True)
                for e, c in prod.items():
                    rows_by_exp.setdefault(e, {})[col] = (
                        rows_by_exp.setdefault(e, {}).get(col, K(0)) + c
                    )

        for j in range(n_gens):
            if not phi[j]:
                continue
            for q_exp in corr_mons:
                col = alpha_col[(r, j, q_exp)]
                prod = multiply_term_dict({q_exp: K(1)}, phi[j], quotient=True)
                for e, c in prod.items():
                    rows_by_exp.setdefault(e, {})[col] = (
                        rows_by_exp.setdefault(e, {}).get(col, K(0)) + c
                    )

        for e, coeffs in rows_by_exp.items():
            row = add_row(entries, rhs, coeffs, K(0))
            if row is not None:
                order2_rows.append(row)

    A = matrix(K, len(rhs), n_unknowns, entries, sparse=True)
    b = vector(K, rhs)

    A1 = A.matrix_from_rows(order1_rows)
    b1 = vector(K, [b[i] for i in order1_rows])
    B1 = A1.augment(matrix(K, len(order1_rows), 1, list(b1), sparse=True))
    rank_A1 = A1.rank()
    rank_B1 = B1.rank()
    order1_ok = (rank_A1 == rank_B1)

    B = A.augment(matrix(K, A.nrows(), 1, list(b), sparse=True))
    rank_A = A.rank()
    rank_B = B.rank()
    lifts = (rank_A == rank_B)

    info = {
        "order": 2,
        "order1_ok": order1_ok,
        "rank_A1": rank_A1,
        "rank_B1": rank_B1,
        "rank_A": rank_A,
        "rank_B": rank_B,
        "n_equations": A.nrows(),
        "success": lifts,
    }

    if not lifts:
        return info, None

    sol = A.solve_right(b)
    state = {
        "gen_vectors": {1: direction, 2: sol[:n_params]},
        "syz_vectors": {1: sol[n_params:]},
    }
    return info, state


def build_order_system(order, gen_terms, syz_vectors):
    entries = {}
    rhs = []
    phi = gen_terms[1]

    for r in range(syz.nrows()):
        corr_deg = syz_degrees[r] - 3
        corr_mons = list(degree_exps(nvars, corr_deg))
        rows_by_exp = {}
        constant_by_exp = {}

        for j in range(n_gens):
            st = syz_terms[r][j]
            if not st:
                continue
            for m_idx, m_exp in enumerate(basis3_exps):
                col = raw_param_index(j, m_idx)
                prod = multiply_term_dict(st, {m_exp: K(1)}, quotient=True)
                for e, c in prod.items():
                    rows_by_exp.setdefault(e, {})[col] = (
                        rows_by_exp.setdefault(e, {}).get(col, K(0)) + c
                    )

        for j in range(n_gens):
            if not phi[j]:
                continue
            for q_exp in corr_mons:
                col = alpha_col[(r, j, q_exp)]
                prod = multiply_term_dict({q_exp: K(1)}, phi[j], quotient=True)
                for e, c in prod.items():
                    rows_by_exp.setdefault(e, {})[col] = (
                        rows_by_exp.setdefault(e, {}).get(col, K(0)) + c
                    )

        for a in range(1, order - 1):
            G = gen_terms[order - a]
            A_a = syz_vectors[a]
            for j in range(n_gens):
                if not G[j]:
                    continue
                for q_exp in corr_mons:
                    coeff = K(A_a[alpha_col[(r, j, q_exp)] - n_params])
                    if coeff == 0:
                        continue
                    prod = multiply_term_dict({q_exp: coeff}, G[j], quotient=True)
                    for e, c in prod.items():
                        add_to_dict(constant_by_exp, e, c)

        for e in constant_by_exp:
            rows_by_exp.setdefault(e, {})

        for e, coeffs in rows_by_exp.items():
            add_row(entries, rhs, coeffs, constant_by_exp.get(e, K(0)))

    A = matrix(K, len(rhs), n_unknowns, entries, sparse=True)
    b = vector(K, rhs)
    return A, b


def extend_one_order(state, order):
    gen_terms = {k: direction_to_terms(v) for k, v in state["gen_vectors"].items()}
    A, b = build_order_system(order, gen_terms, state["syz_vectors"])
    B = A.augment(matrix(K, A.nrows(), 1, list(b), sparse=True))
    rank_A = A.rank()
    rank_B = B.rank()
    lifts = (rank_A == rank_B)

    info = {
        "order": order,
        "rank_A": rank_A,
        "rank_B": rank_B,
        "n_equations": A.nrows(),
        "success": lifts,
    }

    if lifts:
        sol = A.solve_right(b)
        state["gen_vectors"][order] = sol[:n_params]
        state["syz_vectors"][order - 1] = sol[n_params:]

    return info


def rank_test(A, b):
    B = A.augment(matrix(K, A.nrows(), 1, list(b), sparse=True))
    rank_A = A.rank()
    rank_B = B.rank()
    return rank_A, rank_B, (rank_A == rank_B)


def extract_left_obstruction_witness(A, b):
    # Find lambda with A^T lambda = 0 and b.lambda = 1.
    # This is a concrete certificate that b is not in the column span of A.
    bottom = matrix(K, 1, A.nrows(), list(b), sparse=True)
    M = A.transpose().stack(bottom)
    rhs = vector(K, [K(0)] * A.ncols() + [K(1)])
    lam = M.solve_right(rhs)
    left_residual = A.transpose() * lam
    value = b.dot_product(lam)
    return lam, left_residual, value


def extract_supported_left_obstruction_witness(A, b, row_support):
    # Same certificate, but force lambda to be supported only on row_support.
    AT = A.transpose()
    M0 = AT.matrix_from_columns(row_support)
    bottom = matrix(K, 1, len(row_support), [b[i] for i in row_support], sparse=True)
    M = M0.stack(bottom)
    rhs = vector(K, [K(0)] * A.ncols() + [K(1)])
    coeffs = M.solve_right(rhs)
    lam = vector(K, A.nrows())
    for idx, coeff in zip(row_support, coeffs):
        lam[idx] = coeff
    left_residual = A.transpose() * lam
    value = b.dot_product(lam)
    return lam, left_residual, value


def independent_columns_for_rows(A, rows, target_rank):
    cols = []
    current = matrix(K, len(rows), 0, sparse=True)
    current_rank = 0
    for col in range(A.ncols()):
        values = [A[row, col] for row in rows]
        if all(v == 0 for v in values):
            continue
        trial = current.augment(matrix(K, len(rows), 1, values, sparse=True))
        trial_rank = trial.rank()
        if trial_rank > current_rank:
            cols.append(col)
            current = trial
            current_rank = trial_rank
            if current_rank == target_rank:
                return cols
    raise RuntimeError("could not find %d independent columns" % target_rank)


def row_column_submatrix_with_rhs(A, b, rows, cols):
    M = matrix(K, len(rows), len(cols) + 1)
    for i, row in enumerate(rows):
        for j, col in enumerate(cols):
            M[i, j] = A[row, col]
        M[i, len(cols)] = b[row]
    return M


def wall_determinant(A, b, rows, cols):
    M = row_column_submatrix_with_rhs(A, b, rows, cols)
    return M.det(), M.rank()


def saved_branch_state():
    lift = load(FORMAL_LIFT_FILE)
    gen_vectors = {}
    syz_vectors = {}
    for k in [1, 2, 3]:
        gen_vectors[k] = vector(K, list(lift["gen_vectors"][k]))
    for k in [1, 2]:
        syz_vectors[k] = vector(K, list(lift["syz_vectors"][k]))
    return {
        "source_status": lift["status"],
        "max_order_reached": lift["max_order_reached"],
        "gen_vectors": gen_vectors,
        "syz_vectors": syz_vectors,
    }


def top_order4_system_for_seed(seed):
    y = make_component_point((0, 0, 0), seed)
    direction = y_to_direction(y)
    info2, state = solve_order_2(direction)
    if state is None:
        raise RuntimeError("top sample failed at order 2")
    info3 = extend_one_order(state, 3)
    if not info3["success"]:
        raise RuntimeError("top sample failed at order 3")
    terms = {k: direction_to_terms(v) for k, v in state["gen_vectors"].items()}
    A4, b4 = build_order_system(4, terms, state["syz_vectors"])
    rank_A4, rank_B4, lifts4 = rank_test(A4, b4)
    return {
        "seed": seed,
        "y": y,
        "direction": direction,
        "info2": info2,
        "info3": info3,
        "A4": A4,
        "b4": b4,
        "rank_A4": rank_A4,
        "rank_B4": rank_B4,
        "lifts4": lifts4,
    }


pr("Top-component wall determinant oracle")
pr("-------------------------------------")
pr("N_TOP_SAMPLES = %d" % N_TOP_SAMPLES)
pr("SEED_BASE = %d" % SEED_BASE)
pr("FIXED_ROWS = %s" % FIXED_ROWS)
pr("")

pivot_cols = None
results = []

for sample_idx in range(N_TOP_SAMPLES):
    seed = SEED_BASE + sample_idx
    pr("Sample %d seed %d" % (sample_idx + 1, seed))
    pr("--------------------")
    sample = top_order4_system_for_seed(seed)
    pr("quadratic_ok = %s" % is_quadratic_solution(sample["y"]))
    pr("y support size = %d" % len(support(sample["y"])))
    pr("direction nnz = %d" % nnz(sample["direction"]))
    pr("order 2: lifts = %s, rank_A = %d, rank_B = %d" % (
        sample["info2"]["success"], sample["info2"]["rank_A"], sample["info2"]["rank_B"]
    ))
    pr("order 3: lifts = %s, rank_A = %d, rank_B = %d" % (
        sample["info3"]["success"], sample["info3"]["rank_A"], sample["info3"]["rank_B"]
    ))
    pr("order 4: lifts = %s, rank_A = %d, rank_B = %d, equations = %d" % (
        sample["lifts4"], sample["rank_A4"], sample["rank_B4"], sample["A4"].nrows()
    ))

    if sample["lifts4"]:
        raise RuntimeError("generic top sample unexpectedly lifted to order 4")

    A_rows = sample["A4"].matrix_from_rows(FIXED_ROWS)
    row_rank = A_rows.rank()
    pr("fixed-row coefficient rank = %d" % row_rank)
    if row_rank != 7:
        raise RuntimeError("expected fixed rows to have coefficient rank 7")

    if pivot_cols is None:
        pivot_cols = independent_columns_for_rows(sample["A4"], FIXED_ROWS, 7)
        pr("pivot columns initialized = %s" % pivot_cols)

    coeff_rank = sample["A4"].matrix_from_rows(FIXED_ROWS).matrix_from_columns(pivot_cols).rank()
    det_value, augmented_rank = wall_determinant(sample["A4"], sample["b4"], FIXED_ROWS, pivot_cols)
    pr("pivot coefficient rank = %d" % coeff_rank)
    pr("wall determinant = %d" % ff_int(det_value))
    pr("wall determinant nonzero = %s" % (det_value != 0))
    pr("8x8 augmented rank = %d" % augmented_rank)

    results.append({
        "seed": seed,
        "det": det_value,
        "det_nonzero": det_value != 0,
        "coeff_rank": coeff_rank,
        "augmented_rank": augmented_rank,
    })
    pr("")

pr("Summary")
pr("-------")
pr("fixed rows = %s" % FIXED_ROWS)
pr("pivot columns = %s" % pivot_cols)
pr("all pivot coefficient ranks are 7 = %s" % all(r["coeff_rank"] == 7 for r in results))
pr("all wall determinants are nonzero at generic samples = %s" % all(r["det_nonzero"] for r in results))
for r in results:
    pr("seed %d: det = %d, nonzero = %s, augmented_rank = %d" % (
        r["seed"], ff_int(r["det"]), r["det_nonzero"], r["augmented_rank"]
    ))

pr("")
pr("Conclusion")
pr("----------")
pr("The fixed 8-row support and fixed 7 pivot columns give a stable determinant")
pr("oracle for the generic order-4 obstruction.  The local wall equation is")
pr("det([A_FIXED_ROWS,PIVOT_COLUMNS | b_FIXED_ROWS]) = 0.")

out.close()
