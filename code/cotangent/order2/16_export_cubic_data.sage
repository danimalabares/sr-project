# 16_export_cubic_data.sage
#
# Export the finite cubic pattern found modulo 32003 as sparse
# integer coefficient data.
#
# Run from:
#   code/cotangent/order2
#
# Input:
#   cache/formal_lift_to_order30.sobj
#
# Output:
#   cache/cubic_family_data.json
#
# Coefficients are exported as balanced integer lifts of residues
# modulo the original prime. This is just one integer lift. The
# replay script tests whether this chosen integer lift works modulo
# a second prime.

import json

INPUT_FILE = "cache/formal_lift_to_order30.sobj"
OUTPUT_FILE = "cache/cubic_family_data.json"

print("Loading", INPUT_FILE)
lift = load(INPUT_FILE)

PRIME = int(lift["prime"])
BASE_FIELD = GF(PRIME)


def residue_int(c):
    return int(BASE_FIELD(c).lift())


def balanced_int(c):
    a = residue_int(c)
    if a > PRIME // 2:
        a -= PRIME
    return int(a)


def sparse_vector_data(v):
    out = []
    for i, c in enumerate(v):
        c = BASE_FIELD(c)
        if c != 0:
            out.append([int(i), balanced_int(c)])
    return out


def nnz(v):
    return sum(1 for c in v if BASE_FIELD(c) != 0)

for k in [1, 2, 3]:
    if k not in lift["gen_vectors"]:
        raise RuntimeError("missing G_%d" % k)
if 1 not in lift["syz_vectors"]:
    raise RuntimeError("missing A_1")

export = {
    "source": INPUT_FILE,
    "source_prime": PRIME,
    "coefficient_lift": "balanced residues in [-p/2,p/2]",
    "n_params": int(lift["n_params"]),
    "n_corr": int(lift["n_corr"]),
    "G": {
        str(k): sparse_vector_data(lift["gen_vectors"][k])
        for k in [1, 2, 3]
    },
    "A": {
        "1": sparse_vector_data(lift["syz_vectors"][1])
    },
}

with open(OUTPUT_FILE, "w") as f:
    json.dump(export, f, indent=2, sort_keys=True)

print("Exported", OUTPUT_FILE)
print("source prime =", PRIME)
for k in [1, 2, 3]:
    print("G_%d nnz = %d" % (k, nnz(lift["gen_vectors"][k])))
print("A_1 nnz = %d" % nnz(lift["syz_vectors"][1]))
