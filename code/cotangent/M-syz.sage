# Sage script for SR(M) deformation - Analysis mode
# This script loads pre-computed data and continues analysis

# Load all pre-computed data from file
import pickle
import os
from datetime import datetime

constraints_file = "part-1.pkl"
if os.path.exists(constraints_file):
    # Load all pre-computed data
    with open(constraints_file, 'rb') as f:
        data = pickle.load(f)
    timestamp = data['timestamp']
    print(f"Loading data last computed on {timestamp}")
else:
    print("ERROR: part-1.pkl not found!")
    print("Please run 'sage part-1.sage' first to compute the constraints and final generators")
    exit(1)

# Extract final data (steps 8-9 already computed)
R_param_rel = data['R_param_rel']
S_final = data['S_final']
x1_f = data['x1_f']
x2_f = data['x2_f']
x3_f = data['x3_f']
x4_f = data['x4_f']
x5_f = data['x5_f']
x6_f = data['x6_f']
x7_f = data['x7_f']
x8_f = data['x8_f']

# Extract final deformed generators
F1_S = data['F1_S']
F2_S = data['F2_S']
F3_S = data['F3_S']
F4_S = data['F4_S']
F5_S = data['F5_S']
F6_S = data['F6_S']
F7_S = data['F7_S']
F8_S = data['F8_S']
F9_S = data['F9_S']
F10_S = data['F10_S']
F11_S = data['F11_S']
F12_S = data['F12_S']
F13_S = data['F13_S']
F14_S = data['F14_S']
F15_S = data['F15_S']
F16_S = data['F16_S']

# Also extract useful intermediate data if needed
basis = data['basis']
def_params = data['def_params']
num_monomials = data['num_monomials']

print(f"Loaded {len(basis)} constraints")
print(f"Loaded {num_monomials} monomials for deformation")
print(f"Final reduced deformed generators ready for analysis")
print()

print("\nFinal Reduced Deformed Generators:")
print(f"  All 16 generators mapped to the constrained quotient ring")
print()

# Display the deformed generators
print("F1_S:", F1_S)
print("F2_S:", F2_S)
print("F3_S:", F3_S)
print("F4_S:", F4_S)
print("F5_S:", F5_S)
print("F6_S:", F6_S)
print("F7_S:", F7_S)
print("F8_S:", F8_S)
print("F9_S:", F9_S)
print("F10_S:", F10_S)
print("F11_S:", F11_S)
print("F12_S:", F12_S)
print("F13_S:", F13_S)
print("F14_S:", F14_S)
print("F15_S:", F15_S)
print("F16_S:", F16_S)

# You can now continue with additional analysis steps below...
# All data through step 9 is loaded and ready for further computation