"""Compute dim T^1 from linearized first-syzygy equations."""

import pickle
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
FOUNDATION_DATA = REPO_ROOT / "foundations" / "part-1.pkl"

with FOUNDATION_DATA.open("rb") as f:
    data = pickle.load(f)

S = data["R"]
I = data["I"]
parameter_ring = data["R_param"]
parameter_names = data["def_params"]
syzygy_coefficients = data["all_coeffs"]
quotient_monomials = data["nonzero_monomials"]

x = S.gens()
generators = list(I.gens())
parameters = [parameter_ring(name) for name in parameter_names]

n_generators = len(generators)
n_monomials = len(quotient_monomials)
n_parameters = len(parameters)

print("Raw deformation space")
print("---------------------")
print("number of SR generators =", n_generators)
print("number of degree-3 monomials in S/I =", n_monomials)
print("number of raw deformation parameters =", n_parameters)
print()

assert n_generators == 16
assert n_monomials == 104
assert n_parameters == n_generators * n_monomials == 1664

# A degree-zero map I -> S/I assigns to each cubic generator a cubic
# residue class. Linearizing the first syzygies gives the matrix C.
nonzero_equations = [
    parameter_ring(c) for c in syzygy_coefficients if parameter_ring(c) != 0
]
assert all(c.degree() <= 1 for c in nonzero_equations)

C = matrix(QQ, [
    [equation.monomial_coefficient(parameter) for parameter in parameters]
    for equation in nonzero_equations
])

rank_C = C.rank()
dim_Hom = n_parameters - rank_C

print("Linearized first-syzygy equations")
print("----------------------------------")
print("syzygy constraint matrix size =", C.nrows(), "x", C.ncols())
print("rank of syzygy constraint matrix =", rank_C)
print("dim Hom_S(I,S/I)_0 =", dim_Hom)
print()

assert rank_C == 1555
assert dim_Hom == 109

# The derivations delta_ij with delta_ij(x_i) = x_j span Der(S)_0.
# Apply them to the generators of I and express the results modulo I in
# the same raw coefficient space used for C.
monomial_index = {S(m): i for i, m in enumerate(quotient_monomials)}

def parameter_index(generator_index, monomial_index):
    return generator_index * n_monomials + monomial_index


derivation_vectors = []
for i in range(len(x)):
    for j in range(len(x)):
        vector = [QQ(0)] * n_parameters

        for generator_index, generator in enumerate(generators):
            image = S(generator.derivative(x[i]) * x[j]).reduce(I)
            for exponent, coefficient in image.dict().items():
                monomial = S.monomial(*exponent)
                assert monomial in monomial_index
                index = parameter_index(
                    generator_index, monomial_index[monomial]
                )
                vector[index] += QQ(coefficient)

        derivation_vectors.append(vector)

D = matrix(QQ, derivation_vectors)
rank_D = D.rank()
derivations_satisfy_syzygies = (C * D.transpose()).is_zero()

print("Trivial embedded deformations")
print("-----------------------------")
print("derivation matrix size =", D.nrows(), "x", D.ncols())
print("rank image Der(S)_0 =", rank_D)
print("C * D^T is zero =", derivations_satisfy_syzygies)
print()

assert rank_D == 56
assert derivations_satisfy_syzygies

dim_T1 = dim_Hom - rank_D

print("Quotient by coordinate changes")
print("------------------------------")
print("dim T^1 =", dim_T1)

assert dim_T1 == 53
