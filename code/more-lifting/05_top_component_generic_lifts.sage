# 05_top_component_generic_lifts.sage
#
# Sample genuinely generic points on the unique top-dimensional
# quadratic component
#
#   V_A^(0) x V_B^(0) x V_C^(0) x A^17
#
# where V_A^(0), V_B^(0), V_C^(0) are the 7-dimensional "rank-one"
# minimal primes found in 01_versal_base_structure.m2, and test how far
# such directions lift order-by-order over GF(32003).
#
# Run from:
#   code/more-lifting
#
# Suggested invocation:
#   HOME=/tmp sage 05_top_component_generic_lifts.sage

import pickle
import random
from collections import Counter

PICKLE_FILE = "../cotangent/part-1.pkl"
RAW_FILE = "../cotangent/order2/cache/raw_obstruction_data.sobj"
QUADRIC_FILE = "../cotangent/order2/cache/obstruction_quadrics_ff32003.sage"
OUT_FILE = "cache/05_top_component_generic_lifts.log"

PRIME = 32003
K = GF(PRIME)

MAX_ORDER = 8
N_SAMPLES = 3
SEED_BASE = 20260622

A_BLOCK = [0, 3, 7, 9, 23, 31, 35, 36, 39, 44, 48, 52]
B_BLOCK = [1, 4, 19, 20, 22, 26, 27, 29, 38, 43, 45, 47]
C_BLOCK = [6, 8, 15, 16, 24, 25, 32, 33, 37, 40, 49, 50]
FREE_BLOCK = [2, 5, 10, 11, 12, 13, 14, 17, 18, 21, 28, 30, 34, 41, 42, 46, 51]

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


def nnz(v):
    return sum(1 for c in v if c != 0)


def support(vec):
    return [i for i, c in enumerate(vec) if c != 0]


def ff_int(c):
    return int(K(c))


def ff_list(vec):
    return [ff_int(c) for c in vec]


def nz_rand(rng):
    return K(rng.randrange(1, PRIME))


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


# ------------------------------------------------------------
# Syzygy preprocessing and correction-column reconstruction
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
    out = []
    for j in range(n_gens):
        terms = {}
        for m_idx, e in enumerate(basis3_exps):
            coeff = K(direction[raw_param_index(j, m_idx)])
            if coeff != 0:
                terms[e] = coeff
        out.append(terms)
    return out


def make_top_component_point(seed):
    rng = random.Random(int(seed))
    y = [K(0)] * 53

    # Block A, prime 0.
    a = nz_rand(rng)
    b = nz_rand(rng)
    u0 = nz_rand(rng)
    u1 = nz_rand(rng)
    u2 = nz_rand(rng)
    v0 = nz_rand(rng)
    v1 = nz_rand(rng)
    v2 = nz_rand(rng)

    y[0] = a * u0
    y[3] = a * u1
    y[7] = a * u2
    y[31] = b * u0
    y[35] = b * u1
    y[36] = b * u2
    y[9] = a * v0
    y[23] = b * v0
    y[39] = b * v1
    y[48] = a * v1
    y[44] = b * v2
    y[52] = a * v2

    # Block B, prime 0.
    c = nz_rand(rng)
    d = nz_rand(rng)
    w = [nz_rand(rng) for _ in range(6)]

    y[1] = c * w[0]
    y[4] = c * w[1]
    y[22] = c * w[2]
    y[26] = c * w[3]
    y[27] = c * w[4]
    y[29] = c * w[5]
    y[19] = d * w[0]
    y[20] = d * w[1]
    y[47] = d * w[2]
    y[38] = d * w[3]
    y[43] = d * w[4]
    y[45] = d * w[5]

    # Block C, prime 0.
    e = nz_rand(rng)
    f = nz_rand(rng)
    p = [nz_rand(rng) for _ in range(4)]
    q = [nz_rand(rng) for _ in range(2)]

    y[6] = e * p[0]
    y[8] = e * p[1]
    y[15] = e * p[2]
    y[16] = e * p[3]
    y[40] = f * p[0]
    y[37] = f * p[1]
    y[49] = f * p[2]
    y[50] = f * p[3]
    y[32] = e * q[0]
    y[33] = e * q[1]
    y[24] = f * q[0]
    y[25] = f * q[1]

    # Free coordinates.
    for i in FREE_BLOCK:
        y[i] = nz_rand(rng)

    return y


def y_to_direction(y):
    v = vector(K, n_params)
    for i, coeff in enumerate(y):
        coeff = K(coeff)
        if coeff != 0:
            v += coeff * T1_basis[i]
    return v


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

        for e, const in P1.items():
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
                psi_col = raw_param_index(j, m_idx)
                prod = multiply_term_dict(st, {m_exp: K(1)}, quotient=True)
                for e, c in prod.items():
                    rows_by_exp.setdefault(e, {})[psi_col] = (
                        rows_by_exp.setdefault(e, {}).get(psi_col, K(0)) + c
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
        "success": lifts,
    }

    if not lifts:
        return info, None

    sol = A.solve_right(b)
    state = {
        "direction": direction,
        "gen_vectors": {
            1: direction,
            2: sol[:n_params],
        },
        "syz_vectors": {
            1: sol[n_params:],
        },
        "rank_A_by_order": {2: rank_A},
        "rank_B_by_order": {2: rank_B},
    }
    return info, state


def build_order_system(order, gen_terms, syz_vectors):
    entries = {}
    rhs = []
    target_rows = []
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
            row = add_row(entries, rhs, coeffs, constant_by_exp.get(e, K(0)))
            if row is not None:
                target_rows.append(row)

    A = matrix(K, len(rhs), n_unknowns, entries, sparse=True)
    b = vector(K, rhs)
    return A, b, target_rows


def extend_one_order(state, order):
    gen_terms = {k: direction_to_terms(v) for k, v in state["gen_vectors"].items()}
    A, b, target_rows = build_order_system(order, gen_terms, state["syz_vectors"])
    B = A.augment(matrix(K, A.nrows(), 1, list(b), sparse=True))
    rank_A = A.rank()
    rank_B = B.rank()
    lifts = (rank_A == rank_B)

    info = {
        "order": order,
        "rank_A": rank_A,
        "rank_B": rank_B,
        "n_equations": A.nrows(),
        "n_target_rows": len(target_rows),
        "success": lifts,
    }

    if not lifts:
        return info

    sol = A.solve_right(b)
    state["gen_vectors"][order] = sol[:n_params]
    state["syz_vectors"][order - 1] = sol[n_params:]
    state["rank_A_by_order"][order] = rank_A
    state["rank_B_by_order"][order] = rank_B
    return info


def summarize_block(y, block):
    vals = [y[i] for i in block]
    return {
        "nonzero": sum(1 for c in vals if c != 0),
        "values": [ff_int(c) for c in vals],
    }


pr("Testing generic points on the top quadratic component")
pr("-----------------------------------------------------")
pr("MAX_ORDER = %d" % MAX_ORDER)
pr("N_SAMPLES = %d" % N_SAMPLES)
pr("SEED_BASE = %d" % SEED_BASE)
pr("")

results = []

for sample_idx in range(1, N_SAMPLES + 1):
    seed = SEED_BASE + sample_idx - 1
    y = make_top_component_point(seed)
    direction = y_to_direction(y)

    pr("Sample %d" % sample_idx)
    pr("--------")
    pr("seed = %d" % seed)
    pr("support size in y-coordinates = %d" % len(support(y)))
    pr("quadratic equations vanish = %s" % is_quadratic_solution(y))
    pr("A block nonzeros = %d" % summarize_block(y, A_BLOCK)["nonzero"])
    pr("B block nonzeros = %d" % summarize_block(y, B_BLOCK)["nonzero"])
    pr("C block nonzeros = %d" % summarize_block(y, C_BLOCK)["nonzero"])
    pr("free block nonzeros = %d" % summarize_block(y, FREE_BLOCK)["nonzero"])
    pr("A2-excluding coordinates (y9,y23) = (%d,%d)" % (ff_int(y[9]), ff_int(y[23])))
    pr("B2-excluding coordinates (y22,y47) = (%d,%d)" % (ff_int(y[22]), ff_int(y[47])))
    pr("C2-excluding coordinates (y6,y40) = (%d,%d)" % (ff_int(y[6]), ff_int(y[40])))
    pr("direction nnz in raw 1664 coordinates = %d" % nnz(direction))

    info2, state = solve_order_2(direction)
    pr("order 2: order1_ok = %s, lifts = %s, rank_A1 = %d, rank_B1 = %d, rank_A = %d, rank_B = %d" % (
        info2["order1_ok"], info2["success"], info2["rank_A1"], info2["rank_B1"], info2["rank_A"], info2["rank_B"]
    ))

    max_reached = 1
    if state is not None:
        max_reached = 2
        for order in range(3, MAX_ORDER + 1):
            info = extend_one_order(state, order)
            pr("order %d: lifts = %s, rank_A = %d, rank_B = %d, equations = %d" % (
                order, info["success"], info["rank_A"], info["rank_B"], info["n_equations"]
            ))
            if not info["success"]:
                break
            max_reached = order

    pr("max order reached = %d" % max_reached)
    pr("")

    results.append({
        "sample": sample_idx,
        "seed": seed,
        "quadratic_ok": is_quadratic_solution(y),
        "direction_nnz": nnz(direction),
        "max_order_reached": max_reached,
    })

pr("Summary")
pr("-------")
for r in results:
    pr("sample %d seed %d: quadratic_ok = %s, direction_nnz = %d, max_order_reached = %d" % (
        r["sample"], r["seed"], r["quadratic_ok"], r["direction_nnz"], r["max_order_reached"]
    ))

if all(r["max_order_reached"] == 3 for r in results):
    pr("")
    pr("Conclusion: all tested generic top-component directions lifted to order 3 and failed at order 4.")
    pr("This points to a genuine order-4 obstruction on the generic point of the 38-dimensional quadratic component.")
elif all(r["max_order_reached"] >= MAX_ORDER for r in results):
    pr("")
    pr("Conclusion: all tested generic top-component directions lifted through order %d." % MAX_ORDER)
elif any(r["max_order_reached"] <= 2 for r in results):
    pr("")
    pr("Conclusion: at least one tested generic top-component direction already fails very early.")
else:
    pr("")
    pr("Conclusion: the tested generic top-component directions show mixed higher-order behavior.")

out.close()
