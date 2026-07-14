# count_free_params_part1.sage
#
# Purpose:
#   Independent check of dim T^1 from Michele's linearized syzygy method.
#
# It loads part-1.pkl, extracts the linear constraints on the deformation
# parameters, computes their rank over QQ, and prints:
#
#   number of parameters
#   number/rank of independent linear constraints
#   number of free parameters
#
# Expected result, if it matches Christophersen: 53.

import pickle

PICKLE_FILE = "part-1.pkl"
EXPECTED_FREE_DIM = 53

print("Loading", PICKLE_FILE)

with open(PICKLE_FILE, "rb") as f:
    data = pickle.load(f)

R_param = data["R_param"]
def_params = data["def_params"]
all_coeffs = data["all_coeffs"]
basis = data["basis"]

params = [R_param(p) for p in def_params]

print()
print("Basic data")
print("----------")
print("number of deformation parameters =", len(params))
print("number of raw coefficient constraints =", len(all_coeffs))
print("number of Groebner basis constraints =", len(basis))
print()

# ------------------------------------------------------------
# Sanity check: constraints should be linear
# ------------------------------------------------------------

nonzero_coeffs = [R_param(c) for c in all_coeffs if R_param(c) != 0]

bad = []
for c in nonzero_coeffs:
    if c.degree() > 1:
        bad.append(c)

print("Linearity check")
print("---------------")
print("nonzero raw constraints =", len(nonzero_coeffs))
print("nonlinear raw constraints =", len(bad))

if bad:
    print()
    print("ERROR: found nonlinear constraints. First few:")
    for c in bad[:10]:
        print(c)
    raise RuntimeError("Constraints are not purely linear.")

print("OK: all raw constraints are linear.")
print()

# ------------------------------------------------------------
# Build coefficient matrix over QQ
# ------------------------------------------------------------

rows = []
for c in nonzero_coeffs:
    row = [c.monomial_coefficient(p) for p in params]
    rows.append(row)

M = matrix(QQ, rows)
rank = M.rank()

n_params = len(params)
free_dim = n_params - rank

print("Linear algebra")
print("--------------")
print("matrix size =", M.nrows(), "x", M.ncols())
print("rank =", rank)
print("free dimension =", free_dim)
print()

# ------------------------------------------------------------
# Find pivot and non-pivot variables
# ------------------------------------------------------------

E = M.echelon_form()
pivot_cols = list(E.pivots())
pivot_cols = sorted(pivot_cols)
free_cols = [j for j in range(n_params) if j not in pivot_cols]

pivot_params = [def_params[j] for j in pivot_cols]
free_params = [def_params[j] for j in free_cols]

print("Pivots / free variables")
print("-----------------------")
print("number of pivot variables =", len(pivot_params))
print("number of free variables =", len(free_params))
print()

print("Free parameters:")
for p in free_params:
    print(" ", p)

print()
print("Final check")
print("-----------")
print("free dimension == 53:", free_dim == EXPECTED_FREE_DIM)

if free_dim != EXPECTED_FREE_DIM:
    raise RuntimeError(f"Expected {EXPECTED_FREE_DIM}, got {free_dim}")

print()
print("SUCCESS: Michele linearized parameter count matches dim T^1 = 53.")
