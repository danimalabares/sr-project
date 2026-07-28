# count_T1_quotient_part1.sage
#
# Computes:
#   H = Hom_S(I, S/I)_0 from Michele's syzygy constraints
#   B = image of Der(S)_0 -> H, i.e. trivial embedded deformations
#   T1 = H / B
#
# Expected:
#   dim H  = 109
#   dim B  = 56
#   dim T1 = 53

import pickle

PICKLE_FILE = "part-1.pkl"

with open(PICKLE_FILE, "rb") as f:
    data = pickle.load(f)

R = data["R"]
I = data["I"]
R_param = data["R_param"]
def_params = data["def_params"]
all_coeffs = data["all_coeffs"]
nonzero_monomials = data["nonzero_monomials"]

x = R.gens()
params = [R_param(p) for p in def_params]

# Original SR generators, in the same order as part-1.sage
f_list = list(I.gens())
n_gens = len(f_list)
n_mons = len(nonzero_monomials)
n_params = len(def_params)

print("Basic data")
print("----------")
print("number of variables =", len(x))
print("number of SR generators =", n_gens)
print("number of monomials in (S/I)_3 =", n_mons)
print("number of deformation parameters =", n_params)
print()

assert n_gens == 16
assert n_params == n_gens * n_mons

# ------------------------------------------------------------
# 1. Linear constraints defining Hom_S(I,S/I)_0
# ------------------------------------------------------------

nonzero_coeffs = [R_param(c) for c in all_coeffs if R_param(c) != 0]

bad = [c for c in nonzero_coeffs if c.degree() > 1]
if bad:
    print("ERROR: nonlinear constraints found")
    for c in bad[:10]:
        print(c)
    raise RuntimeError("constraints are not linear")

constraint_rows = []
for c in nonzero_coeffs:
    constraint_rows.append([c.monomial_coefficient(p) for p in params])

C = matrix(QQ, constraint_rows)

rank_C = C.rank()
dim_H = n_params - rank_C

print("Hom-space from syzygy constraints")
print("---------------------------------")
print("constraint matrix size =", C.nrows(), "x", C.ncols())
print("rank constraints =", rank_C)
print("dim Hom_S(I,S/I)_0 =", dim_H)
print()

# ------------------------------------------------------------
# 2. Build image of Der(S)_0
# ------------------------------------------------------------
#
# A degree-zero derivation is determined by
#
#   delta(x_i) = x_j
#
# for each pair (i,j). There are 8*8 = 64 such derivations.
#
# For each SR generator f_a, compute delta(f_a), reduce mod I,
# and express it in the monomial basis nonzero_monomials.
#
# This gives one vector in the raw parameter space.

monomial_index = {R(m): i for i, m in enumerate(nonzero_monomials)}

def raw_param_index(gen_index, mon_index):
    return gen_index * n_mons + mon_index

def reduce_mod_I(poly):
    return R(poly).reduce(I)

derivation_vectors = []

for i in range(len(x)):
    for j in range(len(x)):
        # derivation delta with delta(x_i)=x_j, all other variables 0
        row = [QQ(0)] * n_params

        for a, f in enumerate(f_list):
            df = f.derivative(x[i]) * x[j]
            df_red = reduce_mod_I(df)

            if df_red == 0:
                continue

            # df_red should be a linear combination of allowed degree-3 monomials
            for m, coeff in df_red.dict().items():
                mon = R.monomial(*m)
                if mon not in monomial_index:
                    print("ERROR: monomial not in basis after reduction:", mon)
                    print("df_red =", df_red)
                    raise RuntimeError("bad reduction")

                mon_idx = monomial_index[mon]
                row[raw_param_index(a, mon_idx)] += QQ(coeff)

        derivation_vectors.append(row)

D = matrix(QQ, derivation_vectors)
rank_D_raw = D.rank()

print("Trivial embedded deformations")
print("-----------------------------")
print("derivation matrix size =", D.nrows(), "x", D.ncols())
print("rank image Der(S)_0 in raw parameter space =", rank_D_raw)
print()

# ------------------------------------------------------------
# 3. Check derivation image satisfies syzygy constraints
# ------------------------------------------------------------

CDt = C * D.transpose()

print("Compatibility check")
print("-------------------")
print("C * D^T is zero:", CDt.is_zero())
if not CDt.is_zero():
    raise RuntimeError("Derivation image does not satisfy syzygy constraints")
print()

# ------------------------------------------------------------
# 4. Quotient dimension
# ------------------------------------------------------------

dim_T1 = dim_H - rank_D_raw

print("Final quotient")
print("--------------")
print("dim Hom_S(I,S/I)_0 =", dim_H)
print("dim image Der(S)_0 =", rank_D_raw)
print("dim T^1 =", dim_T1)
print()

print("Expected checks")
print("---------------")
print("dim Hom == 109:", dim_H == 109)
print("dim image Der == 56:", rank_D_raw == 56)
print("dim T1 == 53:", dim_T1 == 53)

assert dim_H == 109
assert rank_D_raw == 56
assert dim_T1 == 53

print()
print("SUCCESS: Michele's method matches Christophersen: dim T^1 = 53.")
