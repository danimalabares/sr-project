# Sage script to compute constraints for SR(M) deformation
# This script computes the Groebner basis constraints and saves them to a file
# Run this script when you need to recompute constraints (rarely)

# 1. Define the polynomial ring in variables x1 to x8
R = PolynomialRing(QQ, 8, 'x1,x2,x3,x4,x5,x6,x7,x8', order='lex')
x1,x2,x3,x4,x5,x6,x7,x8 = R.gens()

# 2. Define the SR ideal of M and its syzygies
f1 = x6*x7*x8
f2 = x4*x6*x8
f3 = x3*x7*x8
f4 = x3*x5*x7
f5 = x3*x4*x8
f6 = x2*x7*x8
f7 = x2*x5*x7
f8 = x2*x5*x6
f9 = x2*x4*x7
f10 = x2*x4*x6
f11 = x1*x4*x6
f12 = x1*x4*x5
f13 = x1*x3*x8
f14 = x1*x3*x6
f15 = x1*x3*x5
f16 = x1*x2*x5

I = ideal(f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12, f13, f14, f15, f16)

syz = I.syzygy_module()

# 3. Print all the degree-3 monomials in R/I
print("Degree-3 monomials in R/I:")
degree3_monomials = []
for i in range(8):
    for j in range(i, 8):
        for k in range(j, 8):
            monomial = R.gens()[i] * R.gens()[j] * R.gens()[k]
            degree3_monomials.append(monomial)

# Filter monomials not in the ideal I
nonzero_monomials = []
for mon in degree3_monomials:
    if mon not in I:
        nonzero_monomials.append(mon)

print(f"There are {len(nonzero_monomials)} degree-3 monomials not in I")
print()

# 4. Define deformation polynomials introducing deformation variables
# Extend the polynomial ring with deformation parameters
# Create parameters: a1-a104 for F1, b1-b104 for F2, ..., p1-p104 for F16
num_monomials = len(nonzero_monomials)
def_params = []
for gen_idx in range(16):
    param_letter = chr(ord('a') + gen_idx)  # a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p
    for mon_idx in range(num_monomials):
        def_params.append(f'{param_letter}{mon_idx + 1}')

var_names = ','.join(def_params + ['x1', 'x2', 'x3', 'x4', 'x5', 'x6', 'x7', 'x8'])

S = PolynomialRing(QQ, var_names, order='lex')
vars_list = S.gens()

# Extract deformation parameters for each generator
gen_params = {}
param_index = 0
for gen_idx in range(16):
    param_letter = chr(ord('a') + gen_idx)
    gen_params[param_letter] = []
    for mon_idx in range(num_monomials):
        gen_params[param_letter].append(vars_list[param_index])
        param_index += 1

x1, x2, x3, x4, x5, x6, x7, x8 = vars_list[-8:]

# Deformed generators using degree-3 nonzero monomials from R/I
F1 = f1
F2 = f2
F3 = f3
F4 = f4
F5 = f5
F6 = f6
F7 = f7
F8 = f8
F9 = f9
F10 = f10
F11 = f11
F12 = f12
F13 = f13
F14 = f14
F15 = f15
F16 = f16

# Add deformation terms to each generator
for i, mon in enumerate(nonzero_monomials):
    F1 += gen_params['a'][i] * mon
    F2 += gen_params['b'][i] * mon
    F3 += gen_params['c'][i] * mon
    F4 += gen_params['d'][i] * mon
    F5 += gen_params['e'][i] * mon
    F6 += gen_params['f'][i] * mon
    F7 += gen_params['g'][i] * mon
    F8 += gen_params['h'][i] * mon
    F9 += gen_params['i'][i] * mon
    F10 += gen_params['j'][i] * mon
    F11 += gen_params['k'][i] * mon
    F12 += gen_params['l'][i] * mon
    F13 += gen_params['m'][i] * mon
    F14 += gen_params['n'][i] * mon
    F15 += gen_params['o'][i] * mon
    F16 += gen_params['p'][i] * mon

print("Deformed generators (capital letters):")
print(f"  Each generator has {num_monomials} deformation variables")
print(f"  F1 uses a1-a{num_monomials}, F2 uses b1-b{num_monomials}, ..., F16 uses p1-p{num_monomials}")
print()

# 5. Apply syzygies for SR(M) with deformed generators
# Create list of deformed generators
deformed_generators = [F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12, F13, F14, F15, F16]

# Create syzygy matrix with same dimensions as original syz matrix
# Each entry is the corresponding syzygy coefficient applied to deformed generators
Syz = Matrix(S, syz.nrows(), syz.ncols())
for i in range(syz.nrows()):
    for j in range(syz.ncols()):
        Syz[i,j] = syz[i,j] * deformed_generators[j]

# Define all deformed syzygies before reduction
deformed_syzygies = []
for i in range(syz.nrows()):
    syzygy_i = sum(Syz[i,j] for j in range(Syz.ncols()))
    deformed_syzygies.append(syzygy_i)

# 6. Write syzygies in the quotient

# Define the ideal I_S in the deformation ring S using the original generators
I_S = ideal(S, f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12, f13, f14, f15, f16)

# Obtain reduced syzygies by reducing each deformed syzygy
reduced_syzygies = []
for syz_i in deformed_syzygies:
    syz_i_S = syz_i.reduce(I_S)
    reduced_syzygies.append(syz_i_S)


# 7. Extract relations by treating parameters as coefficients
print("Computing constraints from scratch...")
print("This may take a while...")

# Define the deformation parameter ring and the nested polynomial ring
# def_params was defined in step 4 as the list of string names
R_param = PolynomialRing(QQ, def_params)
S_nested = PolynomialRing(R_param, ['x1', 'x2', 'x3', 'x4', 'x5', 'x6', 'x7', 'x8'])

# Convert the reduced syzygies into the nested ring
nested_syzygies = []
for syz_i_S in reduced_syzygies:
    syz_i_nested = S_nested(syz_i_S)
    nested_syzygies.append(syz_i_nested)

# Collect all coefficients (the linear combinations of deformation parameters)
all_coeffs = []
for syz_nested in nested_syzygies:
    all_coeffs.extend(syz_nested.coefficients())

# Define an ideal of constraints (rel_ideal)
all_params = [R_param(p) for p in def_params]
rel_ideal = ideal(R_param, all_coeffs)
basis = rel_ideal.groebner_basis()

print(f"Computed {len(basis)} constraints")

# Save all data up to constraint computation
import pickle
from datetime import datetime

constraints_data = {
    # Constraints
    'basis': basis,
    'rel_ideal': rel_ideal,
    'all_coeffs': all_coeffs,
    'all_params': all_params,
    
    # Intermediate syzygy data
    'nested_syzygies': nested_syzygies,
    'reduced_syzygies': reduced_syzygies,
    'deformed_syzygies': deformed_syzygies,
    
    # Setup data
    'timestamp': datetime.now(),
    'def_params': def_params,
    'num_monomials': num_monomials,
    'nonzero_monomials': nonzero_monomials,
    'gen_params': gen_params,
    
    # Rings and generators
    'R': R,
    'S': S,
    'R_param': R_param,
    'S_nested': S_nested,
    'I': I,
    'I_S': I_S,
    'syz': syz,
    
    # Deformed generators
    'F1': F1, 'F2': F2, 'F3': F3, 'F4': F4, 'F5': F5, 'F6': F6, 'F7': F7, 'F8': F8,
    'F9': F9, 'F10': F10, 'F11': F11, 'F12': F12, 'F13': F13, 'F14': F14, 'F15': F15, 'F16': F16,
    
    # Variables
    'x1': x1, 'x2': x2, 'x3': x3, 'x4': x4, 'x5': x5, 'x6': x6, 'x7': x7, 'x8': x8,
    'vars_list': vars_list
}

# 8. Define the Deformed Quotient Ring considering the constraints

# Create the quotient of the deformation parameter ring by the constraints found
R_param_rel = R_param.quotient(rel_ideal, names=def_params)

# Create a new ring for the final polynomials
S_final = PolynomialRing(R_param_rel, ['x1', 'x2', 'x3', 'x4', 'x5', 'x6', 'x7', 'x8'])
x1_f, x2_f, x3_f, x4_f, x5_f, x6_f, x7_f, x8_f = S_final.gens()

# 9. Map the deformed generators to this new ring

F1_S = S_final(F1)
F2_S = S_final(F2)
F3_S = S_final(F3)
F4_S = S_final(F4)
F5_S = S_final(F5)
F6_S = S_final(F6)
F7_S = S_final(F7)
F8_S = S_final(F8)
F9_S = S_final(F9)
F10_S = S_final(F10)
F11_S = S_final(F11)
F12_S = S_final(F12)
F13_S = S_final(F13)
F14_S = S_final(F14)
F15_S = S_final(F15)
F16_S = S_final(F16)

print("\nFinal Reduced Deformed Generators:")
print(f"  All 16 generators mapped to the constrained quotient ring")

# Add final data to save
constraints_data.update({
    # Final rings and generators
    'R_param_rel': R_param_rel,
    'S_final': S_final,
    'x1_f': x1_f, 'x2_f': x2_f, 'x3_f': x3_f, 'x4_f': x4_f, 'x5_f': x5_f, 'x6_f': x6_f, 'x7_f': x7_f, 'x8_f': x8_f,
    
    # Final deformed generators
    'F1_S': F1_S, 'F2_S': F2_S, 'F3_S': F3_S, 'F4_S': F4_S, 'F5_S': F5_S, 'F6_S': F6_S, 'F7_S': F7_S, 'F8_S': F8_S,
    'F9_S': F9_S, 'F10_S': F10_S, 'F11_S': F11_S, 'F12_S': F12_S, 'F13_S': F13_S, 'F14_S': F14_S, 'F15_S': F15_S, 'F16_S': F16_S
})

with open('part-1.pkl', 'wb') as f:
    pickle.dump(constraints_data, f)

print(f"\nAll data saved to part-1.pkl on {constraints_data['timestamp']}")
print("You can now run syzygy.sage which will load this data")
print(f"Saved data includes {len(basis)} constraints and all results through step 9")
