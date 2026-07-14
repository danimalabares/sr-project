# 23_analyze_t_torsion_and_saturation_QQ.sage
#
# Diagnostic after 22_check_flatness_over_QQ.sage finds J:(t) != J.
#
# Input:
#   ../part-1.pkl
#   cache/cubic_family_QQ_data.json
#
# Builds
#
#   J = (F_1(t),...,F_16(t)) in QQ[t,x0,...,x7]
#
# and analyzes the t-torsion:
#
#   colon_1 = J : (t)
#   K       = J : (t^infty), computed by iterated colon
#
# Then checks the special fiber of K:
#
#   K_0 = (K + (t))/(t) in QQ[x0,...,x7]
#
# If K_0 == I, then the t-saturation gives a flat family with
# the same SR special fiber. If K_0 strictly contains I, the naive
# cubic family loses the SR special fiber after removing t-torsion.

import pickle
import json

# ------------------------------------------------------------
# User parameters
# ------------------------------------------------------------

PICKLE_FILE = "../part-1.pkl"
INPUT_JSON = "cache/cubic_family_QQ_data.json"
OUTPUT_FILE = "cache/cubic_family_QQ_ttorsion_saturation.sobj"

ORDER = "degrevlex"
MAX_SATURATION_STEPS = 10
MAX_PRINT_GENS = 20

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
# Load data
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
# Build rings
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


def T_poly_specialize_t0_to_S(p):
    """Return p(t=0) as an element of S."""
    out = S(0)
    for e, c in p.dict().items():
        e = tuple(int(a) for a in e)
        if e[0] != 0:
            continue
        x_exp = e[1:]
        out += QQ(c) * monomial_from_exp_S(x_exp)
    return out

# ------------------------------------------------------------
# Build J
# ------------------------------------------------------------

G = {}
G_terms = {}
for k in [1, 2, 3]:
    G[k] = sparse_rational_data_to_vector(cubic["G"][str(k)], n_params)
    G_terms[k] = vector_to_terms(G[k])

f_T = [monomial_from_exp_T(e) for e in f_exps]
f_S = [monomial_from_exp_S(e) for e in f_exps]

F = []
for j in range(n_gens):
    Fj = f_T[j]
    Fj += t * terms_to_poly_T(G_terms[1][j])
    Fj += (t ** 2) * terms_to_poly_T(G_terms[2][j])
    Fj += (t ** 3) * terms_to_poly_T(G_terms[3][j])
    F.append(Fj)

J = T.ideal(F)
I_S = S.ideal(f_S)

print()
print("Basic data")
print("----------")
print("base field = QQ")
print("ring = QQ[t,x0,...,x7]")
print("order =", ORDER)
print("n_gens =", n_gens)
for k in [1, 2, 3]:
    print("G_%d nnz = %d" % (k, nnz(G[k])))
print()

# ------------------------------------------------------------
# First colon and extra generators
# ------------------------------------------------------------

print("Computing J:(t)")
print("----------------")
colon = J.quotient(T.ideal(t))
colon_eq_J = (colon == J)
print("J:(t) == J:", colon_eq_J)
print()

print("Extra generators in J:(t), reduced modulo J")
print("--------------------------------------------")
extra_remainders = []
try:
    gb_J = J.groebner_basis()
    for g in colon.gens():
        r = T(g).reduce(gb_J)
        if r != 0:
            extra_remainders.append(r)
    print("number of nonzero reduced colon generators =", len(extra_remainders))
    for i, r in enumerate(extra_remainders[:MAX_PRINT_GENS]):
        print("extra[%d] =" % i, r)
except Exception as e:
    print("could not reduce colon generators modulo J:", e)
print()

# ------------------------------------------------------------
# Saturation by t via iteration
# ------------------------------------------------------------

print("Computing t-saturation by iterated colon")
print("----------------------------------------")
K = J
sat_steps = 0
for step in range(1, MAX_SATURATION_STEPS + 1):
    K_next = K.quotient(T.ideal(t))
    changed = (K_next != K)
    print("step", step, "changed =", changed)
    if not changed:
        break
    K = K_next
    sat_steps = step
else:
    print("WARNING: reached MAX_SATURATION_STEPS without stabilization")

K_colon = K.quotient(T.ideal(t))
K_t_saturated = (K_colon == K)
print()
print("saturation steps =", sat_steps)
print("K:(t) == K:", K_t_saturated)
print()

# ------------------------------------------------------------
# Special fiber of saturation
# ------------------------------------------------------------

print("Special fiber of the saturated ideal K")
print("--------------------------------------")
K0_gens = []
for g in K.gens():
    sg = T_poly_specialize_t0_to_S(T(g))
    if sg != 0:
        K0_gens.append(sg)

K0 = S.ideal(K0_gens)
K0_eq_I = (K0 == I_S)
I_contained_in_K0 = all(I_S.gen(i) in K0 for i in range(len(I_S.gens())))
K0_contained_in_I = all(K0.gen(i) in I_S for i in range(len(K0.gens())))

print("number of K0 generators =", len(K0_gens))
print("K0 == I:", K0_eq_I)
print("I subset K0:", I_contained_in_K0)
print("K0 subset I:", K0_contained_in_I)
print()

if not K0_eq_I:
    print("Groebner basis of K0, first generators")
    print("--------------------------------------")
    try:
        gb_K0 = K0.groebner_basis()
        print("len Groebner(K0) =", len(gb_K0))
        for i, g in enumerate(gb_K0[:MAX_PRINT_GENS]):
            print("K0gb[%d] =" % i, g)
    except Exception as e:
        print("could not compute/print Groebner(K0):", e)
    print()

# ------------------------------------------------------------
# Save and verdict
# ------------------------------------------------------------

out = {
    "base_field": "QQ",
    "input_json": INPUT_JSON,
    "colon_eq_J": colon_eq_J,
    "sat_steps": sat_steps,
    "K_t_saturated": K_t_saturated,
    "K0_eq_I": K0_eq_I,
    "I_contained_in_K0": I_contained_in_K0,
    "K0_contained_in_I": K0_contained_in_I,
    "n_K0_gens": len(K0_gens),
    "order": ORDER,
}

save(out, OUTPUT_FILE)
print("Saved", OUTPUT_FILE)
print()

print("Verdict")
print("-------")
if colon_eq_J:
    print("J itself is t-saturated: flatness certified for J.")
elif K_t_saturated and K0_eq_I:
    print("J is not flat, but its t-saturation K is flat and has special fiber I.")
    print("So use K, not the naive generated ideal J, as the family ideal.")
elif K_t_saturated and not K0_eq_I:
    print("J is not flat, and t-saturation changes the special fiber.")
    print("So this cubic generated ideal does not yet give the desired flat family.")
else:
    print("Saturation did not stabilize within the step bound; increase MAX_SATURATION_STEPS.")
