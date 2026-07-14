# compute_obstruction_quadrics.sage
#
# Exploratory computation of the quadratic order-2 obstruction map
# for SR(M), using the first-order data stored in part-1.pkl.
#
# Output:
#   - constructs a 53-dimensional complement to trivial coordinate changes;
#   - computes a chosen quadratic obstruction map over GF(PRIME);
#   - writes independent obstruction quadrics to obstruction_quadrics_ff32003.sage.
#
# Important:
#   This is an exploratory finite-field computation. If it finds something
#   interesting, rerun/verify later over QQ and proof-check the construction.

import pickle
from itertools import combinations
from collections import Counter

# ------------------------------------------------------------
# User parameters
# ------------------------------------------------------------

PICKLE_FILE = "../part-1.pkl"
PRIME = 32003
BASE_FIELD = GF(PRIME)

OUTPUT_FILE = "cache/obstruction_quadrics_ff32003.sage"
COMPUTE_IDEAL_DIMENSION = False   # can be expensive
MAX_PRINT_QUADRICS = 5

# ------------------------------------------------------------
# Small utilities
# ------------------------------------------------------------

def exp_tuple(e):
    return tuple(int(a) for a in e)


def add_exp(a, b):
    return tuple(x + y for x, y in zip(a, b))


def sub_exp(a, i):
    a = list(a)
    a[i] -= 1
    return tuple(a)


def add_to_entries(entries, key, val):
    val = BASE_FIELD(val)
    if val == 0:
        return
    entries[key] = entries.get(key, BASE_FIELD(0)) + val
    if entries[key] == 0:
        del entries[key]


def total_degree(e):
    return sum(e)


def poly_terms(poly):
    out = {}
    for e, c in poly.dict().items():
        c = BASE_FIELD(c)
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


def monomial_divides(a, b):
    return all(x <= y for x, y in zip(a, b))


def mat_rank(rows, ncols):
    if not rows:
        return 0
    return matrix(BASE_FIELD, rows).rank()

# ------------------------------------------------------------
# Load first-order data
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

basis3_index = {e: i for i, e in enumerate(basis3_exps)}

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
# First-order Hom-space: C * parameter_vector = 0
# ------------------------------------------------------------

params = [R_param(p) for p in def_params]
constraint_entries = {}
constraint_rhs = []

for c in all_coeffs:
    c = R_param(c)
    if c == 0:
        continue

    row = len(constraint_rhs)
    constant = BASE_FIELD(0)

    for e, coeff in c.dict().items():
        e = exp_tuple(e)
        coeff = BASE_FIELD(coeff)
        deg = sum(e)

        if deg == 0:
            constant += coeff
        elif deg == 1:
            j = e.index(1)
            add_to_entries(constraint_entries, (row, j), coeff)
        else:
            raise RuntimeError("nonlinear first-order constraint found")

    constraint_rhs.append(-constant)

C = matrix(BASE_FIELD, len(constraint_rhs), n_params, constraint_entries, sparse=True)
rank_C = C.rank()
H_basis = C.right_kernel().basis()

def dim_H():
    return n_params - rank_C

print("First-order Hom-space")
print("---------------------")
print("constraint matrix =", C.nrows(), "x", C.ncols())
print("rank =", rank_C)
print("dim Hom_S(I,S/I)_0 =", dim_H())
print("kernel basis length =", len(H_basis))
print()

assert dim_H() == len(H_basis)

# ------------------------------------------------------------
# Trivial embedded deformations: image of Der(S)_0
# ------------------------------------------------------------

derivation_rows = []

for i in range(nvars):
    for j in range(nvars):
        row = [BASE_FIELD(0)] * n_params

        for a, g in enumerate(f_exps):
            if g[i] == 0:
                continue

            e = list(g)
            e[i] -= 1
            e[j] += 1
            e = tuple(e)

            if monomial_in_I(e):
                continue

            if e not in basis3_index:
                raise RuntimeError("derivation monomial not in degree-3 basis")

            col = raw_param_index(a, basis3_index[e])
            row[col] += BASE_FIELD(g[i])

        derivation_rows.append(vector(BASE_FIELD, row))

D = matrix(BASE_FIELD, derivation_rows)
rank_D = D.rank()

print("Trivial embedded deformations")
print("-----------------------------")
print("Der matrix =", D.nrows(), "x", D.ncols())
print("rank Der image =", rank_D)
print("C * D^T = 0:", (C * D.transpose()).is_zero())
print()

assert rank_D == 56
assert (C * D.transpose()).is_zero()

# Choose a complement to Der inside Hom.
span_rows = [v for v in derivation_rows if v != 0]
current_rank = matrix(BASE_FIELD, span_rows).rank()
T1_basis = []

for b in H_basis:
    candidate_rows = span_rows + [b]
    new_rank = matrix(BASE_FIELD, candidate_rows).rank()
    if new_rank > current_rank:
        T1_basis.append(b)
        span_rows.append(b)
        current_rank = new_rank
    if len(T1_basis) == dim_H() - rank_D:
        break

print("T1 quotient basis")
print("-----------------")
print("chosen basis length =", len(T1_basis))
print("expected =", dim_H() - rank_D)
print("rank(D + T1_basis) =", current_rank)
print()

assert len(T1_basis) == 53
assert current_rank == dim_H()

# Convert T1 basis vectors to generator corrections phi[p][j].
def direction_to_phi(direction):
    phi = []
    for j in range(n_gens):
        terms = {}
        for m_idx, e in enumerate(basis3_exps):
            coeff = direction[raw_param_index(j, m_idx)]
            if coeff != 0:
                terms[e] = BASE_FIELD(coeff)
        phi.append(terms)
    return phi

PHI = [direction_to_phi(v) for v in T1_basis]
n_T1 = len(PHI)
quad_pairs = [(i, j) for i in range(n_T1) for j in range(i, n_T1)]
quad_index = {p: k for k, p in enumerate(quad_pairs)}

print("Quadratic monomials in T1 coordinates =", len(quad_pairs))
print()

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
        print("bad syzygy row", r, "degrees", degrees)
        raise RuntimeError("syzygy row is not homogeneous")

    syz_terms.append(row_terms)
    syz_degrees.append(list(degrees)[0])

print("Syzygy total-degree histogram:")
print(dict(sorted(Counter(syz_degrees).items())))
print()

# ------------------------------------------------------------
# Order-1 syzygy correction system E1 * alpha = RHS(y)
# ------------------------------------------------------------

alpha_col = {}
alpha_col_count = 0
order1_row = {}
order1_row_count = 0
E1_entries = {}
RHS_entries = {}
alpha_mons_by_r = {}

def get_alpha_col(r, j, q_exp):
    global alpha_col_count
    key = (r, j, q_exp)
    if key not in alpha_col:
        alpha_col[key] = alpha_col_count
        alpha_col_count += 1
    return alpha_col[key]


def get_order1_row(r, e):
    global order1_row_count
    key = (r, e)
    if key not in order1_row:
        order1_row[key] = order1_row_count
        order1_row_count += 1
    return order1_row[key]

for r in range(syz.nrows()):
    Dtot = syz_degrees[r]
    alpha_deg = Dtot - 3
    alpha_mons = list(degree_exps(nvars, alpha_deg))
    alpha_mons_by_r[r] = alpha_mons

    # alpha_j * f_j terms
    for j in range(n_gens):
        for q_exp in alpha_mons:
            col = get_alpha_col(r, j, q_exp)
            e = add_exp(q_exp, f_exps[j])
            row = get_order1_row(r, e)
            add_to_entries(E1_entries, (row, col), BASE_FIELD(1))

    # RHS terms: - sum_j s_j * phi_j^p, for each T1 basis p
    for p in range(n_T1):
        P1 = {}
        for j in range(n_gens):
            for se, sc in syz_terms[r][j].items():
                for pe, pc in PHI[p][j].items():
                    e = add_exp(se, pe)
                    P1[e] = P1.get(e, BASE_FIELD(0)) + sc * pc
        for e, coeff in P1.items():
            if coeff != 0:
                row = get_order1_row(r, e)
                add_to_entries(RHS_entries, (row, p), -coeff)

E1 = matrix(BASE_FIELD, order1_row_count, alpha_col_count, E1_entries, sparse=True)
RHS = matrix(BASE_FIELD, order1_row_count, n_T1, RHS_entries, sparse=True)

print("Order-1 syzygy correction system")
print("--------------------------------")
print("E1 matrix =", E1.nrows(), "x", E1.ncols())
print("RHS matrix =", RHS.nrows(), "x", RHS.ncols())
print("rank E1 =", E1.rank())
print("rank augmented =", E1.augment(RHS).rank())
print()

if E1.rank() != E1.augment(RHS).rank():
    raise RuntimeError("Some T1 basis vector does not satisfy order-1 syzygy lifting")

print("Solving E1 * alpha = RHS ...")
ALPHA = E1.solve_right(RHS)   # alpha_col_count x n_T1
print("alpha solution matrix =", ALPHA.nrows(), "x", ALPHA.ncols())
print()

# ------------------------------------------------------------
# Order-2 fixed psi map B and quadratic RHS matrix Q0
# ------------------------------------------------------------

order2_row = {}
order2_row_count = 0
B_entries = {}
Q_entries = {}

def get_order2_row(r, e):
    global order2_row_count
    key = (r, e)
    if key not in order2_row:
        order2_row[key] = order2_row_count
        order2_row_count += 1
    return order2_row[key]

# B: psi terms sum_j s_j psi_j, modulo I
for r in range(syz.nrows()):
    for j in range(n_gens):
        for se, sc in syz_terms[r][j].items():
            for m_idx, me in enumerate(basis3_exps):
                e = add_exp(se, me)
                if monomial_in_I(e):
                    continue
                row = get_order2_row(r, e)
                col = raw_param_index(j, m_idx)
                add_to_entries(B_entries, (row, col), sc)

# First create all rows that may appear in alpha * phi terms.
for r in range(syz.nrows()):
    for j in range(n_gens):
        for q_exp in alpha_mons_by_r[r]:
            for me in basis3_exps:
                e = add_exp(q_exp, me)
                if monomial_in_I(e):
                    continue
                get_order2_row(r, e)

B = matrix(BASE_FIELD, order2_row_count, n_params, B_entries, sparse=True)
rank_B = B.rank()

print("Order-2 psi map")
print("---------------")
print("B matrix =", B.nrows(), "x", B.ncols())
print("rank B =", rank_B)
print("cokernel dim of raw B =", B.nrows() - rank_B)
print()

print("Building quadratic RHS matrix Q0 ...")

for p, q in quad_pairs:
    qcol = quad_index[(p, q)]

    for r in range(syz.nrows()):
        for j in range(n_gens):
            # coefficient of y_p*y_q in alpha(y)_j * phi(y)_j
            # p=q: alpha_p * phi_p
            # p<q: alpha_p * phi_q + alpha_q * phi_p

            # alpha_p * phi_q
            for a_exp in alpha_mons_by_r[r]:
                acol = alpha_col[(r, j, a_exp)]
                ac = ALPHA[acol, p]
                if ac != 0:
                    for pe, pc in PHI[q][j].items():
                        e = add_exp(a_exp, pe)
                        if monomial_in_I(e):
                            continue
                        row = get_order2_row(r, e)
                        add_to_entries(Q_entries, (row, qcol), ac * pc)

            if p != q:
                # alpha_q * phi_p
                for a_exp in alpha_mons_by_r[r]:
                    acol = alpha_col[(r, j, a_exp)]
                    ac = ALPHA[acol, q]
                    if ac != 0:
                        for pe, pc in PHI[p][j].items():
                            e = add_exp(a_exp, pe)
                            if monomial_in_I(e):
                                continue
                            row = get_order2_row(r, e)
                            add_to_entries(Q_entries, (row, qcol), ac * pc)

Q0 = matrix(BASE_FIELD, order2_row_count, len(quad_pairs), Q_entries, sparse=True)

print("Q0 matrix =", Q0.nrows(), "x", Q0.ncols())
print("nonzero entries in Q0 =", len(Q_entries))
print()

# ------------------------------------------------------------
# Reduce Q0 modulo image(B) to get obstruction target coordinates.
# ------------------------------------------------------------

print("Computing rank of [B | Q0] ...")
Combined = B.augment(Q0)
rank_combined = Combined.rank()
obs_rank = rank_combined - rank_B

pivots = list(Combined.pivots())
basis_q_indices = [p - B.ncols() for p in pivots if p >= B.ncols()]

print("Obstruction image")
print("-----------------")
print("rank [B | Q0] =", rank_combined)
print("obstruction rank =", obs_rank)
print("number of pivot quadratic columns =", len(basis_q_indices))
print()

if obs_rank == 0:
    print("All computed quadratic obstructions vanish modulo image(B).")
    raise SystemExit

E = Q0.matrix_from_columns(basis_q_indices)
M = B.augment(E)

print("Solving [B | E] * Z = Q0 to get target coordinates ...")
Z = M.solve_right(Q0)
OB = Z.matrix_from_rows(range(B.ncols(), B.ncols() + obs_rank))

print("coordinate matrix for obstruction quadrics =", OB.nrows(), "x", OB.ncols())
print()

# ------------------------------------------------------------
# Convert to actual quadrics in a polynomial ring and write file.
# ------------------------------------------------------------

varnames = ["y%d" % i for i in range(n_T1)]
P = PolynomialRing(BASE_FIELD, varnames)
y = P.gens()

quadrics = []
for row in range(obs_rank):
    qpoly = P(0)
    for col, (i, j) in enumerate(quad_pairs):
        coeff = OB[row, col]
        if coeff != 0:
            qpoly += P(coeff) * y[i] * y[j]
    quadrics.append(qpoly)

print("Independent obstruction quadrics")
print("--------------------------------")
print("number of quadrics =", len(quadrics))
for idx, qpoly in enumerate(quadrics[:MAX_PRINT_QUADRICS]):
    print("Q%d has %d terms" % (idx + 1, len(qpoly.monomials())))
    print("Q%d = %s" % (idx + 1, qpoly))
    print()
if len(quadrics) > MAX_PRINT_QUADRICS:
    print("... not printing remaining quadrics here")
print()

with open(OUTPUT_FILE, "w") as f:
    f.write("# Autogenerated by compute_obstruction_quadrics.sage\n")
    f.write("# Base field: GF(%d)\n" % PRIME)
    f.write("# Variables y0,...,y%d are the chosen T1 quotient coordinates.\n\n" % (n_T1 - 1))
    f.write("P = PolynomialRing(GF(%d), %r)\n" % (PRIME, varnames))
    f.write("%s = P.gens()\n\n" % ",".join(varnames))
    f.write("quadrics = []\n")
    for qpoly in quadrics:
        f.write("quadrics.append(P(%r))\n" % str(qpoly))
    f.write("\nI = ideal(quadrics)\n")
    f.write("print('number of quadrics =', len(quadrics))\n")
    f.write("print('ambient dimension =', %d)\n" % n_T1)
    f.write("# Dimension computation may be expensive. Uncomment if desired.\n")
    f.write("# print('ideal dimension =', I.dimension())\n")

print("Wrote", OUTPUT_FILE)
print()

if COMPUTE_IDEAL_DIMENSION:
    print("Computing ideal dimension...")
    J = ideal(quadrics)
    print("ideal dimension =", J.dimension())

print("Summary")
print("-------")
print("dim Hom_S(I,S/I)_0 =", dim_H())
print("dim trivial directions =", rank_D)
print("dim T1 =", n_T1)
print("computed obstruction rank =", obs_rank)
print("output file =", OUTPUT_FILE)

raw_data = {
    "B": B,
    "Q0": Q0,
    "OB": OB,
    "rank_B": rank_B,
    "obs_rank": obs_rank,
    "quad_pairs": quad_pairs,
    "basis_q_indices": basis_q_indices,
    "order2_row": order2_row,
    "n_params": n_params,
    "n_T1": n_T1,
    "T1_basis": T1_basis,
    "syz_terms": syz_terms,
    "syz_degrees": syz_degrees,
    "f_exps": f_exps,
    "basis3_exps": basis3_exps,
}

save(raw_data, "cache/raw_obstruction_data.sobj")
print("Wrote cache/raw_obstruction_data.sobj")

print()
print("DONE")
