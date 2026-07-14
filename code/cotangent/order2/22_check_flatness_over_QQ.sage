# 22_check_flatness_over_QQ.sage
#
# Flatness test for the QQ cubic family.
#
# Input:
#   ../part-1.pkl
#   cache/cubic_family_QQ_data.json
#
# Builds the ideal
#
#   J = (F_1(t),...,F_16(t)) in QQ[t,x0,...,x7]
#
# where
#
#   F_j(t) = f_j + t G_{1,j} + t^2 G_{2,j} + t^3 G_{3,j}.
#
# Then checks:
#
#   1. F_j(0) = f_j.
#   2. The special fiber J + (t) is the SR ideal I.
#   3. t is a nonzerodivisor on QQ[t,x]/J, i.e.
#
#          J : (t) = J.
#
# If (2) and (3) hold, then the graded coordinate ring is flat
# over QQ[t], hence this is an honest flat family with special
# fiber SR(M).

import pickle
import json

# ------------------------------------------------------------
# User parameters
# ------------------------------------------------------------

PICKLE_FILE = "../part-1.pkl"
INPUT_JSON = "cache/cubic_family_QQ_data.json"
OUTPUT_FILE = "cache/cubic_family_QQ_flatness_check.sobj"

# Term order for Groebner computations.
# If this is slow, try "degrevlex" or "lex" variants locally.
ORDER = "degrevlex"

# ------------------------------------------------------------
# Small utilities
# ------------------------------------------------------------

def exp_tuple(e):
    return tuple(int(a) for a in e)


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


def rational_from_json(pair):
    return QQ(ZZ(pair[0])) / QQ(ZZ(pair[1]))


def sparse_rational_data_to_vector(items, length):
    v = vector(QQ, length)
    for i, pair in items:
        v[int(i)] = rational_from_json(pair)
    return v


def nnz(v):
    return sum(1 for c in v if c != 0)

# ------------------------------------------------------------
# Load base data
# ------------------------------------------------------------

print("Loading", INPUT_JSON)
with open(INPUT_JSON, "r") as f:
    cubic = json.load(f)

if cubic.get("base_field", None) != "QQ":
    raise RuntimeError("expected QQ cubic data JSON")

print("Loading", PICKLE_FILE)
with open(PICKLE_FILE, "rb") as f:
    data = pickle.load(f)

R_old = data["R"]
I_old = data["I"]
nonzero_monomials = data["nonzero_monomials"]

nvars = len(R_old.gens())
xnames = ["x%d" % i for i in range(nvars)]

f_old = list(I_old.gens())
n_gens = len(f_old)
n_mons = len(nonzero_monomials)
n_params = n_gens * n_mons

f_terms_old = [poly_terms(R_old(f)) for f in f_old]
f_exps = []
for ft in f_terms_old:
    assert len(ft) == 1
    f_exps.append(list(ft.keys())[0])

basis3_exps = []
for m in nonzero_monomials:
    mt = poly_terms(R_old(m))
    assert len(mt) == 1
    basis3_exps.append(list(mt.keys())[0])

assert n_gens == 16
assert n_params == int(cubic["n_params"])

# ------------------------------------------------------------
# Build QQ polynomial rings
# ------------------------------------------------------------

T = PolynomialRing(QQ, ["t"] + xnames, order=ORDER)
t = T.gen(0)
X = T.gens()[1:]

S = PolynomialRing(QQ, xnames, order=ORDER)
XS = S.gens()


def monomial_from_exp_T(e):
    m = T(1)
    for i, a in enumerate(e):
        if a:
            m *= X[i] ** int(a)
    return m


def monomial_from_exp_S(e):
    m = S(1)
    for i, a in enumerate(e):
        if a:
            m *= XS[i] ** int(a)
    return m


def vector_to_terms(v):
    out = []
    for j in range(n_gens):
        terms = {}
        for m_idx, e in enumerate(basis3_exps):
            coeff = QQ(v[j * n_mons + m_idx])
            if coeff != 0:
                terms[e] = coeff
        out.append(terms)
    return out


def terms_to_poly_T(terms):
    p = T(0)
    for e, c in terms.items():
        p += QQ(c) * monomial_from_exp_T(e)
    return p

# ------------------------------------------------------------
# Load QQ cubic vectors
# ------------------------------------------------------------

G = {}
G_terms = {}
for k in [1, 2, 3]:
    G[k] = sparse_rational_data_to_vector(cubic["G"][str(k)], n_params)
    G_terms[k] = vector_to_terms(G[k])

print()
print("Basic data")
print("----------")
print("base field = QQ")
print("polynomial ring = QQ[t,x0,...,x7]")
print("term order =", ORDER)
print("number of generators =", n_gens)
print("n_params =", n_params)
for k in [1, 2, 3]:
    print("G_%d nnz = %d" % (k, nnz(G[k])))
print()

# ------------------------------------------------------------
# Build f_j and F_j(t)
# ------------------------------------------------------------

f_T = [monomial_from_exp_T(e) for e in f_exps]
f_S = [monomial_from_exp_S(e) for e in f_exps]

F = []
for j in range(n_gens):
    Fj = f_T[j]
    Fj += t * terms_to_poly_T(G_terms[1][j])
    Fj += (t ** 2) * terms_to_poly_T(G_terms[2][j])
    Fj += (t ** 3) * terms_to_poly_T(G_terms[3][j])
    F.append(Fj)

print("Specialization check")
print("--------------------")
special_ok = True
for j in range(n_gens):
    sp = F[j].subs({t: 0})
    ok = (sp == f_T[j])
    special_ok = special_ok and ok
    print("F_%d(0)=f_%d:" % (j + 1, j + 1), ok)
print()

if not special_ok:
    raise RuntimeError("some F_j does not specialize to f_j")

# ------------------------------------------------------------
# Ideals
# ------------------------------------------------------------

J = T.ideal(F)
I_S = S.ideal(f_S)

# In T/(t), J specializes to the ideal generated by f_j.
# This check is deliberately simple: since F_j == f_j mod t,
# J+(t) maps onto I_S by construction.

print("Special fiber ideal")
print("-------------------")
print("J + (t) has generators F_j and t, hence modulo t gives (f_j).")
print("number of SR generators =", len(f_S))
print()

# ------------------------------------------------------------
# Flatness via t-torsion test
# ------------------------------------------------------------

print("Computing colon ideal J:(t)")
print("---------------------------")
print("This is the expensive step.")
print()

try:
    colon = J.quotient(T.ideal(t))
except TypeError:
    colon = J.quotient(t)

print("Comparing J:(t) with J")
print("----------------------")
colon_eq_J = (colon == J)
print("J:(t) == J:", colon_eq_J)
print()

# Optional extra: compare Groebner basis sizes, useful diagnostic.
print("Diagnostic sizes")
print("----------------")
try:
    gb_J = J.groebner_basis()
    gb_colon = colon.groebner_basis()
    print("len Groebner(J) =", len(gb_J))
    print("len Groebner(J:(t)) =", len(gb_colon))
except Exception as e:
    print("Groebner diagnostic failed:", e)
print()

out = {
    "base_field": "QQ",
    "input_json": INPUT_JSON,
    "special_ok": special_ok,
    "colon_eq_J": colon_eq_J,
    "n_gens": n_gens,
    "n_params": n_params,
    "order": ORDER,
}

save(out, OUTPUT_FILE)
print("Saved", OUTPUT_FILE)
print()

if colon_eq_J:
    print("Flatness verdict")
    print("----------------")
    print("t is a nonzerodivisor on QQ[t,x]/J.")
    print("Since F_j(0)=f_j, the special fiber is SR(M).")
    print("Therefore this certifies a flat family over QQ[t].")
else:
    print("Flatness verdict")
    print("----------------")
    print("Not certified: J:(t) != J.")
    print("This may mean either non-flatness or that we need a different check/saturation analysis.")
