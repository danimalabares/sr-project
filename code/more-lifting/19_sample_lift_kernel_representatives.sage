# 19_sample_lift_kernel_representatives.sage
#
# Fix the promising first-order sparse direction and sample different
# representatives of the order-2/order-3 lift using the affine kernel freedom
# in the lifting linear systems.  Then test whether any representative gives
# a t-flat embedded family with special fiber exactly SR(M).
#
# Run from:
#   code/more-lifting
#
# Suggested invocation:
#   HOME=/tmp sage 19_sample_lift_kernel_representatives.sage

import pickle
import random
import builtins
from collections import Counter, defaultdict

PICKLE_FILE = "../cotangent/part-1.pkl"
RAW_FILE = "../cotangent/order2/cache/raw_obstruction_data.sobj"
QUADRIC_FILE = "../cotangent/order2/cache/obstruction_quadrics_ff32003.sage"
FORMAL_LIFT_FILE = "../cotangent/order2/cache/formal_lift_to_order30.sobj"
OUT_FILE = "cache/19_sample_lift_kernel_representatives.log"

PRIME = 32003
K = GF(PRIME)

MAX_ORDER = 4
FIXED_ROWS = [138, 139, 142, 143, 144, 146, 150, 157]
PIVOT_COLUMNS = [1696, 1699, 1701, 1702, 1723, 1725, 1726]
SPARSE_SUPPORT = [0, 2, 3, 19, 33, 34, 41]
N_RANDOM_SPARSE = 1
MAX_SATURATION_STEPS = 6
MAX_WITNESSES = 12
MAX_LEGAL_CLOSURE_STEPS = 8
N_KERNEL_SAMPLES = 4

LAYER1_EXPS = [
    (1, 0, 1, 1, 0, 0, 0, 1),  # x0*x2*x3*x7
    (1, 0, 1, 1, 1, 0, 0, 0),  # x0*x2*x3*x4
    (0, 0, 2, 3, 0, 0, 0, 2),  # x2^2*x3^3*x7^2
]
LAYER2_EXPS = [
    (0, 0, 1, 2, 0, 0, 0, 1),  # x2*x3^2*x7
    (1, 1, 0, 0, 2, 0, 0, 0),  # x0*x1*x4^2
]
LAYER3_EXPS = [
    (0, 1, 0, 1, 1, 0, 0, 1),  # x1*x3*x4*x7
    (0, 1, 0, 1, 2, 0, 0, 0),  # x1*x3*x4^2
]
LAYER4_EXPS = [
    (0, 1, 0, 2, 0, 0, 0, 2),  # x1*x3^2*x7^2
    (0, 2, 0, 0, 3, 0, 0, 0),  # x1^2*x4^3
]

REPAIRS = [
    ("original", []),
    ("add_layer1", LAYER1_EXPS),
    ("add_layer1_layer2", LAYER1_EXPS + LAYER2_EXPS),
    ("add_all_layers", LAYER1_EXPS + LAYER2_EXPS + LAYER3_EXPS + LAYER4_EXPS),
]
SEED_BASE = 20260629

A_BLOCK = [0, 3, 7, 9, 23, 31, 35, 36, 39, 44, 48, 52]
B_BLOCK = [1, 4, 19, 20, 22, 26, 27, 29, 38, 43, 45, 47]
C_BLOCK = [6, 8, 15, 16, 24, 25, 32, 33, 37, 40, 49, 50]
FREE_BLOCK = [2, 5, 10, 11, 12, 13, 14, 17, 18, 21, 28, 30, 34, 41, 42, 46, 51]

COMPONENT_DIM = {0: 7, 1: 6, 2: 6}
SAMPLE_KERNEL_SOLUTIONS = False
KERNEL_SAMPLE_LOG = []

out = open(OUT_FILE, "w")


def pr(s=""):
    print(s)
    out.write(str(s) + "\n")
    out.flush()


def choose_solution(A, b, label):
    if not SAMPLE_KERNEL_SOLUTIONS:
        return A.solve_right(b)

    # Computing the full right kernel is too expensive here.  Since these
    # systems are underdetermined, solving after a random column permutation
    # changes the chosen representative while avoiding explicit kernel bases.
    gen_cols = list(range(n_params))
    syz_cols = list(range(n_params, A.ncols()))
    random.shuffle(gen_cols)
    perm = gen_cols + syz_cols
    KERNEL_SAMPLE_LOG.append((label, "permuted_gen_columns"))
    pr("    %s solving with randomized generator-column order" % label)
    Aperm = A.matrix_from_columns(perm)
    solp = Aperm.solve_right(b)
    sol = vector(K, A.ncols())
    for new_col, old_col in enumerate(perm):
        sol[old_col] = solp[new_col]
    return sol


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

    sol = choose_solution(A, b, "order2")
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
        sol = choose_solution(A, b, "order%d" % order)
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


def random_y_on_support(rng, supp):
    y = [K(0)] * 53
    for i in supp:
        y[i] = nz_rand(rng)
    return y


def iterate_y_direction(name, y, max_order):
    direction = y_to_direction(y)
    result = {
        "name": name,
        "support": support(y),
        "quadratic_ok": is_quadratic_solution(y),
        "direction_nnz": nnz(direction),
        "max_reached": 1,
        "orders": {},
    }
    if not result["quadratic_ok"]:
        return result

    info2, state = solve_order_2(direction)
    result["orders"][2] = info2
    if state is None:
        return result
    result["max_reached"] = 2

    for order in range(3, max_order + 1):
        info = extend_one_order(state, order)
        result["orders"][order] = info
        if not info["success"]:
            break
        result["max_reached"] = order

    result["gen_nnz"] = {
        k: nnz(v) for k, v in state["gen_vectors"].items()
    }
    result["syz_nnz"] = {
        k: nnz(v) for k, v in state["syz_vectors"].items()
    }
    return result


def state_for_y(y, max_order):
    direction = y_to_direction(y)
    info2, state = solve_order_2(direction)
    if state is None:
        return None, {2: info2}
    infos = {2: info2}
    for order in range(3, max_order + 1):
        info = extend_one_order(state, order)
        infos[order] = info
        if not info["success"]:
            return None, infos
    return state, infos


def print_result(result):
    pr("%s" % result["name"])
    pr("  support = %s" % result["support"])
    pr("  quadratic_ok = %s, direction_nnz = %d" % (
        result["quadratic_ok"], result["direction_nnz"]
    ))
    pr("  max_reached = %d" % result["max_reached"])
    for order in sorted(result["orders"]):
        info = result["orders"][order]
        pr("  order %d: lifts=%s rank_A=%d rank_B=%d equations=%s" % (
            order, info["success"], info["rank_A"], info["rank_B"],
            info.get("n_equations", "-")
        ))
    if "gen_nnz" in result:
        pr("  generator nnz by order = %s" % result["gen_nnz"])
        pr("  syzygy nnz by order = %s" % result["syz_nnz"])


def build_family_ideal(gen_vectors):
    xnames = ["x%d" % i for i in range(nvars)]
    T = PolynomialRing(K, ["t"] + xnames, order="degrevlex")
    t = T.gen(0)
    X = T.gens()[1:]
    S = PolynomialRing(K, xnames, order="degrevlex")
    XS = S.gens()

    def monomial_T(e):
        m = T(1)
        for i, a in enumerate(e):
            if a:
                m *= X[i] ** int(a)
        return m

    def monomial_S(e):
        m = S(1)
        for i, a in enumerate(e):
            if a:
                m *= XS[i] ** int(a)
        return m

    def terms_to_poly_T(terms):
        p = T(0)
        for e, c in terms.items():
            p += T(c) * monomial_T(e)
        return p

    f_T = [monomial_T(e) for e in f_exps]
    f_S = [monomial_S(e) for e in f_exps]
    gen_terms = {k: direction_to_terms(v) for k, v in gen_vectors.items()}

    F = []
    for j in range(n_gens):
        Fj = f_T[j]
        for k in [1, 2, 3]:
            if k in gen_terms:
                Fj += (t ** k) * terms_to_poly_T(gen_terms[k][j])
        F.append(Fj)

    return T, t, S, T.ideal(F), S.ideal(f_S), f_S


def monomial_T_from_exp(T, e):
    X = T.gens()[1:]
    m = T(1)
    for i, a in enumerate(e):
        if a:
            m *= X[i] ** int(a)
    return m


def lifted_repair_polys(T, coeffs):
    t = T.gen(0)
    L1 = [
        (1, 0, 1, 1, 0, 0, 0, 1),  # x0*x2*x3*x7
        (1, 0, 1, 1, 1, 0, 0, 0),  # x0*x2*x3*x4
    ]
    L2 = [
        (0, 0, 1, 2, 0, 0, 0, 1),  # x2*x3^2*x7
        (1, 1, 0, 0, 2, 0, 0, 0),  # x0*x1*x4^2
    ]
    L3 = [
        (0, 1, 0, 1, 1, 0, 0, 1),  # x1*x3*x4*x7
        (0, 1, 0, 1, 2, 0, 0, 0),  # x1*x3*x4^2
    ]

    mL1 = [monomial_T_from_exp(T, e) for e in L1]
    mL2 = [monomial_T_from_exp(T, e) for e in L2]
    mL3 = [monomial_T_from_exp(T, e) for e in L3]

    c = [K(a) for a in coeffs]
    return [
        mL1[0] + t * (c[0] * mL2[0] + c[1] * mL2[1]),
        mL1[1] + t * (c[2] * mL2[0] + c[3] * mL2[1]),
        mL2[0] + t * (c[4] * mL3[0] + c[5] * mL3[1]),
        mL2[1] + t * (c[6] * mL3[0] + c[7] * mL3[1]),
    ]


def specialize_t0_ideal(T, t, S, ideal_T):
    XS = S.gens()

    def monomial_S(e):
        m = S(1)
        for i, a in enumerate(e):
            if a:
                m *= XS[i] ** int(a)
        return m

    gens = []
    for g in ideal_T.gens():
        out = S(0)
        for e, c in T(g).dict().items():
            e = tuple(int(a) for a in e)
            if e[0] == 0:
                out += S(c) * monomial_S(e[1:])
        gens.append(out)
    return S.ideal(gens)


def specialize_t0_poly(T, S, g):
    XS = S.gens()

    def monomial_S(e):
        m = S(1)
        for i, a in enumerate(e):
            if a:
                m *= XS[i] ** int(a)
        return m

    out = S(0)
    for e, c in T(g).dict().items():
        e = tuple(int(a) for a in e)
        if e[0] == 0:
            out += S(c) * monomial_S(e[1:])
    return out


def ideal_eq(A, B):
    return all(B.reduce(g) == 0 for g in A.gens()) and all(A.reduce(g) == 0 for g in B.gens())


def constrained_saturation_repair(name, gen_vectors):
    pr(name)
    pr("  building family ideal")
    T, t, S, J, I_S, f_S = build_family_ideal(gen_vectors)
    pr("  generator nnz = %s" % {k: nnz(v) for k, v in gen_vectors.items()})

    Jcur = J
    added = []
    illegal_blockers = []
    for step in range(1, MAX_LEGAL_CLOSURE_STEPS + 1):
        colon = Jcur.quotient(T.ideal(t))
        colon_eq = (colon == Jcur)
        pr("  legal-closure step %d: J:(t)==J %s" % (step, colon_eq))
        if colon_eq:
            break

        gb_J = Jcur.groebner_basis()
        gb_I = I_S.groebner_basis()
        legal_new = []
        illegal_new = []
        for g in colon.gens():
            r = T(g).reduce(gb_J)
            if r == 0:
                continue
            r0 = specialize_t0_poly(T, S, r)
            if S(r0).reduce(gb_I) == 0:
                if all(T(r).reduce(T.ideal(list(Jcur.gens()) + legal_new).groebner_basis()) != 0 for _ in [0]):
                    legal_new.append(r)
            else:
                illegal_new.append((r, r0, S(r0).reduce(gb_I)))

        pr("    legal new saturation remainders = %d" % len(legal_new))
        for i, r in enumerate(legal_new[:MAX_WITNESSES]):
            pr("      legal[%d] = %s" % (i, r))
            pr("        t=0 -> %s" % specialize_t0_poly(T, S, r))
        pr("    illegal new saturation remainders = %d" % len(illegal_new))
        for i, (r, r0, rem0) in enumerate(illegal_new[:MAX_WITNESSES]):
            pr("      illegal[%d] = %s" % (i, r))
            pr("        t=0 -> %s; mod I -> %s" % (r0, rem0))

        if not legal_new:
            illegal_blockers = illegal_new
            break

        old_ngens = len(Jcur.gens())
        Jcur = T.ideal(list(Jcur.gens()) + legal_new)
        added.extend(legal_new)
        pr("    adjoined legal generators: %d -> %d" % (old_ngens, len(Jcur.gens())))

    colon_eq = (Jcur.quotient(T.ideal(t)) == Jcur)
    pr("  after legal closure, J:(t)==J: %s" % colon_eq)
    pr("  total legal generators adjoined = %d" % len(added))

    Ksat = Jcur
    sat_steps = 0
    layer_witness_counts = []
    for step in range(1, MAX_SATURATION_STEPS + 1):
        Knext = Ksat.quotient(T.ideal(t))
        if Knext == Ksat:
            break
        try:
            gb_K = Ksat.groebner_basis()
            layer_witnesses = []
            for g in Knext.gens():
                r = T(g).reduce(gb_K)
                if r != 0:
                    layer_witnesses.append(r)
            layer_witness_counts.append(len(layer_witnesses))
            pr("  saturation layer %d new witnesses = %d" % (step, len(layer_witnesses)))
            for i, r in enumerate(layer_witnesses[:MAX_WITNESSES]):
                pr("    layer%d[%d] = %s" % (step, i, r))
        except Exception as err:
            pr("  saturation layer %d witness reduction failed: %s" % (step, err))
        Ksat = Knext
        sat_steps = step
    pr("  saturation steps used = %d" % sat_steps)
    pr("  t-saturated = %s" % (Ksat.quotient(T.ideal(t)) == Ksat))

    K0 = specialize_t0_ideal(T, t, S, Ksat)
    K0_eq_I = ideal_eq(I_S, K0)
    pr("  K0 == I = %s" % K0_eq_I)

    try:
        pr("  degree I = %s" % I_S.degree())
        pr("  degree K0 = %s" % K0.degree())
        pr("  hilbert I = %s" % I_S.hilbert_polynomial())
        pr("  hilbert K0 = %s" % K0.hilbert_polynomial())
    except Exception as err:
        pr("  hilbert/degree failed: %s" % err)

    try:
        gb_I = I_S.groebner_basis()
        extras = []
        for g in K0.gens():
            r = S(g).reduce(gb_I)
            if r != 0:
                extras.append(r)
        pr("  extra K0 generators modulo I = %d" % len(extras))
        pr("  first extras = %s" % extras[:6])
    except Exception as err:
        pr("  extra-generator reduction failed: %s" % err)

    return {
        "colon_eq": colon_eq,
        "sat_steps": sat_steps,
        "K0_eq_I": K0_eq_I,
        "layer_witness_counts": layer_witness_counts,
        "n_added": len(added),
        "n_illegal_blockers": len(illegal_blockers),
    }


def random_lifted_repair_search(name, gen_vectors, rng):
    pr(name)
    pr("  building base family ideal")
    T, t, S, J, I_S, f_S = build_family_ideal(gen_vectors)
    gb_I = I_S.groebner_basis()
    pr("  generator nnz = %s" % {k: nnz(v) for k, v in gen_vectors.items()})

    hits = []
    best = []
    for trial in range(1, N_RANDOM_REPAIRS + 1):
        coeffs = [nz_rand(rng) for _ in range(8)]
        repairs = lifted_repair_polys(T, coeffs)
        Jtrial = T.ideal(list(J.gens()) + repairs)
        raw0 = specialize_t0_ideal(T, t, S, Jtrial)
        raw0_eq_I = ideal_eq(I_S, raw0)

        colon_eq = (Jtrial.quotient(T.ideal(t)) == Jtrial)
        Ksat = Jtrial
        sat_steps = 0
        for step in range(1, MAX_SATURATION_STEPS + 1):
            Knext = Ksat.quotient(T.ideal(t))
            if Knext == Ksat:
                break
            Ksat = Knext
            sat_steps = step
        K0 = specialize_t0_ideal(T, t, S, Ksat)
        K0_eq_I = ideal_eq(I_S, K0)

        extras = []
        if not K0_eq_I:
            for g in K0.gens():
                r = S(g).reduce(gb_I)
                if r != 0:
                    extras.append(r)

        score = (0 if colon_eq else 1, 0 if K0_eq_I else 1, len(extras), sat_steps)
        best.append((score, trial, coeffs, colon_eq, raw0_eq_I, K0_eq_I, sat_steps, extras[:4]))
        if colon_eq and raw0_eq_I and K0_eq_I:
            hits.append((trial, coeffs))
            pr("  HIT trial %d coeffs = %s" % (trial, [ff_int(c) for c in coeffs]))
            break
        if trial <= 5 or trial == N_RANDOM_REPAIRS:
            pr("  trial %02d: raw0==I %s, J:(t)==J %s, K0==I %s, sat_steps %d, extras %d" % (
                trial, raw0_eq_I, colon_eq, K0_eq_I, sat_steps, len(extras)
            ))

    best.sort(key=lambda row: row[0])
    pr("  hits = %d" % len(hits))
    pr("  best trials:")
    for score, trial, coeffs, colon_eq, raw0_eq_I, K0_eq_I, sat_steps, extras in best[:5]:
        pr("    trial %02d score %s raw0==I %s J:(t)==J %s K0==I %s sat_steps %d coeffs %s" % (
            trial, score, raw0_eq_I, colon_eq, K0_eq_I, sat_steps, [ff_int(c) for c in coeffs]
        ))
        if extras:
            pr("      extras = %s" % extras)

    return {
        "hits": hits,
        "best": best[:5],
    }


def flatness_summary(name, gen_vectors):
    pr(name)
    T, t, S, J, I_S, f_S = build_family_ideal(gen_vectors)
    pr("  generator nnz = %s" % {k: nnz(v) for k, v in gen_vectors.items()})
    colon_eq = (J.quotient(T.ideal(t)) == J)
    pr("  J:(t)==J = %s" % colon_eq)
    Ksat = J
    sat_steps = 0
    for step in range(1, MAX_SATURATION_STEPS + 1):
        Knext = Ksat.quotient(T.ideal(t))
        if Knext == Ksat:
            break
        Ksat = Knext
        sat_steps = step
    K0 = specialize_t0_ideal(T, t, S, Ksat)
    K0_eq_I = ideal_eq(I_S, K0)
    pr("  sat_steps = %d" % sat_steps)
    pr("  K0==I = %s" % K0_eq_I)
    extras = []
    if not K0_eq_I:
        gb_I = I_S.groebner_basis()
        for g in K0.gens():
            r = S(g).reduce(gb_I)
            if r != 0:
                extras.append(r)
        pr("  extra K0 generators modulo I = %d" % len(extras))
        pr("  first extras = %s" % extras[:6])
    return {
        "colon_eq": colon_eq,
        "sat_steps": sat_steps,
        "K0_eq_I": K0_eq_I,
        "extras": extras[:6],
    }


def sampled_state_for_direction(direction):
    info2, state = solve_order_2(direction)
    infos = {2: info2}
    if state is None:
        return None, infos
    info3 = extend_one_order(state, 3)
    infos[3] = info3
    if not info3["success"]:
        return None, infos
    return state, infos


pr("Sparse-slice lift-kernel representative samples")
pr("------------------------------------------------")
pr("SPARSE_SUPPORT = %s" % SPARSE_SUPPORT)
pr("N_KERNEL_SAMPLES = %d" % N_KERNEL_SAMPLES)
pr("MAX_SATURATION_STEPS = %d" % MAX_SATURATION_STEPS)
pr("")

saved = saved_branch_state()
saved_direction = saved["gen_vectors"][1]
saved_y = project_to_y(saved_direction)
pr("Saved branch first-order y support = %s" % support(saved_y))
pr("Saved branch first-order direction nnz = %d" % nnz(saved_direction))
pr("")

pr("Baseline saved representative")
pr("-----------------------------")
baseline = flatness_summary("saved_order30_branch", saved["gen_vectors"])
pr("")

SAMPLE_KERNEL_SOLUTIONS = True

sample_results = []
for sample in range(1, N_KERNEL_SAMPLES + 1):
    pr("Kernel sample %02d" % sample)
    pr("----------------")
    KERNEL_SAMPLE_LOG[:] = []
    state, infos = sampled_state_for_direction(saved_direction)
    pr("  lift infos = %s" % infos)
    pr("  kernel log = %s" % KERNEL_SAMPLE_LOG)
    if state is None:
        sample_results.append((sample, None, infos))
        pr("")
        continue
    pr("  delta from saved: G2 nnz %d, G3 nnz %d" % (
        nnz(state["gen_vectors"][2] - saved["gen_vectors"][2]),
        nnz(state["gen_vectors"][3] - saved["gen_vectors"][3]),
    ))
    result = flatness_summary("kernel_sample_%02d" % sample, state["gen_vectors"])
    sample_results.append((sample, result, infos))
    pr("")

pr("Conclusion")
pr("----------")
hits = []
for sample, result, infos in sample_results:
    if result is not None and result["colon_eq"] and result["K0_eq_I"]:
        hits.append(sample)
    status = "no lift" if result is None else "J:(t)==J %s, K0==I %s, sat_steps %d" % (
        result["colon_eq"], result["K0_eq_I"], result["sat_steps"]
    )
    pr("sample %02d: %s" % (sample, status))
pr("hits = %s" % hits)

out.close()
